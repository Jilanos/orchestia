# REQ-0001: Orchestia MVP

## Metadata

- ID: REQ-0001
- Status: Accepted for foundation planning
- Backlog: [BL-0001 Foundation](../backlog/BL-0001-foundation.md)
- Review: [REVIEW-0001 Initial Scaffold](../reviews/REVIEW-0001-initial-scaffold.md)

## User Need

Build a simple, local, human-supervised orchestration system for AI-assisted software development.

The system should coordinate planning, bounded local execution, Git-based traceability, review, and reinjection of results without creating an autonomous agent framework.

## Scope

- Use ChatGPT Business for planning, review, and next-step synthesis.
- Use Codex CLI for explicit local execution tasks.
- Use Git as the source of truth for repository state.
- Use Markdown files as readable project memory.
- Use Logics-style folders to track requests, backlog items, tasks, ADRs, and reviews.

## Out of Scope

- Background services or daemons.
- Autonomous agent frameworks.
- Secret management automation.
- Cross-repository modification.
- Destructive scripts or hidden automation.

## Acceptance Criteria

- The repository has a clear scaffold for the workflow.
- Project memory can be read and edited as plain Markdown.
- Execution tasks are bounded and reviewable.
- Security and Git boundaries are explicit.
