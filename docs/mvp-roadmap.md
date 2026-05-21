# MVP Roadmap

## Current State

Orchestia v0.1 provides the local workflow foundation: WSL-first workspace guidance, helper scripts, repository audit output, prompt templates, Logics templates, a validation checklist, a sample end-to-end run, and a release readiness review.

The next goal is v0.2: iterative need-to-completion orchestration.

The minimal state model for v0.2 is defined in [Orchestration State Model](orchestration-state-model.md), with reusable templates in `logics/templates/`.

## v0.2 Goal

v0.2 takes an initial user need, decomposes it into primary needs, and for each primary need runs a structured Logics and Codex execution loop until the primary need is complete or a firm blocker is reached.

The system must continue until the initial need is complete, all remaining work is explicitly out of scope, or a firm blocker prevents safe progress.

## Macro Loop

Initial need -> primary needs -> request/backlog/tasks per primary need -> completion review -> next primary need.

The macro loop includes:

- Initial need intake.
- Primary need decomposition.
- Request creation per primary need.
- Backlog item creation.
- Task generation.
- Completion review for each primary need.
- Next primary need selection.

## Micro Loop

Task -> Codex execution -> collect outputs -> review -> accept, revise, split or reject.

The micro loop includes:

- Codex prompt generation.
- Codex execution.
- Diff, logs and test collection.
- Review decision.
- Follow-up task creation when the decision is revise, split or reject.

## Loop Rules

- One task should remain bounded and reviewable.
- The review decision must be one of: accept, revise, split or reject.
- Accepted work can advance the current primary need.
- Revise means continue with a scoped correction task.
- Split means create smaller tasks before continuing.
- Reject means discard the approach and return to planning.
- The loop stops only when completion criteria are met or a firm blocker is documented.

## Completion Criteria

The initial need is complete only when every primary need is one of:

- Accepted as complete.
- Explicitly out of scope.
- Blocked by a documented firm blocker.

## Firm Blocker Criteria

Firm blocker examples include:

- Missing credentials.
- Unclear product decision.
- Unsafe command required.
- Failing external dependency.
- Insufficient repository context.
- Repeated Codex failure on the same task.
- Unavailable test environment.

## Human Control Points

- Approve the initial need and primary needs.
- Approve scope for each request, backlog item, and task.
- Approve execution mode before Codex runs.
- Review diffs, logs, tests, and review records.
- Decide whether work is complete, out of scope, blocked, or safe to continue.
- Explicitly authorize any tag, push to protected branch, or merge into protected branch.

## Execution Modes

- Manual mode: Codex proposes changes; human reviews, commits, pushes and merges.
- Assisted mode: Codex may prepare changes and commit locally; human still pushes and merges.
- Auto branch mode: Codex may create or use an isolated working branch, then commit and push to that branch after checks pass.
- Controlled auto merge mode: Codex may merge only into an explicitly authorized target branch.

## Controlled Auto Push And Merge

For v0.2, Orchestia may support controlled auto branch execution, controlled auto push, and controlled auto merge only for fresh projects or isolated branches and only behind explicit policy checks.

`main` and `master` remain protected by default. Auto push directly to main or master, or auto merge into main or master, requires an explicit override.

## Non-Goals For v0.2

- Full autonomy.
- Background agents or daemons.
- Secret management automation.
- Unrestricted push or merge.
- Force push.
- Cross-repository orchestration.
- Modifying personal Windows files.
- Bypassing failed checks.

## v0.2 Candidate Tasks

1. Use the orchestration state templates for one manual v0.2 run.
2. Add execution mode fields to Logics task templates.
3. Update prompts to generate primary needs, requests, backlog items, and executable tasks.
4. Add review schema fields for primary need completion and blockers.
5. Define a manual primary-need decomposition example.
6. Implement guarded auto branch checks.
7. Implement guarded auto push for isolated branches.
8. Implement controlled auto merge checks.
9. Update validation checklist for v0.2 execution modes.
