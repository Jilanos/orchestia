# TASK-0029: Add Controlled Git Flow

## Metadata

- ID: TASK-0029
- Status: Complete
- ADR: [ADR-0002 Controlled Auto Push And Merge Policy](../adr/ADR-0002-controlled-auto-push-merge-policy.md)

## Objective

Implement a safe helper script for controlled auto push and controlled auto merge under the documented Orchestia v0.2 policy.

## Context

The policy allows controlled auto push and controlled auto merge for fresh projects or isolated branches under strict guardrails. This task implements the first helper script while keeping dry-run as the default and requiring `--execute` before any Git push or merge.

## Authorized Scope

- `scripts/controlled_git_flow.sh`
- `README.md`
- `docs/workflow.md`
- `docs/security-boundaries.md`
- `docs/mvp-roadmap.md`
- `logics/tasks/TASK-0029-add-controlled-git-flow.md`
- `logics/reviews/REVIEW-0025-controlled-git-flow.md`

## Out Of Scope

- Do not modify existing scripts.
- Do not execute controlled auto push or controlled auto merge.
- Do not run the new script with `--execute`.
- Do not modify sample project files.
- Do not weaken protected branch rules.

## Expected Steps

1. Verify repository path, branch, and clean working tree.
2. Read policy, workflow, roadmap, README, and ADR-0002.
3. Create `scripts/controlled_git_flow.sh`.
4. Make the script executable.
5. Update documentation with concise usage and guardrails.
6. Create this task record and the review record.
7. Run verification commands in dry-run mode only.
8. Commit and push the result.

## Test Commands

```bash
pwd
git branch --show-current
test "$(git branch --show-current)" = "master"
test -f scripts/controlled_git_flow.sh
bash -n scripts/controlled_git_flow.sh
test -x scripts/controlled_git_flow.sh
bash scripts/controlled_git_flow.sh
bash scripts/controlled_git_flow.sh status --workspace ~/ai-workspaces/orchestia-samples/todo-cli
bash scripts/controlled_git_flow.sh auto-push --workspace ~/ai-workspaces/orchestia-samples/todo-cli --remote origin --branch master
bash scripts/controlled_git_flow.sh auto-merge --workspace ~/ai-workspaces/orchestia-samples/todo-cli --remote origin --source-branch feature/example --target-branch integration
grep -R "controlled_git_flow.sh" README.md docs/workflow.md
grep -R "dry-run" README.md docs/security-boundaries.md
grep -R "main/master" docs/security-boundaries.md README.md
grep -R "force push" docs/security-boundaries.md scripts/controlled_git_flow.sh
test -f logics/tasks/TASK-0029-add-controlled-git-flow.md
test -f logics/reviews/REVIEW-0025-controlled-git-flow.md
git status --short
git diff --stat
```

## Acceptance Criteria

- `scripts/controlled_git_flow.sh` exists and is executable.
- The script supports `status`, `auto-push`, and `auto-merge`.
- The script defaults to dry-run and requires `--execute` for push or merge.
- The script protects `main/master` by default.
- The script never uses force push or branch deletion.
- The script writes evidence under `task-runs/`.

## Watch Points

- Do not run with `--execute`.
- Do not perform a real push or merge in this task.
- Keep the helper dependency-free and reviewable.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not print environment variables.
- Do not merge, rebase, tag, force push, or change remotes.

## Result Summary

Added `scripts/controlled_git_flow.sh` with dry-run-first guarded status, auto-push, and auto-merge commands.
