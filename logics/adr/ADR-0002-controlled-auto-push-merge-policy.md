# ADR-0002: Controlled Auto Push And Merge Policy

## Metadata

- ID: ADR-0002
- Status: Accepted
- Date: 2026-05-21
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)
- Backlog: [BL-0003 v0.2 Iterative Orchestration](../backlog/BL-0003-v0.2-iterative-orchestration.md)
- Task: [TASK-0014 Define v0.2 Iterative Orchestration And Auto Policy](../tasks/TASK-0014-define-v0.2-iterative-orchestration-and-auto-policy.md)
- Review: [REVIEW-0013 v0.2 Roadmap And Auto Policy](../reviews/REVIEW-0013-v0.2-roadmap-and-auto-policy.md)

## Context

Orchestia v0.1 established a conservative local workflow: human-supervised planning, bounded Codex execution, Git-based review, Logics memory, and no automatic push or merge.

For v0.2, Orchestia should support an iterative need-to-completion loop and may support controlled auto push and controlled auto merge on fresh projects or isolated branches. This must not turn Orchestia into a fully autonomous system.

This ADR defines policy only. It does not implement auto push or auto merge scripts.

## Decision

Allow controlled auto push and controlled auto merge only under explicit execution modes, branch policies, and review guardrails. `main` and `master` remain protected by default.

## Allowed Execution Modes

### Manual mode

- Codex proposes changes.
- Human reviews, commits, pushes and merges.

### Assisted mode

- Codex may prepare changes and commit locally.
- Human still pushes and merges.

### Auto branch mode

- Codex may create or use an isolated working branch.
- Codex may commit and push to that branch after checks pass.

### Controlled auto merge mode

- Codex may merge only into an explicitly authorized target branch.
- The target branch must be declared for the project or task.
- `main` and `master` are protected by default.
- Auto merge into main or master requires explicit override.

## Auto Push Guardrails

Auto push is allowed only if all conditions are true:

- The work is on a fresh project or isolated branch.
- The current branch is not main or master unless explicitly authorized.
- The target branch is explicitly declared.
- The working tree was clean before the task started.
- Modified files stay within the authorized task scope.
- Required checks pass.
- `git diff --stat` is reviewed or included in the task result.
- No secrets, `.env` files, credentials, or tokens are included in the diff.
- No force push is used.
- No destructive cleanup is performed.
- The automation produces a review record.

## Auto Merge Guardrails

Auto merge is allowed only if all conditions are true:

- Controlled auto merge mode is explicitly selected.
- The work is on a fresh project or isolated branch.
- The target branch is explicitly declared.
- The target branch is not main or master unless explicitly overridden.
- The working tree was clean before the task started.
- Modified files stay within the authorized task scope.
- Required checks pass.
- `git diff --stat` is reviewed or included in the task result.
- No secrets, `.env` files, credentials, or tokens are included in the diff.
- No force push is used.
- No destructive cleanup is performed.
- The automation produces a review record.

## Protected Branches Policy

- `main` and `master` are protected by default.
- Pushing directly to main or master without explicit override is forbidden.
- Merging into main or master without explicit override is forbidden.
- Force push is forbidden by default.
- Deleting branches without explicit instruction is forbidden.

## Rejected Alternatives

- Full autonomy: rejected because human control remains required for safety and scope decisions.
- Auto push from any branch: rejected because protected branches and dirty starting states create avoidable risk.
- Auto merge into main or master by default: rejected because release branches require explicit human authorization.
- Implementing automation before policy: rejected because guardrails must be documented first.

## Consequences

- v0.2 can define guarded automation without weakening default safety.
- Fresh projects and isolated branches can move faster after checks pass.
- Review records become mandatory evidence for automated push or merge.
- Task and prompt templates need updates before this policy can be implemented.
- Scripts must remain unchanged until a later implementation task.

## Follow-Up Implementation Tasks

- Add execution mode, target branch, and protected-branch override fields to Logics task templates.
- Update prompts to generate v0.2 primary needs, requests, backlog items, and tasks.
- Add validation checklist items for execution mode, clean starting state, and target branch.
- Implement guarded auto branch checks.
- Implement guarded auto push for isolated branches.
- Implement controlled auto merge checks.
- Add sample runs for Auto branch mode and Controlled auto merge mode before using them broadly.
