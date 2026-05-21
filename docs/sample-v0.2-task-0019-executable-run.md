# Sample v0.2 TASK-0019 Executable Run

## Purpose

This document prepares the executable run for `TASK-0019`, which will add core todo behavior to the existing sample todo CLI project. It does not execute Codex and does not modify the sample project.

## Source Logics Chain

- Initial need: [IN-0001 Sample Todo CLI](../logics/initial-needs/IN-0001-sample-todo-cli.md)
- Primary need: [PN-0002 Core Todo Features](../logics/primary-needs/PN-0002-core-todo-features.md)
- Request: [REQ-0003 Sample Todo CLI Core Features](../logics/requests/REQ-0003-sample-todo-cli-core-features.md)
- Backlog item: [BL-0005 Sample Todo CLI Core Features](../logics/backlog/BL-0005-sample-todo-cli-core-features.md)
- Task: [TASK-0019 Sample Todo CLI Implement Core Features](../logics/tasks/TASK-0019-sample-todo-cli-implement-core-features.md)
- Loop state: [LS-0001 Sample Todo CLI](../logics/loop-states/LS-0001-sample-todo-cli.md)

## Dedicated Sample Workspace

Run the prepared prompt only in:

```bash
~/ai-workspaces/orchestia-samples/todo-cli
```

Do not run it from the Orchestia repository, and do not use a path under `/mnt/c`.

## Prepared Codex Prompt

Use the prepared Codex prompt at:

```text
prompts/samples/todo-cli-task-0019-codex-prompt.md
```

## Current Baseline

- Sample project path: `~/ai-workspaces/orchestia-samples/todo-cli`
- Baseline commit: `933cc67 Create todo CLI project foundation`
- Baseline status: clean before preparation

## Manual Run Instructions

1. Open `prompts/samples/todo-cli-task-0019-codex-prompt.md`.
2. Start Codex from the existing sample project workspace.
3. Confirm the current path is `~/ai-workspaces/orchestia-samples/todo-cli`.
4. Confirm `git status --short` is clean.
5. Paste the prepared prompt into Codex.
6. Let Codex implement only add, list, done, and local JSON persistence.
7. Do not allow push.
8. Stop if Codex asks for secrets, global dependency installation, destructive commands, work under `/mnt/c`, or scope beyond core todo features.

## Expected Outputs

- Updated Python CLI entry point and supporting code as needed.
- Local JSON persistence, preferably `./todos.json` by default.
- Tests for add, list, done, persistence, and invalid input.
- README usage updates if needed.
- Passing compile and unittest checks.
- Passing manual smoke check using a temporary todo file.
- One local commit in the sample project.
- No changes to the Orchestia repository.

## What To Collect After Execution

- `pwd` from the sample project.
- `git status --short` from the sample project.
- `git log --oneline --decorate --max-count=3` from the sample project.
- Files changed.
- `git diff --stat` before the local commit, if available.
- Required check results:
  - `python3 -m compileall src tests`
  - `python3 -m unittest discover -s tests`
- Manual smoke check commands and output.
- Local commit hash.
- Orchestia `git status --short`.

## How To Review The Result

Review the collected output against `TASK-0019` and the prepared prompt. The review decision must be one of: accept, revise, split, or reject.

Accept only if add, list, done, and local persistence work; checks pass; no push occurred; no unrelated features were added; and the Orchestia repository was not modified.

## Stop Conditions

Stop the run if:

- The sample workspace is dirty before execution.
- The path is under `/mnt/c`.
- Codex requests secrets or credentials.
- Codex needs a destructive command.
- Tests fail repeatedly without a small clear fix.
- The implementation expands beyond core todo features.
- Codex tries to modify the Orchestia repository.
- Codex tries to push.

## Known Limitations

- This preparation does not validate the TASK-0019 implementation yet.
- Storage behavior should remain simple and local for the sample.
- Validation and documentation beyond core feature support are reserved for `TASK-0020`.
- No auto push or auto merge behavior is exercised.
