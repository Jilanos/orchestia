#!/usr/bin/env bash
set -euo pipefail

mode="dry-run"
workspace=""
remote=""
branch=""
source_branch=""
target_branch=""
test_command=""
execute=false
fetch=false
allow_protected_branch=false
allow_protected_target=false
run_dir=""
result="not completed"
action="none"
test_exit_code=""

usage() {
  cat >&2 <<'EOF'
usage:
  scripts/controlled_git_flow.sh status --workspace <path>
  scripts/controlled_git_flow.sh auto-push --workspace <path> --remote <name> --branch <branch> [--test "<command>"] [--execute] [--allow-protected-branch]
  scripts/controlled_git_flow.sh auto-merge --workspace <path> --remote <name> --source-branch <branch> --target-branch <branch> [--test "<command>"] [--fetch] [--execute] [--allow-protected-target]
EOF
}

# force push is intentionally unsupported by this script.

fail() {
  result="failed: $*"
  write_report
  echo "error: $*" >&2
  exit 1
}

is_protected_branch() {
  [ "$1" = "main" ] || [ "$1" = "master" ]
}

under_mnt_c() {
  case "$1" in
    /mnt/c|/mnt/c/*) return 0 ;;
    *) return 1 ;;
  esac
}

timestamp() {
  date -u +%Y%m%dT%H%M%SZ
}

ensure_run_dir() {
  if [ -z "$run_dir" ]; then
    mkdir -p task-runs
    run_dir="task-runs/$(timestamp)-controlled-git-flow-$$"
    mkdir -p "$run_dir"
  fi
}

write_report() {
  [ -n "${command_name:-}" ] || return 0
  ensure_run_dir
  report="$run_dir/evidence.md"
  current_branch_report=""
  git_status_report=""
  git_diff_stat_report=""
  recent_commits_report=""

  if [ -n "$workspace" ] && [ -d "$workspace" ] && git -C "$workspace" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    current_branch_report="$(git -C "$workspace" branch --show-current || true)"
    git_status_report="$(git -C "$workspace" status --short || true)"
    git_diff_stat_report="$(git -C "$workspace" diff --stat || true)"
    recent_commits_report="$(git -C "$workspace" log --oneline --max-count=5 || true)"
  fi

  {
    echo "# Controlled Git Flow Evidence"
    echo
    echo "- Command: ${invocation:-$command_name}"
    echo "- Mode: $mode"
    echo "- Workspace: ${workspace:-}"
    echo "- Current branch: ${current_branch_report:-}"
    echo "- Remote: ${remote:-}"
    echo "- Source branch: ${source_branch:-}"
    echo "- Target branch: ${target_branch:-}"
    echo "- Branch: ${branch:-}"
    echo "- Allow protected branch: $allow_protected_branch"
    echo "- Allow protected target: $allow_protected_target"
    echo "- Test command: ${test_command:-}"
    echo "- Test exit code: ${test_exit_code:-}"
    echo "- Action: $action"
    echo "- Final result: $result"
    echo
    echo "## Git Status"
    echo
    if [ -n "$git_status_report" ]; then
      echo '```text'
      printf '%s\n' "$git_status_report"
      echo '```'
    else
      echo "(clean or unavailable)"
    fi
    echo
    echo "## Git Diff Stat"
    echo
    if [ -n "$git_diff_stat_report" ]; then
      echo '```text'
      printf '%s\n' "$git_diff_stat_report"
      echo '```'
    else
      echo "(no diff stat or unavailable)"
    fi
    echo
    echo "## Recent Commits"
    echo
    if [ -n "$recent_commits_report" ]; then
      echo '```text'
      printf '%s\n' "$recent_commits_report"
      echo '```'
    else
      echo "(unavailable)"
    fi
  } > "$report"
}

verify_orchestia_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "run from the Orchestia Git repository"
  [ -f "AGENTS.md" ] || fail "AGENTS.md not found; run from the Orchestia repository"
  if under_mnt_c "$PWD"; then
    fail "refusing to run from /mnt/c"
  fi
}

verify_workspace() {
  [ -n "$workspace" ] || fail "missing --workspace"
  [ -d "$workspace" ] || fail "workspace not found: $workspace"
  if under_mnt_c "$workspace"; then
    fail "refusing workspace under /mnt/c"
  fi
  git -C "$workspace" rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "workspace is not a Git repository: $workspace"
}

verify_remote() {
  [ -n "$remote" ] || fail "missing --remote"
  git -C "$workspace" remote get-url "$remote" >/dev/null 2>&1 || fail "remote not found in workspace: $remote"
}

workspace_status() {
  git -C "$workspace" status --short
}

require_clean_workspace() {
  status="$(workspace_status)"
  [ -z "$status" ] || {
    echo "$status" >&2
    fail "workspace has uncommitted changes"
  }
}

run_test_if_needed() {
  [ -n "$test_command" ] || return 0
  echo "Running test command: $test_command"
  set +e
  (cd "$workspace" && sh -c "$test_command")
  test_exit_code=$?
  set -e
  [ "$test_exit_code" -eq 0 ] || fail "test command failed with exit code $test_exit_code"
}

branch_exists() {
  name="$1"
  git -C "$workspace" show-ref --verify --quiet "refs/heads/$name" || git -C "$workspace" show-ref --verify --quiet "refs/remotes/$remote/$name"
}

parse_args() {
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
      --branch)
        shift
        [ "$#" -gt 0 ] || fail "missing value for --branch"
        branch="$1"
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
      --execute)
        execute=true
        mode="execute"
        ;;
      --fetch)
        fetch=true
        ;;
      --allow-protected-branch)
        allow_protected_branch=true
        ;;
      --allow-protected-target)
        allow_protected_target=true
        ;;
      *)
        fail "unsupported argument: $1"
        ;;
    esac
    shift
  done
}

command_status() {
  parse_args "$@"
  mode="dry-run"
  verify_workspace
  current_branch="$(git -C "$workspace" branch --show-current)"
  action="status inspection"
  result="status reported"

  echo "Mode: $mode"
  echo "Workspace: $workspace"
  echo "Current branch: $current_branch"
  echo "Remotes:"
  git -C "$workspace" remote -v || true
  echo "Git status:"
  status="$(workspace_status)"
  if [ -n "$status" ]; then
    printf '%s\n' "$status"
  else
    echo "(clean)"
  fi
  echo "Recent commits:"
  git -C "$workspace" log --oneline --max-count=5
  if is_protected_branch "$current_branch"; then
    echo "Protected by default: yes"
  else
    echo "Protected by default: no"
  fi

  write_report
  echo "Evidence report: $run_dir/evidence.md"
}

command_auto_push() {
  parse_args "$@"
  verify_workspace
  verify_remote
  current_branch="$(git -C "$workspace" branch --show-current)"
  [ -n "$branch" ] || fail "missing --branch"
  [ "$current_branch" = "$branch" ] || fail "current branch '$current_branch' does not match --branch '$branch'"
  if is_protected_branch "$current_branch" && [ "$allow_protected_branch" != "true" ]; then
    fail "refusing auto-push from protected branch $current_branch without --allow-protected-branch"
  fi

  run_test_if_needed
  action="git push $remote $branch"
  echo "Mode: $mode"
  echo "Workspace: $workspace"
  echo "Current branch: $current_branch"
  echo "Push command:"
  printf 'git -C %q push %q %q\n' "$workspace" "$remote" "$branch"

  if [ "$execute" != "true" ]; then
    result="dry-run complete; push not performed"
    write_report
    echo "Dry-run only. Pass --execute to push."
    echo "Evidence report: $run_dir/evidence.md"
    return 0
  fi

  require_clean_workspace
  git -C "$workspace" push "$remote" "$branch"
  result="pushed branch $branch to $remote"
  write_report
  echo "Evidence report: $run_dir/evidence.md"
}

checkout_branch() {
  name="$1"
  if git -C "$workspace" show-ref --verify --quiet "refs/heads/$name"; then
    git -C "$workspace" checkout "$name"
  else
    git -C "$workspace" checkout -b "$name" "$remote/$name"
  fi
}

merge_source_ref() {
  if git -C "$workspace" show-ref --verify --quiet "refs/heads/$source_branch"; then
    printf '%s\n' "$source_branch"
  else
    printf '%s/%s\n' "$remote" "$source_branch"
  fi
}

command_auto_merge() {
  parse_args "$@"
  verify_workspace
  verify_remote
  [ -n "$source_branch" ] || fail "missing --source-branch"
  [ -n "$target_branch" ] || fail "missing --target-branch"
  if is_protected_branch "$target_branch" && [ "$allow_protected_target" != "true" ]; then
    fail "refusing auto-merge into protected target $target_branch without --allow-protected-target"
  fi
  if [ "$fetch" = "true" ]; then
    git -C "$workspace" fetch "$remote"
  fi
  branch_exists "$source_branch" || fail "source branch not found locally or on $remote: $source_branch"
  branch_exists "$target_branch" || fail "target branch not found locally or on $remote: $target_branch"

  run_test_if_needed
  source_ref="$(merge_source_ref)"
  source_commit="$(git -C "$workspace" rev-parse --short "$source_ref" 2>/dev/null || true)"
  target_commit="$(git -C "$workspace" rev-parse --short "$target_branch" 2>/dev/null || git -C "$workspace" rev-parse --short "$remote/$target_branch" 2>/dev/null || true)"
  action="checkout $target_branch; merge --no-ff $source_ref; push $remote $target_branch"

  echo "Mode: $mode"
  echo "Workspace: $workspace"
  echo "Source branch: $source_branch (${source_commit:-unknown})"
  echo "Target branch: $target_branch (${target_commit:-unknown})"
  echo "Commands:"
  printf 'git -C %q checkout %q\n' "$workspace" "$target_branch"
  printf 'git -C %q merge --no-ff %q\n' "$workspace" "$source_ref"
  printf 'git -C %q push %q %q\n' "$workspace" "$remote" "$target_branch"

  if [ "$execute" != "true" ]; then
    result="dry-run complete; merge and push not performed"
    write_report
    echo "Dry-run only. Pass --execute to merge and push."
    echo "Evidence report: $run_dir/evidence.md"
    return 0
  fi

  require_clean_workspace
  checkout_branch "$target_branch"
  git -C "$workspace" merge --no-ff "$source_ref"
  run_test_if_needed
  git -C "$workspace" push "$remote" "$target_branch"
  result="merged $source_branch into $target_branch and pushed $target_branch to $remote"
  write_report
  echo "Evidence report: $run_dir/evidence.md"
}

main() {
  invocation="scripts/controlled_git_flow.sh $*"

  [ "$#" -ge 1 ] || {
    usage
    exit 0
  }

  command_name="$1"
  shift
  verify_orchestia_repo
  ensure_run_dir

  case "$command_name" in
    status)
      command_status "$@"
      ;;
    auto-push)
      command_auto_push "$@"
      ;;
    auto-merge)
      command_auto_merge "$@"
      ;;
    *)
      usage
      exit 2
      ;;
  esac
}

main "$@"
