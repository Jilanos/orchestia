# Codex Task Contract

## Purpose

This compact contract is the reusable baseline for Codex execution tasks in Orchestia. Future prompts should reference this file instead of repeating the full operating instructions, then add only task-specific scope, files, commands, and acceptance criteria.

## Required Prompt Shape

Every Codex task should include:

- Objective: the concrete outcome to complete.
- Authorized scope: exact repositories, directories, and files that may be changed.
- Out-of-scope actions: forbidden edits, commands, network actions, and release actions.
- Expected steps: the intended workflow, including pre-flight checks.
- Acceptance criteria: observable conditions for success.
- Verification commands: exact commands to run before commit.
- Git instructions: staging, commit message, push or no-push policy.
- Watch points: safety and product boundaries that must not be crossed.

## Default Operating Rules

- Start by verifying the current repository, branch, status, and relevant expected commits.
- Treat Git as the source of truth.
- Do not modify files outside the authorized scope.
- Do not revert user changes unless explicitly instructed.
- Keep changes small, reviewable, and tied to a written task.
- Prefer existing repository patterns over new abstractions.
- Use Python standard library and shell tooling already present in the repository unless a task explicitly authorizes dependencies.
- Use `rg` for text search when available.
- Use `apply_patch` for manual file edits.
- Run the requested validation commands and report any command that could not be run.

## Default Stop Conditions

Stop and report instead of improvising when:

- the working tree has unauthorized changes;
- an expected branch, commit, tag, or remote state is missing;
- an authorized file path would require editing outside the task scope;
- a command would read secrets or credential files;
- a command would push, merge, rebase, tag, force push, or delete branches without explicit authorization;
- validation fails in a way that would make a success commit misleading.

## How Future Prompts Should Use This

For routine tasks, use [Compact Prompt Mode](compact-prompt-mode.md) with this contract instead of writing a long standalone prompt.

Use a short reference block:

```text
Use docs/codex-task-contract.md as the default Codex operating contract.
Task-specific overrides:
- Authorized files: ...
- Verification commands: ...
- Git instructions: ...
```

Do not paste the full contract into every prompt unless a remote executor cannot access the repository.
