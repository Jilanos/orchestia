# AGENTS.md

## Repository Purpose

Orchestia is the foundation for a semi-autonomous orchestration system for AI-assisted software development. It documents a bounded workflow where ChatGPT Business plans and reviews, Codex CLI executes local tasks, Git remains the source of truth, and Logics Manager-compatible files track requests, backlog items, tasks, specs, ADRs, and reviews.

## Rules for Codex and AI Agents

- Work only inside this repository unless a human explicitly authorizes a wider scope.
- Treat Git as the source of truth for project state.
- Keep generated changes small, reviewable, and tied to a written task.
- Prefer documentation, prompts, and simple scripts before adding automation.
- Do not create background services, daemons, credentials, or agentic frameworks without explicit approval.

## Security Boundaries

- WSL is an execution environment, not a strong security sandbox.
- Do not assume that local commands are isolated from the host machine.
- Avoid working in mounted Windows paths such as `/mnt/c` by default.
- Scripts must be transparent, minimal, and non-destructive.

## Secrets

- Do not read, print, copy, summarize, or commit secrets.
- Do not inspect `.env`, credential stores, token files, SSH keys, browser profiles, or cloud configuration files unless a human explicitly asks and confirms the exact file.
- If a task appears to require secrets, stop and ask for a safer handoff path.

## File Scope

- Do not modify files outside the authorized task scope.
- Do not delete files unless the task explicitly asks for deletion and the target path is named.
- Do not edit parent directories or sibling repositories.

## Git Policy

- Do not push, merge, rebase, tag, or publish releases unless explicitly requested.
- Do not force push.
- Before committing, inspect `git status --short`.
- Commit messages should describe the actual project change.

## Mandatory Codex Task Format

Every Codex execution task should include:

1. Objective
2. Authorized scope
3. Out-of-scope actions
4. Expected steps
5. Acceptance criteria
6. Verification commands
7. Git instructions
8. Watch points

## Review Rules

- Reviews should lead with risks, bugs, missing verification, and scope drift.
- Reviewers should compare the diff against the task, not against unstated preferences.
- If implementation details are unclear, request a smaller follow-up task instead of expanding scope during review.
