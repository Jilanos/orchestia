# REVIEW-0008: Logics Templates

## Metadata

- ID: REVIEW-0008
- Status: Accepted
- Task: [TASK-0009 Add Logics Templates](../tasks/TASK-0009-add-logics-templates.md)
- Backlog: [BL-0002 MVP Hardening](../backlog/BL-0002-mvp-hardening.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)

## Checks

- `test -f logics/templates/task_template.md`
- `test -f logics/templates/review_template.md`
- `test -f logics/tasks/TASK-0009-add-logics-templates.md`
- `test -f logics/reviews/REVIEW-0008-logics-templates.md`
- `grep -R "accept" logics/templates/review_template.md`
- `grep -R "revise" logics/templates/review_template.md`
- `grep -R "split" logics/templates/review_template.md`
- `grep -R "reject" logics/templates/review_template.md`
- `grep -R "logics/templates" README.md docs/workflow.md`
- `git status --short`
- `git diff --stat`

## Result

Reusable Logics task and review templates now exist for future Orchestia work.

## Accepted

- The task template is concise and includes the required execution and safety fields.
- The review template includes the required review evidence and decision fields.
- Review decisions are restricted to accept, revise, split, or reject.
- README and workflow documentation point to `logics/templates/`.

## Risks

- Templates are conventions only; schema tooling is intentionally not added yet.
- Future tasks should keep using the templates consistently before adding validation automation.

## Next Step

Use the templates for the next bounded task and review, then adjust them only if real use reveals a gap.
