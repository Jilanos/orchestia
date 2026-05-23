# Auto-loop Sample Execution Validation

## Purpose

Validate real `codex exec` execution through `scripts/orchestia_loop.sh auto-loop` against the sample todo CLI project on an isolated local branch.

## Scope

- Orchestia repository: `/home/pmondou/ai-workspaces/orchestia`
- Sample workspace: `/home/pmondou/ai-workspaces/orchestia-samples/todo-cli`
- Sample branch: `feature/auto-loop-sample-validation`
- Baseline commit before validation: `f7a0574`
- Sample validation commit: `da28859`
- Temporary Loop state: `task-runs/auto-loop-sample-validation-loop-state.md`
- Temporary prepared prompt: `task-runs/auto-loop-sample-validation-prompt.md`
- Auto-loop evidence: `task-runs/20260523T212102Z-auto-loop/`

The sample branch was not pushed and was not merged.

## Commands Run

```bash
git -C /home/pmondou/ai-workspaces/orchestia-samples/todo-cli switch -c feature/auto-loop-sample-validation

bash scripts/orchestia_loop.sh auto-loop \
  task-runs/auto-loop-sample-validation-loop-state.md \
  --workspace /home/pmondou/ai-workspaces/orchestia-samples/todo-cli \
  --max-steps 1 \
  --execute-codex \
  --test "python3 -m unittest discover -s tests"

cd /home/pmondou/ai-workspaces/orchestia-samples/todo-cli
grep -R "This README note was added by Orchestia auto-loop validation." README.md
python3 -m compileall src tests
python3 -m unittest discover -s tests
python3 -m py_compile todo_cli.py
git diff --check
git add README.md
git commit -m "Validate auto-loop sample execution"
```

## Result

Validation succeeded.

- `codex exec` ran through auto-loop with sandbox mode `workspace-write`.
- Codex exit code: `0`.
- Auto-loop test command exit code: `0`.
- `README.md` was the only changed sample file.
- The README contains: `This README note was added by Orchestia auto-loop validation.`
- Source files under `src/`, tests under `tests/`, and `todo_cli.py` were not changed.
- Full sample checks passed after execution.
- Auto-loop created `review-draft.md`.
- Decision remained `pending`.
- Loop state was not advanced.

## Evidence Files

- `task-runs/20260523T212102Z-auto-loop/codex-command.txt`
- `task-runs/20260523T212102Z-auto-loop/codex-exit-code.txt`
- `task-runs/20260523T212102Z-auto-loop/test-exit-code.txt`
- `task-runs/20260523T212102Z-auto-loop/workspace-status-before.txt`
- `task-runs/20260523T212102Z-auto-loop/workspace-status-after.txt`
- `task-runs/20260523T212102Z-auto-loop/workspace-diff-stat-after.txt`
- `task-runs/20260523T212102Z-auto-loop/review-draft.md`

The recorded Codex command was:

```bash
cd /home/pmondou/ai-workspaces/orchestia-samples/todo-cli && codex exec --sandbox workspace-write - < /home/pmondou/ai-workspaces/orchestia/task-runs/20260523T212102Z-auto-loop/codex-prompt.md
```

## What Passed

- Dedicated sample branch was used.
- Auto-loop executed Codex only after explicit `--execute-codex`.
- Codex used `workspace-write`, not `danger-full-access`.
- README-only change was produced.
- Local tests passed: `11` tests.
- Additional syntax checks passed.
- Sample change was committed locally on the feature branch.
- No controlled Git flow execute path was used.
- No sample push or merge was performed.

## What Was Not Tested

- Loop state advancement with `--advance`.
- Human decision finalization.
- Controlled Git push or merge after the sample auto-loop run.
- Multi-step auto-loop execution.

## Safety Observations

The validation confirmed that executable auto-loop can operate against a real sample project while preserving human review boundaries. Evidence remained under `task-runs/`, the decision stayed pending, and the sample branch was left as a local-only validation branch.

## Remaining Risks

- `workspace-write` allows Codex to edit the target workspace, so branch isolation and clean-workspace checks remain required.
- The validation depended on prompt compliance for README-only scope; review must still inspect changed files.
- The local sample branch has not been pushed or merged and should remain isolated until a separate controlled Git flow task authorizes that path.

## Next Recommended Task

Validate guarded negative paths for executable auto-loop on the sample project, including dirty workspace refusal, missing prompt, failed tests, and missing advancement fields.
