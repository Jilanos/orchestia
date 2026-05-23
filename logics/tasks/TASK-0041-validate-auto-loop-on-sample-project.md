# TASK-0041: Validate Auto-loop On Sample Project

## Status

Complete

## Objective

Validate real auto-loop Codex execution on the sample todo CLI project using a dedicated feature branch, then document the result in Orchestia.

## Context

Auto-loop Codex execution had already been validated on a disposable workspace with `codex exec --sandbox workspace-write`. This task validated the same mechanism against the real sample todo CLI project with a minimal README-only change.

## Authorized Scope

- `docs/auto-loop-sample-execution-validation.md`
- `docs/mvp-roadmap.md`
- `logics/tasks/TASK-0041-validate-auto-loop-on-sample-project.md`
- `logics/reviews/REVIEW-0037-auto-loop-sample-execution-validation.md`
- Temporary ignored files under `task-runs/`
- Sample workspace branch `feature/auto-loop-sample-validation`

## Steps Performed

1. Verified Orchestia was on `master` and clean.
2. Verified the sample todo CLI workspace existed and was clean.
3. Created `feature/auto-loop-sample-validation` from sample `integration` at `f7a0574`.
4. Created a temporary prepared prompt under `task-runs/`.
5. Created a temporary Loop state under `task-runs/`.
6. Ran `scripts/orchestia_loop.sh auto-loop` with `--execute-codex`.
7. Verified Codex used `codex exec --sandbox workspace-write`.
8. Verified only `README.md` changed.
9. Ran sample checks.
10. Committed the sample README change locally as `da28859`.
11. Documented the result in Orchestia.

## Validation Commands

```bash
bash scripts/orchestia_loop.sh auto-loop \
  task-runs/auto-loop-sample-validation-loop-state.md \
  --workspace /home/pmondou/ai-workspaces/orchestia-samples/todo-cli \
  --max-steps 1 \
  --execute-codex \
  --test "python3 -m unittest discover -s tests"

python3 -m compileall src tests
python3 -m unittest discover -s tests
python3 -m py_compile todo_cli.py
git diff --check
```

## Acceptance Criteria

- Dedicated branch `feature/auto-loop-sample-validation` is used.
- Auto-loop runs with `--execute-codex` against the sample workspace.
- Codex uses `workspace-write`.
- README contains the expected validation note.
- Source code is not changed.
- Tests pass.
- A local sample commit is created.
- No sample push or merge is performed.
- Decision remains pending.
- Loop state is not advanced.

## Result

Complete. Auto-loop evidence was captured in `task-runs/20260523T212102Z-auto-loop/`, Codex exit code was `0`, test exit code was `0`, README-only scope held, and local sample commit `da28859` was created on `feature/auto-loop-sample-validation`.
