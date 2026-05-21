# TASK-0019: Sample Todo CLI Implement Core Features

## Metadata

- ID: TASK-0019
- Status: Planned
- Request: [REQ-0003 Sample Todo CLI Core Features](../requests/REQ-0003-sample-todo-cli-core-features.md)
- Backlog: [BL-0005 Sample Todo CLI Core Features](../backlog/BL-0005-sample-todo-cli-core-features.md)
- Primary need: [PN-0002 Core Todo Features](../primary-needs/PN-0002-core-todo-features.md)

## Objective

Define a planned sample task for implementing add, list, complete, and local persistence behavior.

## Context

This is a planned sample task, not executed. It depends on the foundation task being completed and accepted in a dedicated sample project workspace.

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
# Planned only; exact command depends on selected runtime.
```

## Acceptance Criteria

- User can add todo items.
- User can list todo items.
- User can mark todo items complete.
- Todo items persist between runs.
- Invalid commands return clear errors.

## Watch Points

- This planned sample task must not run before TASK-0018 is accepted.
- Persistence format should remain simple and local.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not inspect `.env`, credential stores, token files, SSH keys, browser profiles, or cloud configuration.
- Do not use force push.
- Do not modify files outside the authorized sample workspace.
- Stop if repository or path checks fail.
