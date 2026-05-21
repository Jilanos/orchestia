# Security Boundaries

## WSL Is Not a Strong Sandbox

WSL is useful for Linux-compatible tooling, but it is not a strong isolation boundary. Commands can still affect files and processes available to the current user.

## Avoid `/mnt/c` by Default

Do not work under `/mnt/c` unless a human explicitly approves that path. Prefer a Linux filesystem location for active repositories when using WSL.

## Secret Handling

- Do not read or display secrets.
- Do not inspect token files, SSH keys, credential stores, browser profiles, or `.env` files without explicit instruction.
- Do not commit secrets.
- If credentials are needed, ask the human to perform the sensitive action.

## Forbidden Commands

Do not run destructive or high-risk commands unless a human explicitly names the target and confirms intent:

- `rm -rf`
- `git reset --hard`
- `git clean -fd`
- force pushes
- recursive permission changes
- disk formatting, mounting, or partitioning commands
- commands that print environment secrets

## Git Policy

- Git status must be checked before commits.
- Push, merge, rebase, tag, and release operations require explicit human instruction.
- Force push is forbidden by default.
- The remote repository must match the intended project before pushing.

## File Scope Rules

- Stay inside the authorized repository.
- Modify only paths named or implied by the task.
- Do not edit sibling repositories.
- Do not delete files unless deletion is explicitly requested.

## Human Execution Rules

- Humans approve objectives and scope.
- Agents execute bounded tasks.
- Humans review diffs before expanding scope.
- Ambiguous tasks should be clarified or split.
