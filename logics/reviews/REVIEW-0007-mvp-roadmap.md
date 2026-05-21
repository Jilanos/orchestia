# REVIEW-0007: MVP Roadmap

## Metadata

- ID: REVIEW-0007
- Status: Accepted
- Task: [TASK-0008 Add MVP Roadmap](../tasks/TASK-0008-add-mvp-roadmap.md)
- Backlog: [BL-0002 MVP Hardening](../backlog/BL-0002-mvp-hardening.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)

## Checks

- `test -f docs/mvp-roadmap.md`
- `test -f logics/backlog/BL-0002-mvp-hardening.md`
- `test -f logics/tasks/TASK-0008-add-mvp-roadmap.md`
- `test -f logics/reviews/REVIEW-0007-mvp-roadmap.md`
- `grep -R "MVP roadmap" README.md docs/mvp-roadmap.md`
- `grep -R "full autonomy" docs/mvp-roadmap.md`
- `grep -R "v0.1" docs/mvp-roadmap.md`
- `git status --short`
- `git diff --stat`

## Result

The MVP roadmap defines the current state, remaining milestones, risks, next tasks, and completion criteria for Orchestia MVP hardening.

## Accepted

- The roadmap is concise and scoped to MVP hardening.
- Remaining milestones include schema hardening, review decisions, sample run, audit review loop, validation, optional compatibility check, documentation cleanup, and v0.1 release preparation.
- The README links to the roadmap.
- The roadmap warns against full autonomy before the workflow is proven.

## Risks

- The roadmap will need updates as tasks are completed.
- The v0.1 tag must not be created until explicitly authorized in a later task.

## Next Step

Start with task file schema hardening so future Codex tasks remain consistent and reviewable.
