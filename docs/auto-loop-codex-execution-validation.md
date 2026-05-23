# Auto-loop Codex Execution Validation

## Purpose

Validate real `codex exec` execution through `scripts/orchestia_loop.sh auto-loop` on a disposable workspace under `task-runs/`.

## Scope

This validation used only:

- Disposable workspace: `task-runs/auto-loop-codex-disposable-workspace/`
- Disposable Loop state: `task-runs/auto-loop-codex-disposable-loop-state.md`
- Disposable prepared prompt: `task-runs/auto-loop-codex-disposable-prompt.md`
- Auto-loop evidence: `task-runs/20260523T202633Z-auto-loop/`

No Codex execution was run against Orchestia itself or the sample todo CLI project.

## Commands Run

```bash
pwd
git branch --show-current
git status --short
codex --version
codex exec --help
git init
git add README.md hello.txt
git commit -m "Disposable baseline"
bash scripts/orchestia_loop.sh auto-loop \
  task-runs/auto-loop-codex-disposable-loop-state.md \
  --workspace task-runs/auto-loop-codex-disposable-workspace \
  --max-steps 1 \
  --execute-codex \
  --test "test -f validation.txt"
```

## Disposable Workspace Details

Baseline commit:

```text
e3c1cda Disposable baseline
```

Baseline files:

- `README.md`
- `hello.txt`

The prepared prompt instructed Codex to update `hello.txt` and create `validation.txt` without committing, pushing, merging, rebasing, tagging, installing dependencies, or reading secrets.

## Result

Validation was blocked.

`codex exec` was invoked by auto-loop and output was captured, but the Codex session ran with `sandbox: read-only` and approval `never`. Codex attempted the expected minimal patch, but the write was rejected by the read-only sandbox.

Observed result:

- Codex version: `codex-cli 0.133.0`
- Auto-loop run directory: `task-runs/20260523T202633Z-auto-loop/`
- Codex exit code: `0`
- Test command: `test -f validation.txt`
- Test exit code: `1`
- Workspace status before execution: clean
- Workspace status after execution: clean
- Workspace diff stat after execution: empty
- `validation.txt`: not created
- Decision: pending
- Loop state advancement: not performed

## Evidence Files

Key evidence files:

- `task-runs/20260523T202633Z-auto-loop/codex-command.txt`
- `task-runs/20260523T202633Z-auto-loop/codex-stdout.txt`
- `task-runs/20260523T202633Z-auto-loop/codex-stderr.txt`
- `task-runs/20260523T202633Z-auto-loop/codex-exit-code.txt`
- `task-runs/20260523T202633Z-auto-loop/workspace-status-before.txt`
- `task-runs/20260523T202633Z-auto-loop/workspace-status-after.txt`
- `task-runs/20260523T202633Z-auto-loop/workspace-diff-stat-after.txt`
- `task-runs/20260523T202633Z-auto-loop/test-command.txt`
- `task-runs/20260523T202633Z-auto-loop/test-exit-code.txt`
- `task-runs/20260523T202633Z-auto-loop/review-draft.md`
- `task-runs/20260523T202633Z-auto-loop/errors.md`

## What Passed

- Disposable workspace was created under `task-runs/`.
- Disposable Loop state and prepared prompt were created under `task-runs/`.
- Auto-loop invoked `codex exec` against the disposable workspace.
- Auto-loop captured Codex stdout, stderr, exit code, workspace status before and after, diff stat, recent commits, test command, test exit code, and a review draft.
- Decision remained pending.
- Loop state was not advanced.
- No controlled Git flow execute path was used.
- No push or merge was performed.

## What Failed Or Was Not Tested

- The requested file change did not happen because the Codex session used a read-only sandbox.
- `validation.txt` was not created.
- The post-execution test failed with exit code `1`.
- Successful write execution through auto-loop remains unvalidated.

## Safety Observations

- The disposable workspace remained clean because no writes succeeded.
- No files under `/mnt/c` were modified.
- No Codex execution occurred against Orchestia or the sample todo CLI.
- No secrets or environment variables were printed.
- The blocked result was captured as evidence rather than bypassed.

## Remaining Risks

- `scripts/orchestia_loop.sh` currently invokes `codex exec` without forcing a writable sandbox mode for the target workspace.
- A future validation needs an explicit, policy-approved way to run `codex exec` with workspace write access only for the disposable target workspace.
- Codex exit code `0` did not mean the task succeeded; the post-execution test caught the failure.

## Next Recommended Task

Revise auto-loop Codex execution to pass an explicit safe sandbox mode for disposable or authorized workspaces, then rerun this validation.

## Follow-up Validation: Workspace-write Sandbox Fix

The previous blocker was addressed by updating auto-loop Codex execution to invoke:

```bash
codex exec --sandbox workspace-write
```

The default auto-loop mode remains dry-run. The writable sandbox is used only when `--execute-codex` or `--execute-all` is explicitly provided, after the target workspace has been verified and confirmed clean.

Follow-up disposable validation used:

- Disposable workspace: `task-runs/auto-loop-codex-sandbox-validation-workspace/`
- Disposable Loop state: `task-runs/auto-loop-codex-sandbox-validation-loop-state.md`
- Disposable prepared prompt: `task-runs/auto-loop-codex-sandbox-validation-prompt.md`
- Auto-loop evidence: `task-runs/20260523T205548Z-auto-loop/`

Command:

```bash
bash scripts/orchestia_loop.sh auto-loop \
  task-runs/auto-loop-codex-sandbox-validation-loop-state.md \
  --workspace task-runs/auto-loop-codex-sandbox-validation-workspace \
  --max-steps 1 \
  --execute-codex \
  --test "test -f validation.txt"
```

Follow-up result:

- Codex command: `codex exec --sandbox workspace-write`
- Codex sandbox mode: `workspace-write`
- Codex exit code: `0`
- Test exit code: `0`
- `hello.txt` was updated with `Codex workspace-write execution validated.`
- `validation.txt` was created with `validation passed`
- Workspace status before execution: clean
- Workspace status after execution: modified files pending review
- Diff stat after execution: captured
- Review draft: created
- Decision: pending
- Loop state advancement: not performed

Evidence files:

- `task-runs/20260523T205548Z-auto-loop/codex-command.txt`
- `task-runs/20260523T205548Z-auto-loop/codex-stdout.txt`
- `task-runs/20260523T205548Z-auto-loop/codex-stderr.txt`
- `task-runs/20260523T205548Z-auto-loop/codex-exit-code.txt`
- `task-runs/20260523T205548Z-auto-loop/codex-sandbox-mode.txt`
- `task-runs/20260523T205548Z-auto-loop/workspace-status-before.txt`
- `task-runs/20260523T205548Z-auto-loop/workspace-status-after.txt`
- `task-runs/20260523T205548Z-auto-loop/workspace-diff-stat-after.txt`
- `task-runs/20260523T205548Z-auto-loop/test-exit-code.txt`
- `task-runs/20260523T205548Z-auto-loop/review-draft.md`

Safety observations:

- No Codex execution occurred against Orchestia or the sample todo CLI.
- No controlled Git flow execute path was used.
- No push, merge, rebase, tag, or force push occurred.
- No files under `/mnt/c` were modified.

Remaining risks:

- Workspace-write execution is intentionally powerful within the verified target workspace and must remain gated by explicit `--execute-codex` or `--execute-all`.
- Post-execution checks remain necessary because Codex exit code alone is not sufficient to prove task success.
