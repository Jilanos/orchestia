# Orchestration State Model

This document defines the minimal v0.2 state model for Orchestia's iterative need-to-completion loop. It is a documentation model only; it does not implement automation.

## Initial Need

The initial need is the original user-level goal that starts an orchestration run.

Fields:

- ID: stable identifier.
- Title: short human-readable name.
- Original user-level goal: the user's starting need.
- Success criteria: observable completion conditions.
- Constraints: technical, safety, policy, time, or scope constraints.
- Non-goals: explicit exclusions.
- Primary needs: linked list of derived primary needs.
- Global status: one of the allowed initial need statuses.

Allowed initial need status:

- intake
- decomposed
- in_progress
- complete
- blocked
- cancelled

## Primary Need

A primary need is a coherent sub-need derived from the initial need. Each primary need should be small enough to plan, execute, review, and complete through Logics records.

Fields:

- ID: stable identifier.
- Title: short human-readable name.
- Parent initial need: linked initial need.
- Related request: linked request file.
- Related backlog items: linked backlog files.
- Related tasks: linked task files.
- Status: one of the allowed primary need statuses.
- Completion criteria: observable conditions for completion.
- Blockers: documented firm blockers, if any.

Allowed primary need status:

- proposed
- accepted
- in_progress
- complete
- blocked
- out_of_scope

## Loop State

Loop state tracks the current position in the micro loop for one primary need.

Fields:

- Current primary need.
- Current request.
- Current backlog item.
- Current task.
- Last Codex run.
- Last review.
- Decision.
- Next action.
- Stop condition.

Allowed task loop decision:

- accept
- revise
- split
- reject

Stop conditions:

- all primary needs complete
- remaining primary needs out of scope
- firm blocker reached
- human stop requested

## Firm Blocker Criteria

A firm blocker prevents safe progress until a human resolves it or changes scope.

Firm blocker examples:

- missing credentials
- unclear product decision
- unsafe command required
- failing external dependency
- insufficient repository context
- repeated Codex failure on the same task
- unavailable test environment

## State Transitions

- Initial need starts as `intake`.
- After primary needs are identified, initial need becomes `decomposed`.
- When work begins on any accepted primary need, initial need becomes `in_progress`.
- A primary need moves from `proposed` to `accepted` only after human approval.
- A primary need becomes `complete` only after review accepts its completion criteria.
- A primary need becomes `blocked` only with a documented firm blocker.
- Initial need becomes `complete` only when every primary need is complete, out_of_scope, or blocked by a documented firm blocker.
