# TASK-0018: Sample Todo CLI Create Project Foundation

## Metadata

- ID: TASK-0018
- Status: Planned
- Request: [REQ-0002 Sample Todo CLI Foundation](../requests/REQ-0002-sample-todo-cli-foundation.md)
- Backlog: [BL-0004 Sample Todo CLI Foundation](../backlog/BL-0004-sample-todo-cli-foundation.md)
- Primary need: [PN-0001 Project Foundation](../primary-needs/PN-0001-project-foundation.md)

## Objective

Define a planned sample task for creating the todo CLI project foundation in a dedicated sample project workspace.

## Context

This is a planned sample task, not executed. It exists to show how PN-0001 would become an executable Codex task in a future dedicated sample workspace.

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
# Planned only; exact command depends on selected runtime.
```

## Acceptance Criteria

- Project structure exists in the dedicated sample workspace.
- CLI placeholder can run.
- Runtime and verification command are documented.
- No Orchestia repository files are modified during future execution.

## Watch Points

- This planned sample task must not be executed in the Orchestia repository.
- Runtime choice may be a firm blocker if unclear.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not inspect `.env`, credential stores, token files, SSH keys, browser profiles, or cloud configuration.
- Do not use force push.
- Do not modify files outside the authorized sample workspace.
- Stop if repository or path checks fail.
