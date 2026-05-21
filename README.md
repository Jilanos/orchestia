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

## Repository Structure

```text
.
├── AGENTS.md
├── PROJECT_BRIEF.md
├── README.md
├── docs/
│   ├── architecture.md
│   ├── security-boundaries.md
│   └── workflow.md
├── prompts/
│   ├── codex_task_prompt.md
│   ├── planning_prompt.md
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
- [MVP roadmap](docs/mvp-roadmap.md)
- [Prompt Templates](prompts/)
- [Logics Templates](logics/templates/)
- [Logics Requests](logics/requests/)
- [Logics Backlog](logics/backlog/)
- [Logics Tasks](logics/tasks/)
- [Logics ADRs](logics/adr/)
- [Logics Reviews](logics/reviews/)
