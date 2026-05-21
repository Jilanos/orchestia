# TASK-0020: Sample Todo CLI Add Validation And Docs

## Metadata

- ID: TASK-0020
- Status: Planned
- Request: [REQ-0004 Sample Todo CLI Validation And Docs](../requests/REQ-0004-sample-todo-cli-validation-docs.md)
- Backlog: [BL-0006 Sample Todo CLI Validation And Docs](../backlog/BL-0006-sample-todo-cli-validation-docs.md)
- Primary need: [PN-0003 Validation And Docs](../primary-needs/PN-0003-validation-and-docs.md)

## Objective

Define a planned sample task for adding validation checks and concise user documentation.

## Context

This is a planned sample task, not executed. It depends on foundation and core features being completed and accepted in a dedicated sample project workspace.

## Authorized Scope

- Future dedicated sample todo CLI project workspace only.
- Specific documentation and test files must be named before execution.

## Out Of Scope

- Do not implement code in this Orchestia task.
- Do not modify the Orchestia repository.
- Do not execute Codex on an external project now.
- Do not add CI or package publishing.

## Expected Steps

1. Print the current directory with `pwd`.
2. Verify this is the dedicated sample project workspace.
3. Verify the path is not under `/mnt/c`.
4. Check `git status --short`.
5. Review accepted foundation and core feature work.
6. Add validation checks and usage documentation.
7. Run the test commands.
8. Summarize the diff and verification result.

## Test Commands

```bash
# Planned only; exact command depends on selected runtime.
```

## Acceptance Criteria

- Verification command is documented and passes.
- Usage documentation explains add, list, and complete.
- Known limitations are documented.
- Review can compare implementation with IN-0001 success criteria.

## Watch Points

- This planned sample task must not run before TASK-0018 and TASK-0019 are accepted.
- Documentation must not claim unsupported behavior.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not inspect `.env`, credential stores, token files, SSH keys, browser profiles, or cloud configuration.
- Do not use force push.
- Do not modify files outside the authorized sample workspace.
- Stop if repository or path checks fail.
