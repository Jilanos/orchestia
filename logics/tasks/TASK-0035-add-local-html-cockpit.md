# TASK-0035: Add Local HTML Cockpit

## Status

Complete

## Objective

Add a simple local, read-only HTML cockpit for inspecting Orchestia state, Logics records, reviews, Loop states, and `task-runs/` reports.

## Context

Orchestia v0.2 has state-driven loop helpers, controlled Git flow helpers, review finalization support, completed sample loop records, and local evidence under `task-runs/`. A small cockpit can improve inspection without adding write actions or dependencies.

## Authorized Scope

- `scripts/orchestia_ui.py`
- README and workflow/roadmap documentation
- `docs/local-cockpit.md`
- This task and review record

## Out Of Scope

- Existing shell script changes
- Frontend build tooling
- External dependencies
- Codex execution
- Push, merge, rebase, tag, or force push actions
- Loop state updates
- Review creation from the UI
- Secret or hidden file display

## Expected Steps

1. Create a Python standard-library HTTP server.
2. Add read-only dashboard, Loop state, `task-runs/`, Logics, reviews, file, and debug pages.
3. Add safe file filtering and path traversal protection.
4. Document startup and safety boundaries.
5. Run syntax and localhost smoke checks.

## Verification Commands

```bash
python3 -m py_compile scripts/orchestia_ui.py
python3 scripts/orchestia_ui.py --help
python3 scripts/orchestia_ui.py --host 127.0.0.1 --port 8765
```

Smoke verification used localhost requests for `/`, `/loops`, `/runs`, `/logics`, `/reviews`, and `/debug`.

## Acceptance Criteria

- `scripts/orchestia_ui.py` exists and is executable.
- The UI uses only Python standard library.
- The UI defaults to `127.0.0.1:8765`.
- The UI is read-only.
- The UI has dashboard, loops, run, file, Logics, reviews, and debug pages.
- Secret-like and hidden files are refused.
- No Codex, push, merge, Loop state update, or review creation action is available.

## Result

Implemented. The first local cockpit is available through `python3 scripts/orchestia_ui.py` and serves read-only pages on `http://127.0.0.1:8765`.
