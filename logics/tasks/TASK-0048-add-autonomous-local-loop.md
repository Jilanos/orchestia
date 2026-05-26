# TASK-0048: Add Autonomous Local Loop

## Metadata

- ID: TASK-0048
- Status: Complete
- Review: [REVIEW-0044 Autonomous Local Loop](../reviews/REVIEW-0044-autonomous-local-loop.md)

## Objective

Implement an autonomous local loop mode for Orchestia, validate it on a disposable workspace, and document the result.

## Context

Orchestia v0.2-alpha already supports controlled auto-loop execution, evidence capture, review finalization, controlled Git flow, and cockpit inspection. The next step is a repeated local loop that can run multiple Codex cycles until completion, blocker, ambiguity, or max cycle limit.

## Authorized Scope

- `scripts/orchestia_loop.sh`
- `scripts/orchestia_ui.py`
- `README.md`
- `docs/workflow.md`
- `docs/local-cockpit.md`
- `docs/orchestration-state-model.md`
- `docs/mvp-roadmap.md`
- `docs/autonomous-local-loop.md`
- `logics/tasks/TASK-0048-add-autonomous-local-loop.md`
- `logics/reviews/REVIEW-0044-autonomous-local-loop.md`
- ignored disposable files under `task-runs/`

## Implementation Summary

- Added `autonomous-loop` to `scripts/orchestia_loop.sh`.
- Added `--max-cycles`, `--execute-codex`, `--execute-all`, `--auto-accept-if-checks-pass`, `--advance-if-next-ready`, `--stop-on-dirty`, `--test`, `--blocker`, and `--instruction`.
- Added run-level evidence under `task-runs/*-autonomous-loop/`.
- Added per-cycle evidence directories.
- Added auto-accept only when Codex and tests pass and no blocker is present.
- Added safe stop on missing or ambiguous next state.
- Added read-only cockpit views for autonomous-loop runs.

## Validation Commands

```bash
bash -n scripts/orchestia_loop.sh
python3 -m py_compile scripts/orchestia_ui.py
bash scripts/orchestia_loop.sh autonomous-loop \
  task-runs/autonomous-loop-disposable/loop-state.md \
  --workspace task-runs/autonomous-loop-disposable/workspace \
  --max-cycles 2 \
  --execute-codex \
  --auto-accept-if-checks-pass \
  --advance-if-next-ready \
  --test "python3 -m unittest discover -s tests" \
  --instruction "Keep changes minimal and stop if tests fail."
```

## Acceptance Criteria

- `autonomous-loop` exists.
- Codex executes only with explicit authorization.
- Per-cycle evidence is captured.
- Passing cycles can be auto-accepted only with explicit policy.
- Missing next state stops safely.
- No push or merge is performed.
- Cockpit can inspect autonomous-loop runs.
- Validation uses only disposable workspace files under `task-runs/`.

## Result

Accepted. Disposable validation run `task-runs/20260526T081619Z-autonomous-loop/` completed two Codex cycles with decisions `accept`, captured evidence, and stopped safely when no explicit next state remained.
