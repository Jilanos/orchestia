# Sample v0.2 First Executable Run

## Purpose

This document records the first executable sample run for the v0.2 todo CLI scenario.

## Source Logics Chain

- Initial need: [IN-0001 Sample Todo CLI](../logics/initial-needs/IN-0001-sample-todo-cli.md)
- Primary need: [PN-0001 Project Foundation](../logics/primary-needs/PN-0001-project-foundation.md)
- Request: [REQ-0002 Sample Todo CLI Foundation](../logics/requests/REQ-0002-sample-todo-cli-foundation.md)
- Backlog item: [BL-0004 Sample Todo CLI Foundation](../logics/backlog/BL-0004-sample-todo-cli-foundation.md)
- Task: [TASK-0018 Sample Todo CLI Create Project Foundation](../logics/tasks/TASK-0018-sample-todo-cli-create-project-foundation.md)
- Loop state: [LS-0001 Sample Todo CLI](../logics/loop-states/LS-0001-sample-todo-cli.md)

## Dedicated Sample Workspace

The prepared run targets this separate workspace:

```bash
~/ai-workspaces/orchestia-samples/todo-cli
```

Do not run the sample task from the Orchestia repository, and do not use a path under `/mnt/c`.

## Prepared Codex Prompt

Use the prepared Codex prompt at:

```text
prompts/samples/todo-cli-task-0018-codex-prompt.md
```

## Manual Run Instructions

1. Open the prepared Codex prompt.
2. Start Codex from a safe WSL Linux filesystem workspace.
3. Paste the prompt into Codex.
4. Confirm Codex is targeting `~/ai-workspaces/orchestia-samples/todo-cli`.
5. Let Codex create only the foundation sample project.
6. Do not allow push.
7. Stop if Codex asks for secrets, global dependency installation, destructive commands, or work under `/mnt/c`.

## Expected Outputs

- A new local sample project at `~/ai-workspaces/orchestia-samples/todo-cli`.
- A separate Git repository initialized inside the sample project.
- A minimal `README.md`.
- A minimal project structure.
- A minimal CLI entry point.
- A minimal test or syntax check.
- One local initial commit in the sample project.
- No changes to the Orchestia repository.

## Observed Execution Result

- Sample project path: `~/ai-workspaces/orchestia-samples/todo-cli`
- Sample project commit: `933cc67 Create todo CLI project foundation`
- Runtime: Python standard library only
- Files observed:
  - `.gitignore`
  - `README.md`
  - `src/todo_cli/__init__.py`
  - `src/todo_cli/__main__.py`
  - `tests/test_smoke.py`
- Checks passed:
  - `git status --short`: clean
  - `python3 -m compileall src tests`
  - `python3 -m unittest discover -s tests`: 2 tests OK
- No push was performed from the sample project.
- Orchestia remained clean after execution.
- The full todo feature set was not implemented.

## What To Collect After Execution

- `pwd` from the sample project.
- `git status --short` from the sample project.
- `git log --oneline --decorate --max-count=3` from the sample project.
- The commands Codex ran.
- The verification results.
- A short diff summary from the sample project.

## How To Review The Result

Review the collected output against `TASK-0018` and the prepared prompt. The review decision must be one of: accept, revise, split, or reject.

Accept only if the sample project foundation exists, verification passes, the full todo feature set was not implemented, no push occurred, and the Orchestia repository was not modified.

## Stop Conditions

Stop the run if:

- The workspace path is under `/mnt/c`.
- The target directory already contains unrelated files.
- Codex requests secrets or credentials.
- Codex needs a destructive command.
- Codex tries to modify the Orchestia repository.
- Codex tries to push.
- Runtime setup requires global dependency installation.

## Known Limitations

- The sample project foundation is validated, but only at foundation scope.
- Runtime choice was Python standard library only.
- The sample run covers project foundation only, not core todo features.
- No auto push or auto merge behavior is exercised.
