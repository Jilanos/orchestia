# Orchestia Standard Validation

## Purpose

This file defines reusable validation blocks for Orchestia tasks. Future prompts should cite the relevant block instead of listing every command repeatedly.

## Base Repository Validation

Run from `~/ai-workspaces/orchestia`:

```bash
pwd
git branch --show-current
test "$(git branch --show-current)" = "master"
git status --short
git diff --check
```

Use this block before committing any documentation, Logics, or script task.

## Script Validation

Run when scripts are touched or when a task relies on script behavior:

```bash
bash -n scripts/*.sh
python3 -m py_compile scripts/orchestia_ui.py
test -x scripts/orchestia_loop.sh
test -x scripts/orchestia_ui.py
```

For a narrower task, it is acceptable to run only the directly relevant syntax checks if no scripts were modified.

## Cockpit Smoke Validation

Run when cockpit behavior changes:

```bash
python3 scripts/orchestia_ui.py --host 127.0.0.1 --port 8765 > task-runs/orchestia-ui-smoke.log 2>&1 &
UI_PID=$!
sleep 2

curl -fsS http://127.0.0.1:8765/ > /tmp/orchestia-home.html
curl -fsS http://127.0.0.1:8765/needs > /tmp/orchestia-needs.html
curl -fsS http://127.0.0.1:8765/loop-dashboard > /tmp/orchestia-loop-dashboard.html
curl -fsS http://127.0.0.1:8765/iterations > /tmp/orchestia-iterations.html
curl -fsS http://127.0.0.1:8765/tokens > /tmp/orchestia-tokens.html
curl -fsS http://127.0.0.1:8765/orchestration-runs > /tmp/orchestia-orchestration-runs.html
curl -fsS http://127.0.0.1:8765/orchestration/start > /tmp/orchestia-orchestration-start.html
curl -fsS http://127.0.0.1:8765/debug > /tmp/orchestia-debug.html

kill "$UI_PID"

grep -i "Orchestia" /tmp/orchestia-home.html
grep -i "Need" /tmp/orchestia-needs.html
grep -i "Loop" /tmp/orchestia-loop-dashboard.html
grep -i "Iteration" /tmp/orchestia-iterations.html
grep -i "Token" /tmp/orchestia-tokens.html
grep -i "orchestration" /tmp/orchestia-orchestration-runs.html
grep -i "orchestration" /tmp/orchestia-orchestration-start.html
grep -i "Debug" /tmp/orchestia-debug.html
```

## job-offer-analyzer Reference Validation

Run only when a task explicitly involves the published reference project:

```bash
cd ~/ai-workspaces/job-offer-analyzer
git status --short
git branch --show-current
test "$(git branch --show-current)" = "integration"
git remote get-url origin
git ls-remote --heads origin integration
python3 -m compileall src tests
python3 -m unittest discover -s tests
git diff --check
```

Do not modify or push this project unless the task explicitly authorizes it.

## Documentation-Only Validation

For documentation-only tasks, use:

```bash
git status --short
git diff --stat
git diff --check
```

Add targeted `grep` checks for required phrases, IDs, or links.

## How Future Prompts Should Use This

Use a short validation reference:

```text
Use docs/orchestia-standard-validation.md.
Required blocks: Base Repository Validation and Documentation-Only Validation.
Additional task-specific checks: ...
```
