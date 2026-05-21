# Codex Task Prompt

Use this template to give Codex CLI one bounded execution task.

## Prompt

You are Codex working in the Orchestia repository. Complete only the task below.

## Mandatory Task Format

### Objective

State the concrete outcome.

### Context

Provide only the background needed to execute safely.

### Authorized scope

List the exact files or directories Codex may create or modify.

### Out of scope

List forbidden files, directories, commands, and project areas.

### Expected steps

1. Print the current directory with `pwd`.
2. Verify this is the expected repository.
3. Verify the path is not under `/mnt/c`.
4. Check `git status --short`.
5. Read only the files needed for the task.
6. Make the smallest useful change.
7. Run the test commands.
8. Summarize the diff and verification result.

### Test commands

List exact commands to run.

### Acceptance criteria

List observable conditions that must be true when the task is done.

### Watch points

List likely mistakes, edge cases, or scope risks.

### Security rules

- Do not read, print, summarize, or log secrets.
- Do not inspect `.env`, credential stores, token files, SSH keys, browser profiles, or cloud configuration unless explicitly authorized with an exact path.
- Do not push, merge, rebase, force, delete, or run destructive commands unless explicitly authorized.
- Do not modify files outside the authorized scope.
- Stop if the repository or path check fails.

## Expected Output

1. Files changed.
2. Verification commands run and results.
3. Diff summary.
4. Remaining risks or follow-up tasks.
