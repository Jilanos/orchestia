# TASK-0026: Prepare Sample Task 0020 Executable Run

## Metadata

- ID: TASK-0026
- Status: Complete
- Related task: [TASK-0020 Sample Todo CLI Add Validation And Docs](TASK-0020-sample-todo-cli-add-validation-and-docs.md)
- Loop state: [LS-0001 Sample Todo CLI](../loop-states/LS-0001-sample-todo-cli.md)

## Objective

Prepare a Codex-ready prompt and execution guide for sample `TASK-0020` without executing Codex or modifying the sample project.

## Context

`TASK-0018` and `TASK-0019` were accepted, `PN-0001` and `PN-0002` are complete, and `LS-0001` now points to `PN-0003`, `REQ-0004`, `BL-0006`, and `TASK-0020`. The sample project exists at `~/ai-workspaces/orchestia-samples/todo-cli` and is clean at commit `1788bae Implement core todo CLI features`.

## Authorized Scope

- `prompts/samples/todo-cli-task-0020-codex-prompt.md`
- `docs/sample-v0.2-task-0020-executable-run.md`
- `logics/loop-states/LS-0001-sample-todo-cli.md`
- `logics/tasks/TASK-0026-prepare-sample-task-0020-executable-run.md`
- `logics/reviews/REVIEW-0022-sample-task-0020-preparation.md`

## Out Of Scope

- Do not execute Codex.
- Do not modify the sample todo CLI project.
- Do not implement validation or docs.
- Do not modify scripts or existing prompt templates.
- Do not modify `TASK-0020`.
- Do not push from the sample project.

## Expected Steps

1. Verify Orchestia repository path, branch, and clean working tree.
2. Verify the sample project exists, is clean, and has latest commit `1788bae`.
3. Read `TASK-0020`, `LS-0001`, `REQ-0004`, `BL-0006`, `PN-0003`, the Codex task prompt, workflow, and security boundaries.
4. Create the prepared `TASK-0020` Codex prompt.
5. Create the `TASK-0020` executable run guide.
6. Update `LS-0001` to reference the prepared prompt and keep the decision pending.
7. Create this task record and the preparation review.
8. Run verification commands.
9. Commit and push the preparation artifacts.

## Test Commands

```bash
pwd
git branch --show-current
test "$(git branch --show-current)" = "master"
test -d ~/ai-workspaces/orchestia-samples/todo-cli
cd ~/ai-workspaces/orchestia-samples/todo-cli
git status --short
git log --oneline --max-count=3
cd ~/ai-workspaces/orchestia
test -f prompts/samples/todo-cli-task-0020-codex-prompt.md
test -f docs/sample-v0.2-task-0020-executable-run.md
test -f logics/tasks/TASK-0026-prepare-sample-task-0020-executable-run.md
test -f logics/reviews/REVIEW-0022-sample-task-0020-preparation.md
grep -R "orchestia-samples/todo-cli" prompts/samples/todo-cli-task-0020-codex-prompt.md docs/sample-v0.2-task-0020-executable-run.md
grep -R "do not modify the Orchestia repository" prompts/samples/todo-cli-task-0020-codex-prompt.md
grep -R "do not work under /mnt/c" prompts/samples/todo-cli-task-0020-codex-prompt.md
grep -R "do not push" prompts/samples/todo-cli-task-0020-codex-prompt.md
grep -R "validation and documentation" prompts/samples/todo-cli-task-0020-codex-prompt.md
grep -R "python3 -m compileall src tests" prompts/samples/todo-cli-task-0020-codex-prompt.md
grep -R "python3 -m unittest discover -s tests" prompts/samples/todo-cli-task-0020-codex-prompt.md
grep -R "python3 -m py_compile todo_cli.py" prompts/samples/todo-cli-task-0020-codex-prompt.md
grep -R "prepared Codex prompt" logics/loop-states/LS-0001-sample-todo-cli.md
grep -R "TASK-0020" logics/loop-states/LS-0001-sample-todo-cli.md
grep -R "pending" logics/loop-states/LS-0001-sample-todo-cli.md
git status --short
git diff --stat
```

## Acceptance Criteria

- The Codex-ready `TASK-0020` sample prompt exists.
- The `TASK-0020` executable run documentation exists.
- `LS-0001` references the prepared `TASK-0020` prompt and remains pending.
- No Codex execution is performed.
- No sample project files are modified.

## Watch Points

- Keep this as preparation only.
- Do not implement `TASK-0020`.
- Do not modify existing prompt templates or scripts.
- Do not weaken safety boundaries.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not print environment variables.
- Do not modify files outside the authorized scope.
- Do not merge, rebase, tag, force push, or change remotes.

## Result Summary

Prepared the `TASK-0020` Codex prompt, execution guide, and loop-state update for the validation and documentation micro-loop.
