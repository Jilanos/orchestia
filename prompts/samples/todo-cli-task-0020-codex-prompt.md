# Codex Prompt: TASK-0020 Sample Todo CLI Validation And Docs

You are Codex executing the third sample task in the Orchestia v0.2 todo CLI scenario.

## Objective

Improve validation and documentation for the existing sample todo CLI, without adding unrelated features.

## Context

The sample project foundation and core todo features have already been completed and accepted.

- Sample workspace: `~/ai-workspaces/orchestia-samples/todo-cli`
- Baseline commit: `1788bae Implement core todo CLI features`
- Related task: `TASK-0020 Sample Todo CLI Add Validation And Docs`
- Related primary need: `PN-0003 Validation And Docs`

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
- do not implement new core todo features unless needed to fix a validation issue
- do not add delete, edit, priority, due dates, categories, configuration files, packaging metadata, or remote sync
- do not merge, rebase, tag, force push, or delete unrelated files

## Expected Steps

1. Print the current directory with `pwd`.
2. Verify the path is `~/ai-workspaces/orchestia-samples/todo-cli`.
3. Verify the path is not under `/mnt/c`.
4. Check `git status --short` and stop if the workspace is dirty.
5. Confirm the baseline includes commit `1788bae Implement core todo CLI features`.
6. Review existing CLI behavior, tests, and README.
7. Preserve the existing project structure unless a small change is clearly justified.
8. Improve validation and documentation only:
   - improve README usage examples
   - document storage behavior
   - document `--file` usage
   - document known limitations
   - ensure help output is useful
   - add or improve tests where appropriate
   - add a lightweight validation checklist or usage section if useful
   - clarify the minimal `todo_cli.py` wrapper risk if needed
9. Keep the implementation minimal.
10. Run the required checks and a manual smoke check.
11. Review `git status --short` and `git diff --stat`.
12. Create one local commit if checks pass.
13. Do not push.

## Required Checks

Run these commands:

```bash
python3 -m compileall src tests
python3 -m unittest discover -s tests
python3 -m py_compile todo_cli.py
git diff --check
```

Also run a manual smoke check using a temporary JSON file so it does not rely on persistent state from previous runs:

```bash
python3 -m todo_cli --help
python3 -m todo_cli --file ./tmp-smoke-todos.json add "Buy milk"
python3 -m todo_cli --file ./tmp-smoke-todos.json list
python3 -m todo_cli --file ./tmp-smoke-todos.json done 1
python3 -m todo_cli --file ./tmp-smoke-todos.json list
```

If the smoke check creates `./tmp-smoke-todos.json`, remove only that temporary file after the check. Do not delete unrelated files.

## Acceptance Criteria

- README explains add, list, done, and `--file` usage clearly.
- Storage behavior is documented.
- Known limitations are documented.
- Help output remains useful.
- Tests are added or improved where appropriate.
- Required checks pass.
- Manual smoke check passes with a temporary JSON file.
- One local commit is created in the sample project.
- No push is performed.
- No Orchestia repository files are modified.
- No unrelated features are added.

## Watch Points

- Keep this task focused on validation and documentation.
- Do not expand beyond validation and documentation.
- Do not add packaging metadata unless explicitly authorized by a later task.
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
