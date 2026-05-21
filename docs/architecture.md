# Architecture

## Overview

Orchestia coordinates a human-directed loop across Windows, WSL, a Linux-oriented repository, Codex CLI, Git, ChatGPT Business, and Logics Manager-compatible documentation.

## Components

- Windows host: provides the user workstation, browser, GitHub access, and local storage.
- WSL: preferred shell environment for Linux-style development commands.
- Linux repo: the working copy where tasks are executed and reviewed.
- Codex CLI: bounded executor that makes local changes only when given explicit scope.
- Git: source of truth for status, diffs, commits, branches, and remote synchronization.
- ChatGPT Business: planner, researcher, reviewer, and next-step synthesizer.
- Logics Manager: structure for requests, backlog, tasks, specs, ADRs, and reviews.

## Data Flow

1. A human writes or approves a request.
2. ChatGPT Business turns the request into research notes, a plan, and a bounded Codex task.
3. Codex CLI executes the task locally in the repository.
4. Git records the diff and commit history.
5. Scripts collect status, diff, and test output into `task-runs/`.
6. ChatGPT Business reviews the collected results.
7. Decisions are reinjected into the next request, backlog item, task, spec, ADR, or review.

## MVP Limitations

- No autonomous scheduling.
- No background workers.
- No cross-repository orchestration.
- No secret handling automation.
- No production deployment pipeline.
- No GitHub Actions.
