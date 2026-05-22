# TASK-0030: Validate Controlled Git Flow

## Metadata

- ID: TASK-0030
- Status: Blocked
- Related script: `scripts/controlled_git_flow.sh`
- Review: [REVIEW-0026 Controlled Git Flow Validation](../reviews/REVIEW-0026-controlled-git-flow-validation.md)

## Objective

Validate controlled auto-push and controlled auto-merge on a dedicated sample GitHub repository, not on Orchestia.

## Context

The intended validation target was the local sample todo CLI repository at `~/ai-workspaces/orchestia-samples/todo-cli`, with a dedicated GitHub repository named `orchestia-sample-todo-cli`.

## Authorized Scope

- `docs/controlled-git-flow-validation.md`
- `docs/mvp-roadmap.md`
- `logics/tasks/TASK-0030-validate-controlled-git-flow.md`
- `logics/reviews/REVIEW-0026-controlled-git-flow-validation.md`

## Steps Performed

1. Verified the Orchestia repository path.
2. Verified Orchestia was on `master`.
3. Verified the Orchestia working tree was clean.
4. Verified `scripts/controlled_git_flow.sh` exists and is executable.
5. Verified the sample todo CLI workspace exists and is clean.
6. Checked the sample todo CLI branch, recent commits, and remotes.
7. Checked `gh --version`.
8. Checked `gh auth status`.
9. Stopped because `gh auth status` reported an invalid active account token.

## Validation Commands

```bash
pwd
git branch --show-current
git status --short
test -x scripts/controlled_git_flow.sh
cd ~/ai-workspaces/orchestia-samples/todo-cli
git status --short
git branch --show-current
git log --oneline --decorate --max-count=5
git remote -v
cd ~/ai-workspaces/orchestia
gh --version
gh auth status
```

## Acceptance Criteria

- Dedicated GitHub sample repository is used.
- Controlled auto-push dry-run and execute are validated.
- Controlled auto-merge dry-run and execute are validated.
- `main` and `master` are not targeted.
- No force push or branch deletion is used.
- Evidence is documented in Orchestia.

## Result

Blocked before repository creation or controlled Git flow execution.

`gh auth status` reported:

```text
The token in /home/pmondou/.config/gh/hosts.yml is invalid.
```

No sample remote was configured, no push occurred, no merge occurred, and no sample project files were modified.

## Next Step

Resolve the GitHub CLI authentication inconsistency and rerun this validation.
