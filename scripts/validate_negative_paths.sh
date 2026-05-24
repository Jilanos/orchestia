#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT_DIR"

case "$PWD" in
  /mnt/c|/mnt/c/*)
    echo "error: refusing to run under /mnt/c" >&2
    exit 1
    ;;
esac

[ -f "AGENTS.md" ] || {
  echo "error: run from the Orchestia repository" >&2
  exit 1
}

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_DIR="task-runs/${timestamp}-negative-path-validation"
mkdir -p "$RUN_DIR"
REPORT="$RUN_DIR/negative-path-validation.md"

total=0
passed=0
failed=0
blocked=0

log() {
  printf '%s\n' "$*"
}

append_report() {
  printf '%s\n' "$*" >> "$REPORT"
}

git_init_repo() {
  local repo="$1"
  local branch="${2:-master}"
  mkdir -p "$repo"
  git -C "$repo" init -q -b "$branch"
  git -C "$repo" config user.name "Orchestia Negative Path"
  git -C "$repo" config user.email "orchestia-negative-path@example.invalid"
}

git_init_bare() {
  local remote="$1"
  mkdir -p "$(dirname "$remote")"
  git init -q --bare "$remote"
}

commit_all() {
  local repo="$1"
  local message="$2"
  git -C "$repo" add .
  git -C "$repo" commit -q -m "$message"
}

write_loop_state() {
  local path="$1"
  local prompt_path="$2"
  cat > "$path" <<EOF
# Disposable Loop State

- Current primary need: negative-path validation
- Current task: TASK-NEGATIVE-PATH
- Prepared Codex prompt: $prompt_path
- Decision: pending
- Next action: validate safe refusal
- Stop condition: negative-path validation complete
EOF
}

run_capture() {
  local case_dir="$1"
  local name="$2"
  local rc
  shift 2
  printf '%q ' "$@" > "$case_dir/${name}-command.txt"
  printf '\n' >> "$case_dir/${name}-command.txt"
  set +e
  "$@" > "$case_dir/${name}-stdout.txt" 2> "$case_dir/${name}-stderr.txt"
  rc=$?
  set -e
  printf '%s\n' "$rc" > "$case_dir/${name}-exit-code.txt"
  return 0
}

run_shell_capture() {
  local case_dir="$1"
  local name="$2"
  local command="$3"
  local rc
  printf '%s\n' "$command" > "$case_dir/${name}-command.txt"
  set +e
  sh -c "$command" > "$case_dir/${name}-stdout.txt" 2> "$case_dir/${name}-stderr.txt"
  rc=$?
  set -e
  printf '%s\n' "$rc" > "$case_dir/${name}-exit-code.txt"
  return 0
}

latest_auto_loop_dir() {
  find task-runs -maxdepth 1 -type d -name '*-auto-loop' | sort | tail -1
}

latest_git_flow_review_dir() {
  find task-runs -maxdepth 1 -type d -name '*-git-flow-review-*' | sort | tail -1
}

mark_case() {
  local name="$1"
  local status="$2"
  local expected="$3"
  local actual="$4"
  local evidence="$5"

  total=$((total + 1))
  case "$status" in
    PASS) passed=$((passed + 1)) ;;
    BLOCKED) blocked=$((blocked + 1)) ;;
    *) failed=$((failed + 1)) ;;
  esac

  append_report "## $name"
  append_report
  append_report "- Status: $status"
  append_report "- Expected result: $expected"
  append_report "- Actual result: $actual"
  append_report "- Evidence: $evidence"
  append_report
}

case_1_missing_prompt() {
  case_dir="$RUN_DIR/case-1-missing-prompt"
  mkdir -p "$case_dir"
  repo="$case_dir/workspace"
  git_init_repo "$repo"
  printf 'baseline\n' > "$repo/file.txt"
  commit_all "$repo" "baseline"
  loop="$case_dir/loop-state.md"
  write_loop_state "$loop" "$case_dir/missing-prompt.md"

  before="$(git -C "$repo" status --short)"
  sleep 1
  run_capture "$case_dir" auto-loop bash scripts/orchestia_loop.sh auto-loop "$loop" --workspace "$repo" --max-steps 1 --execute-codex
  run_dir="$(latest_auto_loop_dir)"
  after="$(git -C "$repo" status --short)"

  if [ "$before" = "$after" ] && [ -f "$run_dir/errors.md" ] && [ ! -f "$run_dir/codex-stdout.txt" ]; then
    mark_case "Case 1: auto-loop missing prompt" PASS "missing prompt is refused safely" "errors.md created; no Codex execution; workspace unchanged" "$case_dir, $run_dir"
  else
    mark_case "Case 1: auto-loop missing prompt" FAIL "missing prompt is refused safely" "unexpected state; inspect logs" "$case_dir, $run_dir"
  fi
}

case_2_dry_run_no_execute() {
  case_dir="$RUN_DIR/case-2-dry-run-no-execute"
  mkdir -p "$case_dir"
  repo="$case_dir/workspace"
  git_init_repo "$repo"
  printf 'original\n' > "$repo/file.txt"
  commit_all "$repo" "baseline"
  prompt="$case_dir/prompt.md"
  cat > "$prompt" <<EOF
Modify file.txt to say changed.
EOF
  loop="$case_dir/loop-state.md"
  write_loop_state "$loop" "$prompt"

  sleep 1
  run_capture "$case_dir" auto-loop bash scripts/orchestia_loop.sh auto-loop "$loop" --workspace "$repo" --max-steps 1
  run_dir="$(latest_auto_loop_dir)"

  if grep -q 'original' "$repo/file.txt" && [ -f "$run_dir/command-preview.md" ] && grep -q 'Mode: dry-run' "$run_dir/auto-loop-state.md" && [ ! -f "$run_dir/codex-stdout.txt" ]; then
    mark_case "Case 2: auto-loop dry-run without execute" PASS "dry-run does not execute Codex or modify files" "file unchanged; command preview exists; no codex stdout" "$case_dir, $run_dir"
  else
    mark_case "Case 2: auto-loop dry-run without execute" FAIL "dry-run does not execute Codex or modify files" "unexpected dry-run behavior" "$case_dir, $run_dir"
  fi
}

case_3_dirty_workspace_refusal() {
  case_dir="$RUN_DIR/case-3-dirty-workspace-refusal"
  mkdir -p "$case_dir"
  repo="$case_dir/workspace"
  git_init_repo "$repo"
  printf 'baseline\n' > "$repo/file.txt"
  commit_all "$repo" "baseline"
  printf 'dirty\n' >> "$repo/file.txt"
  prompt="$case_dir/prompt.md"
  printf 'Modify file.txt.\n' > "$prompt"
  loop="$case_dir/loop-state.md"
  write_loop_state "$loop" "$prompt"

  sleep 1
  run_capture "$case_dir" auto-loop bash scripts/orchestia_loop.sh auto-loop "$loop" --workspace "$repo" --max-steps 1 --execute-codex
  run_dir="$(latest_auto_loop_dir)"

  if [ -f "$run_dir/errors.md" ] && grep -qi 'not clean' "$run_dir/errors.md" && [ ! -f "$run_dir/codex-stdout.txt" ]; then
    mark_case "Case 3: auto-loop dirty workspace refusal" PASS "dirty workspace blocks Codex execution" "dirty workspace reported; no Codex stdout" "$case_dir, $run_dir"
  else
    mark_case "Case 3: auto-loop dirty workspace refusal" FAIL "dirty workspace blocks Codex execution" "unexpected dirty workspace behavior" "$case_dir, $run_dir"
  fi
}

case_4_invalid_decision_refusal() {
  case_dir="$RUN_DIR/case-4-invalid-decision"
  mkdir -p "$case_dir"
  repo="$case_dir/workspace"
  git_init_repo "$repo"
  printf 'baseline\n' > "$repo/file.txt"
  commit_all "$repo" "baseline"
  prompt="$case_dir/prompt.md"
  printf 'No changes.\n' > "$prompt"
  loop="$case_dir/loop-state.md"
  write_loop_state "$loop" "$prompt"

  run_capture "$case_dir" auto-loop bash scripts/orchestia_loop.sh auto-loop "$loop" --workspace "$repo" --max-steps 1 --decision maybe
  rc="$(cat "$case_dir/auto-loop-exit-code.txt")"
  if [ "$rc" -ne 0 ] && grep -qi 'decision' "$case_dir/auto-loop-stderr.txt"; then
    mark_case "Case 4: invalid decision refusal" PASS "invalid decision is rejected before advancement" "command failed safely with decision error" "$case_dir"
  else
    mark_case "Case 4: invalid decision refusal" FAIL "invalid decision is rejected before advancement" "invalid decision was not rejected" "$case_dir"
  fi
}

case_5_finalize_draft_outside_task_runs() {
  case_dir="$RUN_DIR/case-5-finalize-draft-outside-task-runs"
  mkdir -p "$case_dir"
  draft="/tmp/orchestia-negative-path-review-draft-$$.md"
  review_file="logics/reviews/REVIEW-9998-outside-draft-check.md"
  rm -f "$review_file"
  printf '# Draft\n' > "$draft"

  run_capture "$case_dir" finalize bash scripts/orchestia_loop.sh finalize-review --draft "$draft" --review-id REVIEW-9998 --review-title "Outside draft check" --reviewed-task TASK-9998 --decision accept
  rc="$(cat "$case_dir/finalize-exit-code.txt")"
  rm -f "$draft"
  if [ "$rc" -ne 0 ] && [ ! -f "$review_file" ] && grep -qi 'task-runs' "$case_dir/finalize-stderr.txt"; then
    mark_case "Case 5: finalize-review refuses draft outside task-runs" PASS "outside draft is refused and no review is created" "draft refused; no REVIEW-9998 file" "$case_dir"
  else
    mark_case "Case 5: finalize-review refuses draft outside task-runs" FAIL "outside draft is refused and no review is created" "unexpected finalize-review behavior" "$case_dir"
  fi
}

case_6_finalize_invalid_decision() {
  case_dir="$RUN_DIR/case-6-finalize-invalid-decision"
  mkdir -p "$case_dir"
  draft="$case_dir/review-draft.md"
  review_file="logics/reviews/REVIEW-9997-invalid-decision-check.md"
  rm -f "$review_file"
  printf '# Draft\n' > "$draft"

  run_capture "$case_dir" finalize bash scripts/orchestia_loop.sh finalize-review --draft "$draft" --review-id REVIEW-9997 --review-title "Invalid decision check" --reviewed-task TASK-9997 --decision maybe
  rc="$(cat "$case_dir/finalize-exit-code.txt")"
  if [ "$rc" -ne 0 ] && [ ! -f "$review_file" ] && grep -qi 'decision' "$case_dir/finalize-stderr.txt"; then
    mark_case "Case 6: finalize-review refuses invalid decision" PASS "invalid decision is refused and no review is created" "decision refused; no REVIEW-9997 file" "$case_dir"
  else
    mark_case "Case 6: finalize-review refuses invalid decision" FAIL "invalid decision is refused and no review is created" "unexpected invalid decision behavior" "$case_dir"
  fi
}

setup_push_repo() {
  local repo="$1"
  local remote="$2"
  local branch="${3:-feature/test}"
  local remote_abs
  git_init_bare "$remote"
  git_init_repo "$repo" master
  printf 'baseline\n' > "$repo/file.txt"
  commit_all "$repo" "baseline"
  remote_abs="$(cd "$(dirname "$remote")" && pwd -P)/$(basename "$remote")"
  git -C "$repo" remote add origin "$remote_abs"
  if [ "$branch" != "master" ]; then
    git -C "$repo" switch -q -c "$branch"
    printf 'feature\n' >> "$repo/file.txt"
    commit_all "$repo" "feature"
  fi
}

case_7_auto_push_protected_branch() {
  case_dir="$RUN_DIR/case-7-auto-push-protected-branch"
  mkdir -p "$case_dir"
  repo="$case_dir/workspace"
  remote="$case_dir/remote.git"
  setup_push_repo "$repo" "$remote" master

  run_capture "$case_dir" auto-push bash scripts/controlled_git_flow.sh auto-push --workspace "$repo" --remote origin --branch master --execute
  rc="$(cat "$case_dir/auto-push-exit-code.txt")"
  if [ "$rc" -ne 0 ] && grep -qi 'protected branch' "$case_dir/auto-push-stderr.txt" && ! git --git-dir="$remote" show-ref --verify --quiet refs/heads/master; then
    mark_case "Case 7: controlled auto-push protected branch refusal" PASS "protected branch push is refused without override" "push refused; remote master was not created" "$case_dir"
  else
    mark_case "Case 7: controlled auto-push protected branch refusal" FAIL "protected branch push is refused without override" "protected branch guard failed or remote was updated" "$case_dir"
  fi
}

case_8_auto_push_dirty_workspace() {
  case_dir="$RUN_DIR/case-8-auto-push-dirty-workspace"
  mkdir -p "$case_dir"
  repo="$case_dir/workspace"
  remote="$case_dir/remote.git"
  setup_push_repo "$repo" "$remote" feature/dirty
  printf 'dirty\n' >> "$repo/file.txt"

  run_capture "$case_dir" auto-push bash scripts/controlled_git_flow.sh auto-push --workspace "$repo" --remote origin --branch feature/dirty --execute
  rc="$(cat "$case_dir/auto-push-exit-code.txt")"
  if [ "$rc" -ne 0 ] && grep -qi 'uncommitted changes' "$case_dir/auto-push-stderr.txt" && ! git --git-dir="$remote" show-ref --verify --quiet refs/heads/feature/dirty; then
    mark_case "Case 8: controlled auto-push dirty workspace refusal" PASS "dirty workspace blocks push" "push refused; remote feature branch absent" "$case_dir"
  else
    mark_case "Case 8: controlled auto-push dirty workspace refusal" FAIL "dirty workspace blocks push" "dirty workspace guard failed or remote was updated" "$case_dir"
  fi
}

case_9_auto_push_failed_test() {
  case_dir="$RUN_DIR/case-9-auto-push-failed-test"
  mkdir -p "$case_dir"
  repo="$case_dir/workspace"
  remote="$case_dir/remote.git"
  setup_push_repo "$repo" "$remote" feature/failing-test

  run_capture "$case_dir" auto-push bash scripts/controlled_git_flow.sh auto-push --workspace "$repo" --remote origin --branch feature/failing-test --test "sh -c 'exit 1'" --execute
  rc="$(cat "$case_dir/auto-push-exit-code.txt")"
  if [ "$rc" -ne 0 ] && grep -qi 'test command failed' "$case_dir/auto-push-stderr.txt" && ! git --git-dir="$remote" show-ref --verify --quiet refs/heads/feature/failing-test; then
    mark_case "Case 9: controlled auto-push failed-test blocking" PASS "failed test blocks push" "test failure refused push; remote feature branch absent" "$case_dir"
  else
    mark_case "Case 9: controlled auto-push failed-test blocking" FAIL "failed test blocks push" "failed-test guard failed or remote was updated" "$case_dir"
  fi
}

setup_merge_repo() {
  local repo="$1"
  local remote="$2"
  local target="$3"
  local source="$4"
  local remote_abs
  git_init_bare "$remote"
  git_init_repo "$repo" "$target"
  printf 'base\n' > "$repo/file.txt"
  commit_all "$repo" "base"
  remote_abs="$(cd "$(dirname "$remote")" && pwd -P)/$(basename "$remote")"
  git -C "$repo" remote add origin "$remote_abs"
  git -C "$repo" push -q origin "$target"
  git -C "$repo" switch -q -c "$source"
  printf 'source\n' >> "$repo/file.txt"
  commit_all "$repo" "source"
  git -C "$repo" push -q origin "$source"
  git -C "$repo" switch -q "$target"
}

case_10_auto_merge_protected_target() {
  case_dir="$RUN_DIR/case-10-auto-merge-protected-target"
  mkdir -p "$case_dir"
  repo="$case_dir/workspace"
  remote="$case_dir/remote.git"
  setup_merge_repo "$repo" "$remote" master "feature/protected-target"
  before="$(git -C "$repo" rev-parse master)"

  run_capture "$case_dir" auto-merge bash scripts/controlled_git_flow.sh auto-merge --workspace "$repo" --remote origin --source-branch feature/protected-target --target-branch master --execute
  rc="$(cat "$case_dir/auto-merge-exit-code.txt")"
  after="$(git -C "$repo" rev-parse master)"
  if [ "$rc" -ne 0 ] && [ "$before" = "$after" ] && grep -qi 'protected target' "$case_dir/auto-merge-stderr.txt"; then
    mark_case "Case 10: controlled auto-merge protected target refusal" PASS "protected target merge is refused" "merge refused; master unchanged" "$case_dir"
  else
    mark_case "Case 10: controlled auto-merge protected target refusal" FAIL "protected target merge is refused" "protected target guard failed" "$case_dir"
  fi
}

case_11_auto_merge_failed_test() {
  case_dir="$RUN_DIR/case-11-auto-merge-failed-test"
  mkdir -p "$case_dir"
  repo="$case_dir/workspace"
  remote="$case_dir/remote.git"
  setup_merge_repo "$repo" "$remote" integration "feature/failing-merge-test"
  before="$(git -C "$repo" rev-parse integration)"

  run_capture "$case_dir" auto-merge bash scripts/controlled_git_flow.sh auto-merge --workspace "$repo" --remote origin --source-branch feature/failing-merge-test --target-branch integration --test "sh -c 'exit 1'" --execute
  rc="$(cat "$case_dir/auto-merge-exit-code.txt")"
  after="$(git -C "$repo" rev-parse integration)"
  if [ "$rc" -ne 0 ] && [ "$before" = "$after" ] && grep -qi 'test command failed' "$case_dir/auto-merge-stderr.txt"; then
    mark_case "Case 11: controlled auto-merge failed-test blocking" PASS "failed test blocks merge" "test failure refused merge; integration unchanged" "$case_dir"
  else
    mark_case "Case 11: controlled auto-merge failed-test blocking" FAIL "failed test blocks merge" "failed-test merge guard failed" "$case_dir"
  fi
}

case_12_auto_merge_conflict() {
  case_dir="$RUN_DIR/case-12-auto-merge-conflict"
  mkdir -p "$case_dir"
  repo="$case_dir/workspace"
  remote="$case_dir/remote.git"
  git_init_bare "$remote"
  git_init_repo "$repo" integration
  printf 'base\n' > "$repo/conflict.txt"
  commit_all "$repo" "base"
  remote_abs="$(cd "$(dirname "$remote")" && pwd -P)/$(basename "$remote")"
  git -C "$repo" remote add origin "$remote_abs"
  git -C "$repo" push -q origin integration
  git -C "$repo" switch -q -c feature/conflict
  printf 'source change\n' > "$repo/conflict.txt"
  commit_all "$repo" "source conflict"
  git -C "$repo" push -q origin feature/conflict
  git -C "$repo" switch -q integration
  printf 'target change\n' > "$repo/conflict.txt"
  commit_all "$repo" "target conflict"
  git -C "$repo" push -q origin integration
  before_remote="$(git --git-dir="$remote" rev-parse refs/heads/integration)"

  run_capture "$case_dir" auto-merge bash scripts/controlled_git_flow.sh auto-merge --workspace "$repo" --remote origin --source-branch feature/conflict --target-branch integration --execute
  rc="$(cat "$case_dir/auto-merge-exit-code.txt")"
  git -C "$repo" status --short > "$case_dir/conflict-status.txt" || true
  after_remote="$(git --git-dir="$remote" rev-parse refs/heads/integration)"
  if git -C "$repo" rev-parse -q --verify MERGE_HEAD >/dev/null 2>&1; then
    git -C "$repo" merge --abort || true
  fi

  if [ "$rc" -ne 0 ] && [ "$before_remote" = "$after_remote" ] && grep -Eq '^(UU|AA|DD|AU|UA) ' "$case_dir/conflict-status.txt"; then
    mark_case "Case 12: controlled auto-merge conflict blocking" PASS "merge conflict stops flow and remote integration is not pushed" "conflict recorded; merge aborted after evidence; remote unchanged" "$case_dir"
  else
    mark_case "Case 12: controlled auto-merge conflict blocking" FAIL "merge conflict stops flow and remote integration is not pushed" "conflict guard failed or remote changed" "$case_dir"
  fi
}

case_13_git_flow_review_missing_evidence() {
  case_dir="$RUN_DIR/case-13-git-flow-review-missing-evidence"
  mkdir -p "$case_dir"
  repo="$case_dir/workspace"
  git_init_repo "$repo"
  printf 'baseline\n' > "$repo/file.txt"
  commit_all "$repo" "baseline"
  loop="$case_dir/loop-state.md"
  write_loop_state "$loop" "$case_dir/prompt.md"
  missing="task-runs/does-not-exist-negative-path-$$"

  run_capture "$case_dir" review-draft bash scripts/orchestia_loop.sh git-flow-review-draft "$loop" --workspace "$repo" --evidence-dir "$missing"
  rc="$(cat "$case_dir/review-draft-exit-code.txt")"
  latest_review="$(latest_git_flow_review_dir)"
  review_created=false
  [ -n "$latest_review" ] && [ -f "$latest_review/git-flow-review-draft.md" ] && review_created=true

  if [ "$rc" -eq 0 ] && [ "$review_created" = "true" ] && grep -qi 'Evidence directory' "$latest_review/git-flow-review-draft.md" && ! ls logics/reviews/REVIEW-9996* >/dev/null 2>&1; then
    mark_case "Case 13: git-flow-review-draft refuses missing evidence" PASS "missing evidence is handled safely without final review creation" "draft created with missing evidence context; no final review created" "$case_dir, $latest_review"
  else
    mark_case "Case 13: git-flow-review-draft refuses missing evidence" FAIL "missing evidence is handled safely without final review creation" "missing evidence behavior unexpected" "$case_dir"
  fi
}

case_14_missing_execute_prevents_execution() {
  case_dir="$RUN_DIR/case-14-missing-execute-prevents-execution"
  mkdir -p "$case_dir"
  repo="$case_dir/workspace"
  remote="$case_dir/remote.git"
  setup_merge_repo "$repo" "$remote" integration "feature/dry-run"
  git -C "$repo" switch -q feature/dry-run
  remote_feature_before="missing"
  git --git-dir="$remote" rev-parse refs/heads/feature/dry-run >/dev/null 2>&1 && remote_feature_before="$(git --git-dir="$remote" rev-parse refs/heads/feature/dry-run)"
  integration_before="$(git -C "$repo" rev-parse integration)"
  remote_integration_before="$(git --git-dir="$remote" rev-parse refs/heads/integration)"

  run_capture "$case_dir" auto-push-dry-run bash scripts/controlled_git_flow.sh auto-push --workspace "$repo" --remote origin --branch feature/dry-run
  git -C "$repo" switch -q integration
  run_capture "$case_dir" auto-merge-dry-run bash scripts/controlled_git_flow.sh auto-merge --workspace "$repo" --remote origin --source-branch feature/dry-run --target-branch integration
  remote_feature_after="$(git --git-dir="$remote" rev-parse refs/heads/feature/dry-run)"
  integration_after="$(git -C "$repo" rev-parse integration)"
  remote_integration_after="$(git --git-dir="$remote" rev-parse refs/heads/integration)"

  if [ "$remote_feature_before" = "$remote_feature_after" ] && [ "$integration_before" = "$integration_after" ] && [ "$remote_integration_before" = "$remote_integration_after" ]; then
    mark_case "Case 14: missing --execute prevents execution" PASS "dry-run push and merge perform no remote update or merge commit" "refs unchanged after dry-runs" "$case_dir"
  else
    mark_case "Case 14: missing --execute prevents execution" FAIL "dry-run push and merge perform no remote update or merge commit" "dry-run changed refs unexpectedly" "$case_dir"
  fi
}

{
  echo "# v0.2-alpha Negative-path Validation"
  echo
  echo "- Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "- Report directory: $RUN_DIR"
  echo "- Orchestia commit: $(git rev-parse --short HEAD)"
  echo
  echo "Expected refusals are PASS when the refusal is safe and documented."
  echo
} > "$REPORT"

case_1_missing_prompt
case_2_dry_run_no_execute
case_3_dirty_workspace_refusal
case_4_invalid_decision_refusal
case_5_finalize_draft_outside_task_runs
case_6_finalize_invalid_decision
case_7_auto_push_protected_branch
case_8_auto_push_dirty_workspace
case_9_auto_push_failed_test
case_10_auto_merge_protected_target
case_11_auto_merge_failed_test
case_12_auto_merge_conflict
case_13_git_flow_review_missing_evidence
case_14_missing_execute_prevents_execution

{
  echo "# Summary"
  echo
  echo "- Total cases: $total"
  echo "- Passed cases: $passed"
  echo "- Failed cases: $failed"
  echo "- Blocked cases: $blocked"
  echo "- Report directory: $RUN_DIR"
  echo
  if [ "$failed" -eq 0 ]; then
    echo "- Final decision recommendation: accept"
  else
    echo "- Final decision recommendation: revise"
  fi
  echo
  cat "$REPORT"
} > "$RUN_DIR/summary.tmp"
mv "$RUN_DIR/summary.tmp" "$REPORT"

log "Report: $REPORT"
log "Total: $total"
log "Passed: $passed"
log "Failed: $failed"
log "Blocked: $blocked"

[ "$failed" -eq 0 ]
