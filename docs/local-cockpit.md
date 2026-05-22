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
- Runs: local `task-runs/` directories and readable evidence files.
- Logics: grouped Logics Markdown records.
- Reviews: review files and extracted decisions.
- Debug: read-only Git and expected file/folder checks.

## What It Reads

- `logics/`
- `logics/loop-states/`
- `logics/reviews/`
- `task-runs/`
- selected repository documentation and text files through safe links
- Git status and recent commits through read-only Git commands

## What It Does Not Do

- It does not execute Codex.
- It does not push, merge, rebase, tag, force push, or delete branches.
- It does not modify Loop state.
- It does not create final reviews.
- It does not write to Logics.
- It does not run controlled Git flow commands.

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
- Large or binary evidence files are skipped.

## Next Possible Improvements

- Add a richer read-only review comparison view.
- Add explicit negative-path validation reports.
- Add a read-only Loop state timeline.
- Add guarded links that prefill CLI commands without executing them.
