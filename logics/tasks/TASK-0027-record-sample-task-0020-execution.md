# TASK-0027: Record Sample Task 0020 Execution

## Metadata

- ID: TASK-0027
- Status: Complete
- Related task: [TASK-0020 Sample Todo CLI Add Validation And Docs](TASK-0020-sample-todo-cli-add-validation-and-docs.md)
- Review: [REVIEW-0023 Sample Task 0020 Execution](../reviews/REVIEW-0023-sample-task-0020-execution.md)

## Objective

Record the completed sample `TASK-0020` execution in Orchestia and complete the sample v0.2 loop.

## Context

The sample todo CLI validation and documentation work was completed in `~/ai-workspaces/orchestia-samples/todo-cli` and committed locally as `728b946 Improve todo CLI validation and docs`. Verification passed, the sample project remained clean, and all three sample primary needs are complete.

## Authorized Scope

- `logics/tasks/TASK-0020-sample-todo-cli-add-validation-and-docs.md`
- `logics/requests/REQ-0004-sample-todo-cli-validation-docs.md`
- `logics/backlog/BL-0006-sample-todo-cli-validation-docs.md`
- `logics/primary-needs/PN-0003-validation-and-docs.md`
- `logics/initial-needs/IN-0001-sample-todo-cli.md`
- `logics/loop-states/LS-0001-sample-todo-cli.md`
- `docs/sample-v0.2-task-0020-executable-run.md`
- `docs/sample-v0.2-orchestration-scenario.md`
- `logics/tasks/TASK-0027-record-sample-task-0020-execution.md`
- `logics/reviews/REVIEW-0023-sample-task-0020-execution.md`

## Out Of Scope

- Do not modify the sample todo CLI project.
- Do not push from the sample project.
- Do not execute Codex.
- Do not modify scripts or prompts.

## Expected Steps

1. Verify Orchestia repository path, branch, and clean working tree.
2. Inspect the sample project Git status and latest commit without modifying it.
3. Run verification commands against the sample project.
4. Mark `TASK-0020`, `REQ-0004`, `BL-0006`, and `PN-0003` as accepted or complete.
5. Mark `IN-0001` as complete because all primary needs are complete.
6. Update `LS-0001` with stop condition `all primary needs complete`.
7. Update sample documentation with the observed execution result.
8. Create the execution review.
9. Run verification commands.
10. Commit and push the Orchestia recording artifacts.

## Test Commands

```bash
pwd
git branch --show-current
test "$(git branch --show-current)" = "master"
test -d ~/ai-workspaces/orchestia-samples/todo-cli
cd ~/ai-workspaces/orchestia-samples/todo-cli
git status --short
git log --oneline --max-count=3
python3 -m compileall src tests
python3 -m unittest discover -s tests
python3 -m py_compile todo_cli.py
git diff --check
cd ~/ai-workspaces/orchestia
test -f logics/reviews/REVIEW-0023-sample-task-0020-execution.md
test -f logics/tasks/TASK-0027-record-sample-task-0020-execution.md
grep -R "accept" logics/reviews/REVIEW-0023-sample-task-0020-execution.md
grep -R "complete" logics/primary-needs/PN-0003-validation-and-docs.md
grep -R "complete" logics/initial-needs/IN-0001-sample-todo-cli.md
grep -R "all primary needs complete" logics/loop-states/LS-0001-sample-todo-cli.md
git status --short
git diff --stat
```

## Acceptance Criteria

- `TASK-0020` is recorded as executed and accepted.
- `REQ-0004` is accepted.
- `BL-0006` is accepted.
- `PN-0003` is complete.
- `IN-0001` is complete.
- `LS-0001` records `all primary needs complete`.
- `REVIEW-0023` records an `accept` decision.

## Watch Points

- Do not modify the sample project while recording the result.
- Do not modify files outside the authorized scope.
- Do not weaken safety boundaries.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not print environment variables.
- Do not merge, rebase, tag, force push, or change remotes.

## Result Summary

Recorded the accepted `TASK-0020` execution and completed the sample v0.2 loop.
