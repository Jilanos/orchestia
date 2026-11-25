# Orchestia

A human-supervised workflow for AI-assisted software development: ChatGPT plans and reviews, Codex CLI executes bounded local tasks, Git stays the source of truth, and Logics-style files keep the project memory.

## Problem

AI coding agents drift when they get large, vague tasks, and their work is hard to audit. Orchestia is for a developer who wants to keep control. Each task has a written scope, acceptance criteria and verification commands. Diffs, test output and reviews are stored as evidence in the repository.

It is not an autonomous agent framework. Every step that writes outside the task scope, pushes or merges needs an explicit human decision.

## Features

- Prompt templates for research, planning, Codex tasks, reviews and repository audits (`prompts/`).
- Logics records for needs, requests, backlog items, tasks, specs, ADRs and reviews (`logics/`).
- Shell helpers for environment checks, repo audits, diff and test evidence, and bounded Codex commands (`scripts/`).
- `scripts/orchestia_loop.sh`: state-driven loop with dry-run by default, `auto-loop`, `autonomous-loop`, and `orchestration-run` (need intake to Logics drafts, Codex execution, tests, review evidence).
- `scripts/controlled_git_flow.sh`: dry-run by default; push and merge need `--execute`, `main` and `master` are protected, force push is forbidden, failed tests block execution.
- `scripts/orchestia_ui.py`: local cockpit on `http://127.0.0.1:8765` to browse Loop state, runs, Logics records, reviews and token evidence, and to create draft need intakes. It cannot run Codex, push or merge.
- `scripts/validate_negative_paths.sh`: checks that unsafe actions are refused.

## Quick start

Use WSL 2 Ubuntu or Linux, with the repository on the Linux filesystem (not `/mnt/c`). Required: `bash`, `git`. Optional: `gh`, `node`, `npm`, `codex`.

```bash
git clone https://github.com/Jilanos/orchestia.git
cd orchestia
bash scripts/check_environment.sh
bash scripts/validate_negative_paths.sh
python3 scripts/orchestia_ui.py
```

Print a bounded Codex command without running it, then collect evidence:

```bash
bash scripts/run_codex_task.sh logics/tasks/TASK-0001-initial-scaffold.md
bash scripts/collect_diff.sh
bash scripts/collect_test_results.sh -- bash -n scripts/check_environment.sh
bash scripts/summarize_task_result.sh
```

Inspect a loop step (read only):

```bash
bash scripts/orchestia_loop.sh status logics/loop-states/LS-0001-sample-todo-cli.md
bash scripts/orchestia_loop.sh next logics/loop-states/LS-0001-sample-todo-cli.md
```

Everything else (`git-flow`, `finalize-review`, `auto-loop`, `autonomous-loop`, `orchestration-run`) is documented in `docs/` and in the usage text of `scripts/orchestia_loop.sh`. Execution flags such as `--execute-codex` or `--execute` are always explicit.

## Workflow

1. Write a request in `logics/requests/`.
2. Research and plan with the prompts in `prompts/`.
3. Give Codex one scoped task.
4. Collect diffs and test results into `task-runs/`.
5. Review with `prompts/review_prompt.md`.
6. Record the decision in `logics/reviews/` and pick the next task.

## Tech stack

Bash, Python 3 (standard library, for the cockpit), Git, Codex CLI, Markdown.

## Status

Release `v0.2-beta` is documented in [v0.2-beta Release](docs/v0.2-beta-release.md). It is not production-ready. Work on `v0.3` (cockpit-driven orchestration with explicit confirmations) is in progress: see [v0.3 Roadmap](docs/v0.3-roadmap.md) and [current state](docs/orchestia-current-state.md). The workflow was validated on small sample projects, for example [orchestia-sample-todo-cli](https://github.com/Jilanos/orchestia-sample-todo-cli). There is no automated unit test suite; validation uses the scripts above and the checklists in `docs/`.

## Safety Warning

WSL is not a strong sandbox. Do not read, print, summarize, or log secrets. Do not inspect `.env`, token files, SSH keys, browser profiles, or credential stores unless explicitly authorized with an exact path. Do not push, merge, rebase, delete files, or run destructive commands unless the human explicitly instructs that action.

## More Documentation

- [Architecture](docs/architecture.md)
- [Security Boundaries](docs/security-boundaries.md)
- [Workflow](docs/workflow.md)
- [Local cockpit](docs/local-cockpit.md)
- [Orchestration State Model](docs/orchestration-state-model.md)
- [MVP roadmap](docs/mvp-roadmap.md)
- [v0.3 Roadmap](docs/v0.3-roadmap.md)
- [Sample v0.2 orchestration scenario](docs/sample-v0.2-orchestration-scenario.md)
- [validation checklist](docs/validation-checklist.md)
- [Sample end-to-end run](docs/sample-end-to-end-run.md)
- [Prompt Templates](prompts/)
- [Logics Templates](logics/templates/)
- [Logics Requests](logics/requests/)
- [Logics Backlog](logics/backlog/)
- [Logics Tasks](logics/tasks/)
- [Logics ADRs](logics/adr/)
- [Logics Reviews](logics/reviews/)
