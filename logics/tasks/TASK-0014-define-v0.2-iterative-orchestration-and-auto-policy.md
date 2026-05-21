# TASK-0014: Define v0.2 Iterative Orchestration And Auto Policy

## Metadata

- ID: TASK-0014
- Backlog: [BL-0003 v0.2 Iterative Orchestration](../backlog/BL-0003-v0.2-iterative-orchestration.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)
- Status: Completed
- ADR: [ADR-0002 Controlled Auto Push And Merge Policy](../adr/ADR-0002-controlled-auto-push-merge-policy.md)
- Review: [REVIEW-0013 v0.2 Roadmap And Auto Policy](../reviews/REVIEW-0013-v0.2-roadmap-and-auto-policy.md)

## Objective

Define Orchestia v0.2 as an iterative need-to-completion orchestration loop and update the safety policy for controlled auto push and controlled auto merge.

## Scope

- Update `docs/mvp-roadmap.md`.
- Update `docs/security-boundaries.md`.
- Update `docs/workflow.md`.
- Update `README.md`.
- Create BL-0003, ADR-0002, and REVIEW-0013 records.
- Do not implement auto push or auto merge automation.

## Completed Work

- Defined the v0.2 macro loop from initial need to primary need completion.
- Defined the v0.2 micro loop from task execution to review decision.
- Documented completion criteria, firm blocker criteria, and human control points.
- Documented Manual mode, Assisted mode, Auto branch mode, and Controlled auto merge mode.
- Documented controlled auto push and auto merge guardrails.

## Verification

Run the checks listed in [REVIEW-0013 v0.2 Roadmap And Auto Policy](../reviews/REVIEW-0013-v0.2-roadmap-and-auto-policy.md).
