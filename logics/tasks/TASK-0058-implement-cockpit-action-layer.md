# TASK-0058: Implement Cockpit Action Layer

## Metadata

- ID: TASK-0058
- Status: Complete
- Review: [REVIEW-0053 Cockpit Action Layer](../reviews/REVIEW-0053-cockpit-action-layer.md)

## Objective

Extend `scripts/orchestia_ui.py` into the first actionable local cockpit for v0.2-beta while preserving local-only safety boundaries.

## Scope

- `scripts/orchestia_ui.py`
- `scripts/orchestia_loop.sh`
- `README.md`
- `docs/workflow.md`
- `docs/local-cockpit.md`
- `docs/mvp-roadmap.md`
- `docs/v0.2-beta-readiness.md`
- `docs/cockpit-action-layer.md`
- v0.2-beta task and review records

## Implemented Pages

- `/needs`
- `/needs/new`
- `/need-intake?path=<relative-path>`
- `/loop-dashboard`
- `/iterations`
- `/iteration?path=<relative-path>`
- `/tokens`
- Enhanced `/autonomous-loop` and `/autonomous-loop-run`

## Implemented Actions

- `POST /needs/create`: creates draft intake files under `task-runs/<timestamp>-need-intake/`.
- `POST /actions/autonomous-loop-instruct`: appends instructions under an existing autonomous-loop run.
- `POST /actions/autonomous-loop-stop`: appends stop requests under an existing autonomous-loop run.
- `scripts/orchestia_loop.sh autonomous-loop-status`: read-only autonomous-loop status command.

## Safety Boundaries

- No arbitrary command execution.
- No Codex execution from the browser.
- No push or merge from the browser.
- No controlled Git flow execute from the browser.
- No final Logics records are created from the need intake form.
- Browser actions write only under `task-runs/`.
- Safe path validation blocks traversal, hidden files, `.git`, secret-like files, and oversized files.
- Token usage is parsed only from local evidence and is shown as not available when missing.

## Validation Commands

```bash
pwd
git branch --show-current
test "$(git branch --show-current)" = "master"
bash -n scripts/orchestia_loop.sh
python3 -m py_compile scripts/orchestia_ui.py
test -x scripts/orchestia_loop.sh
test -x scripts/orchestia_ui.py
```

Cockpit GET smoke:

```bash
curl -fsS http://127.0.0.1:8765/
curl -fsS http://127.0.0.1:8765/needs
curl -fsS http://127.0.0.1:8765/needs/new
curl -fsS http://127.0.0.1:8765/loop-dashboard
curl -fsS http://127.0.0.1:8765/iterations
curl -fsS http://127.0.0.1:8765/tokens
curl -fsS http://127.0.0.1:8765/autonomous-loop
curl -fsS http://127.0.0.1:8765/debug
```

Functional POST smoke:

- Created disposable need intake draft under `task-runs/`.
- Appended disposable instruction text to an existing autonomous-loop run.
- Appended disposable stop request text to an existing autonomous-loop run.

## Result

- Result: accepted.
- The first v0.2-beta cockpit action layer is implemented and smoke tested.
