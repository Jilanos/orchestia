# TASK-0006: Update Main Documentation

## Metadata

- ID: TASK-0006
- Backlog: [BL-0001 Foundation](../backlog/BL-0001-foundation.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)
- Status: Completed
- Review: [REVIEW-0005 Main Documentation](../reviews/REVIEW-0005-main-documentation.md)

## Objective

Update the main documentation so it matches the current Orchestia MVP state.

## Scope

- Update `README.md`.
- Update `docs/architecture.md`.
- Update `docs/security-boundaries.md`.
- Update `docs/workflow.md`.
- Record this task and review in Logics memory.

## Completed Work

- README now describes current MVP status, repository structure, WSL-first setup, basic commands, task execution, evidence collection, summaries, safety warnings, and links.
- Architecture documentation now describes the Windows host, WSL 2 Ubuntu workspace, Linux filesystem repository, ChatGPT Business, Codex CLI, Git, Logics memory, task-runs, prompts, scripts, and MVP limitations.
- Security documentation now states WSL, `/mnt/c`, secrets, Git, destructive command, dependency, and bounded-task rules.
- Workflow documentation now covers the full request, research, planning, backlog, Codex execution, diff/test collection, review, reinjection, and next-task loop.

## Verification

Run the checks listed in [REVIEW-0005 Main Documentation](../reviews/REVIEW-0005-main-documentation.md).
