# Local Cockpit

## Purpose

The local cockpit is a small local HTML interface for inspecting Orchestia repository state, Loop state files, Logics records, reviews, and local `task-runs/` evidence.

It is intended for local situational awareness and narrow safe actions only. Codex execution, push, merge, and Loop state advancement remain in the CLI scripts.

## Start

From the Orchestia repository:

```bash
python3 scripts/orchestia_ui.py
```

Default URL:

```text
http://127.0.0.1:8765
```

Optional arguments:

```bash
python3 scripts/orchestia_ui.py --host 127.0.0.1 --port 8765 --repo .
```

## Pages

- Dashboard: repository path, branch, Git status, latest commit, counts, and warnings.
- Needs: draft need intakes under `task-runs/` and existing initial needs.
- New Need: create a draft intake file without writing to Logics.
- Logics Drafts: generated draft Logics directories under `task-runs/*-logics-draft/`.
- Logics Draft Detail: summary, manifest, generated draft files, source intake link, and promotion checklist.
- Loop Dashboard: compact Loop state status, next action, stop condition, and latest run context.
- Loops: Loop state files and extracted current task/decision fields.
- Auto Loop: controlled auto-loop run directories, inferred status, latest event, instructions, stop requests, errors, command previews, and review drafts.
- Autonomous Loop: autonomous local loop run directories, cycle count, latest decision, latest errors, cycle evidence, safe instruction/stop actions, token evidence, and human action required status.
- Iterations: inferred timeline across task-runs, reviews, and tasks.
- Tokens: evidence-based token usage parsing when local token data is present.
- Runs: local `task-runs/` directories and readable evidence files.
- Logics: grouped Logics Markdown records.
- Reviews: review files and extracted decisions.
- Debug: read-only Git and expected file/folder checks.

## What It Reads

- `logics/`
- `logics/loop-states/`
- `logics/reviews/`
- `task-runs/`
- `task-runs/*-auto-loop/`
- selected repository documentation and text files through safe links
- Git status and recent commits through read-only Git commands

## Action Model

The first cockpit action layer writes only safe local files:

- need intake drafts under `task-runs/<timestamp>-need-intake/`
- Logics draft files under `task-runs/<timestamp>-logics-draft/`
- autonomous-loop instructions under an existing `task-runs/*-autonomous-loop/`
- autonomous-loop stop requests under an existing `task-runs/*-autonomous-loop/`

The action layer does not run arbitrary commands. It does not execute Codex, push, merge, mutate Logics records, or modify project workspaces.

## Need Intake To Logics Drafts

The cockpit can convert a need intake draft into draft-only Logics files:

1. Create a need intake from `/needs/new`.
2. Open the intake detail page from `/needs` or `/need-intake?path=...`.
3. Use the `Generate Logics drafts` form.
4. Review the generated draft directory from `/logics-drafts` or `/logics-draft?path=...`.

The generated directory contains `summary.md`, `manifest.json`, `initial_need_draft.md`, `primary_needs_draft.md`, `request_draft.md`, `backlog_draft.md`, `loop_state_draft.md`, `task_prompt_outline.md`, and `promotion_checklist.md`.

This is a draft-only action. It writes only under `task-runs/`, requires a source under `task-runs/*-need-intake/`, and does not promote anything into final `logics/` records. Human review is required before any future manual or guarded promotion.

## What It Does Not Do

- It does not execute Codex.
- It does not push, merge, rebase, tag, force push, or delete branches.
- It does not modify Loop state.
- It does not create final reviews.
- It does not write to Logics.
- It does not run controlled Git flow commands.
- It does not advance controlled auto loops.

## Controlled Auto Loop View

The cockpit shows the latest auto-loop run on the dashboard and provides an Auto Loop page for `task-runs/*-auto-loop/` directories.

Each auto-loop detail page shows:

- current loop status
- Human action required warnings
- Codex execution status and exit code
- Codex sandbox mode from command evidence when available
- test command exit code when present
- event log tail
- errors, instructions, and stop requests when present
- links and previews for `codex-stdout.txt`, `codex-stderr.txt`, workspace diff stat, and test stdout/stderr
- command preview
- review draft
- copyable `auto-loop-status`, `auto-loop-instruct`, and `auto-loop-stop` commands

Instructions and stop requests remain CLI-driven in this version:

```bash
bash scripts/orchestia_loop.sh auto-loop-instruct task-runs/example-auto-loop "Prefer minimal changes."
bash scripts/orchestia_loop.sh auto-loop-stop task-runs/example-auto-loop "Stop before merge."
```

The cockpit does not execute those commands from the browser.

After an executable auto-loop run, inspect:

- `codex-stdout.txt`
- `codex-stderr.txt`
- `codex-exit-code.txt`
- `workspace-status-before.txt`
- `workspace-status-after.txt`
- `workspace-diff-stat-after.txt`
- `test-stdout.txt` and `test-stderr.txt` when a test command was supplied

Human action is required when the run is waiting for a decision, Codex failed, tests failed, a stop request exists, a blocker was recorded, or Loop state advancement needs explicit fields.

## Autonomous Loop View

The cockpit shows the latest autonomous-loop run on the dashboard and provides an Autonomous page for `task-runs/*-autonomous-loop/` directories.

Each autonomous-loop detail page shows:

- overall status
- current or latest cycle
- max cycles and completed cycles
- latest decision
- latest prompt evidence
- latest Codex and test exit codes
- latest error
- human action required state
- instructions and stop requests when present
- links to per-cycle evidence files
- copyable command previews for rerun, instruction, and stop-request creation

The cockpit can append instructions and stop requests for an existing autonomous-loop run. It does not execute the autonomous loop, push, merge, or update Loop state from the browser.

## Token Usage View

The Tokens page scans local `task-runs/` text evidence for token usage patterns. It shows totals only when values are parseable and shows not available when no token evidence exists. It does not call billing APIs or infer missing usage.

## Safety Boundaries

- The default bind address is `127.0.0.1`.
- Repositories under `/mnt/c` are refused unless `--allow-mnt-c` is explicit.
- Hidden dotfiles, `.git/`, `.env`, token-like, credential-like, SSH key-like, and secret-like files are not displayed.
- Files larger than 200 KB are skipped.
- All file output is HTML-escaped.
- The UI does not print environment variables.

## Known Limitations

- Markdown is shown as text, not fully rendered.
- Parsing is label-based and intentionally simple.
- There is no authentication layer.
- Write actions are limited to need drafts, autonomous-loop instructions, and autonomous-loop stop requests under `task-runs/`.
- Auto-loop controls remain copyable CLI commands, not browser-executed actions.
- Autonomous-loop execution remains CLI-driven.
- Large or binary evidence files are skipped.

## Next Possible Improvements

- Add a richer read-only review comparison view.
- Add explicit negative-path validation reports.
- Add a read-only Loop state timeline.
- Add guarded links that prefill CLI commands without executing them.
