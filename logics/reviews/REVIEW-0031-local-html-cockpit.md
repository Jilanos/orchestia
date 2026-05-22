# REVIEW-0031: Local HTML Cockpit

## Reviewed Task

[TASK-0035](../tasks/TASK-0035-add-local-html-cockpit.md)

## Inputs Reviewed

- `scripts/orchestia_ui.py`
- `README.md`
- `docs/workflow.md`
- `docs/mvp-roadmap.md`
- `docs/local-cockpit.md`
- Recent orchestration helper reviews

## Checks Performed

- Python syntax compilation.
- Executable bit check.
- Help output check.
- Localhost smoke checks for dashboard, loops, runs, Logics, reviews, and debug pages.
- Documentation grep checks.
- Git status and diff stat review.

## Findings

- The cockpit is implemented with Python standard library only.
- The default bind address is `127.0.0.1` and default port is `8765`.
- The UI is read-only and implements no POST actions.
- File serving is restricted to the configured repository root.
- Hidden files, `.git/`, `.env`, `hosts.yml`, token-like, credential-like, and SSH key-like files are refused.
- Git commands use explicit argument lists with timeouts.
- The UI does not execute Codex, push, merge, update Loop state, or create reviews.

## Risks

- There is no authentication layer; it should remain bound to localhost.
- Markdown rendering is intentionally minimal.
- File safety checks are conservative but should be reviewed again before adding write actions.

## Decision

accept

## Required Follow-Up

Keep the cockpit read-only until a separate task defines explicit guarded write actions.

## Next Recommended Task

Add read-only cockpit links to specific finalized review and Loop state workflows, or add negative-path validation views.
