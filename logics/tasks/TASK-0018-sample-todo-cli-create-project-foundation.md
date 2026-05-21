# TASK-0018: Sample Todo CLI Create Project Foundation

## Metadata

- ID: TASK-0018
- Status: Accepted
- Request: [REQ-0002 Sample Todo CLI Foundation](../requests/REQ-0002-sample-todo-cli-foundation.md)
- Backlog: [BL-0004 Sample Todo CLI Foundation](../backlog/BL-0004-sample-todo-cli-foundation.md)
- Primary need: [PN-0001 Project Foundation](../primary-needs/PN-0001-project-foundation.md)

## Objective

Create the todo CLI project foundation in a dedicated sample project workspace.

## Context

This sample task was executed in the dedicated sample workspace at `~/ai-workspaces/orchestia-samples/todo-cli` and accepted in [REVIEW-0019](../reviews/REVIEW-0019-sample-task-0018-execution.md).

## Authorized Scope

- Future dedicated sample todo CLI project workspace only.
- Specific files must be named before execution.

## Out Of Scope

- Do not implement code in this Orchestia task.
- Do not modify the Orchestia repository.
- Do not execute Codex on an external project now.
- Do not push, merge, rebase, tag, or force push.

## Expected Steps

1. Print the current directory with `pwd`.
2. Verify this is the dedicated sample project workspace.
3. Verify the path is not under `/mnt/c`.
4. Check `git status --short`.
5. Confirm runtime choice with the human if missing.
6. Create the minimal project structure and CLI placeholder.
7. Run the test commands.
8. Summarize the diff and verification result.

## Test Commands

```bash
python3 -m compileall src tests
python3 -m unittest discover -s tests
```

## Acceptance Criteria

- Project structure exists in the dedicated sample workspace.
- CLI placeholder can run.
- Runtime and verification command are documented.
- No Orchestia repository files were modified during execution.

## Execution Result

- Sample project path: `~/ai-workspaces/orchestia-samples/todo-cli`
- Sample project commit: `933cc67 Create todo CLI project foundation`
- Runtime: Python standard library only
- Files created:
  - `.gitignore`
  - `README.md`
  - `src/todo_cli/__init__.py`
  - `src/todo_cli/__main__.py`
  - `tests/test_smoke.py`
- Checks passed:
  - `git status --short`: clean
  - `python3 -m compileall src tests`
  - `python3 -m unittest discover -s tests`: 2 tests OK
- Review decision: accept

## Watch Points

- This planned sample task must not be executed in the Orchestia repository.
- Runtime choice may be a firm blocker if unclear.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not inspect `.env`, credential stores, token files, SSH keys, browser profiles, or cloud configuration.
- Do not use force push.
- Do not modify files outside the authorized sample workspace.
- Stop if repository or path checks fail.
