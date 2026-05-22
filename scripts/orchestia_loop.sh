#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
usage:
  scripts/orchestia_loop.sh status <loop-state>
  scripts/orchestia_loop.sh next <loop-state>
  scripts/orchestia_loop.sh run <loop-state> --workspace <path> [--execute]
  scripts/orchestia_loop.sh collect <loop-state> --workspace <path> [--test "<command>"]
  scripts/orchestia_loop.sh review-draft <loop-state> --workspace <path>
  scripts/orchestia_loop.sh git-flow <loop-state> --workspace <path> --remote <name> --source-branch <branch> --target-branch <branch> [--test "<command>"] [--allow-protected-branch] [--allow-protected-target]
EOF
}

fail() {
  echo "error: $*" >&2
  exit 1
}

warn_mnt_c() {
  case "$1" in
    /mnt/c|/mnt/c/*) return 0 ;;
    *) return 1 ;;
  esac
}

verify_orchestia_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "not inside a Git repository"
  [ -f "AGENTS.md" ] || fail "AGENTS.md not found; run from the Orchestia repository"
  if warn_mnt_c "$PWD"; then
    fail "refusing to run from /mnt/c; use a WSL Linux filesystem clone"
  fi
}

require_loop_state() {
  [ -n "${1:-}" ] || fail "missing Loop state file"
  [ -f "$1" ] || fail "Loop state file not found: $1"
}

field_value() {
  label="$1"
  file="$2"
  awk -v label="$label" '
    BEGIN { wanted = "- " tolower(label) ":" }
    tolower($0) ~ "^" wanted {
      sub(/^- [^:]+:[[:space:]]*/, "", $0)
      print
      exit
    }
  ' "$file"
}

link_text_or_value() {
  value="$1"
  if [ -z "$value" ]; then
    echo "None"
    return
  fi
  case "$value" in
    *"]("*")"*)
      printf '%s\n' "$value" | sed -n 's/.*\[\([^]]*\)\](.*/\1/p'
      ;;
    *)
      printf '%s\n' "$value"
      ;;
  esac
}

link_target_or_value() {
  value="$1"
  if [ -z "$value" ]; then
    echo ""
    return
  fi
  case "$value" in
    *"]("*")"*)
      printf '%s\n' "$value" | sed -n 's/.*](\([^)]*\)).*/\1/p'
      ;;
    "None"|"None yet")
      echo ""
      ;;
    *)
      printf '%s\n' "$value"
      ;;
  esac
}

resolve_from_loop_dir() {
  loop_file="$1"
  maybe_path="$2"
  [ -n "$maybe_path" ] || return 0

  case "$maybe_path" in
    /*)
      printf '%s\n' "$maybe_path"
      ;;
    *)
      loop_dir="$(cd "$(dirname "$loop_file")" && pwd -P)"
      target_dir="$(dirname "$loop_dir/$maybe_path")"
      target_base="$(basename "$maybe_path")"
      if [ -d "$target_dir" ]; then
        printf '%s/%s\n' "$(cd "$target_dir" && pwd -P)" "$target_base"
      else
        printf '%s/%s\n' "$loop_dir" "$maybe_path"
      fi
      ;;
  esac
}

current_primary_need() { field_value "Current primary need" "$1"; }
current_request() { field_value "Current request" "$1"; }
current_backlog_item() { field_value "Current backlog item" "$1"; }
current_task() { field_value "Current task" "$1"; }
prepared_prompt() { field_value "Prepared Codex prompt" "$1"; }
decision() { field_value "Decision" "$1"; }
next_action() { field_value "Next action" "$1"; }
stop_condition() { field_value "Stop condition" "$1"; }

loop_is_complete() {
  loop_file="$1"
  task="$(current_task "$loop_file")"
  stop="$(stop_condition "$loop_file")"
  [ "$task" = "None" ] || [ "$stop" = "all primary needs complete" ]
}

verify_workspace() {
  workspace="$1"
  [ -n "$workspace" ] || fail "missing --workspace path"
  [ -d "$workspace" ] || fail "workspace not found: $workspace"
  if warn_mnt_c "$workspace"; then
    fail "refusing workspace under /mnt/c"
  fi
  git -C "$workspace" rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "workspace is not a Git repository: $workspace"
}

workspace_must_be_clean() {
  workspace="$1"
  status="$(git -C "$workspace" status --short)"
  [ -z "$status" ] || {
    echo "$status" >&2
    fail "workspace Git status is not clean"
  }
}

parse_workspace_args() {
  workspace=""
  execute=false
  test_command=""

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --workspace)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --workspace"
        workspace="$1"
        ;;
      --execute)
        execute=true
        ;;
      --test)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --test"
        test_command="$1"
        ;;
      *)
        fail "unknown argument: $1"
        ;;
    esac
    shift
  done
}

parse_git_flow_args() {
  workspace=""
  remote=""
  source_branch=""
  target_branch=""
  test_command=""
  allow_protected_branch=false
  allow_protected_target=false

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --workspace)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --workspace"
        workspace="$1"
        ;;
      --remote)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --remote"
        remote="$1"
        ;;
      --source-branch)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --source-branch"
        source_branch="$1"
        ;;
      --target-branch)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --target-branch"
        target_branch="$1"
        ;;
      --test)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --test"
        test_command="$1"
        ;;
      --allow-protected-branch)
        allow_protected_branch=true
        ;;
      --allow-protected-target)
        allow_protected_target=true
        ;;
      *)
        fail "unknown argument: $1"
        ;;
    esac
    shift
  done

  [ -n "$remote" ] || fail "missing --remote"
  [ -n "$source_branch" ] || fail "missing --source-branch"
  [ -n "$target_branch" ] || fail "missing --target-branch"
}

is_protected_branch() {
  [ "$1" = "main" ] || [ "$1" = "master" ]
}

append_test_args() {
  [ -n "$test_command" ] || return 0
  printf ' --test %q' "$test_command"
  return 0
}

controlled_status_command() {
  printf 'bash scripts/controlled_git_flow.sh status --workspace %q' "$workspace"
  return 0
}

controlled_auto_push_command() {
  printf 'bash scripts/controlled_git_flow.sh auto-push --workspace %q --remote %q --branch %q' "$workspace" "$remote" "$source_branch"
  append_test_args
  [ "$allow_protected_branch" = "true" ] && printf ' --allow-protected-branch'
  return 0
}

controlled_auto_merge_command() {
  printf 'bash scripts/controlled_git_flow.sh auto-merge --workspace %q --remote %q --source-branch %q --target-branch %q' "$workspace" "$remote" "$source_branch" "$target_branch"
  append_test_args
  [ "$allow_protected_target" = "true" ] && printf ' --allow-protected-target'
  return 0
}

print_status() {
  loop_file="$1"
  echo "Loop state: $loop_file"
  echo "Current primary need: $(current_primary_need "$loop_file")"
  echo "Current request: $(current_request "$loop_file")"
  echo "Current backlog item: $(current_backlog_item "$loop_file")"
  echo "Current task: $(current_task "$loop_file")"
  echo "Prepared Codex prompt: $(prepared_prompt "$loop_file")"
  echo "Decision: $(decision "$loop_file")"
  echo "Next action: $(next_action "$loop_file")"
  echo "Stop condition: $(stop_condition "$loop_file")"
}

print_next() {
  loop_file="$1"
  if loop_is_complete "$loop_file"; then
    echo "No executable task is pending. Stop condition: $(stop_condition "$loop_file")"
    return 0
  fi

  prompt_value="$(prepared_prompt "$loop_file")"
  prompt_target="$(link_target_or_value "$prompt_value")"
  if [ -n "$prompt_target" ]; then
    echo "Next actionable step: run the prepared Codex prompt."
    echo "Current task: $(current_task "$loop_file")"
    echo "Prepared Codex prompt: $prompt_target"
  else
    echo "Next actionable step: prepare a Codex prompt for the current task."
    echo "Current task: $(current_task "$loop_file")"
  fi
}

command_run() {
  loop_file="$1"
  shift
  parse_workspace_args "$@"
  verify_workspace "$workspace"
  workspace_must_be_clean "$workspace"

  if loop_is_complete "$loop_file"; then
    echo "No executable task is pending. Stop condition: $(stop_condition "$loop_file")"
    return 0
  fi

  prompt_value="$(prepared_prompt "$loop_file")"
  prompt_target="$(link_target_or_value "$prompt_value")"
  [ -n "$prompt_target" ] || fail "no prepared Codex prompt found; prepare a prompt first"
  prompt_path="$(resolve_from_loop_dir "$loop_file" "$prompt_target")"
  [ -f "$prompt_path" ] || fail "prepared Codex prompt not found: $prompt_path"

  echo "Workspace: $workspace"
  echo "Prepared Codex prompt: $prompt_path"
  echo "Copyable command:"
  printf 'cd %q && codex < %q\n' "$workspace" "$prompt_path"

  if [ "$execute" != "true" ]; then
    echo "No command was executed. Pass --execute to run Codex."
    return 0
  fi

  command -v codex >/dev/null 2>&1 || fail "codex command not found"
  (cd "$workspace" && codex < "$prompt_path")
}

new_run_dir() {
  suffix="$1"
  mkdir -p task-runs
  timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
  run_dir="task-runs/${timestamp}-${suffix}-$$"
  mkdir -p "$run_dir"
  printf '%s\n' "$run_dir"
}

command_collect() {
  loop_file="$1"
  shift
  parse_workspace_args "$@"
  verify_workspace "$workspace"

  run_dir="$(new_run_dir "loop-collect")"
  prompt_value="$(prepared_prompt "$loop_file")"
  prompt_target="$(link_target_or_value "$prompt_value")"

  printf '%s\n' "$loop_file" > "$run_dir/loop-state.txt"
  printf '%s\n' "$workspace" > "$run_dir/workspace.txt"
  printf '%s\n' "$(current_task "$loop_file")" > "$run_dir/current-task.txt"
  printf '%s\n' "$prompt_target" > "$run_dir/prepared-prompt.txt"
  git -C "$workspace" status --short > "$run_dir/workspace-git-status.txt"
  git -C "$workspace" diff --stat > "$run_dir/workspace-git-diff-stat.txt"
  git -C "$workspace" log --oneline --max-count=5 > "$run_dir/workspace-git-log.txt"

  if [ -n "$test_command" ]; then
    printf '%s\n' "$test_command" > "$run_dir/test-command.txt"
    set +e
    (cd "$workspace" && sh -c "$test_command") > "$run_dir/test-output.txt" 2>&1
    exit_code=$?
    set -e
    printf '%s\n' "$exit_code" > "$run_dir/test-exit-code.txt"
  fi

  echo "Run directory: $run_dir"
}

command_review_draft() {
  loop_file="$1"
  shift
  parse_workspace_args "$@"
  verify_workspace "$workspace"

  run_dir="$(new_run_dir "loop-review")"
  draft="$run_dir/review-draft.md"
  latest_commit="$(git -C "$workspace" log --oneline --max-count=1 || true)"
  workspace_status="$(git -C "$workspace" status --short)"

  {
    echo "# Loop Review Draft"
    echo
    echo "- Loop state: $loop_file"
    echo "- Current task: $(current_task "$loop_file")"
    echo "- Current primary need: $(current_primary_need "$loop_file")"
    echo "- Workspace: $workspace"
    echo "- Latest workspace commit: ${latest_commit:-None}"
    echo
    echo "## Workspace Git Status"
    echo
    if [ -n "$workspace_status" ]; then
      echo '```text'
      printf '%s\n' "$workspace_status"
      echo '```'
    else
      echo "(clean)"
    fi
    echo
    echo "## Inputs Reviewed"
    echo
    echo "- Pending"
    echo
    echo "## Checks Performed"
    echo
    echo "- Pending"
    echo
    echo "## Findings"
    echo
    echo "- Pending"
    echo
    echo "## Risks"
    echo
    echo "- Pending"
    echo
    echo "## Decision, accept/revise/split/reject"
    echo
    echo "pending"
    echo
    echo "## Required Follow-Up"
    echo
    echo "- Pending"
    echo
    echo "## Next Recommended Task"
    echo
    echo "- Pending"
  } > "$draft"

  echo "Run directory: $run_dir"
  echo "Review draft: $draft"
}

command_git_flow() {
  loop_file="$1"
  shift
  parse_git_flow_args "$@"
  verify_workspace "$workspace"
  [ -x "scripts/controlled_git_flow.sh" ] || fail "scripts/controlled_git_flow.sh is missing or not executable"
  git -C "$workspace" remote get-url "$remote" >/dev/null 2>&1 || fail "remote not found in workspace: $remote"

  workspace_branch="$(git -C "$workspace" branch --show-current)"
  workspace_status="$(git -C "$workspace" status --short)"
  workspace_remotes="$(git -C "$workspace" remote -v)"
  status_cmd="$(controlled_status_command)"
  auto_push_cmd="$(controlled_auto_push_command)"
  auto_merge_cmd="$(controlled_auto_merge_command)"
  auto_push_execute_cmd="$auto_push_cmd --execute"
  auto_merge_execute_cmd="$auto_merge_cmd --execute"
  run_dir="$(new_run_dir "git-flow-handoff")"
  report="$run_dir/handoff.md"

  if is_protected_branch "$source_branch" && [ "$allow_protected_branch" != "true" ]; then
    echo "Warning: source branch is protected by default; controlled_git_flow.sh will refuse execute mode without --allow-protected-branch." >&2
  fi
  if is_protected_branch "$target_branch" && [ "$allow_protected_target" != "true" ]; then
    echo "Warning: target branch is protected by default; controlled_git_flow.sh will refuse execute mode without --allow-protected-target." >&2
  fi
  if [ "$workspace_branch" != "$source_branch" ]; then
    echo "Warning: workspace is currently on '$workspace_branch'; controlled auto-push execute requires switching to '$source_branch' first." >&2
  fi

  {
    echo "# Controlled Git Flow Handoff"
    echo
    echo "- Command: scripts/orchestia_loop.sh git-flow $loop_file --workspace $workspace --remote $remote --source-branch $source_branch --target-branch $target_branch"
    echo "- Loop state: $loop_file"
    echo "- Workspace: $workspace"
    echo "- Remote: $remote"
    echo "- Source branch: $source_branch"
    echo "- Target branch: $target_branch"
    echo "- Test command: ${test_command:-}"
    echo
    echo "## Current Loop Summary"
    echo
    echo "- Current primary need: $(current_primary_need "$loop_file")"
    echo "- Current request: $(current_request "$loop_file")"
    echo "- Current backlog item: $(current_backlog_item "$loop_file")"
    echo "- Current task: $(current_task "$loop_file")"
    echo "- Prepared Codex prompt: $(prepared_prompt "$loop_file")"
    echo "- Decision: $(decision "$loop_file")"
    echo "- Next action: $(next_action "$loop_file")"
    echo "- Stop condition: $(stop_condition "$loop_file")"
    echo
    echo "## Workspace Git Summary"
    echo
    echo "- Workspace branch: ${workspace_branch:-unknown}"
    if [ "$workspace_branch" != "$source_branch" ]; then
      echo "- Warning: controlled auto-push execute requires the workspace to be on '$source_branch'."
    fi
    echo
    echo "### Workspace Remotes"
    echo
    echo '```text'
    printf '%s\n' "$workspace_remotes"
    echo '```'
    echo
    echo "### Workspace Git Status"
    echo
    if [ -n "$workspace_status" ]; then
      echo '```text'
      printf '%s\n' "$workspace_status"
      echo '```'
    else
      echo "(clean)"
    fi
    echo
    echo "## Generated controlled_git_flow.sh Commands"
    echo
    echo "Status:"
    echo
    echo '```bash'
    printf '%s\n' "$status_cmd"
    echo '```'
    echo
    echo "Auto-push dry-run:"
    echo
    echo '```bash'
    printf '%s\n' "$auto_push_cmd"
    echo '```'
    echo
    echo "Auto-push execute, human-approved only:"
    echo
    echo '```bash'
    printf '%s\n' "$auto_push_execute_cmd"
    echo '```'
    echo
    echo "Auto-merge dry-run:"
    echo
    echo '```bash'
    printf '%s\n' "$auto_merge_cmd"
    echo '```'
    echo
    echo "Auto-merge execute, human-approved only:"
    echo
    echo '```bash'
    printf '%s\n' "$auto_merge_execute_cmd"
    echo '```'
    echo
    echo "Execute commands require human approval and must be run through controlled_git_flow.sh."
  } > "$report"

  print_status "$loop_file"
  echo
  echo "Workspace: $workspace"
  echo "Workspace branch: ${workspace_branch:-unknown}"
  echo "Workspace remotes:"
  printf '%s\n' "$workspace_remotes"
  echo "Workspace Git status:"
  if [ -n "$workspace_status" ]; then
    printf '%s\n' "$workspace_status"
  else
    echo "(clean)"
  fi
  echo
  echo "Copyable controlled_git_flow.sh commands:"
  echo "Status:"
  printf '%s\n' "$status_cmd"
  echo
  echo "Auto-push dry-run:"
  printf '%s\n' "$auto_push_cmd"
  echo
  echo "Auto-push execute, human-approved only:"
  printf '%s\n' "$auto_push_execute_cmd"
  echo
  echo "Auto-merge dry-run:"
  printf '%s\n' "$auto_merge_cmd"
  echo
  echo "Auto-merge execute, human-approved only:"
  printf '%s\n' "$auto_merge_execute_cmd"
  echo
  echo "No push or merge was executed. Handoff report: $report"
}

main() {
  verify_orchestia_repo

  [ "$#" -ge 1 ] || {
    usage
    exit 0
  }

  [ "$#" -ge 2 ] || {
    usage
    exit 2
  }

  command_name="$1"
  loop_file="$2"
  shift 2
  require_loop_state "$loop_file"

  case "$command_name" in
    status)
      [ "$#" -eq 0 ] || fail "status does not accept extra arguments"
      print_status "$loop_file"
      ;;
    next)
      [ "$#" -eq 0 ] || fail "next does not accept extra arguments"
      print_next "$loop_file"
      ;;
    run)
      command_run "$loop_file" "$@"
      ;;
    collect)
      command_collect "$loop_file" "$@"
      ;;
    review-draft)
      command_review_draft "$loop_file" "$@"
      ;;
    git-flow)
      command_git_flow "$loop_file" "$@"
      ;;
    *)
      usage
      exit 2
      ;;
  esac
}

main "$@"
