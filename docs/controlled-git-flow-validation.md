# Controlled Git Flow Validation

## Purpose

Document validation of `scripts/controlled_git_flow.sh` against a dedicated sample GitHub repository after manual remote setup.

## Scope

The validation target was the sample todo CLI repository at:

```text
~/ai-workspaces/orchestia-samples/todo-cli
```

The dedicated sample GitHub repository was:

```text
https://github.com/Jilanos/orchestia-sample-todo-cli
```

The Orchestia repository was not used as the controlled Git flow target.

## Manual GitHub Setup Note

Repository creation and remote setup were handled manually from the WSL shell because Codex could not reliably access the GitHub API through `gh` in this environment.

For this validation, Codex did not use `gh`, did not create a repository, and did not modify the Orchestia remote.

## Branches

- Baseline branch: `master`
- Target branch: `integration`
- Isolated feature branch: `feature/controlled-git-flow-validation`
- Feature validation commit: `fe4a51c Validate controlled git flow`
- Integration merge commit: `f7a0574 Merge branch 'feature/controlled-git-flow-validation' into integration`

`main` and `master` were not targeted by controlled auto-merge.

## Commands Run

From the sample repository:

```bash
git status --short
git branch --show-current
git remote -v
git add README.md
git commit -m "Validate controlled git flow"
```

From the Orchestia repository:

```bash
bash scripts/controlled_git_flow.sh status \
  --workspace ~/ai-workspaces/orchestia-samples/todo-cli

bash scripts/controlled_git_flow.sh auto-push \
  --workspace ~/ai-workspaces/orchestia-samples/todo-cli \
  --remote origin \
  --branch feature/controlled-git-flow-validation \
  --test "python3 -m unittest discover -s tests"

bash scripts/controlled_git_flow.sh auto-push \
  --workspace ~/ai-workspaces/orchestia-samples/todo-cli \
  --remote origin \
  --branch feature/controlled-git-flow-validation \
  --test "python3 -m unittest discover -s tests" \
  --execute

bash scripts/controlled_git_flow.sh auto-merge \
  --workspace ~/ai-workspaces/orchestia-samples/todo-cli \
  --remote origin \
  --source-branch feature/controlled-git-flow-validation \
  --target-branch integration \
  --test "python3 -m unittest discover -s tests"

bash scripts/controlled_git_flow.sh auto-merge \
  --workspace ~/ai-workspaces/orchestia-samples/todo-cli \
  --remote origin \
  --source-branch feature/controlled-git-flow-validation \
  --target-branch integration \
  --test "python3 -m unittest discover -s tests" \
  --execute
```

## Results

- `status` completed in dry-run mode.
- `auto-push` dry-run completed and printed the intended push command.
- `auto-push --execute` pushed `feature/controlled-git-flow-validation` to `origin`.
- `auto-merge` dry-run completed and printed the intended checkout, merge, and push commands.
- `auto-merge --execute` merged `feature/controlled-git-flow-validation` into `integration` using `--no-ff`.
- `auto-merge --execute` pushed `integration` to `origin`.
- The test command `python3 -m unittest discover -s tests` passed before controlled push and controlled merge.
- The test command passed again after the merge before pushing `integration`.
- No force push was used.
- No branch deletion was used.
- No rebase or tag was used.
- No merge into `main` or `master` occurred.

## Evidence Directories

- `task-runs/20260522T074301Z-controlled-git-flow-2/`
- `task-runs/20260522T074306Z-controlled-git-flow-2/`
- `task-runs/20260522T074324Z-controlled-git-flow-71994/`
- `task-runs/20260522T074332Z-controlled-git-flow-72059/`
- `task-runs/20260522T074336Z-controlled-git-flow-72101/`

An earlier execute attempt failed in the sandbox before the escalated network run:

- `task-runs/20260522T074310Z-controlled-git-flow-2/`

That failed attempt did not push anything because the sandbox could not resolve `github.com`.

## Safety Guardrails Observed

- The sample repository was used as the target, not Orchestia.
- The workspace was outside `/mnt/c`.
- The feature branch was isolated.
- The target branch was `integration`, not `main` or `master`.
- The script defaulted to dry-run.
- `--execute` was required before push or merge.
- Tests passed before each execute action.
- The sample project was clean before controlled push and controlled merge.
- Evidence reports were written under Orchestia `task-runs/`.

## What Passed

- Dedicated sample remote validation.
- Controlled auto-push dry-run.
- Controlled auto-push execute.
- Controlled auto-merge dry-run.
- Controlled auto-merge execute.
- Evidence report creation.
- Final sample repository clean status.

## What Failed Or Was Not Tested

Failed:

- The first sandboxed `auto-push --execute` attempt could not resolve `github.com`. The same script command succeeded after running with network access.

Not tested:

- Merge into protected `main` or `master`.
- Protected branch override flags.
- Failed-test blocking behavior during execute mode.

## Remaining Risks

- The validation covered one happy path on a small sample repository.
- Protected branch override behavior still needs a separate negative test.
- Failed-test blocking should be validated with an intentional failing command in a disposable branch.
- GitHub CLI repository creation remains outside Codex in this environment.

## Next Recommended Step

Add focused negative-path validation for controlled Git flow guardrails, including protected target refusal and failed-test refusal.
