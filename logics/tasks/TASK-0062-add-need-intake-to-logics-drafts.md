# TASK-0062: Add Need Intake To Logics Drafts

## Objective

Implement the first Orchestia v0.3 cockpit-driven orchestration action: convert a cockpit need intake draft into Logics draft files under `task-runs/` without promoting them to final Logics records.

## Context

v0.3 planning defines cockpit-driven orchestration as the next step after `v0.2-beta`. The cockpit already supports need intake drafts. The next safe browser action is draft generation for human review, with final Logics promotion left manual or future guarded work.

## Authorized Scope

- `scripts/orchestia_ui.py`
- `README.md`
- `docs/local-cockpit.md`
- `docs/cockpit-driven-orchestration.md`
- `docs/mvp-roadmap.md`
- `logics/tasks/TASK-0062-add-need-intake-to-logics-drafts.md`
- `logics/reviews/REVIEW-0057-need-intake-to-logics-drafts.md`

## Implementation Summary

- Added `/logics-drafts` to list generated Logics draft directories.
- Added `/logics-draft?path=...` to inspect a draft directory.
- Added `/needs/generate-logics-draft` as a safe POST action from a need intake.
- Added a need intake detail form for generating draft-only Logics files.
- Generated draft directories contain summary, manifest, initial need, primary needs, request, backlog, loop state, task prompt outline, and promotion checklist files.
- Kept all generated drafts under `task-runs/*-logics-draft/`.
- Kept final `logics/` records untouched by the UI action.

## Validation Commands

```bash
python3 -m py_compile scripts/orchestia_ui.py
test -x scripts/orchestia_ui.py

python3 scripts/orchestia_ui.py --host 127.0.0.1 --port 8765
curl -fsS http://127.0.0.1:8765/
curl -fsS http://127.0.0.1:8765/needs
curl -fsS http://127.0.0.1:8765/needs/new
curl -fsS http://127.0.0.1:8765/logics-drafts
curl -fsS http://127.0.0.1:8765/debug

curl -fsS -X POST http://127.0.0.1:8765/needs/create ...
curl -fsS -X POST http://127.0.0.1:8765/needs/generate-logics-draft ...
curl -fsS "http://127.0.0.1:8765/logics-draft?path=${LATEST_DRAFT}"

git diff --check
```

## Result

- Result: accepted.
- The cockpit can generate draft-only Logics files from a need intake.
- Generated outputs remain under `task-runs/`.
- No final Logics records are created by the action.
- No Codex execution, autonomous-loop execution, push, merge, or arbitrary command execution was added.
