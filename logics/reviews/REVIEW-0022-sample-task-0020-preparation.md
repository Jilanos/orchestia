# REVIEW-0022: Sample Task 0020 Preparation

## Metadata

- ID: REVIEW-0022
- Status: Complete
- Reviewed task: [TASK-0026 Prepare Sample Task 0020 Executable Run](../tasks/TASK-0026-prepare-sample-task-0020-executable-run.md)
- Related task: [TASK-0020 Sample Todo CLI Add Validation And Docs](../tasks/TASK-0020-sample-todo-cli-add-validation-and-docs.md)

## Inputs Reviewed

- `prompts/samples/todo-cli-task-0020-codex-prompt.md`
- `docs/sample-v0.2-task-0020-executable-run.md`
- `logics/loop-states/LS-0001-sample-todo-cli.md`
- Sample project status at `~/ai-workspaces/orchestia-samples/todo-cli`

## Checks Performed

- Confirmed the sample project exists and is clean.
- Confirmed the sample project latest commit is `1788bae Implement core todo CLI features`.
- Confirmed the prepared prompt targets only `~/ai-workspaces/orchestia-samples/todo-cli`.
- Confirmed the prompt forbids modifying Orchestia, `/mnt/c`, push, secrets, global dependency installation, new project creation, and unrelated features.
- Confirmed the prompt requires validation and documentation work only.
- Confirmed the prompt requires compile, unittest, wrapper syntax, diff whitespace, and manual smoke checks.
- Confirmed `LS-0001` references the prepared prompt and keeps decision `pending`.

## Findings

- No blocking preparation issues found.
- The prepared prompt is scoped to validation and documentation only.
- The sample project was inspected but not modified.

## Risks

- The sample still uses a minimal `todo_cli.py` wrapper instead of packaging metadata.
- Documentation must not claim unsupported behavior.
- TASK-0020 should not add new core features except for small fixes required by validation.

## Decision

accept

## Required Follow-Up

Execute the prepared `TASK-0020` prompt in Codex from the dedicated sample workspace, then collect and review the result.

## Next Recommended Task

Run `TASK-0020` using `prompts/samples/todo-cli-task-0020-codex-prompt.md`.
