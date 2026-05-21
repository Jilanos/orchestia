# Sample v0.2 TASK-0020 Executable Run

## Purpose

This document prepares the executable run for `TASK-0020`, which will improve validation and documentation for the existing sample todo CLI project. It does not execute Codex and does not modify the sample project.

## Source Logics Chain

- Initial need: [IN-0001 Sample Todo CLI](../logics/initial-needs/IN-0001-sample-todo-cli.md)
- Primary need: [PN-0003 Validation And Docs](../logics/primary-needs/PN-0003-validation-and-docs.md)
- Request: [REQ-0004 Sample Todo CLI Validation And Docs](../logics/requests/REQ-0004-sample-todo-cli-validation-docs.md)
- Backlog item: [BL-0006 Sample Todo CLI Validation And Docs](../logics/backlog/BL-0006-sample-todo-cli-validation-docs.md)
- Task: [TASK-0020 Sample Todo CLI Add Validation And Docs](../logics/tasks/TASK-0020-sample-todo-cli-add-validation-and-docs.md)
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
prompts/samples/todo-cli-task-0020-codex-prompt.md
```

## Current Baseline

- Sample project path: `~/ai-workspaces/orchestia-samples/todo-cli`
- Baseline commit: `1788bae Implement core todo CLI features`
- Baseline status: clean before preparation

## Manual Run Instructions

1. Open `prompts/samples/todo-cli-task-0020-codex-prompt.md`.
2. Start Codex from the existing sample project workspace.
3. Confirm the current path is `~/ai-workspaces/orchestia-samples/todo-cli`.
4. Confirm `git status --short` is clean.
5. Paste the prepared prompt into Codex.
6. Let Codex improve validation and documentation only.
7. Do not allow push.
8. Stop if Codex asks for secrets, global dependency installation, destructive commands, work under `/mnt/c`, or scope beyond validation and documentation.

## Expected Outputs

- README improvements for add, list, done, `--file`, storage behavior, and known limitations.
- Useful help output preserved or improved.
- Tests added or improved where appropriate.
- Passing compile, unittest, wrapper syntax, and diff whitespace checks.
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
  - `python3 -m py_compile todo_cli.py`
  - `git diff --check`
- Manual smoke check commands and output.
- Local commit hash.
- Orchestia `git status --short`.

## How To Review The Result

Review the collected output against `TASK-0020` and the prepared prompt. The review decision must be one of: accept, revise, split, or reject.

Accept only if validation and documentation improve, required checks pass, manual smoke check passes, no push occurred, no unrelated features were added, and the Orchestia repository was not modified.

## Stop Conditions

Stop the run if:

- The sample workspace is dirty before execution.
- The path is under `/mnt/c`.
- Codex requests secrets or credentials.
- Codex needs a destructive command.
- Tests fail repeatedly without a small clear fix.
- The implementation expands beyond validation and documentation.
- Codex tries to modify the Orchestia repository.
- Codex tries to push.

## Known Limitations

- This preparation does not validate the TASK-0020 implementation yet.
- The sample still uses a minimal `todo_cli.py` wrapper instead of packaging metadata.
- Packaging metadata, CI, release automation, and distribution are not part of TASK-0020.
- No auto push or auto merge behavior is exercised.
