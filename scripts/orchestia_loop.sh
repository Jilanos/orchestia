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
  scripts/orchestia_loop.sh git-flow-review-draft <loop-state> --workspace <path> [--evidence-dir task-runs/<dir>] [--decision accept|revise|split|reject]
  scripts/orchestia_loop.sh finalize-review --draft task-runs/<dir>/<draft.md> --review-id REVIEW-XXXX --review-title "<title>" --reviewed-task TASK-XXXX --decision accept|revise|split|reject
  scripts/orchestia_loop.sh auto-loop <loop-state> --workspace <path> --max-steps <n> [--decision accept|revise|split|reject] [--advance --last-review <path> --next-action "<text>" --stop-condition "<text>"]
  scripts/orchestia_loop.sh autonomous-loop <loop-state> --workspace <path> --max-cycles <n> [--execute-codex|--execute-all] [--auto-accept-if-checks-pass] [--advance-if-next-ready] [--test "<command>"] [--instruction "<text>"]
  scripts/orchestia_loop.sh orchestration-run <need-intake-or-loop-state> --workspace <path> --max-cycles <n> [--execute-codex|--execute-all] [--auto-promote-logics] [--auto-generate-task-prompts] [--auto-accept-if-checks-pass] [--advance-if-next-ready] [--auto-push --remote <name> --push-branch <branch>] [--test "<command>"] [--instruction "<text>"]
  scripts/orchestia_loop.sh auto-loop-status task-runs/<dir>-auto-loop
  scripts/orchestia_loop.sh auto-loop-instruct task-runs/<dir>-auto-loop "<instruction>"
  scripts/orchestia_loop.sh auto-loop-stop task-runs/<dir>-auto-loop "<reason>"
  scripts/orchestia_loop.sh autonomous-loop-status task-runs/<dir>-autonomous-loop
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

resolve_prompt_from_repo() {
  maybe_path="$1"
  [ -n "$maybe_path" ] || return 0

  case "$maybe_path" in
    /*)
      printf '%s\n' "$maybe_path"
      ;;
    *)
      printf '%s/%s\n' "$PWD" "$maybe_path"
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
next_primary_need() { field_value "Next primary need" "$1"; }
next_request() { field_value "Next request" "$1"; }
next_backlog_item() { field_value "Next backlog item" "$1"; }
next_task() { field_value "Next task" "$1"; }
next_prepared_prompt() { field_value "Next prepared Codex prompt" "$1"; }

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

parse_git_flow_review_args() {
  workspace=""
  evidence_dir=""
  review_decision="pending"

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --workspace)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --workspace"
        workspace="$1"
        ;;
      --evidence-dir)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --evidence-dir"
        evidence_dir="$1"
        ;;
      --decision)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --decision"
        review_decision="$1"
        case "$review_decision" in
          accept|revise|split|reject) ;;
          *) fail "--decision must be one of: accept, revise, split, reject" ;;
        esac
        ;;
      *)
        fail "unknown argument: $1"
        ;;
    esac
    shift
  done

  [ -n "$workspace" ] || fail "missing --workspace"
  if [ -n "$evidence_dir" ]; then
    case "$evidence_dir" in
      task-runs|task-runs/*) ;;
      *) fail "--evidence-dir must be under task-runs/" ;;
    esac
  fi
}

parse_finalize_review_args() {
  draft_path=""
  review_id=""
  review_title=""
  reviewed_task=""
  review_decision=""

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --draft)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --draft"
        draft_path="$1"
        ;;
      --review-id)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --review-id"
        review_id="$1"
        ;;
      --review-title)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --review-title"
        review_title="$1"
        ;;
      --reviewed-task)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --reviewed-task"
        reviewed_task="$1"
        ;;
      --decision)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --decision"
        review_decision="$1"
        case "$review_decision" in
          accept|revise|split|reject) ;;
          *) fail "--decision must be one of: accept, revise, split, reject" ;;
        esac
        ;;
      *)
        fail "unknown argument: $1"
        ;;
    esac
    shift
  done

  [ -n "$draft_path" ] || fail "missing --draft"
  [ -n "$review_id" ] || fail "missing --review-id"
  [ -n "$review_title" ] || fail "missing --review-title"
  [ -n "$reviewed_task" ] || fail "missing --reviewed-task"
  [ -n "$review_decision" ] || fail "missing --decision"

  case "$draft_path" in
    task-runs/*) ;;
    *) fail "--draft must be under task-runs/" ;;
  esac
  case "$draft_path" in
    *..*) fail "--draft must not contain '..'" ;;
  esac
  [ -f "$draft_path" ] || fail "draft not found: $draft_path"

  case "$review_id" in
    REVIEW-*) ;;
    *) fail "--review-id must start with REVIEW-" ;;
  esac
  case "$reviewed_task" in
    TASK-*) ;;
    *) fail "--reviewed-task must start with TASK-" ;;
  esac
}

validate_decision() {
  case "$1" in
    accept|revise|split|reject) ;;
    *) fail "--decision must be one of: accept, revise, split, reject" ;;
  esac
}

parse_auto_loop_args() {
  workspace=""
  max_steps=""
  execute_codex=false
  execute_git_flow=false
  execute_all=false
  auto_decision=""
  auto_advance=false
  auto_last_review=""
  auto_last_run=""
  auto_next_primary_need=""
  auto_next_request=""
  auto_next_backlog=""
  auto_next_task=""
  auto_next_action=""
  auto_stop_condition=""
  auto_blocker=""
  test_command=""
  remote=""
  source_branch=""
  target_branch=""

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --workspace)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --workspace"
        workspace="$1"
        ;;
      --max-steps)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --max-steps"
        max_steps="$1"
        ;;
      --execute-codex)
        execute_codex=true
        ;;
      --execute-git-flow)
        execute_git_flow=true
        ;;
      --execute-all)
        execute_all=true
        execute_codex=true
        execute_git_flow=true
        ;;
      --decision)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --decision"
        auto_decision="$1"
        validate_decision "$auto_decision"
        ;;
      --advance)
        auto_advance=true
        ;;
      --last-review)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --last-review"
        auto_last_review="$1"
        ;;
      --last-run)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --last-run"
        auto_last_run="$1"
        ;;
      --next-primary-need)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --next-primary-need"
        auto_next_primary_need="$1"
        ;;
      --next-request)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --next-request"
        auto_next_request="$1"
        ;;
      --next-backlog)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --next-backlog"
        auto_next_backlog="$1"
        ;;
      --next-task)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --next-task"
        auto_next_task="$1"
        ;;
      --next-action)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --next-action"
        auto_next_action="$1"
        ;;
      --stop-condition)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --stop-condition"
        auto_stop_condition="$1"
        ;;
      --blocker)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --blocker"
        auto_blocker="$1"
        ;;
      --test)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --test"
        test_command="$1"
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
      *)
        fail "unknown argument: $1"
        ;;
    esac
    shift
  done

  [ -n "$workspace" ] || fail "missing --workspace"
  [ -n "$max_steps" ] || fail "missing --max-steps"
  case "$max_steps" in
    ''|*[!0-9]*) fail "--max-steps must be a positive integer" ;;
  esac
  [ "$max_steps" -gt 0 ] || fail "--max-steps must be greater than zero"
}

parse_autonomous_loop_args() {
  workspace=""
  max_cycles=""
  execute_codex=false
  execute_all=false
  autonomous_auto_accept=false
  autonomous_advance=false
  autonomous_stop_on_dirty=false
  autonomous_blocker=""
  autonomous_instruction=""
  autonomous_review_id_prefix=""
  autonomous_task_id_prefix=""
  test_command=""

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --workspace)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --workspace"
        workspace="$1"
        ;;
      --max-cycles)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --max-cycles"
        max_cycles="$1"
        ;;
      --execute-codex)
        execute_codex=true
        ;;
      --execute-all)
        execute_all=true
        execute_codex=true
        ;;
      --auto-accept-if-checks-pass)
        autonomous_auto_accept=true
        ;;
      --advance-if-next-ready)
        autonomous_advance=true
        ;;
      --stop-on-dirty)
        autonomous_stop_on_dirty=true
        ;;
      --test)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --test"
        test_command="$1"
        ;;
      --blocker)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --blocker"
        autonomous_blocker="$1"
        ;;
      --instruction)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --instruction"
        autonomous_instruction="$1"
        ;;
      --review-id-prefix)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --review-id-prefix"
        autonomous_review_id_prefix="$1"
        ;;
      --task-id-prefix)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --task-id-prefix"
        autonomous_task_id_prefix="$1"
        ;;
      *)
        fail "unknown argument: $1"
        ;;
    esac
    shift
  done

  [ -n "$workspace" ] || fail "missing --workspace"
  [ -n "$max_cycles" ] || fail "missing --max-cycles"
  case "$max_cycles" in
    ''|*[!0-9]*) fail "--max-cycles must be a positive integer" ;;
  esac
  [ "$max_cycles" -gt 0 ] || fail "--max-cycles must be greater than zero"
}

parse_orchestration_run_args() {
  workspace=""
  max_cycles=""
  execute_codex=false
  execute_all=false
  orchestration_auto_promote=false
  orchestration_auto_generate_prompts=false
  orchestration_auto_accept=false
  orchestration_advance=false
  orchestration_auto_push=false
  remote=""
  push_branch=""
  orchestration_instruction=""
  test_command=""

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --workspace)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --workspace"
        workspace="$1"
        ;;
      --max-cycles)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --max-cycles"
        max_cycles="$1"
        ;;
      --execute-codex)
        execute_codex=true
        ;;
      --execute-all)
        execute_all=true
        execute_codex=true
        ;;
      --auto-promote-logics)
        orchestration_auto_promote=true
        ;;
      --auto-generate-task-prompts)
        orchestration_auto_generate_prompts=true
        ;;
      --auto-accept-if-checks-pass)
        orchestration_auto_accept=true
        ;;
      --advance-if-next-ready)
        orchestration_advance=true
        ;;
      --auto-push)
        orchestration_auto_push=true
        ;;
      --remote)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --remote"
        remote="$1"
        ;;
      --push-branch)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --push-branch"
        push_branch="$1"
        ;;
      --test)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --test"
        test_command="$1"
        ;;
      --instruction)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --instruction"
        orchestration_instruction="$1"
        ;;
      *)
        fail "unknown argument: $1"
        ;;
    esac
    shift
  done

  [ -n "$workspace" ] || fail "missing --workspace"
  [ -n "$max_cycles" ] || fail "missing --max-cycles"
  case "$max_cycles" in
    ''|*[!0-9]*) fail "--max-cycles must be a positive integer" ;;
  esac
  [ "$max_cycles" -gt 0 ] || fail "--max-cycles must be greater than zero"
  if [ "$orchestration_auto_push" = "true" ]; then
    [ -n "$remote" ] || fail "--auto-push requires --remote"
    [ -n "$push_branch" ] || fail "--auto-push requires --push-branch"
    if is_protected_branch "$push_branch"; then
      fail "refusing orchestration auto-push to protected branch $push_branch"
    fi
  fi
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

write_evidence_excerpt() {
  file="$1"
  name="$(basename "$file")"
  size="$(wc -c < "$file" | tr -d ' ')"

  case "$name" in
    *env*|*secret*|*credential*|*token*)
      echo "- ${name}: skipped because the filename may contain sensitive material."
      return 0
      ;;
  esac

  if [ "$size" -gt 4000 ]; then
    echo "- ${name}: skipped because it is larger than 4000 bytes."
    return 0
  fi

  case "$name" in
    *.md|*.txt|*.log|evidence)
      echo "### $name"
      echo
      sed -E 's/([Tt]oken|[Ss]ecret|[Pp]assword|[Cc]redential)[^[:space:]]*/[REDACTED]/g' "$file" | sed -n '1,80p' | sed 's/^/    /'
      ;;
    *)
      echo "- ${name}: listed but not excerpted."
      ;;
  esac
}

slugify() {
  printf '%s\n' "$1" |
    tr '[:upper:]' '[:lower:]' |
    sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

draft_section() {
  draft="$1"
  section="$2"
  awk -v wanted="$(printf '%s\n' "$section" | tr '[:upper:]' '[:lower:]')" '
    function lower(s) { return tolower(s) }
    /^##[[:space:]]+/ {
      heading = $0
      sub(/^##[[:space:]]+/, "", heading)
      in_section = (lower(heading) == wanted)
      next
    }
    /^#[[:space:]]+/ {
      if (in_section) {
        in_section = 0
      }
    }
    in_section {
      print
      found = 1
    }
    END {
      if (!found) {
        print "Not specified in source draft."
      }
    }
  ' "$draft"
}

command_finalize_review() {
  parse_finalize_review_args "$@"
  mkdir -p logics/reviews

  title_slug="$(slugify "$review_title")"
  if [ -n "$title_slug" ]; then
    review_file="logics/reviews/${review_id}-${title_slug}.md"
  else
    review_file="logics/reviews/${review_id}.md"
  fi
  [ ! -e "$review_file" ] || fail "review file already exists: $review_file"

  finalized_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  {
    echo "# ${review_id}: ${review_title}"
    echo
    echo "## Metadata"
    echo
    echo "- Review ID: $review_id"
    echo "- Title: $review_title"
    echo "- Reviewed task: $reviewed_task"
    echo "- Decision: $review_decision"
    echo "- Source draft: $draft_path"
    echo "- Finalized timestamp: $finalized_at"
    echo
    echo "## Inputs Reviewed"
    echo
    draft_section "$draft_path" "Inputs reviewed"
    echo
    echo "## Checks Performed"
    echo
    draft_section "$draft_path" "Checks performed"
    echo
    echo "## Findings"
    echo
    draft_section "$draft_path" "Findings"
    echo
    echo "## Risks"
    echo
    draft_section "$draft_path" "Risks"
    echo
    echo "## Decision"
    echo
    echo "$review_decision"
    echo
    echo "## Required Follow-Up"
    echo
    draft_section "$draft_path" "Required follow-up"
    echo
    echo "## Next Recommended Task"
    echo
    draft_section "$draft_path" "Next recommended task"
    echo
    echo "## Finalization Note"
    echo
    echo "This final review was created from a local draft. The decision was provided explicitly by the human or calling command. Loop state was not updated by this command."
  } > "$review_file"

  echo "Final review created: $review_file"
  echo "Loop state was not updated. No push or merge was performed."
}

command_git_flow_review_draft() {
  loop_file="$1"
  shift
  parse_git_flow_review_args "$@"
  verify_workspace "$workspace"

  run_dir="$(new_run_dir "git-flow-review")"
  draft="$run_dir/git-flow-review-draft.md"
  generated_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  workspace_branch="$(git -C "$workspace" branch --show-current)"
  latest_commit="$(git -C "$workspace" log --oneline --max-count=1 || true)"
  recent_commits="$(git -C "$workspace" log --oneline --max-count=5 || true)"
  workspace_status="$(git -C "$workspace" status --short)"
  prompt_value="$(prepared_prompt "$loop_file")"
  prompt_target="$(link_target_or_value "$prompt_value")"

  {
    echo "# Git Flow Evidence Review Draft"
    echo
    echo "- Generated timestamp: $generated_at"
    echo "- Loop state: $loop_file"
    echo "- Workspace: $workspace"
    echo "- Current primary need: $(current_primary_need "$loop_file")"
    echo "- Current task: $(current_task "$loop_file")"
    echo "- Prepared Codex prompt: ${prompt_target:-None}"
    echo "- Evidence directory: ${evidence_dir:-None provided}"
    echo
    echo "## Workspace Summary"
    echo
    echo "- Current branch: ${workspace_branch:-unknown}"
    echo "- Latest commit: ${latest_commit:-None}"
    echo
    echo "### Git Status"
    echo
    if [ -n "$workspace_status" ]; then
      echo '```text'
      printf '%s\n' "$workspace_status"
      echo '```'
    else
      echo "(clean)"
    fi
    echo
    echo "### Recent Commits"
    echo
    if [ -n "$recent_commits" ]; then
      echo '```text'
      printf '%s\n' "$recent_commits"
      echo '```'
    else
      echo "(none)"
    fi
    echo
    echo "## Evidence Files"
    echo
    if [ -n "$evidence_dir" ] && [ -d "$evidence_dir" ]; then
      find "$evidence_dir" -maxdepth 1 -type f | sort | sed 's/^/- /'
    elif [ -n "$evidence_dir" ]; then
      echo "- Evidence directory was provided but is missing or empty: $evidence_dir"
    else
      echo "- No evidence directory provided."
    fi
    echo
    echo "## Evidence Snippets"
    echo
    if [ -n "$evidence_dir" ] && [ -d "$evidence_dir" ]; then
      found=false
      for evidence_file in "$evidence_dir"/*; do
        [ -f "$evidence_file" ] || continue
        found=true
        write_evidence_excerpt "$evidence_file"
        echo
      done
      [ "$found" = "true" ] || echo "- Evidence directory contains no files."
    else
      echo "- No evidence snippets available."
    fi
    echo
    echo "## Checks Performed"
    echo
    echo "- Reviewed Loop state path."
    echo "- Inspected workspace branch, latest commit, Git status, and recent commits."
    if [ -n "$evidence_dir" ]; then
      echo "- Inspected provided evidence directory when available."
    fi
    echo
    echo "## Findings"
    echo
    echo "- Pending human review."
    echo
    echo "## Risks"
    echo
    echo "- Pending human review."
    echo
    echo "## Decision"
    echo
    echo "$review_decision"
    echo
    echo "## Required Follow-Up"
    echo
    echo "- Pending human review."
    echo
    echo "## Next Recommended Task"
    echo
    echo "- Pending human review."
    echo
    echo "This is a draft. Human review is required before creating a Logics review or advancing Loop state."
  } > "$draft"

  echo "Run directory: $run_dir"
  echo "Git flow review draft: $draft"
  echo "Decision: $review_decision"
  echo "No Logics review was created. Loop state was not updated."
}

require_auto_loop_dir() {
  run_dir="$1"
  [ -n "$run_dir" ] || fail "missing auto-loop run directory"
  case "$run_dir" in
    task-runs/*-auto-loop) ;;
    *) fail "auto-loop directory must be under task-runs/ and end with -auto-loop" ;;
  esac
  case "$run_dir" in
    *..*) fail "auto-loop directory must not contain '..'" ;;
  esac
  [ -d "$run_dir" ] || fail "auto-loop directory not found: $run_dir"
}

require_autonomous_loop_dir() {
  run_dir="$1"
  [ -n "$run_dir" ] || fail "missing autonomous-loop run directory"
  case "$run_dir" in
    task-runs/*-autonomous-loop) ;;
    *) fail "autonomous-loop directory must be under task-runs/ and end with -autonomous-loop" ;;
  esac
  case "$run_dir" in
    *..*) fail "autonomous-loop directory must not contain '..'" ;;
  esac
  [ -d "$run_dir" ] || fail "autonomous-loop directory not found: $run_dir"
}

append_auto_event() {
  run_dir="$1"
  message="$2"
  printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$message" >> "$run_dir/events.log"
}

read_auto_instructions() {
  run_dir="$1"
  if [ -f "$run_dir/instructions.md" ]; then
    sed -n '1,120p' "$run_dir/instructions.md"
  else
    echo "None"
  fi
}

write_auto_command_preview() {
  run_dir="$1"
  loop_file="$2"
  prompt_value="$(prepared_prompt "$loop_file")"
  prompt_target="$(link_target_or_value "$prompt_value")"

  {
    echo "# Auto Loop Command Preview"
    echo
    echo "Default mode is dry-run. Commands with execution flags require explicit human approval."
    echo "Executable Codex mode uses codex exec --sandbox workspace-write, limited to the verified target workspace."
    echo
    echo "## Loop Commands"
    echo
    echo '```bash'
    printf 'bash scripts/orchestia_loop.sh status %q\n' "$loop_file"
    printf 'bash scripts/orchestia_loop.sh next %q\n' "$loop_file"
    printf 'bash scripts/orchestia_loop.sh run %q --workspace %q\n' "$loop_file" "$workspace"
    if [ -n "$prompt_target" ]; then
      printf 'bash scripts/orchestia_loop.sh auto-loop %q --workspace %q --max-steps 1 --execute-codex\n' "$loop_file" "$workspace"
      printf 'cd %q && codex exec --sandbox workspace-write - < %q\n' "$workspace" "$prompt_target"
    fi
    echo '```'
    echo
    echo "## Controlled Git Flow Commands"
    if [ -n "$remote" ] && [ -n "$source_branch" ] && [ -n "$target_branch" ]; then
      echo
      echo "Dry-run and human-approved execute commands:"
      echo
      echo '```bash'
      printf 'bash scripts/controlled_git_flow.sh status --workspace %q\n' "$workspace"
      printf 'bash scripts/controlled_git_flow.sh auto-push --workspace %q --remote %q --branch %q' "$workspace" "$remote" "$source_branch"
      [ -n "$test_command" ] && printf ' --test %q' "$test_command"
      printf '\n'
      printf 'bash scripts/controlled_git_flow.sh auto-push --workspace %q --remote %q --branch %q' "$workspace" "$remote" "$source_branch"
      [ -n "$test_command" ] && printf ' --test %q' "$test_command"
      printf ' --execute # human-approved only\n'
      printf 'bash scripts/controlled_git_flow.sh auto-merge --workspace %q --remote %q --source-branch %q --target-branch %q' "$workspace" "$remote" "$source_branch" "$target_branch"
      [ -n "$test_command" ] && printf ' --test %q' "$test_command"
      printf '\n'
      printf 'bash scripts/controlled_git_flow.sh auto-merge --workspace %q --remote %q --source-branch %q --target-branch %q' "$workspace" "$remote" "$source_branch" "$target_branch"
      [ -n "$test_command" ] && printf ' --test %q' "$test_command"
      printf ' --execute # human-approved only\n'
      echo '```'
    else
      echo
      echo "Provide --remote, --source-branch, and --target-branch to generate controlled Git flow commands."
    fi
  } > "$run_dir/command-preview.md"
}

write_auto_error() {
  run_dir="$1"
  message="$2"
  if [ ! -f "$run_dir/errors.md" ]; then
    {
      echo "# Auto Loop Errors"
      echo
    } > "$run_dir/errors.md"
  fi
  {
    echo "## $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    printf '%s\n' "$message"
    echo
  } >> "$run_dir/errors.md"
  append_auto_event "$run_dir" "error: $message"
}

auto_status_from_files() {
  run_dir="$1"
  if [ -f "$run_dir/stop-request.md" ]; then
    echo "stopped"
  elif [ -n "$auto_blocker" ]; then
    echo "blocked"
  elif [ -f "$run_dir/codex-exit-code.txt" ] && [ "$(cat "$run_dir/codex-exit-code.txt")" != "0" ]; then
    echo "codex_failed"
  elif [ -f "$run_dir/test-exit-code.txt" ] && [ "$(cat "$run_dir/test-exit-code.txt")" != "0" ]; then
    echo "tests_failed"
  elif [ -f "$run_dir/errors.md" ]; then
    echo "error"
  elif [ "$auto_advance" = "true" ] && [ -n "$auto_decision" ]; then
    echo "advanced"
  elif [ -n "$auto_decision" ]; then
    echo "ready_for_advance"
  elif [ -f "$run_dir/codex-exit-code.txt" ]; then
    echo "waiting_for_decision"
  elif [ "$execute_codex" = "true" ]; then
    echo "codex_completed"
  else
    echo "dry_run_ready"
  fi
}

prepare_codex_prompt() {
  run_dir="$1"
  loop_file="$2"
  prompt_value="$(prepared_prompt "$loop_file")"
  prompt_target="$(link_target_or_value "$prompt_value")"
  if [ -z "$prompt_target" ]; then
    write_auto_error "$run_dir" "No prepared Codex prompt found in Loop state."
    return 1
  fi

  prompt_path="$(resolve_prompt_from_repo "$prompt_target")"
  if [ ! -f "$prompt_path" ]; then
    write_auto_error "$run_dir" "Prepared Codex prompt not found: $prompt_path"
    return 1
  fi

  printf '%s\n' "$prompt_path" > "$run_dir/prepared-prompt-path.txt"
  {
    cat "$prompt_path"
    if [ -f "$run_dir/instructions.md" ]; then
      echo
      echo "## Additional human instructions"
      echo
      cat "$run_dir/instructions.md"
    fi
  } > "$run_dir/codex-prompt.md"
  return 0
}

run_post_codex_test() {
  run_dir="$1"
  [ -n "$test_command" ] || return 0

  printf '%s\n' "$test_command" > "$run_dir/test-command.txt"
  append_auto_event "$run_dir" "running test command"
  set +e
  (cd "$workspace" && sh -c "$test_command") > "$run_dir/test-stdout.txt" 2> "$run_dir/test-stderr.txt"
  test_exit_code=$?
  set -e
  printf '%s\n' "$test_exit_code" > "$run_dir/test-exit-code.txt"
  if [ "$test_exit_code" -ne 0 ]; then
    write_auto_error "$run_dir" "Test command failed with exit code $test_exit_code."
    return 1
  fi
  append_auto_event "$run_dir" "test command completed successfully"
  return 0
}

execute_codex_prompt() {
  run_dir="$1"
  loop_file="$2"

  command -v codex >/dev/null 2>&1 || {
    write_auto_error "$run_dir" "codex command not found."
    return 1
  }
  codex exec --help >/dev/null 2>&1 || {
    write_auto_error "$run_dir" "codex exec is not available."
    return 1
  }
  git -C "$workspace" status --short > "$run_dir/workspace-status-before.txt"
  if [ -s "$run_dir/workspace-status-before.txt" ]; then
    write_auto_error "$run_dir" "Workspace Git status is not clean before Codex execution."
    return 1
  fi
  prepare_codex_prompt "$run_dir" "$loop_file" || return 1

  codex_prompt_abs="$PWD/$run_dir/codex-prompt.md"
  printf 'workspace-write\n' > "$run_dir/codex-sandbox-mode.txt"
  printf 'cd %q && codex exec --sandbox workspace-write - < %q\n' "$workspace" "$codex_prompt_abs" > "$run_dir/codex-command.txt"
  append_auto_event "$run_dir" "codex_running"
  set +e
  (cd "$workspace" && codex exec --sandbox workspace-write - < "$codex_prompt_abs") > "$run_dir/codex-stdout.txt" 2> "$run_dir/codex-stderr.txt"
  codex_exit_code=$?
  set -e
  printf '%s\n' "$codex_exit_code" > "$run_dir/codex-exit-code.txt"
  git -C "$workspace" status --short > "$run_dir/workspace-status-after.txt"
  git -C "$workspace" diff --stat > "$run_dir/workspace-diff-stat-after.txt"
  git -C "$workspace" log --oneline --max-count=5 > "$run_dir/workspace-log-after.txt"

  if [ "$codex_exit_code" -ne 0 ]; then
    write_auto_error "$run_dir" "Codex exited with code $codex_exit_code."
    append_auto_event "$run_dir" "codex_failed"
    return 1
  fi
  append_auto_event "$run_dir" "codex_completed"
  run_post_codex_test "$run_dir" || return 1
  return 0
}

write_auto_review_draft() {
  run_dir="$1"
  loop_file="$2"
  review_decision="${auto_decision:-pending}"
  workspace_branch="$(git -C "$workspace" branch --show-current || true)"
  latest_commit="$(git -C "$workspace" log --oneline --max-count=1 || true)"
  workspace_status="$(git -C "$workspace" status --short || true)"
  prompt_path="$(cat "$run_dir/prepared-prompt-path.txt" 2>/dev/null || true)"
  codex_command="$(cat "$run_dir/codex-command.txt" 2>/dev/null || true)"
  codex_sandbox_mode="$(cat "$run_dir/codex-sandbox-mode.txt" 2>/dev/null || echo "not run")"
  codex_exit_code="$(cat "$run_dir/codex-exit-code.txt" 2>/dev/null || echo "not run")"
  test_exit_code="$(cat "$run_dir/test-exit-code.txt" 2>/dev/null || echo "not run")"

  {
    echo "# Auto Loop Review Draft"
    echo
    echo "- Generated timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "- Loop state: $loop_file"
    echo "- Workspace: $workspace"
    echo "- Current primary need: $(current_primary_need "$loop_file")"
    echo "- Current task: $(current_task "$loop_file")"
    echo "- Prepared Codex prompt: ${prompt_path:-$(prepared_prompt "$loop_file")}"
    echo "- Codex command: ${codex_command:-not run}"
    echo "- Codex sandbox mode: $codex_sandbox_mode"
    echo "- Codex exit code: $codex_exit_code"
    echo "- Test command: ${test_command:-not provided}"
    echo "- Test exit code: $test_exit_code"
    echo "- Workspace branch: ${workspace_branch:-unknown}"
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
    echo "## Workspace Status Before"
    echo
    if [ -f "$run_dir/workspace-status-before.txt" ]; then
      echo '```text'
      sed -n '1,120p' "$run_dir/workspace-status-before.txt"
      echo '```'
    else
      echo "Not captured."
    fi
    echo
    echo "## Workspace Status After"
    echo
    if [ -f "$run_dir/workspace-status-after.txt" ]; then
      echo '```text'
      sed -n '1,120p' "$run_dir/workspace-status-after.txt"
      echo '```'
    else
      echo "Not captured."
    fi
    echo
    echo "## Diff Stat After"
    echo
    if [ -f "$run_dir/workspace-diff-stat-after.txt" ]; then
      echo '```text'
      sed -n '1,120p' "$run_dir/workspace-diff-stat-after.txt"
      echo '```'
    else
      echo "Not captured."
    fi
    echo
    echo "## Codex Output Summary"
    echo
    if [ -f "$run_dir/codex-stdout.txt" ]; then
      echo "- Stdout: $run_dir/codex-stdout.txt"
      echo "- Stderr: $run_dir/codex-stderr.txt"
      echo "- Exit code: $codex_exit_code"
    else
      echo "- Codex was not executed."
    fi
    echo
    echo "## Inputs Reviewed"
    echo
    echo "- Loop state file."
    echo "- Workspace Git summary."
    echo "- Auto-loop command preview."
    echo
    echo "## Checks Performed"
    echo
    echo "- Repository context verified."
    echo "- Workspace path and Git repository verified."
    if [ -f "$run_dir/codex-exit-code.txt" ]; then
      echo "- Codex execution through codex exec captured stdout, stderr, exit code, workspace status, diff stat, and recent log."
    else
      echo "- Dry-run command preview only; Codex was not executed."
    fi
    if [ -f "$run_dir/test-exit-code.txt" ]; then
      echo "- Test command captured with exit code $test_exit_code."
    fi
    echo
    echo "## Findings"
    echo
    if loop_is_complete "$loop_file"; then
      echo "- No executable task is pending for this Loop state."
    elif [ -f "$run_dir/codex-exit-code.txt" ] && [ "$codex_exit_code" = "0" ]; then
      echo "- Codex execution completed successfully and is pending human review."
    elif [ -f "$run_dir/codex-exit-code.txt" ]; then
      echo "- Codex execution failed and requires human review."
    else
      echo "- Current task remains pending human review or execution."
    fi
    echo
    echo "## Risks"
    echo
    echo "- Human review is required before creating a final Logics review or advancing Loop state."
    echo
    echo "## Decision"
    echo
    echo "$review_decision"
    echo
    echo "## Required Follow-Up"
    echo
    if [ -z "$auto_decision" ]; then
      echo "- Human action required: provide an explicit accept, revise, split, or reject decision before advancement."
    else
      echo "- Decision was provided explicitly; Loop state advancement still requires --advance and required fields."
    fi
    echo
    echo "## Next Recommended Task"
    echo
    echo "- $(next_action "$loop_file")"
    echo
    echo "This is a draft. Human review is required before creating a Logics review or advancing Loop state."
  } > "$run_dir/review-draft.md"
}

write_auto_loop_state() {
  run_dir="$1"
  loop_file="$2"
  status_text="$3"
  codex_executed="no"
  [ -f "$run_dir/codex-exit-code.txt" ] && codex_executed="yes"
  codex_sandbox_mode="$(cat "$run_dir/codex-sandbox-mode.txt" 2>/dev/null || echo "not run")"
  codex_exit_code="$(cat "$run_dir/codex-exit-code.txt" 2>/dev/null || echo "not run")"
  test_exit_code="$(cat "$run_dir/test-exit-code.txt" 2>/dev/null || echo "not run")"
  prompt_path="$(cat "$run_dir/prepared-prompt-path.txt" 2>/dev/null || true)"
  {
    echo "# Auto Loop State"
    echo
    echo "- Generated timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "- Status: $status_text"
    echo "- Mode: $([ "$execute_codex" = "true" ] && echo "execute-codex" || echo "dry-run")"
    echo "- Loop state: $loop_file"
    echo "- Workspace: $workspace"
    echo "- Max steps: $max_steps"
    echo "- Execute Codex authorized: $execute_codex"
    echo "- Execute Git flow authorized: $execute_git_flow"
    echo "- Execute all authorized: $execute_all"
    echo "- Decision: ${auto_decision:-pending}"
    echo "- Blocker: ${auto_blocker:-None}"
    echo "- Codex executed: $codex_executed"
    echo "- Codex sandbox mode: $codex_sandbox_mode"
    echo "- Codex exit code: $codex_exit_code"
    echo "- Test exit code: $test_exit_code"
    echo
    echo "## Current Loop Summary"
    echo
    echo "- Current primary need: $(current_primary_need "$loop_file")"
    echo "- Current request: $(current_request "$loop_file")"
    echo "- Current backlog item: $(current_backlog_item "$loop_file")"
    echo "- Current task: $(current_task "$loop_file")"
    echo "- Prepared Codex prompt: $(prepared_prompt "$loop_file")"
    echo "- Prepared prompt path: ${prompt_path:-None}"
    echo "- Last Codex run: $(field_value "Last Codex run" "$loop_file")"
    echo "- Last review: $(field_value "Last review" "$loop_file")"
    echo "- Next action: $(next_action "$loop_file")"
    echo "- Stop condition: $(stop_condition "$loop_file")"
    echo
    echo "## Human Instructions"
    echo
    read_auto_instructions "$run_dir"
    echo
    echo "## Human Action Required"
    if [ -n "$auto_blocker" ]; then
      echo "Firm blocker recorded. Human resolution is required."
    elif [ -f "$run_dir/stop-request.md" ]; then
      echo "Stop request exists. The loop must stop at this checkpoint."
    elif [ -f "$run_dir/errors.md" ]; then
      echo "Errors were recorded. Human review is required before continuing."
    elif [ -z "$auto_decision" ]; then
      echo "Decision is pending. Human action required before Loop state advancement."
    else
      echo "Decision provided explicitly. Advancement still requires --advance and all required fields."
    fi
  } > "$run_dir/auto-loop-state.md"
}

update_loop_state_field() {
  input_file="$1"
  output_file="$2"
  label="$3"
  value="$4"
  awk -v label="$label" -v value="$value" '
    BEGIN { found = 0; wanted = tolower(label) ":" }
    {
      line = $0
      normalized = tolower(line)
      sub(/^[[:space:]]*-[[:space:]]*/, "", normalized)
      if (normalized ~ "^" wanted) {
        print "- " label ": " value
        found = 1
      } else {
        print line
      }
    }
    END {
      if (!found) {
        print "- " label ": " value
      }
    }
  ' "$input_file" > "$output_file"
}

advance_loop_state() {
  run_dir="$1"
  loop_file="$2"

  case "$loop_file" in
    logics/loop-states/*.md) ;;
    *) fail "--advance requires a Loop state file under logics/loop-states/" ;;
  esac
  [ -n "$auto_decision" ] || fail "--advance requires --decision"
  [ -n "$auto_last_review" ] || fail "--advance requires --last-review"
  [ -n "$auto_next_action" ] || fail "--advance requires --next-action"
  [ -n "$auto_stop_condition" ] || fail "--advance requires --stop-condition"
  if [ -z "$auto_last_run" ]; then
    auto_last_run="$(git -C "$workspace" log --oneline --max-count=1 || true)"
    [ -n "$auto_last_run" ] || fail "--advance requires --last-run or a readable workspace latest commit"
  fi
  if ! loop_is_complete "$loop_file"; then
    if [ -z "$auto_next_primary_need" ] || [ -z "$auto_next_request" ] || [ -z "$auto_next_backlog" ] || [ -z "$auto_next_task" ]; then
      fail "--advance requires --next-primary-need, --next-request, --next-backlog, and --next-task unless the Loop state is terminal"
    fi
  fi

  backup="$run_dir/$(basename "$loop_file").backup"
  cp "$loop_file" "$backup"
  tmp_a="$run_dir/loop-state-update-a.md"
  tmp_b="$run_dir/loop-state-update-b.md"

  update_loop_state_field "$loop_file" "$tmp_a" "Last Codex run" "${auto_last_run:-None}"
  update_loop_state_field "$tmp_a" "$tmp_b" "Last review" "$auto_last_review"
  update_loop_state_field "$tmp_b" "$tmp_a" "Decision" "$auto_decision"
  update_loop_state_field "$tmp_a" "$tmp_b" "Current primary need" "${auto_next_primary_need:-None}"
  update_loop_state_field "$tmp_b" "$tmp_a" "Current request" "${auto_next_request:-None}"
  update_loop_state_field "$tmp_a" "$tmp_b" "Current backlog item" "${auto_next_backlog:-None}"
  update_loop_state_field "$tmp_b" "$tmp_a" "Current task" "${auto_next_task:-None}"
  update_loop_state_field "$tmp_a" "$tmp_b" "Next action" "$auto_next_action"
  update_loop_state_field "$tmp_b" "$tmp_a" "Stop condition" "$auto_stop_condition"
  cp "$tmp_a" "$loop_file"

  {
    echo "# Loop State Update"
    echo
    echo "- Updated: $loop_file"
    echo "- Backup: $backup"
    echo "- Last Codex run: $auto_last_run"
    echo "- Last review: $auto_last_review"
    echo "- Decision: $auto_decision"
    echo "- Current primary need: ${auto_next_primary_need:-None}"
    echo "- Current request: ${auto_next_request:-None}"
    echo "- Current backlog item: ${auto_next_backlog:-None}"
    echo "- Current task: ${auto_next_task:-None}"
    echo "- Next action: $auto_next_action"
    echo "- Stop condition: $auto_stop_condition"
  } > "$run_dir/loop-state-update.md"

  append_auto_event "$run_dir" "advanced Loop state after explicit decision: $auto_decision"
  echo "Loop state advanced: $loop_file"
  echo "Backup: $backup"
}

command_auto_loop() {
  loop_file="$1"
  shift
  parse_auto_loop_args "$@"
  verify_workspace "$workspace"

  mkdir -p task-runs
  run_dir="task-runs/$(date -u +%Y%m%dT%H%M%SZ)-auto-loop"
  [ ! -e "$run_dir" ] || fail "auto-loop run directory already exists: $run_dir"
  mkdir -p "$run_dir"
  append_auto_event "$run_dir" "created auto-loop run"

  if [ -n "$auto_blocker" ]; then
    {
      echo "# Auto Loop Blocker"
      echo
      echo "- Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      echo "- Blocker: $auto_blocker"
    } > "$run_dir/errors.md"
    append_auto_event "$run_dir" "firm blocker recorded"
  fi

  write_auto_command_preview "$run_dir" "$loop_file"
  git -C "$workspace" status --short > "$run_dir/latest-evidence.md"
  prepare_codex_prompt "$run_dir" "$loop_file" || true
  execution_failed=false

  step=1
  while [ "$step" -le "$max_steps" ]; do
    append_auto_event "$run_dir" "checkpoint step $step"
    if [ -f "$run_dir/stop-request.md" ]; then
      append_auto_event "$run_dir" "stop request found; stopping"
      break
    fi
    if [ -n "$auto_blocker" ]; then
      append_auto_event "$run_dir" "blocker present; stopping"
      break
    fi
    if [ "$execute_codex" = "true" ]; then
      if ! execute_codex_prompt "$run_dir" "$loop_file"; then
        execution_failed=true
        break
      fi
    fi
    if [ "$execute_git_flow" = "true" ]; then
      append_auto_event "$run_dir" "controlled Git flow execution was explicitly authorized but no command was run by auto-loop in this dry-run checkpoint"
      echo "Controlled Git flow execution authorization detected. Use command-preview.md and controlled_git_flow.sh for guarded execution."
    fi
    break
  done

  if [ -z "$auto_decision" ]; then
    append_auto_event "$run_dir" "no decision provided; creating pending review draft"
    write_auto_review_draft "$run_dir" "$loop_file"
    write_auto_loop_state "$run_dir" "$loop_file" "$(auto_status_from_files "$run_dir")"
  else
    append_auto_event "$run_dir" "explicit decision provided: $auto_decision"
    write_auto_review_draft "$run_dir" "$loop_file"
    if [ "$execution_failed" = "true" ]; then
      append_auto_event "$run_dir" "execution failed; Loop state advancement skipped"
      write_auto_loop_state "$run_dir" "$loop_file" "$(auto_status_from_files "$run_dir")"
    elif [ "$auto_advance" = "true" ]; then
      advance_loop_state "$run_dir" "$loop_file"
      write_auto_loop_state "$run_dir" "$loop_file" "$(auto_status_from_files "$run_dir")"
    else
      write_auto_loop_state "$run_dir" "$loop_file" "ready_for_advance"
    fi
  fi

  echo "Auto-loop run directory: $run_dir"
  echo "Command preview: $run_dir/command-preview.md"
  [ -f "$run_dir/review-draft.md" ] && echo "Review draft: $run_dir/review-draft.md"
  echo "No push or merge was performed by auto-loop."
}

command_auto_loop_status() {
  run_dir="$1"
  require_auto_loop_dir "$run_dir"
  echo "Auto-loop run: $run_dir"
  if [ -f "$run_dir/auto-loop-state.md" ]; then
    echo
    sed -n '1,80p' "$run_dir/auto-loop-state.md"
  fi
  echo
  echo "Latest events:"
  if [ -f "$run_dir/events.log" ]; then
    tail -20 "$run_dir/events.log"
  else
    echo "None"
  fi
  echo
  echo "Errors:"
  if [ -f "$run_dir/errors.md" ]; then
    sed -n '1,80p' "$run_dir/errors.md"
  else
    echo "None"
  fi
  echo
  echo "Command preview: $run_dir/command-preview.md"
  [ -f "$run_dir/review-draft.md" ] && echo "Review draft: $run_dir/review-draft.md"
  if [ -f "$run_dir/stop-request.md" ]; then
    echo
    echo "Stop request:"
    sed -n '1,40p' "$run_dir/stop-request.md"
  fi
  if [ -f "$run_dir/instructions.md" ]; then
    echo
    echo "Instructions:"
    sed -n '1,40p' "$run_dir/instructions.md"
  fi
}

command_auto_loop_instruct() {
  run_dir="$1"
  shift
  require_auto_loop_dir "$run_dir"
  [ "$#" -gt 0 ] || fail "missing instruction text"
  {
    echo
    echo "## $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf '%s\n' "$*"
  } >> "$run_dir/instructions.md"
  append_auto_event "$run_dir" "instruction appended"
  echo "Instruction appended: $run_dir/instructions.md"
}

command_auto_loop_stop() {
  run_dir="$1"
  shift
  require_auto_loop_dir "$run_dir"
  [ "$#" -gt 0 ] || fail "missing stop reason"
  {
    echo
    echo "## $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf '%s\n' "$*"
  } >> "$run_dir/stop-request.md"
  append_auto_event "$run_dir" "stop requested"
  echo "Stop request recorded: $run_dir/stop-request.md"
}

command_autonomous_loop_status() {
  run_dir="$1"
  require_autonomous_loop_dir "$run_dir"
  echo "Autonomous-loop run: $run_dir"
  if [ -f "$run_dir/autonomous-loop-state.md" ]; then
    echo
    sed -n '1,100p' "$run_dir/autonomous-loop-state.md"
  fi
  echo
  echo "Summary:"
  if [ -f "$run_dir/summary.md" ]; then
    sed -n '1,80p' "$run_dir/summary.md"
  else
    echo "None"
  fi
  echo
  echo "Latest events:"
  if [ -f "$run_dir/events.log" ]; then
    tail -20 "$run_dir/events.log"
  else
    echo "None"
  fi
  echo
  echo "Errors:"
  if [ -f "$run_dir/errors.md" ]; then
    sed -n '1,80p' "$run_dir/errors.md"
  else
    echo "None"
  fi
  echo
  echo "Cycles:"
  find "$run_dir" -maxdepth 1 -type d -name 'cycle-*' | sort | sed 's/^/- /' || true
  if [ -f "$run_dir/stop-request.md" ]; then
    echo
    echo "Stop request:"
    sed -n '1,40p' "$run_dir/stop-request.md"
  fi
  if [ -f "$run_dir/instructions.md" ]; then
    echo
    echo "Instructions:"
    sed -n '1,40p' "$run_dir/instructions.md"
  fi
}

append_autonomous_event() {
  run_dir="$1"
  message="$2"
  printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$message" >> "$run_dir/events.log"
}

write_autonomous_error() {
  run_dir="$1"
  message="$2"
  if [ ! -f "$run_dir/errors.md" ]; then
    {
      echo "# Autonomous Loop Errors"
      echo
    } > "$run_dir/errors.md"
  fi
  {
    echo "## $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    printf '%s\n' "$message"
    echo
  } >> "$run_dir/errors.md"
  append_autonomous_event "$run_dir" "error: $message"
}

autonomous_cycle_dir() {
  run_dir="$1"
  cycle="$2"
  printf '%s/cycle-%03d\n' "$run_dir" "$cycle"
}

autonomous_secret_like_path() {
  path="$1"
  name="$(basename "$path" | tr '[:upper:]' '[:lower:]')"
  case "$name" in
    .env|.env.*|hosts.yml|id_rsa|id_dsa|id_ecdsa|id_ed25519|known_hosts) return 0 ;;
  esac
  case "$name" in
    *token*|*secret*|*credential*|*credentials*|*password*|*passwd*|*private_key*) return 0 ;;
  esac
  return 1
}

autonomous_modified_files_ok() {
  cycle_dir="$1"
  status_file="$cycle_dir/workspace-status-after.txt"
  [ -f "$status_file" ] || return 0
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    file_path="$(printf '%s\n' "$line" | sed -E 's/^...//; s/ -> /\n/' | tail -1)"
    if autonomous_secret_like_path "$file_path"; then
      printf 'Secret-like file was touched: %s\n' "$file_path" > "$cycle_dir/errors.md"
      return 1
    fi
  done < "$status_file"
  return 0
}

resolve_autonomous_prompt() {
  prompt_value="$1"
  if [ -z "$prompt_value" ] || [ "$prompt_value" = "None" ]; then
    return 1
  fi
  prompt_target="$(link_target_or_value "$prompt_value")"
  [ -n "$prompt_target" ] || return 1
  resolve_prompt_from_repo "$prompt_target"
}

write_autonomous_prompt() {
  run_dir="$1"
  cycle_dir="$2"
  prompt_path="$3"
  {
    cat "$prompt_path"
    if [ -f "$run_dir/instructions.md" ]; then
      echo
      echo "## Additional human instructions"
      echo
      cat "$run_dir/instructions.md"
    fi
  } > "$cycle_dir/prompt-used.md"
}

autonomous_run_test() {
  cycle_dir="$1"
  [ -n "$test_command" ] || return 0
  printf '%s\n' "$test_command" > "$cycle_dir/test-command.txt"
  set +e
  (cd "$workspace" && sh -c "$test_command") > "$cycle_dir/test-stdout.txt" 2> "$cycle_dir/test-stderr.txt"
  test_exit_code=$?
  set -e
  printf '%s\n' "$test_exit_code" > "$cycle_dir/test-exit-code.txt"
  [ "$test_exit_code" -eq 0 ]
}

autonomous_write_review_draft() {
  run_dir="$1"
  cycle_dir="$2"
  loop_file="$3"
  cycle="$4"
  decision_value="$5"
  {
    echo "# Autonomous Loop Review Draft"
    echo
    echo "- Generated timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "- Autonomous run: $run_dir"
    echo "- Cycle: $cycle"
    echo "- Loop state: $loop_file"
    echo "- Workspace: $workspace"
    echo "- Current primary need: $(current_primary_need "$loop_file")"
    echo "- Current task: $(current_task "$loop_file")"
    echo "- Prepared Codex prompt: $(prepared_prompt "$loop_file")"
    echo "- Codex command: $(cat "$cycle_dir/codex-command.txt" 2>/dev/null || echo "not run")"
    echo "- Codex exit code: $(cat "$cycle_dir/codex-exit-code.txt" 2>/dev/null || echo "not run")"
    echo "- Test command: ${test_command:-not provided}"
    echo "- Test exit code: $(cat "$cycle_dir/test-exit-code.txt" 2>/dev/null || echo "not run")"
    echo
    echo "## Inputs Reviewed"
    echo
    echo "- Loop state before cycle."
    echo "- Prepared prompt."
    echo "- Workspace Git evidence."
    echo "- Codex and test evidence when executed."
    echo
    echo "## Checks Performed"
    echo
    if [ -f "$cycle_dir/codex-exit-code.txt" ]; then
      echo "- Codex execution captured through codex exec --sandbox workspace-write."
    else
      echo "- Dry-run command preview; Codex was not executed."
    fi
    if [ -f "$cycle_dir/test-exit-code.txt" ]; then
      echo "- Test command captured with exit code $(cat "$cycle_dir/test-exit-code.txt")."
    fi
    echo "- Workspace status and diff stat captured."
    echo
    echo "## Findings"
    echo
    if [ "$decision_value" = "accept" ]; then
      echo "- Cycle checks passed and auto-accept policy allowed acceptance."
    elif [ "$decision_value" = "pending" ]; then
      echo "- Cycle is pending because auto-accept was not enabled or execution was dry-run."
    else
      echo "- Cycle did not satisfy acceptance conditions."
    fi
    echo
    echo "## Risks"
    echo
    echo "- Autonomous acceptance is local-only and depends on declared checks."
    echo "- Human selection is still required when next state is missing or ambiguous."
    echo
    echo "## Decision"
    echo
    echo "$decision_value"
    echo
    echo "## Required Follow-Up"
    echo
    if [ "$decision_value" = "accept" ]; then
      echo "- Continue only if next state is explicit and safe."
    else
      echo "- Human review required before continuing."
    fi
    echo
    echo "## Next Recommended Task"
    echo
    echo "- $(next_action "$loop_file")"
  } > "$cycle_dir/review-draft.md"
}

autonomous_advance_loop_state() {
  run_dir="$1"
  cycle_dir="$2"
  loop_file="$3"

  next_primary="$(next_primary_need "$loop_file")"
  next_req="$(next_request "$loop_file")"
  next_backlog="$(next_backlog_item "$loop_file")"
  next_task_value="$(next_task "$loop_file")"
  next_prompt_value="$(next_prepared_prompt "$loop_file")"

  if [ -z "$next_primary" ] || [ -z "$next_req" ] || [ -z "$next_backlog" ] || [ -z "$next_task_value" ] || [ -z "$next_prompt_value" ]; then
    write_autonomous_error "$run_dir" "Next state is missing or ambiguous; human selection is required."
    return 1
  fi
  next_prompt_path="$(resolve_autonomous_prompt "$next_prompt_value" || true)"
  if [ -z "$next_prompt_path" ] || [ ! -f "$next_prompt_path" ]; then
    write_autonomous_error "$run_dir" "Next prepared prompt is missing: $next_prompt_value"
    return 1
  fi

  cp "$loop_file" "$cycle_dir/loop-state-before-advance.md"
  tmp_a="$cycle_dir/loop-state-update-a.md"
  tmp_b="$cycle_dir/loop-state-update-b.md"
  latest_run="$(git -C "$workspace" log --oneline --max-count=1 || true)"

  update_loop_state_field "$loop_file" "$tmp_a" "Last Codex run" "${latest_run:-workspace changes not committed}"
  update_loop_state_field "$tmp_a" "$tmp_b" "Decision" "accept"
  update_loop_state_field "$tmp_b" "$tmp_a" "Current primary need" "$next_primary"
  update_loop_state_field "$tmp_a" "$tmp_b" "Current request" "$next_req"
  update_loop_state_field "$tmp_b" "$tmp_a" "Current backlog item" "$next_backlog"
  update_loop_state_field "$tmp_a" "$tmp_b" "Current task" "$next_task_value"
  update_loop_state_field "$tmp_b" "$tmp_a" "Prepared Codex prompt" "$next_prompt_value"
  update_loop_state_field "$tmp_a" "$tmp_b" "Next primary need" ""
  update_loop_state_field "$tmp_b" "$tmp_a" "Next request" ""
  update_loop_state_field "$tmp_a" "$tmp_b" "Next backlog item" ""
  update_loop_state_field "$tmp_b" "$tmp_a" "Next task" ""
  update_loop_state_field "$tmp_a" "$tmp_b" "Next prepared Codex prompt" ""
  cp "$tmp_b" "$loop_file"
  cp "$loop_file" "$cycle_dir/loop-state-after.md"
  append_autonomous_event "$run_dir" "advanced Loop state for next explicit cycle"
  return 0
}

write_autonomous_state() {
  run_dir="$1"
  status_text="$2"
  cycles_completed="$3"
  latest_decision="$4"
  human_action="$5"
  {
    echo "# Autonomous Loop State"
    echo
    echo "- Generated timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "- Status: $status_text"
    echo "- Workspace: $workspace"
    echo "- Max cycles: $max_cycles"
    echo "- Cycles completed: $cycles_completed"
    echo "- Execute Codex authorized: $execute_codex"
    echo "- Execute all authorized: $execute_all"
    echo "- Auto-accept if checks pass: $autonomous_auto_accept"
    echo "- Advance if next ready: $autonomous_advance"
    echo "- Latest decision: $latest_decision"
    echo "- Human action required: $human_action"
    echo "- Test command: ${test_command:-not provided}"
    echo
    echo "## Human Instructions"
    echo
    if [ -f "$run_dir/instructions.md" ]; then
      sed -n '1,120p' "$run_dir/instructions.md"
    else
      echo "None"
    fi
  } > "$run_dir/autonomous-loop-state.md"
}

write_autonomous_summary() {
  run_dir="$1"
  status_text="$2"
  cycles_completed="$3"
  latest_decision="$4"
  {
    echo "# Autonomous Loop Summary"
    echo
    echo "- Status: $status_text"
    echo "- Cycles completed: $cycles_completed"
    echo "- Latest decision: $latest_decision"
    echo "- Workspace: $workspace"
    echo "- Push performed: no"
    echo "- Merge performed: no"
    echo
    echo "## Cycle Directories"
    echo
    find "$run_dir" -maxdepth 1 -type d -name 'cycle-*' | sort | sed 's/^/- /'
    echo
    echo "## Final Notes"
    echo
    if [ -f "$run_dir/errors.md" ]; then
      echo "- Errors or blockers were recorded. Human review is required."
    else
      echo "- No errors recorded."
    fi
  } > "$run_dir/summary.md"
}

command_autonomous_loop() {
  loop_file="$1"
  shift
  parse_autonomous_loop_args "$@"
  verify_workspace "$workspace"

  mkdir -p task-runs
  run_dir="task-runs/$(date -u +%Y%m%dT%H%M%SZ)-autonomous-loop"
  [ ! -e "$run_dir" ] || fail "autonomous-loop run directory already exists: $run_dir"
  mkdir -p "$run_dir"
  append_autonomous_event "$run_dir" "created autonomous-loop run"

  if [ -n "$autonomous_instruction" ]; then
    {
      echo "# Autonomous Loop Instructions"
      echo
      echo "## $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      printf '%s\n' "$autonomous_instruction"
    } > "$run_dir/instructions.md"
  fi
  if [ -n "$autonomous_blocker" ]; then
    write_autonomous_error "$run_dir" "Firm blocker provided: $autonomous_blocker"
    write_autonomous_state "$run_dir" "blocked" "0" "blocked" "yes"
    write_autonomous_summary "$run_dir" "blocked" "0" "blocked"
    echo "Autonomous-loop run directory: $run_dir"
    return 0
  fi

  cycles_completed=0
  latest_decision="pending"
  status_text="dry_run_ready"
  human_action="no"

  cycle=1
  while [ "$cycle" -le "$max_cycles" ]; do
    cycle_dir="$(autonomous_cycle_dir "$run_dir" "$cycle")"
    mkdir -p "$cycle_dir"
    append_autonomous_event "$run_dir" "starting cycle $cycle"
    cp "$loop_file" "$cycle_dir/loop-state-before.md"

    if [ -f "$run_dir/stop-request.md" ]; then
      write_autonomous_error "$run_dir" "Stop request exists before cycle $cycle."
      status_text="stopped"
      human_action="yes"
      break
    fi

    prompt_path="$(resolve_autonomous_prompt "$(prepared_prompt "$loop_file")" || true)"
    if [ -z "$prompt_path" ] || [ ! -f "$prompt_path" ]; then
      write_autonomous_error "$run_dir" "Missing prepared Codex prompt for cycle $cycle."
      status_text="blocked"
      human_action="yes"
      break
    fi
    write_autonomous_prompt "$run_dir" "$cycle_dir" "$prompt_path"

    git -C "$workspace" status --short > "$cycle_dir/workspace-status-before.txt"
    if [ -s "$cycle_dir/workspace-status-before.txt" ] && { [ "$cycle" -eq 1 ] || [ "$autonomous_stop_on_dirty" = "true" ]; }; then
      write_autonomous_error "$run_dir" "Workspace is dirty before cycle $cycle."
      status_text="blocked"
      human_action="yes"
      break
    fi

    prompt_used_abs="$(cd "$(dirname "$cycle_dir/prompt-used.md")" && pwd -P)/prompt-used.md"
    printf 'cd %q && codex exec --sandbox workspace-write - < %q\n' "$workspace" "$prompt_used_abs" > "$cycle_dir/codex-command.txt"
    if [ "$execute_codex" = "true" ]; then
      command -v codex >/dev/null 2>&1 || fail "codex command not found"
      codex exec --help >/dev/null 2>&1 || fail "codex exec is not available"
      append_autonomous_event "$run_dir" "cycle $cycle codex_running"
      set +e
      (cd "$workspace" && codex exec --sandbox workspace-write - < "$prompt_used_abs") > "$cycle_dir/codex-stdout.txt" 2> "$cycle_dir/codex-stderr.txt"
      codex_exit_code=$?
      set -e
      printf '%s\n' "$codex_exit_code" > "$cycle_dir/codex-exit-code.txt"
    else
      codex_exit_code=0
    fi

    git -C "$workspace" status --short > "$cycle_dir/workspace-status-after.txt"
    git -C "$workspace" diff --stat > "$cycle_dir/workspace-diff-stat-after.txt"
    git -C "$workspace" log --oneline --max-count=5 > "$cycle_dir/workspace-log-after.txt"

    if [ "$execute_codex" = "true" ] && [ "$codex_exit_code" -ne 0 ]; then
      printf 'revise\n' > "$cycle_dir/decision.md"
      autonomous_write_review_draft "$run_dir" "$cycle_dir" "$loop_file" "$cycle" "revise"
      write_autonomous_error "$run_dir" "Codex exited non-zero in cycle $cycle."
      latest_decision="revise"
      status_text="codex_failed"
      human_action="yes"
      break
    fi

    if ! autonomous_run_test "$cycle_dir"; then
      printf 'revise\n' > "$cycle_dir/decision.md"
      autonomous_write_review_draft "$run_dir" "$cycle_dir" "$loop_file" "$cycle" "revise"
      write_autonomous_error "$run_dir" "Test command failed in cycle $cycle."
      latest_decision="revise"
      status_text="tests_failed"
      human_action="yes"
      break
    fi

    if ! autonomous_modified_files_ok "$cycle_dir"; then
      printf 'blocked\n' > "$cycle_dir/decision.md"
      autonomous_write_review_draft "$run_dir" "$cycle_dir" "$loop_file" "$cycle" "revise"
      write_autonomous_error "$run_dir" "Forbidden or secret-like file modification detected in cycle $cycle."
      latest_decision="blocked"
      status_text="blocked"
      human_action="yes"
      break
    fi

    if [ "$autonomous_auto_accept" = "true" ] && { [ -s "$cycle_dir/workspace-diff-stat-after.txt" ] || [ "$execute_codex" != "true" ]; }; then
      latest_decision="accept"
    elif [ "$autonomous_auto_accept" = "true" ]; then
      latest_decision="accept"
      append_autonomous_event "$run_dir" "cycle $cycle accepted with no diff; no-change accepted"
    else
      latest_decision="pending"
      status_text="waiting_for_decision"
      human_action="yes"
      printf 'pending\n' > "$cycle_dir/decision.md"
      autonomous_write_review_draft "$run_dir" "$cycle_dir" "$loop_file" "$cycle" "pending"
      break
    fi

    printf '%s\n' "$latest_decision" > "$cycle_dir/decision.md"
    autonomous_write_review_draft "$run_dir" "$cycle_dir" "$loop_file" "$cycle" "$latest_decision"
    cycles_completed=$cycle
    append_autonomous_event "$run_dir" "cycle $cycle decision: $latest_decision"

    if [ "$autonomous_advance" = "true" ]; then
      if ! autonomous_advance_loop_state "$run_dir" "$cycle_dir" "$loop_file"; then
        status_text="blocked"
        human_action="yes"
        break
      fi
    else
      status_text="ready_for_advance"
      human_action="yes"
      break
    fi

    cycle=$((cycle + 1))
  done

  if [ "$cycle" -gt "$max_cycles" ]; then
    status_text="max_cycles_reached"
  fi
  if [ "$status_text" = "dry_run_ready" ] && [ "$execute_codex" = "true" ]; then
    status_text="completed"
  fi
  write_autonomous_state "$run_dir" "$status_text" "$cycles_completed" "$latest_decision" "$human_action"
  write_autonomous_summary "$run_dir" "$status_text" "$cycles_completed" "$latest_decision"
  echo "Autonomous-loop run directory: $run_dir"
  echo "Summary: $run_dir/summary.md"
  echo "No push or merge was performed by autonomous-loop."
}

append_orchestration_event() {
  run_dir="$1"
  message="$2"
  printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$message" >> "$run_dir/events.log"
}

write_orchestration_error() {
  run_dir="$1"
  message="$2"
  if [ ! -f "$run_dir/errors.md" ]; then
    {
      echo "# Orchestration Run Errors"
      echo
    } > "$run_dir/errors.md"
  fi
  {
    echo "## $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    printf '%s\n' "$message"
    echo
  } >> "$run_dir/errors.md"
  append_orchestration_event "$run_dir" "error: $message"
}

write_orchestration_policy() {
  run_dir="$1"
  source_path="$2"
  {
    echo "# Orchestration Run Policy"
    echo
    echo "- Created at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "- Source: $source_path"
    echo "- Workspace: $workspace"
    echo "- Execute Codex allowed: $execute_codex"
    echo "- Execute all allowed: $execute_all"
    echo "- Auto-promote Logics allowed: $orchestration_auto_promote"
    echo "- Auto-generate prompts allowed: $orchestration_auto_generate_prompts"
    echo "- Auto-accept allowed: $orchestration_auto_accept"
    echo "- Advance Loop state allowed: $orchestration_advance"
    echo "- Auto-push allowed: $orchestration_auto_push"
    echo "- Remote: ${remote:-none}"
    echo "- Push branch: ${push_branch:-none}"
    echo "- Protected branches: main/master"
    echo "- Max cycles: $max_cycles"
    echo "- Test command: ${test_command:-none}"
    echo "- Stop conditions: missing intake, invalid intake, ID collision, draft generation failure, promotion failure, missing workspace, /mnt/c workspace, non-Git workspace, dirty workspace before execution, missing prompt, Codex failure, test failure, forbidden file change, ambiguous next primary need, missing next prompt, stop-request.md, protected push branch, controlled auto-push failure, max cycles reached, initial need complete"
  } > "$run_dir/policy.md"
}

write_orchestration_state() {
  run_dir="$1"
  status_text="$2"
  cycles_completed="$3"
  latest_decision="$4"
  push_status="$5"
  human_action="$6"
  {
    echo "# Orchestration Run State"
    echo
    echo "- Generated timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "- Status: $status_text"
    echo "- Workspace: $workspace"
    echo "- Max cycles: $max_cycles"
    echo "- Cycles completed: $cycles_completed"
    echo "- Latest decision: $latest_decision"
    echo "- Push status: $push_status"
    echo "- Human action required: $human_action"
  } > "$run_dir/orchestration-state.md"
}

write_orchestration_summary() {
  run_dir="$1"
  status_text="$2"
  cycles_completed="$3"
  latest_decision="$4"
  push_status="$5"
  {
    echo "# Orchestration Run Summary"
    echo
    echo "- Status: $status_text"
    echo "- Cycles completed: $cycles_completed"
    echo "- Latest decision: $latest_decision"
    echo "- Auto-push status: $push_status"
    echo "- Workspace: $workspace"
    echo "- Merge performed: no"
    echo
    echo "## Evidence"
    echo
    echo "- Policy: policy.md"
    echo "- Events: events.log"
    echo "- Cycles: cycles/"
    echo "- Git flow: git-flow/"
    echo
    if [ -f "$run_dir/errors.md" ]; then
      echo "## Errors"
      echo
      sed -n '1,120p' "$run_dir/errors.md"
    else
      echo "## Errors"
      echo
      echo "None recorded."
    fi
  } > "$run_dir/summary.md"
}

orchestration_copy_source() {
  source_path="$1"
  run_dir="$2"
  [ -n "$source_path" ] || fail "missing source path"
  [ -f "$source_path" ] || fail "source file not found: $source_path"
  case "$source_path" in
    *..*) fail "source path must not contain '..'" ;;
  esac
  mkdir -p "$run_dir/need-intake"
  cp "$source_path" "$run_dir/need-intake/$(basename "$source_path")"
}

orchestration_source_title() {
  source_path="$1"
  title="$(awk '
    /^# / { sub(/^# /, "", $0); print; exit }
    tolower($0) ~ /^- title:/ { sub(/^- [^:]+:[[:space:]]*/, "", $0); print; exit }
    tolower($0) ~ /^title:/ { sub(/^[^:]+:[[:space:]]*/, "", $0); print; exit }
  ' "$source_path")"
  [ -n "$title" ] || title="$(basename "$source_path")"
  printf '%s\n' "$title"
}

orchestration_source_description() {
  source_path="$1"
  awk '
    BEGIN { capture = 0 }
    /^## Description/ { capture = 1; next }
    /^## / && capture == 1 { exit }
    capture == 1 { print }
  ' "$source_path"
}

orchestration_generate_logics_drafts() {
  run_dir="$1"
  source_path="$2"
  title="$(orchestration_source_title "$source_path")"
  mkdir -p "$run_dir/logics-drafts"
  {
    echo "# Logics Draft Summary"
    echo
    echo "- Status: draft"
    echo "- Source: $source_path"
    echo "- Title: $title"
    echo "- Promotion: ${orchestration_auto_promote}"
  } > "$run_dir/logics-drafts/summary.md"
  {
    echo "# Initial Need Draft"
    echo
    echo "- Proposed ID: IN-TODO"
    echo "- Title: $title"
    echo "- Status: draft"
    echo
    echo "## Problem Statement"
    echo
    orchestration_source_description "$source_path" || true
  } > "$run_dir/logics-drafts/initial_need_draft.md"
  {
    echo "# Primary Needs Draft"
    echo
    echo "- Draft primary need 1: foundation"
    echo "- Draft primary need 2: implementation"
    echo "- Draft primary need 3: validation and documentation"
  } > "$run_dir/logics-drafts/primary_needs_draft.md"
  {
    echo "# Request Draft"
    echo
    echo "- Status: draft"
    echo "- First request: implement the first bounded slice for $title"
  } > "$run_dir/logics-drafts/request_draft.md"
  {
    echo "# Backlog Draft"
    echo
    echo "- Status: draft"
    echo "- Acceptance criteria: tests pass; evidence captured; human review remains possible"
  } > "$run_dir/logics-drafts/backlog_draft.md"
  append_orchestration_event "$run_dir" "generated Logics drafts"
}

orchestration_promote_logics_package() {
  run_dir="$1"
  mkdir -p "$run_dir/promoted-logics"
  {
    echo "# Promoted Logics Package"
    echo
    echo "This first orchestration-run implementation records a promotion package under task-runs only."
    echo "It does not write final tracked Logics records. Future promotion must perform ID collision checks."
    echo
    echo "- Source drafts: ../logics-drafts/"
    echo "- Promotion authorized: $orchestration_auto_promote"
  } > "$run_dir/promoted-logics/promotion-package.md"
  append_orchestration_event "$run_dir" "recorded Logics promotion package"
}

orchestration_generate_prompt() {
  run_dir="$1"
  source_path="$2"
  title="$(orchestration_source_title "$source_path")"
  description="$(orchestration_source_description "$source_path" || true)"
  mkdir -p "$run_dir/prompts"
  {
    echo "# Orchestration Task Prompt"
    echo
    echo "Work only in this workspace:"
    echo
    echo "$workspace"
    echo
    echo "## Objective"
    echo
    echo "$title"
    echo
    echo "## Context From Need Intake"
    echo
    printf '%s\n' "${description:-No description provided.}"
    echo
    echo "## Safety"
    echo
    echo "- Do not read secrets."
    echo "- Do not print environment variables."
    echo "- Do not push, merge, rebase, tag, or delete branches."
    echo "- Keep changes minimal."
    echo "- If the intake says no file changes are needed, inspect only and leave the workspace unchanged."
    if [ -n "$orchestration_instruction" ]; then
      echo
      echo "## Additional human instructions"
      echo
      printf '%s\n' "$orchestration_instruction"
    fi
  } > "$run_dir/prompts/task-prompt.md"
  append_orchestration_event "$run_dir" "generated task prompt"
}

orchestration_run_test() {
  cycle_dir="$1"
  [ -n "$test_command" ] || return 0
  printf '%s\n' "$test_command" > "$cycle_dir/test-command.txt"
  set +e
  (cd "$workspace" && sh -c "$test_command") > "$cycle_dir/test-stdout.txt" 2> "$cycle_dir/test-stderr.txt"
  test_exit_code=$?
  set -e
  printf '%s\n' "$test_exit_code" > "$cycle_dir/test-exit-code.txt"
  [ "$test_exit_code" -eq 0 ]
}

orchestration_cycle_review() {
  run_dir="$1"
  cycle_dir="$2"
  decision_value="$3"
  {
    echo "# Orchestration Cycle Review Draft"
    echo
    echo "- Run: $run_dir"
    echo "- Cycle: $(basename "$cycle_dir")"
    echo "- Workspace: $workspace"
    echo "- Codex exit code: $(cat "$cycle_dir/codex-exit-code.txt" 2>/dev/null || echo "not run")"
    echo "- Test exit code: $(cat "$cycle_dir/test-exit-code.txt" 2>/dev/null || echo "not run")"
    echo
    echo "## Findings"
    echo
    if [ "$decision_value" = "accept" ]; then
      echo "- Checks passed under the declared orchestration policy."
    else
      echo "- Human review is required before continuing."
    fi
    echo
    echo "## Decision"
    echo
    echo "$decision_value"
  } > "$cycle_dir/review-draft.md"
  mkdir -p "$run_dir/reviews"
  cp "$cycle_dir/review-draft.md" "$run_dir/reviews/$(basename "$cycle_dir")-review-draft.md"
}

orchestration_auto_push() {
  run_dir="$1"
  mkdir -p "$run_dir/git-flow"
  [ -n "$remote" ] || {
    write_orchestration_error "$run_dir" "auto-push requested without remote"
    return 1
  }
  [ -n "$push_branch" ] || {
    write_orchestration_error "$run_dir" "auto-push requested without push branch"
    return 1
  }
  if is_protected_branch "$push_branch"; then
    write_orchestration_error "$run_dir" "refusing auto-push to protected branch $push_branch"
    return 1
  fi

  append_orchestration_event "$run_dir" "starting controlled auto-push dry-run"
  push_args=(auto-push --workspace "$workspace" --remote "$remote" --branch "$push_branch")
  if [ -n "$test_command" ]; then
    push_args+=(--test "$test_command")
  fi
  set +e
  bash scripts/controlled_git_flow.sh "${push_args[@]}" > "$run_dir/git-flow/auto-push-dry-run-stdout.txt" 2> "$run_dir/git-flow/auto-push-dry-run-stderr.txt"
  dry_exit=$?
  set -e
  printf '%s\n' "$dry_exit" > "$run_dir/git-flow/auto-push-dry-run-exit-code.txt"
  [ "$dry_exit" -eq 0 ] || {
    write_orchestration_error "$run_dir" "controlled auto-push dry-run failed"
    return 1
  }

  append_orchestration_event "$run_dir" "starting controlled auto-push execute"
  push_args+=(--execute)
  set +e
  bash scripts/controlled_git_flow.sh "${push_args[@]}" > "$run_dir/git-flow/auto-push-execute-stdout.txt" 2> "$run_dir/git-flow/auto-push-execute-stderr.txt"
  exec_exit=$?
  set -e
  printf '%s\n' "$exec_exit" > "$run_dir/git-flow/auto-push-execute-exit-code.txt"
  [ "$exec_exit" -eq 0 ] || {
    write_orchestration_error "$run_dir" "controlled auto-push execute failed"
    return 1
  }
  echo "auto-push completed for $push_branch to $remote" > "$run_dir/git-flow/push-result.md"
  append_orchestration_event "$run_dir" "controlled auto-push completed"
  return 0
}

command_orchestration_run() {
  source_path="$1"
  shift
  parse_orchestration_run_args "$@"

  mkdir -p task-runs
  run_dir="task-runs/$(date -u +%Y%m%dT%H%M%SZ)-orchestration-run"
  [ ! -e "$run_dir" ] || fail "orchestration run directory already exists: $run_dir"
  mkdir -p "$run_dir"/{cycles,git-flow,loop-state-updates,need-intake,promoted-logics,prompts,reviews}
  append_orchestration_event "$run_dir" "created orchestration-run"
  write_orchestration_policy "$run_dir" "$source_path"

  status_text="dry_run_ready"
  cycles_completed=0
  latest_decision="pending"
  push_status="not requested"
  human_action="no"

  if [ -n "$orchestration_instruction" ]; then
    {
      echo "# Orchestration Instructions"
      echo
      printf '%s\n' "$orchestration_instruction"
    } > "$run_dir/instructions.md"
  fi

  if ! orchestration_copy_source "$source_path" "$run_dir"; then
    write_orchestration_error "$run_dir" "invalid source: $source_path"
    status_text="blocked"
    human_action="yes"
    write_orchestration_state "$run_dir" "$status_text" "$cycles_completed" "$latest_decision" "$push_status" "$human_action"
    write_orchestration_summary "$run_dir" "$status_text" "$cycles_completed" "$latest_decision" "$push_status"
    echo "Orchestration run directory: $run_dir"
    return 0
  fi

  orchestration_generate_logics_drafts "$run_dir" "$source_path"
  if [ "$orchestration_auto_promote" = "true" ]; then
    orchestration_promote_logics_package "$run_dir"
  fi
  if [ "$orchestration_auto_generate_prompts" = "true" ]; then
    orchestration_generate_prompt "$run_dir" "$source_path"
  fi

  {
    echo "# Command Preview"
    echo
    printf 'bash scripts/orchestia_loop.sh orchestration-run %q --workspace %q --max-cycles %q' "$source_path" "$workspace" "$max_cycles"
    [ "$execute_codex" = "true" ] && printf ' --execute-codex'
    [ "$orchestration_auto_promote" = "true" ] && printf ' --auto-promote-logics'
    [ "$orchestration_auto_generate_prompts" = "true" ] && printf ' --auto-generate-task-prompts'
    [ "$orchestration_auto_accept" = "true" ] && printf ' --auto-accept-if-checks-pass'
    [ "$orchestration_advance" = "true" ] && printf ' --advance-if-next-ready'
    if [ "$orchestration_auto_push" = "true" ]; then
      printf ' --auto-push --remote %q --push-branch %q' "$remote" "$push_branch"
    fi
    [ -n "$test_command" ] && printf ' --test %q' "$test_command"
    [ -n "$orchestration_instruction" ] && printf ' --instruction %q' "$orchestration_instruction"
    echo
  } > "$run_dir/command-preview.md"

  if [ "$execute_codex" = "true" ] || [ "$orchestration_auto_push" = "true" ]; then
    if ! verify_workspace "$workspace"; then
      write_orchestration_error "$run_dir" "workspace verification failed"
      status_text="blocked"
      human_action="yes"
      write_orchestration_state "$run_dir" "$status_text" "$cycles_completed" "$latest_decision" "$push_status" "$human_action"
      write_orchestration_summary "$run_dir" "$status_text" "$cycles_completed" "$latest_decision" "$push_status"
      echo "Orchestration run directory: $run_dir"
      return 0
    fi
  fi

  cycle_dir="$run_dir/cycles/cycle-001"
  mkdir -p "$cycle_dir"
  git -C "$workspace" status --short > "$cycle_dir/workspace-status-before.txt" 2>/dev/null || true
  if [ "$execute_codex" = "true" ] && [ -s "$cycle_dir/workspace-status-before.txt" ]; then
    write_orchestration_error "$run_dir" "workspace is dirty before execution"
    status_text="blocked"
    human_action="yes"
  elif [ "$execute_codex" = "true" ]; then
    prompt_file="$run_dir/prompts/task-prompt.md"
    [ -f "$prompt_file" ] || orchestration_generate_prompt "$run_dir" "$source_path"
    cp "$prompt_file" "$cycle_dir/prompt-used.md"
    prompt_abs="$(cd "$(dirname "$prompt_file")" && pwd -P)/$(basename "$prompt_file")"
    printf 'cd %q && codex exec --sandbox workspace-write - < %q\n' "$workspace" "$prompt_abs" > "$cycle_dir/codex-command.txt"
    command -v codex >/dev/null 2>&1 || fail "codex command not found"
    codex exec --help >/dev/null 2>&1 || fail "codex exec is not available"
    append_orchestration_event "$run_dir" "cycle-001 codex_running"
    set +e
    (cd "$workspace" && codex exec --sandbox workspace-write - < "$prompt_abs") > "$cycle_dir/codex-stdout.txt" 2> "$cycle_dir/codex-stderr.txt"
    codex_exit=$?
    set -e
    printf '%s\n' "$codex_exit" > "$cycle_dir/codex-exit-code.txt"
    [ "$codex_exit" -eq 0 ] || {
      write_orchestration_error "$run_dir" "Codex exited non-zero"
      status_text="codex_failed"
      human_action="yes"
    }
  fi

  git -C "$workspace" status --short > "$cycle_dir/workspace-status-after.txt" 2>/dev/null || true
  git -C "$workspace" diff --stat > "$cycle_dir/workspace-diff-stat-after.txt" 2>/dev/null || true
  git -C "$workspace" log --oneline --max-count=5 > "$cycle_dir/workspace-log-after.txt" 2>/dev/null || true

  if [ "$status_text" != "blocked" ] && [ "$status_text" != "codex_failed" ]; then
    if orchestration_run_test "$cycle_dir"; then
      if [ "$orchestration_auto_accept" = "true" ]; then
        latest_decision="accept"
        status_text="accepted"
      else
        latest_decision="pending"
        status_text="waiting_for_decision"
        human_action="yes"
      fi
    else
      latest_decision="revise"
      status_text="tests_failed"
      human_action="yes"
      write_orchestration_error "$run_dir" "test command failed"
    fi
  fi
  printf '%s\n' "$latest_decision" > "$cycle_dir/decision.md"
  orchestration_cycle_review "$run_dir" "$cycle_dir" "$latest_decision"
  cycles_completed=1

  if [ "$orchestration_advance" = "true" ] && [ "$latest_decision" = "accept" ]; then
    {
      echo "# Loop State Update"
      echo
      echo "Loop state advancement was authorized by policy."
      echo "This first orchestration-run implementation records advancement evidence under task-runs only unless a future promoted Loop state is supplied."
    } > "$run_dir/loop-state-updates/update.md"
    cp "$run_dir/loop-state-updates/update.md" "$cycle_dir/loop-state-after.md"
    append_orchestration_event "$run_dir" "recorded Loop state advancement evidence"
  fi

  if [ "$orchestration_auto_push" = "true" ] && [ "$latest_decision" = "accept" ]; then
    if [ -s "$cycle_dir/workspace-status-after.txt" ]; then
      push_status="blocked: workspace dirty"
      status_text="blocked"
      human_action="yes"
      write_orchestration_error "$run_dir" "workspace has uncommitted changes; controlled auto-push requires committed clean state"
    elif orchestration_auto_push "$run_dir"; then
      push_status="pushed"
      status_text="completed"
    else
      push_status="failed"
      status_text="blocked"
      human_action="yes"
    fi
  elif [ "$orchestration_auto_push" = "true" ]; then
    push_status="not run: decision not accepted"
  fi

  write_orchestration_state "$run_dir" "$status_text" "$cycles_completed" "$latest_decision" "$push_status" "$human_action"
  write_orchestration_summary "$run_dir" "$status_text" "$cycles_completed" "$latest_decision" "$push_status"
  echo "Orchestration run directory: $run_dir"
  echo "Summary: $run_dir/summary.md"
  echo "Merge performed: no"
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
  if [ "$command_name" = "finalize-review" ]; then
    shift
    command_finalize_review "$@"
    exit 0
  fi
  if [ "$command_name" = "auto-loop-status" ]; then
    [ "$#" -eq 2 ] || fail "auto-loop-status requires one auto-loop run directory"
    command_auto_loop_status "$2"
    exit 0
  fi
  if [ "$command_name" = "auto-loop-instruct" ]; then
    [ "$#" -ge 3 ] || fail "auto-loop-instruct requires an auto-loop run directory and instruction text"
    shift
    run_dir="$1"
    shift
    command_auto_loop_instruct "$run_dir" "$@"
    exit 0
  fi
  if [ "$command_name" = "auto-loop-stop" ]; then
    [ "$#" -ge 3 ] || fail "auto-loop-stop requires an auto-loop run directory and stop reason"
    shift
    run_dir="$1"
    shift
    command_auto_loop_stop "$run_dir" "$@"
    exit 0
  fi
  if [ "$command_name" = "autonomous-loop-status" ]; then
    [ "$#" -eq 2 ] || fail "autonomous-loop-status requires one autonomous-loop run directory"
    command_autonomous_loop_status "$2"
    exit 0
  fi

  loop_file="$2"
  shift 2
  if [ "$command_name" = "orchestration-run" ]; then
    [ -f "$loop_file" ] || fail "orchestration source file not found: $loop_file"
    command_orchestration_run "$loop_file" "$@"
    exit 0
  fi
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
    git-flow-review-draft)
      command_git_flow_review_draft "$loop_file" "$@"
      ;;
    auto-loop)
      command_auto_loop "$loop_file" "$@"
      ;;
    autonomous-loop)
      command_autonomous_loop "$loop_file" "$@"
      ;;
    *)
      usage
      exit 2
      ;;
  esac
}

main "$@"
