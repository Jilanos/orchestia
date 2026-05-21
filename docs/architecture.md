# Architecture

## Overview

Orchestia is a local, human-supervised workflow for AI-assisted software development. It connects a Windows host, a WSL 2 Ubuntu workspace, a Git repository, ChatGPT Business, Codex CLI, Logics memory, and local task-run outputs.

## Components

- Windows host: the user workstation for browser access, GitHub, ChatGPT Business, and local files.
- WSL 2 Ubuntu workspace: the preferred command environment for repository work.
- Linux filesystem repository: the working copy should live under the WSL Linux filesystem, not `/mnt/c`, by default.
- ChatGPT Business: planner, researcher, reviewer, and next-step synthesizer.
- Codex CLI: bounded local executor for one explicit task at a time.
- Git: source of truth for status, diffs, commits, branches, and remote state.
- Logics folders: Markdown project memory for requests, backlog items, tasks, specs, ADRs, and reviews.
- `task-runs/`: local runtime output for generated diff snapshots, test results, and task summaries.
- Prompt templates: reusable operating standards for research, planning, Codex execution, review, and audits.
- Helper scripts: small Bash scripts for environment checks and collecting review evidence.

## Repository Layout

```text
docs/       Architecture, security, and workflow documentation.
prompts/    Copyable prompt templates for the MVP workflow.
scripts/    Minimal local helper scripts.
logics/     Versioned project memory.
task-runs/  Local generated task outputs; contents are ignored by Git except .gitkeep.
```

## Data Flow

1. A human records or approves a request in `logics/requests/`.
2. ChatGPT Business researches the request and helps plan a bounded task.
3. The task is recorded in `logics/tasks/`.
4. Codex CLI executes the task locally inside the repository.
5. Git exposes the resulting status and diff.
6. Helper scripts collect diff and test evidence into `task-runs/`.
7. ChatGPT Business reviews the evidence and recommends accept, revise, split, or reject.
8. The decision is recorded in Logics memory and used to choose the next task.

## Current MVP Limitations

- No autonomous scheduler or background worker.
- No GitHub Actions or deployment pipeline.
- No secret handling automation.
- No cross-repository orchestration.
- No dependency installation workflow.
- No guarantee that WSL isolates commands from the host.
- `task-runs/` output is local and ignored by default unless manually converted into tracked project memory.
