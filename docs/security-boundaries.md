# Security Boundaries

## WSL Is Not a Strong Sandbox

WSL is the preferred execution environment for Orchestia, but it is not a strong sandbox. Commands can affect files and processes available to the current user.

## Workspace Location

Do not work under `/mnt/c` by default. Keep active repositories under the WSL Linux filesystem unless a human explicitly approves a mounted Windows path.

## Secrets

- Do not read, print, copy, summarize, or log secrets.
- Do not inspect `.env`, `.env.*`, token files, SSH keys, credential stores, browser profiles, or cloud configuration files unless explicitly authorized with an exact path.
- Do not commit secrets.
- If a task appears to require credentials, stop and ask for a safer human handoff.

## Git Safety

- Check `git status --short` before making or reviewing changes.
- Treat Git as the source of truth for project state.
- Do not push, merge, rebase, tag, or publish releases unless explicitly instructed.
- Do not force push.
- Review diffs before committing.

## Destructive Actions

Do not run destructive commands unless a human explicitly authorizes the exact action and target.

Examples include:

- `rm`, especially recursive deletion.
- `git reset --hard`.
- `git clean`.
- Recursive permission or ownership changes.
- Disk formatting, mounting, or partitioning commands.
- Commands that expose environment variables or credentials.

## Dependency Installation

Do not install global dependencies unless the task justifies it and the human explicitly approves. Prefer existing local tools and minimal scripts.

## Codex Task Boundaries

- Give Codex CLI one bounded task at a time.
- State authorized scope and out-of-scope paths explicitly.
- Keep changes small, reviewable, and tied to a written task.
- Stop if the repository or path does not match the expected scope.
- Do not expand a task during execution; create a follow-up task instead.
