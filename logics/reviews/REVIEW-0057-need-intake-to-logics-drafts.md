# REVIEW-0057: Need Intake To Logics Drafts

## Reviewed Task

[TASK-0062 Add Need Intake To Logics Drafts](../tasks/TASK-0062-add-need-intake-to-logics-drafts.md)

## Files Changed

- `scripts/orchestia_ui.py`
- `README.md`
- `docs/local-cockpit.md`
- `docs/cockpit-driven-orchestration.md`
- `docs/mvp-roadmap.md`
- `logics/tasks/TASK-0062-add-need-intake-to-logics-drafts.md`
- `logics/reviews/REVIEW-0057-need-intake-to-logics-drafts.md`

## Smoke Tests

- Python compile check for `scripts/orchestia_ui.py`.
- Cockpit GET smoke for dashboard, needs, new need, Logics drafts, and debug pages.
- Cockpit POST smoke for need intake creation and Logics draft generation.
- Draft detail page smoke for generated `task-runs/*-logics-draft/` output.
- Grep checks for routes, docs, task, and review decision.
- `git diff --check`.

## Findings

- The action writes generated files only under `task-runs/*-logics-draft/`.
- The source intake must validate under `task-runs/*-need-intake/`.
- Generated files are clearly marked as draft.
- The generated promotion checklist requires human review before final Logics records are created.
- The cockpit does not execute Codex, run autonomous-loop, run shell commands, push, merge, or write final `logics/` records for this action.

## Risks

- Draft quality is heuristic and still needs human review before promotion.
- Future promotion will need strict ID collision checks and a separate confirmation flow.
- The generated primary needs are suggestions, not product decisions.

## Decision

accept

## Required Follow-Up

- Implement a guarded promotion or task prompt preparation action only after separate review.
- Add negative-path validation for invalid intake paths and blocked draft generation paths.

## Next Recommended Task

Design the next v0.3 cockpit action: prepare a task prompt draft from reviewed Logics draft content without executing Codex.
