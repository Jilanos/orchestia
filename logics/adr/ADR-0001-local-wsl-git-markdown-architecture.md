# ADR-0001: Local WSL, Git, Markdown Architecture

## Metadata

- ID: ADR-0001
- Status: Accepted
- Date: 2026-05-21
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)
- Backlog: [BL-0001 Foundation](../backlog/BL-0001-foundation.md)
- Review: [REVIEW-0001 Initial Scaffold](../reviews/REVIEW-0001-initial-scaffold.md)

## Context

Orchestia needs a simple operating model for AI-assisted software development that remains local, human-directed, reviewable, and readable without special tools.

The project should coordinate ChatGPT Business planning and review with bounded Codex CLI execution while keeping Git as the source of truth.

## Decision

Use the following foundation architecture:

- WSL Linux filesystem as the primary workspace.
- Git as the source of truth for project state, diffs, and commits.
- Markdown as the project memory format.
- ChatGPT Business as planner, reviewer, and next-step synthesizer.
- Codex CLI as a bounded local executor for explicit tasks.
- Logics-style folders for structured workflow records.

## Consequences

- Project memory remains readable in any text editor.
- Work can be reviewed through ordinary Git diffs.
- Local execution stays bounded by written tasks.
- WSL is treated as an execution environment, not a strong security sandbox.
- Future automation should remain transparent, minimal, and non-destructive unless explicitly approved.

## Related Work

- [TASK-0001 Initial Scaffold](../tasks/TASK-0001-initial-scaffold.md)
- [TASK-0002 Track Empty Directories](../tasks/TASK-0002-track-empty-directories.md)
