# TASK-0019: Sample Todo CLI Implement Core Features

## Metadata

- ID: TASK-0019
- Status: Accepted
- Request: [REQ-0003 Sample Todo CLI Core Features](../requests/REQ-0003-sample-todo-cli-core-features.md)
- Backlog: [BL-0005 Sample Todo CLI Core Features](../backlog/BL-0005-sample-todo-cli-core-features.md)
- Primary need: [PN-0002 Core Todo Features](../primary-needs/PN-0002-core-todo-features.md)

## Objective

Implement add, list, complete, and local persistence behavior in the dedicated sample todo CLI workspace.

## Context

This sample task was executed in the dedicated sample workspace at `~/ai-workspaces/orchestia-samples/todo-cli` and accepted in [REVIEW-0021](../reviews/REVIEW-0021-sample-task-0019-execution.md).

## Authorized Scope

- Future dedicated sample todo CLI project workspace only.
- Specific source and data files must be named before execution.

## Out Of Scope

- Do not implement code in this Orchestia task.
- Do not modify the Orchestia repository.
- Do not execute Codex on an external project now.
- Do not add sync, GUI, service, or package publishing behavior.

## Expected Steps

1. Print the current directory with `pwd`.
2. Verify this is the dedicated sample project workspace.
3. Verify the path is not under `/mnt/c`.
4. Check `git status --short`.
5. Review accepted foundation work.
6. Implement add, list, complete, and persistence behavior.
7. Run the test commands.
8. Summarize the diff and verification result.

## Test Commands

```bash
python3 -m compileall src tests
python3 -m unittest discover -s tests
python3 -m py_compile todo_cli.py
git diff --check
```

## Acceptance Criteria

- User can add todo items.
- User can list todo items.
- User can mark todo items complete.
- Todo items persist between runs.
- Invalid commands return clear errors.

## Execution Result

- Sample project path: `~/ai-workspaces/orchestia-samples/todo-cli`
- Baseline commit: `933cc67 Create todo CLI project foundation`
- Sample project commit: `1788bae Implement core todo CLI features`
- Files changed:
  - `src/todo_cli/__main__.py`
  - `todo_cli.py`
  - `tests/test_smoke.py`
  - `README.md`
- Features implemented:
  - add todo item
  - list todo items
  - mark todo item as done
  - JSON persistence
  - `--file` option
  - invalid ID handling
  - storage error handling
  - invalid command handling
- Checks passed:
  - `python3 -m compileall src tests`
  - `python3 -m unittest discover -s tests`: 7 tests
  - `python3 -m py_compile todo_cli.py`
  - `git diff --check`
  - manual smoke check with `./tmp-smoke-todos.json`
- Review decision: accept

## Watch Points

- This planned sample task must not run before TASK-0018 is accepted.
- Persistence format should remain simple and local.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not inspect `.env`, credential stores, token files, SSH keys, browser profiles, or cloud configuration.
- Do not use force push.
- Do not modify files outside the authorized sample workspace.
- Stop if repository or path checks fail.
