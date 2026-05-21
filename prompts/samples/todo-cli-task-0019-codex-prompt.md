# Codex Prompt: TASK-0019 Sample Todo CLI Core Features

You are Codex executing the second sample task in the Orchestia v0.2 todo CLI scenario.

## Objective

Implement only the core todo CLI features in the existing sample project:

- add a todo item
- list todo items
- mark a todo item as done
- persist todo items locally in a simple file

## Context

The sample project foundation has already been completed and accepted.

- Sample workspace: `~/ai-workspaces/orchestia-samples/todo-cli`
- Baseline commit: `933cc67 Create todo CLI project foundation`
- Related task: `TASK-0019 Sample Todo CLI Implement Core Features`
- Related primary need: `PN-0002 Core Todo Features`

## Authorized Scope

You may create or modify files only inside:

```bash
~/ai-workspaces/orchestia-samples/todo-cli
```

You may create one local commit in the sample project after checks pass.

## Out Of Scope

- do not modify the Orchestia repository
- do not work under /mnt/c
- do not create a new project
- do not push
- do not read secrets
- do not install global dependencies
- do not implement validation/docs beyond what is needed for TASK-0019
- do not implement unrelated features
- do not add sync, GUI, background services, publishing, networking, or multi-user behavior
- do not merge, rebase, tag, force push, or delete unrelated files

## Expected Steps

1. Print the current directory with `pwd`.
2. Verify the path is `~/ai-workspaces/orchestia-samples/todo-cli`.
3. Verify the path is not under `/mnt/c`.
4. Check `git status --short` and stop if the workspace is dirty.
5. Confirm the baseline includes commit `933cc67 Create todo CLI project foundation`.
6. Review the existing project structure.
7. Preserve the existing project structure unless a small change is clearly justified.
8. Implement minimal core commands:
   - `python3 -m todo_cli add "Buy milk"`
   - `python3 -m todo_cli list`
   - `python3 -m todo_cli done 1`
9. Use Python standard library only.
10. Use a simple JSON file for persistence.
11. Prefer local default storage at `./todos.json`.
12. Allow an optional `--file` path only if it stays simple and is tested.
13. Keep storage local to the project or a user-provided path.
14. Add or update tests for add, list, done, persistence, and invalid input.
15. Update README usage instructions if needed.
16. Run the required checks and smoke checks.
17. Review `git status --short` and `git diff --stat`.
18. Create one local commit if checks pass.
19. Do not push.

## Test Commands

Run these commands:

```bash
python3 -m compileall src tests
python3 -m unittest discover -s tests
```

Also run a manual smoke check using a temporary todo file so it does not rely on persistent state from previous runs:

```bash
python3 -m todo_cli --help
python3 -m todo_cli --file ./tmp-smoke-todos.json add "Buy milk"
python3 -m todo_cli --file ./tmp-smoke-todos.json list
python3 -m todo_cli --file ./tmp-smoke-todos.json done 1
python3 -m todo_cli --file ./tmp-smoke-todos.json list
```

If the smoke check creates a temporary file, remove it only if the file is clearly a temporary file created by this smoke check. Do not delete unrelated files.

## Acceptance Criteria

- User can add a todo item.
- User can list todo items.
- User can mark a todo item as done.
- Todo items persist between runs in a simple JSON file.
- Invalid commands or invalid IDs return clear errors.
- Tests cover the core behavior.
- Required checks pass.
- README usage instructions are updated if needed.
- One local commit is created in the sample project.
- No push is performed.
- No Orchestia repository files are modified.

## Watch Points

- Keep the implementation minimal.
- Do not implement features outside add, list, done, and local persistence.
- Do not write to arbitrary user directories by default.
- Do not install dependencies.
- Stop if the sample workspace is dirty before the task starts.
- Stop if a destructive command appears necessary.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not inspect `.env`, credential stores, token files, SSH keys, browser profiles, or cloud configuration.
- Do not install global dependencies.
- Do not push, merge, rebase, tag, force push, or delete unrelated files.
- Do not modify files outside `~/ai-workspaces/orchestia-samples/todo-cli`.

## Expected Output

1. Files changed in the sample project.
2. Commands run and results.
3. Manual smoke check result.
4. Diff summary.
5. Local commit hash, if committed.
6. Remaining risks or next task.
