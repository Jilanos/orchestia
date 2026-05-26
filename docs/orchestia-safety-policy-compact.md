# Orchestia Safety Policy Compact

## Purpose

This is the compact safety baseline for Orchestia tasks. Future prompts should reference it instead of repeating the full safety policy unless a task needs stricter rules.

## Repository And Filesystem Boundaries

- Work only in explicitly authorized repositories and paths.
- Avoid `/mnt/c` and mounted Windows paths unless explicitly authorized.
- Do not modify parent directories, sibling repositories, or unrelated projects.
- Do not inspect hidden credential locations, `.env` files, SSH keys, token files, browser profiles, cloud configuration, or credential stores.
- Do not print environment variables or secret-like values.

## Git Boundaries

- Do not push, merge, rebase, tag, force push, delete branches, or publish releases unless explicitly authorized.
- Treat `main` and `master` as protected publication targets unless a task explicitly says otherwise.
- Use controlled Git flow for guarded publication tasks when required.
- Inspect `git status --short` before staging and committing.
- Stage only authorized files.

## Execution Boundaries

- Do not run Codex, autonomous-loop, orchestration-run, controlled Git flow execute, or long-running UI actions unless explicitly authorized.
- Browser UI actions must not execute arbitrary commands.
- Cockpit writes should remain narrow, local, and auditable under `task-runs/` unless a reviewed task authorizes final records.
- Prefer dry-run evidence and command previews before execution.

## Network And Dependency Boundaries

- Do not install dependencies unless explicitly authorized.
- Do not add external APIs, billing APIs, scraping, browser automation, or service integrations unless explicitly authorized.
- Do not create GitHub repositories or add remotes unless explicitly authorized.
- Do not use Playwright, Selenium, requests, BeautifulSoup, Scrapy, browser cookies, or LinkedIn APIs for product validation tasks unless a task explicitly changes that product boundary.

## Review And Documentation Boundaries

- Reviews should lead with findings, risks, missing verification, and scope drift.
- Do not mark work accepted unless required checks pass or the documented acceptance policy permits it.
- If blocked, document the exact blocker and avoid creating misleading success records.

## How Future Prompts Should Use This

Use a compact safety reference:

```text
Apply docs/orchestia-safety-policy-compact.md.
Task-specific extra restrictions:
- ...
```

Only repeat individual safety rules in the prompt when they are unusually important for the task.
