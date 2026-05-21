# Orchestia

Orchestia is a lightweight foundation for semi-autonomous orchestration in AI-assisted software development. It keeps humans in control while connecting planning, bounded Codex CLI execution, Git diffs, tests, review, and Logics Manager-compatible records.

## MVP Status

This repository is an initial scaffold. It contains documentation, prompt templates, Logics folders, and minimal non-destructive helper scripts.

## Repository Structure

```text
.
├── AGENTS.md
├── PROJECT_BRIEF.md
├── README.md
├── docs/
├── prompts/
├── scripts/
├── logics/
│   ├── requests/
│   ├── backlog/
│   ├── tasks/
│   ├── specs/
│   ├── adr/
│   └── reviews/
└── task-runs/
```

## Minimal Workflow

1. Write a request in `logics/requests/`.
2. Research and plan with ChatGPT Business.
3. Promote the work into backlog and task files.
4. Give Codex CLI one bounded task.
5. Collect the diff and test results.
6. Review the result.
7. Reinject decisions into the next task.

## WSL Security Warning

WSL is not a strong sandbox. Avoid working in `/mnt/c` by default, do not expose secrets to agents, and treat every local command as capable of affecting the machine within the user's permissions.

## Getting Started

```bash
git clone <repository-url>
cd orchestia
bash scripts/check_environment.sh
find . -maxdepth 3 -type f | sort
```
