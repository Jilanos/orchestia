# Cockpit Action Layer

## Purpose

The cockpit action layer turns the local cockpit into a first interaction surface for Orchestia while preserving the `v0.2-alpha` safety model. It adds draft intake and loop control files, not unrestricted automation.

## Pages

- `/needs`: lists draft need intakes and existing initial needs.
- `/needs/new`: form for a new initial need draft.
- `/need-intake?path=...`: safe view for an intake draft.
- `/loop-dashboard`: compact Loop state dashboard.
- `/iterations`: timeline inferred from `task-runs/`, tasks, and reviews.
- `/iteration?path=...`: detail view for a run, task, or review.
- `/tokens`: token usage evidence dashboard.
- `/autonomous-loop`: autonomous-loop run list.
- `/autonomous-loop-run?path=...`: autonomous-loop status, cycles, evidence, token evidence, and safe controls.

## Safe Actions

- Create a need intake draft under `task-runs/<timestamp>-need-intake/need-intake.md`.
- Append an instruction to `task-runs/*-autonomous-loop/instructions.md`.
- Append a stop request to `task-runs/*-autonomous-loop/stop-request.md`.

These actions write only to `task-runs/` and do not modify Logics records, project workspaces, or Git state.

## Forbidden Actions

- No arbitrary command execution.
- No Codex execution from the browser.
- No push or merge from the browser.
- No controlled Git flow execute from the browser.
- No Logics mutation from need intake POST.
- No secret, token, credential, SSH key, `.env`, `.git`, or hidden dotfile display.
- No external network calls.
- No billing API calls.

## Need Intake Flow

The cockpit form captures title, description, constraints, non-goals, preferred project path, and notes. Submission creates a draft under `task-runs/` with source `cockpit`.

Final Logics records remain a reviewed workflow step. The cockpit does not directly create `IN`, `PN`, `REQ`, `BL`, or `TASK` records in this first action layer.

## Loop Dashboard

The Loop dashboard summarizes Loop state files with current primary need, current task, next action, stop condition, last review, latest run names, and inferred human action needs.

## Iteration Timeline

The iteration timeline combines:

- `task-runs/*-auto-loop`
- `task-runs/*-autonomous-loop`
- `task-runs/*-controlled-git-flow`
- `task-runs/*-git-flow-handoff`
- `task-runs/*-git-flow-review*`
- `logics/reviews/*.md`
- `logics/tasks/*.md`

The timeline is inferred from filenames and local record contents, so it is an operator aid rather than an authoritative state machine.

## Token Usage Evidence

The token page scans local `task-runs/` text evidence for parseable token usage patterns such as `Token usage`, `total=`, `input=`, `output=`, `reasoning=`, `cached=`, and `tokens`.

Token usage is evidence-based only. Missing values are shown as not available. The cockpit does not invent usage totals, call billing APIs, or read credential files.

## Instructions And Stop Requests

Autonomous-loop run pages include forms for instruction and stop request files. POST actions append timestamped text to the selected run directory and add an event log entry. They do not execute commands.

## Limitations

- There is no authentication layer.
- Need intake creates drafts only.
- Token parsing is best-effort and local-file-only.
- The iteration timeline is inferred from filenames and simple record parsing.
- Browser actions do not launch Codex, push, merge, or update Loop state.

## Next Improvements

- Add a reviewed Logics promotion flow from draft intake files.
- Add richer run-to-review linking.
- Add machine-readable evidence files for token usage.
- Add explicit action result records under `task-runs/*-cockpit-action/` if command allowlists are introduced later.
