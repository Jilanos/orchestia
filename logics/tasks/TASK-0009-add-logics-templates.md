# TASK-0009: Add Logics Templates

## Metadata

- ID: TASK-0009
- Backlog: [BL-0002 MVP Hardening](../backlog/BL-0002-mvp-hardening.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)
- Status: Completed
- Review: [REVIEW-0008 Logics Templates](../reviews/REVIEW-0008-logics-templates.md)

## Objective

Add reusable Logics document templates for Orchestia tasks and reviews.

## Scope

- Create `logics/templates/task_template.md`.
- Create `logics/templates/review_template.md`.
- Add short references to the templates in `README.md` and `docs/workflow.md`.
- Record this task and review in Logics memory.

## Completed Work

- Added a task template with stable ID, title, status, related request, backlog item, objective, context, scope, steps, tests, acceptance criteria, watch points, security rules, and result summary.
- Added a review template with stable ID, title, reviewed task, reviewed commit or diff, inputs reviewed, checks, findings, risks, decision, follow-up, and next recommended task.
- Restricted review decisions to accept, revise, split, or reject.
- Linked the templates from README and workflow documentation.

## Verification

Run the checks listed in [REVIEW-0008 Logics Templates](../reviews/REVIEW-0008-logics-templates.md).
