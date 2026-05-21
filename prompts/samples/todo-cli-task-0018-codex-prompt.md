# Codex Prompt: TASK-0018 Sample Todo CLI Project Foundation

You are Codex preparing the first executable sample task for the Orchestia v0.2 todo CLI scenario.

## Objective

Create only the project foundation for a small local todo CLI in a dedicated sample workspace.

## Context

This task executes the planned sample task `TASK-0018` from the Orchestia sample Logics chain:

- Initial need: `IN-0001 Sample Todo CLI`
- Primary need: `PN-0001 Project Foundation`
- Request: `REQ-0002 Sample Todo CLI Foundation`
- Backlog item: `BL-0004 Sample Todo CLI Foundation`
- Task: `TASK-0018 Sample Todo CLI Create Project Foundation`

The sample project workspace is:

```bash
~/ai-workspaces/orchestia-samples/todo-cli
```

## Authorized Scope

You may create or modify files only inside:

```bash
~/ai-workspaces/orchestia-samples/todo-cli
```

You may initialize a new Git repository in that directory and create one local initial commit.

## Out Of Scope

- do not modify the Orchestia repository
- do not work under /mnt/c
- do not implement the full todo feature set yet
- do not push unless explicitly authorized in the prompt
- do not read secrets
- do not install global dependencies
- do not modify files outside the sample workspace
- do not merge, rebase, tag, force push, or delete unrelated files

## Expected Steps

1. Print the current directory with `pwd`.
2. Verify the target path is not under `/mnt/c`.
3. Create `~/ai-workspaces/orchestia-samples/todo-cli` if it does not exist.
4. Stop if the target directory already contains unrelated files.
5. Enter the target directory.
6. Initialize Git if needed.
7. Choose a simple implementation language with minimal dependency risk.
8. Create `README.md`.
9. Create a minimal project structure.
10. Add a minimal CLI entry point.
11. Add a minimal test or syntax check.
12. Document commands to run.
13. Run the verification commands.
14. Show `git status --short` and `git diff --stat`.
15. Create one local initial commit if verification passes.
16. Do not push.

## Test Commands

Choose exact commands that match the selected runtime and keep them dependency-light. Prefer tools already available locally.

## Acceptance Criteria

- The sample project exists at `~/ai-workspaces/orchestia-samples/todo-cli`.
- The sample project has its own Git repository.
- `README.md` documents the project foundation and commands.
- A minimal CLI entry point exists.
- A minimal test or syntax check exists and passes.
- One local initial commit exists in the sample project.
- The full todo feature set is not implemented yet.
- No Orchestia repository files are modified.
- No push is performed.

## Watch Points

- Stop if the current path or target path is under `/mnt/c`.
- Stop if the target directory contains unrelated files.
- Stop if runtime choice requires global dependency installation.
- Stop if secrets, credentials, `.env` files, or tokens are requested.
- Stop if a destructive command is needed.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not inspect `.env`, credential stores, token files, SSH keys, browser profiles, or cloud configuration.
- Do not install global dependencies.
- Do not push, merge, rebase, tag, force push, or delete unrelated files.
- Keep the implementation minimal and bounded to project foundation only.

## Expected Output

1. Files created or changed in the sample project.
2. Runtime choice and why it is low-risk.
3. Verification commands run and results.
4. Local commit hash, if committed.
5. Remaining risks or next task.
