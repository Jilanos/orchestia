# Local Cockpit

## Purpose

The local cockpit is a small read-only HTML interface for inspecting Orchestia repository state, Loop state files, Logics records, reviews, and local `task-runs/` evidence.

It is intended for local situational awareness only. Execution remains in the CLI scripts.

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
- Loops: Loop state files and extracted current task/decision fields.
- Auto Loop: controlled auto-loop run directories, inferred status, latest event, instructions, stop requests, errors, command previews, and review drafts.
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
- There are no write actions or workflow buttons.
- Auto-loop controls are copyable CLI commands, not browser-executed actions.
- Large or binary evidence files are skipped.

## Next Possible Improvements

- Add a richer read-only review comparison view.
- Add explicit negative-path validation reports.
- Add a read-only Loop state timeline.
- Add guarded links that prefill CLI commands without executing them.
