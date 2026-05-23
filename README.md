# Orchestia

Orchestia is a lightweight operating model for AI-assisted software development. It keeps humans in control while connecting ChatGPT Business planning and review, bounded Codex CLI execution, Git diffs, test evidence, and Logics-style project memory.

## MVP Status

The MVP foundation is in place:

- Public GitHub repository.
- WSL-first Linux workspace.
- Initial repository scaffold.
- Tracked Logics directories.
- Initial Logics project memory.
- Safe helper scripts for environment checks and task output collection.
- `.gitignore` policy for generated runtime output and local artifacts.
- Reusable prompt templates for research, planning, Codex tasks, reviews, and repository audits.

Orchestia is not an autonomous agent framework. It is a documented, human-supervised workflow.

## Execution Modes

Orchestia policy defines Manual mode, Assisted mode, Auto branch mode, and Controlled auto merge mode. Auto push and auto merge are policy-gated for fresh projects or isolated branches; `main` and `master` stay protected by default.

For v0.2, Orchestia is moving toward iterative need-to-completion orchestration: initial need, primary needs, requests, backlog items, tasks, Codex execution, collected evidence, review, and repeat until complete or blocked. Controlled auto push and controlled auto merge are planned only for fresh projects or isolated branches under explicit guardrails. Orchestia remains human-supervised, not fully autonomous.

The minimal v0.2 state model is documented in [Orchestration State Model](docs/orchestration-state-model.md), with initial need, primary need, and loop state templates under `logics/templates/`.

v0.2 orchestration prompts live in `prompts/initial_need_intake_prompt.md`, `prompts/primary_need_decomposition_prompt.md`, and `prompts/orchestration_loop_prompt.md`.

## Repository Structure

```text
.
├── AGENTS.md
├── PROJECT_BRIEF.md
├── README.md
├── docs/
│   ├── architecture.md
│   ├── mvp-roadmap.md
│   ├── security-boundaries.md
│   └── workflow.md
├── prompts/
│   ├── codex_task_prompt.md
│   ├── initial_need_intake_prompt.md
│   ├── orchestration_loop_prompt.md
│   ├── planning_prompt.md
│   ├── primary_need_decomposition_prompt.md
│   ├── repo_audit_prompt.md
│   ├── research_prompt.md
│   └── review_prompt.md
├── scripts/
│   ├── check_environment.sh
│   ├── audit_repo.sh
│   ├── collect_diff.sh
│   ├── collect_test_results.sh
│   ├── run_codex_task.sh
│   └── summarize_task_result.sh
├── logics/
│   ├── requests/
│   ├── backlog/
│   ├── tasks/
│   ├── templates/
│   ├── specs/
│   ├── adr/
│   └── reviews/
└── task-runs/
```

## WSL-First Setup

Use a WSL 2 Ubuntu shell and keep the repository under the Linux filesystem, not under `/mnt/c`, unless a human explicitly approves the mounted Windows path.

```bash
git clone https://github.com/Jilanos/orchestia.git
cd orchestia
pwd
```

## Basic Commands

Check the local environment:

```bash
bash scripts/check_environment.sh
```

Generate a local Markdown repository audit:

```bash
bash scripts/audit_repo.sh
```

Print a bounded Codex CLI command without executing it:

```bash
bash scripts/run_codex_task.sh logics/tasks/TASK-0001-initial-scaffold.md
```

Execute Codex only when the task scope is approved:

```bash
bash scripts/run_codex_task.sh --execute logics/tasks/TASK-0001-initial-scaffold.md
```

Collect Git status, diff, diff stat, and recent log output:

```bash
bash scripts/collect_diff.sh
```

Capture a test command result:

```bash
bash scripts/collect_test_results.sh -- bash -n scripts/check_environment.sh
```

Summarize the latest local task run:

```bash
bash scripts/summarize_task_result.sh
```

Inspect or assist a v0.2 state-driven loop step:

```bash
bash scripts/orchestia_loop.sh status logics/loop-states/LS-0001-sample-todo-cli.md
bash scripts/orchestia_loop.sh next logics/loop-states/LS-0001-sample-todo-cli.md
```

The state-driven runner can print a Codex command, collect workspace evidence, and create a review draft. It does not update Loop state, push, merge, or make review decisions.

Generate a controlled Git flow handoff from Loop state to copyable Git commands:

```bash
bash scripts/orchestia_loop.sh git-flow logics/loop-states/LS-0001-sample-todo-cli.md --workspace ~/ai-workspaces/example-project --remote origin --source-branch feature/example --target-branch integration --test "python3 -m unittest discover -s tests"
```

The handoff creates evidence under `task-runs/` and prints `controlled_git_flow.sh` status, dry-run, and human-approved execute commands. It does not push or merge.

Draft a review from Git-flow evidence:

```bash
bash scripts/orchestia_loop.sh git-flow-review-draft logics/loop-states/LS-0001-sample-todo-cli.md --workspace ~/ai-workspaces/example-project --evidence-dir task-runs/example-controlled-git-flow
```

The draft is written under `task-runs/`; final Logics reviews and Loop state updates remain human-controlled.

Finalize a human-approved review draft into Logics memory:

```bash
bash scripts/orchestia_loop.sh finalize-review --draft task-runs/example/review-draft.md --review-id REVIEW-0031 --review-title "Example review" --reviewed-task TASK-0031 --decision accept
```

`finalize-review` requires an explicit decision and writes only to `logics/reviews/`. It does not update Loop state, push, or merge.

Run a controlled auto-loop checkpoint in dry-run mode:

```bash
bash scripts/orchestia_loop.sh auto-loop logics/loop-states/LS-0001-sample-todo-cli.md --workspace ~/ai-workspaces/example-project --max-steps 1
bash scripts/orchestia_loop.sh auto-loop-status task-runs/example-auto-loop
bash scripts/orchestia_loop.sh auto-loop-instruct task-runs/example-auto-loop "Prefer minimal changes."
bash scripts/orchestia_loop.sh auto-loop-stop task-runs/example-auto-loop "Stop before merge."
```

`auto-loop` creates evidence under `task-runs/`, previews commands, supports instruction and stop files, and can advance Loop state only with an explicit decision plus `--advance` and required fields. Execution still requires explicit flags such as `--execute-codex`, `--execute-git-flow`, or `--execute-all`.

Start the local cockpit:

```bash
python3 scripts/orchestia_ui.py
```

Open `http://127.0.0.1:8765` to inspect Loop state, auto-loop runs, task-runs, Logics records, reviews, and debug status. The local cockpit is read-only and includes an auto-loop view with status, human action required, and copyable commands.

Inspect or dry-run controlled Git flow automation:

```bash
bash scripts/controlled_git_flow.sh status --workspace ~/ai-workspaces/example-project
bash scripts/controlled_git_flow.sh auto-push --workspace ~/ai-workspaces/example-project --remote origin --branch feature/example
bash scripts/controlled_git_flow.sh auto-merge --workspace ~/ai-workspaces/example-project --remote origin --source-branch feature/example --target-branch integration
```

`scripts/controlled_git_flow.sh` defaults to dry-run. Auto-push and auto-merge require `--execute`; `main/master` are protected by default, force push is forbidden, and failed tests block execution.

The audit script writes `repo-audit.md` under a timestamped `task-runs/` directory. Paste that report into ChatGPT Business with `prompts/repo_audit_prompt.md` when you want a repository-level review.

## MVP Workflow

1. Create or update a request in `logics/requests/`.
2. Research with `prompts/research_prompt.md`.
3. Plan backlog slices and bounded tasks with `prompts/planning_prompt.md`.
4. Give Codex CLI one scoped task using `prompts/codex_task_prompt.md`.
5. Collect diffs and test results into `task-runs/`.
6. Optionally generate `task-runs/.../repo-audit.md` with `scripts/audit_repo.sh`.
7. Review the result with `prompts/review_prompt.md` or audit the repository with `prompts/repo_audit_prompt.md`.
8. Record decisions in `logics/reviews/` and select the next task.

## Safety Warning

WSL is not a strong sandbox. Do not read, print, summarize, or log secrets. Do not inspect `.env`, token files, SSH keys, browser profiles, or credential stores unless explicitly authorized with an exact path. Do not push, merge, rebase, delete files, or run destructive commands unless the human explicitly instructs that action.

## More Documentation

- [Architecture](docs/architecture.md)
- [Security Boundaries](docs/security-boundaries.md)
- [Workflow](docs/workflow.md)
- [Local cockpit](docs/local-cockpit.md)
- [Orchestration State Model](docs/orchestration-state-model.md)
- [MVP roadmap](docs/mvp-roadmap.md)
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
