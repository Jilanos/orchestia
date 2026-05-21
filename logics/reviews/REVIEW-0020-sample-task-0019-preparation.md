# REVIEW-0020: Sample Task 0019 Preparation

## Metadata

- ID: REVIEW-0020
- Status: Complete
- Reviewed task: [TASK-0024 Prepare Sample Task 0019 Executable Run](../tasks/TASK-0024-prepare-sample-task-0019-executable-run.md)
- Related task: [TASK-0019 Sample Todo CLI Implement Core Features](../tasks/TASK-0019-sample-todo-cli-implement-core-features.md)

## Inputs Reviewed

- `prompts/samples/todo-cli-task-0019-codex-prompt.md`
- `docs/sample-v0.2-task-0019-executable-run.md`
- `logics/loop-states/LS-0001-sample-todo-cli.md`
- Sample project status at `~/ai-workspaces/orchestia-samples/todo-cli`

## Checks Performed

- Confirmed the sample project exists and is clean.
- Confirmed the sample project latest commit is `933cc67 Create todo CLI project foundation`.
- Confirmed the prepared prompt targets only `~/ai-workspaces/orchestia-samples/todo-cli`.
- Confirmed the prompt forbids modifying Orchestia, `/mnt/c`, push, secrets, global dependency installation, unrelated features, and new project creation.
- Confirmed the prompt requires add, list, done, JSON persistence, tests, and README updates if needed.
- Confirmed `LS-0001` references the prepared prompt and keeps decision `pending`.

## Findings

- No blocking preparation issues found.
- The prepared prompt is scoped to core todo behavior only.
- The sample project was inspected but not modified.

## Risks

- Storage behavior should remain local and simple during execution.
- Manual smoke checks should use a temporary file to avoid prior persistent state.
- TASK-0020 validation/docs scope must not be pulled into TASK-0019 beyond minimal README usage updates.

## Decision

accept

## Required Follow-Up

Execute the prepared `TASK-0019` prompt in Codex from the dedicated sample workspace, then collect and review the result.

## Next Recommended Task

Run `TASK-0019` using `prompts/samples/todo-cli-task-0019-codex-prompt.md`.
