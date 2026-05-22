# TASK-0028: Add State-Driven Loop Runner

## Metadata

- ID: TASK-0028
- Status: Complete
- Related loop state: [LS-0001 Sample Todo CLI](../loop-states/LS-0001-sample-todo-cli.md)

## Objective

Implement the first safe state-driven orchestration loop runner for Orchestia.

## Context

The v0.2 sample loop has been completed manually. This task introduces a helper script that reads Loop state, reports the active task and prepared prompt, verifies a target workspace, and helps run or collect evidence for a loop step without making autonomous decisions.

## Authorized Scope

- `scripts/orchestia_loop.sh`
- `README.md`
- `docs/workflow.md`
- `docs/mvp-roadmap.md`
- `docs/orchestration-state-model.md`
- `logics/tasks/TASK-0028-add-state-driven-loop-runner.md`
- `logics/reviews/REVIEW-0024-state-driven-loop-runner.md`

## Out Of Scope

- Do not modify existing scripts.
- Do not modify prompts.
- Do not update Loop state automatically.
- Do not make accept/revise/split/reject decisions automatically.
- Do not auto push or auto merge.

## Expected Steps

1. Verify repository path, branch, and clean working tree.
2. Read the state model, workflow docs, roadmap, README, existing helper scripts, and sample Loop state.
3. Create `scripts/orchestia_loop.sh`.
4. Make the script executable.
5. Update documentation with concise usage.
6. Create this task record and the review record.
7. Run verification commands.
8. Commit and push the result.

## Test Commands

```bash
pwd
git branch --show-current
test "$(git branch --show-current)" = "master"
test -f scripts/orchestia_loop.sh
bash -n scripts/orchestia_loop.sh
test -x scripts/orchestia_loop.sh
bash scripts/orchestia_loop.sh status logics/loop-states/LS-0001-sample-todo-cli.md
bash scripts/orchestia_loop.sh next logics/loop-states/LS-0001-sample-todo-cli.md
bash scripts/orchestia_loop.sh run logics/loop-states/LS-0001-sample-todo-cli.md --workspace ~/ai-workspaces/orchestia-samples/todo-cli
bash scripts/orchestia_loop.sh collect logics/loop-states/LS-0001-sample-todo-cli.md --workspace ~/ai-workspaces/orchestia-samples/todo-cli --test "python3 -m unittest discover -s tests"
bash scripts/orchestia_loop.sh review-draft logics/loop-states/LS-0001-sample-todo-cli.md --workspace ~/ai-workspaces/orchestia-samples/todo-cli
grep -R "orchestia_loop.sh" README.md docs/workflow.md
grep -R "state-driven" README.md docs/workflow.md docs/mvp-roadmap.md
test -f logics/tasks/TASK-0028-add-state-driven-loop-runner.md
test -f logics/reviews/REVIEW-0024-state-driven-loop-runner.md
git status --short
git diff --stat
```

## Acceptance Criteria

- `scripts/orchestia_loop.sh` exists and is executable.
- The script supports `status`, `next`, `run`, `collect`, and `review-draft`.
- The script reads Loop state fields.
- The script verifies workspace safety before run or collect.
- The script does not execute Codex unless `--execute` is explicitly provided.
- The script does not push, merge, rebase, tag, force push, update Loop state, or make review decisions.

## Watch Points

- Keep the implementation simple.
- Do not introduce external dependencies.
- Do not implement full need-to-completion automation yet.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not print environment variables.
- Do not weaken WSL or Git safety boundaries.

## Result Summary

Added `scripts/orchestia_loop.sh`, documented usage, and clarified the Loop state field used by the runner.
