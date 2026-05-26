# REVIEW-0044: Autonomous Local Loop

## Metadata

- ID: REVIEW-0044
- Status: Complete
- Reviewed task: [TASK-0048 Add Autonomous Local Loop](../tasks/TASK-0048-add-autonomous-local-loop.md)
- Decision: accept

## Inputs Reviewed

- `scripts/orchestia_loop.sh`
- `scripts/orchestia_ui.py`
- `docs/autonomous-local-loop.md`
- Disposable validation workspace under `task-runs/autonomous-loop-disposable/`
- Autonomous-loop evidence: `task-runs/20260526T081619Z-autonomous-loop/`

## Checks Performed

- `bash -n scripts/orchestia_loop.sh`
- `python3 -m py_compile scripts/orchestia_ui.py`
- `codex exec --sandbox workspace-write` executed in disposable cycle 1.
- `codex exec --sandbox workspace-write` executed in disposable cycle 2.
- `python3 -m unittest discover -s tests` passed in both accepted cycles.
- UI routes were added for autonomous-loop list and detail pages.

## Findings

- The new `autonomous-loop` command creates `task-runs/*-autonomous-loop/`.
- It creates per-cycle directories with prompt, Codex, workspace, test, decision, and review-draft evidence.
- It requires explicit execution flags before Codex runs.
- It auto-accepts only when `--auto-accept-if-checks-pass` is provided and checks pass.
- It advanced from cycle 1 to cycle 2 using explicit next-state fields.
- It stopped safely after cycle 2 because no explicit next state remained.
- No push, merge, rebase, tag, branch deletion, GitHub remote, or real project modification occurred.

## Risks

- Project-specific allowed-file policies are not yet enforced beyond secret-like file detection.
- The runner does not create final Logics reviews automatically.
- Target workspace changes are not committed by the autonomous loop.
- Terminal completion needs clearer state fields before the loop can mark a whole initial need complete.

## Decision

accept

## Required Follow-Up

- Add explicit terminal completion fields or policy before using autonomous-loop for full project completion.
- Add project-specific allowed-file checks before running on real projects.
- Validate on `job-offer-analyzer` in a separate authorized task.

## Next Recommended Task

Prepare a scoped validation of autonomous-loop against `job-offer-analyzer` scoring only after the next request, backlog item, task, and prompt are reviewed.
