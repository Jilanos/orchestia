# TASK-XXXX: Title

## Metadata

- ID: TASK-XXXX
- Status: Proposed
- Request: [REQ-XXXX Title](../requests/REQ-XXXX-title.md)
- Backlog: [BL-XXXX Title](../backlog/BL-XXXX-title.md)
- Review: [REVIEW-XXXX Title](../reviews/REVIEW-XXXX-title.md)

## Objective

State the concrete outcome of this task.

## Context

Provide only the background needed to execute safely.

## Authorized Scope

- List exact files or directories that may be created or modified.

## Out Of Scope

- List forbidden files, directories, commands, and project areas.
- Do not expand scope during execution.

## Expected Steps

1. Print the current directory with `pwd`.
2. Verify this is the expected repository.
3. Verify the path is not under `/mnt/c`.
4. Check `git status --short`.
5. Read only the files needed for this task.
6. Make the smallest useful change.
7. Run the test commands.
8. Summarize the diff and verification result.

## Test Commands

```bash
# Add exact commands here.
```

## Acceptance Criteria

- State observable conditions that must be true when the task is done.

## Watch Points

- List likely mistakes, edge cases, or scope risks.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not inspect `.env`, credential stores, token files, SSH keys, browser profiles, or cloud configuration unless explicitly authorized with an exact path.
- Do not push, merge, rebase, force, delete, or run destructive commands unless explicitly authorized.
- Do not modify files outside the authorized scope.
- Stop if the repository or path check fails.

## Result Summary

- Files changed:
- Verification run:
- Diff summary:
- Remaining risks:
