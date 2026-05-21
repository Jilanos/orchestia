# Project Brief: Orchestia

## Objective

Orchestia provides a lightweight operating model for AI-assisted software development. Its first goal is to coordinate planning, bounded local execution, review, and reinjection of results without introducing an autonomous agent framework.

## User Context

The target user works with ChatGPT Business for planning and review, Codex CLI for local execution, WSL for Linux-oriented command execution, Git for source control, and Logics Manager-style documents for traceability.

## Target Architecture

- ChatGPT Business: research, planning, review, and next-step synthesis.
- Codex CLI: local bounded executor for explicit tasks.
- WSL: preferred execution environment for project commands.
- Git: source of truth for diffs, commits, branches, and reviewable state.
- Logics Manager structure: request, backlog, task, spec, ADR, and review records.

## MVP Scope

- Project documentation.
- Reusable prompt templates.
- Minimal environment and task-result scripts.
- Logics-compatible folder structure.
- Clear security and Git boundaries.

## Non-Goals

- No autonomous agent framework.
- No background automation.
- No GitHub Actions.
- No global dependency installation.
- No secret management system.
- No cross-repository modification.

## Design Principles

- Human-directed execution.
- Explicit scope before local changes.
- Git-first traceability.
- Reviewable outputs over hidden automation.
- Security boundaries stated plainly.
- Small scripts with predictable behavior.

## Success Criteria

- A new public repository can be created from this scaffold.
- A human can create a request, turn it into a task, execute with Codex CLI, collect diffs and test output, and review the result.
- Scripts do not perform destructive actions.
- Security constraints are visible to every agent and reviewer.
