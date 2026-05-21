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
- Do not push, merge, rebase, tag, or publish releases unless the execution mode explicitly allows it.
- Do not use force push.
- Review diffs before committing.

## Execution Modes

### Manual mode

- Codex proposes changes.
- A human reviews, commits, pushes, and merges.

### Assisted mode

- Codex may prepare changes and commit locally when the task explicitly allows it.
- A human still pushes and merges.

### Auto branch mode

- Codex may create or use an isolated working branch.
- Codex may commit and push to that branch after required checks pass.
- The branch must not be `main` or `master` unless explicitly authorized; main or master are protected by default.
- This mode is intended for fresh projects or isolated branches.

### Controlled auto merge mode

- Codex may merge only into an explicitly authorized target branch.
- The target branch must be declared for the project or task.
- `main` and `master` are protected by default; main or master require explicit override for auto merge.
- Auto merge into `main` or `master` requires an explicit override.

## Auto Push And Auto Merge Guardrails

Auto push and auto merge are allowed only when all conditions are true:

- The work is on a fresh project or isolated branch.
- The current branch is not `main` or `master` unless explicitly authorized; main or master are protected by default.
- The target branch is explicitly declared.
- The working tree was clean before the task started.
- Modified files stay within the authorized task scope.
- Required checks pass.
- `git diff --stat` is reviewed or included in the task result.
- No secrets, `.env` files, credentials, or tokens are included in the diff.
- No force push is used.
- No destructive cleanup is performed.
- The automation produces a review record.

## Auto Push Guardrails

- Auto push is allowed only in Auto branch mode or Controlled auto merge mode preparation.
- The pushed branch must be isolated from protected branches unless explicitly overridden.
- The push must use normal Git push, never force push.
- The task result must include branch name, remote name, checks run, and `git diff --stat`.

## Auto Merge Guardrails

- Auto merge is allowed only in Controlled auto merge mode.
- The target branch must be explicitly declared before execution.
- `main` and `master` are protected by default.
- Auto merge into main or master requires explicit override.
- The merge must stop if required checks fail, secrets appear in the diff, or out-of-scope files changed.

## Forbidden By Default

- Force push.
- Deleting branches without explicit instruction.
- Pushing directly to `main` or `master` without explicit override.
- Merging into `main` or `master` without explicit override.
- Bypassing failed tests.
- Merging with out-of-scope file changes.
- Merging when secrets appear in the diff.
- Modifying files outside the repository.
- Modifying personal Windows files.

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
