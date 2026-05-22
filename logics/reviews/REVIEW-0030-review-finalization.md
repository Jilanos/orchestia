# REVIEW-0030: Review Finalization Support

## Reviewed Task

[TASK-0034](../tasks/TASK-0034-add-review-finalization.md)

## Inputs Reviewed

- `scripts/orchestia_loop.sh`
- `README.md`
- `docs/workflow.md`
- `docs/mvp-roadmap.md`
- `logics/templates/review_template.md`
- `REVIEW-0029`

## Checks Performed

- Ran Bash syntax validation for `scripts/orchestia_loop.sh`.
- Ran usage output for `scripts/orchestia_loop.sh`.
- Checked documentation references for `finalize-review`.
- Created a temporary review draft under `task-runs/`.
- Ran `finalize-review` with temporary `REVIEW-9999`.
- Verified the temporary final review contained the review ID, reviewed task, and decision.
- Removed the temporary final review before commit.

## Findings

- `finalize-review` requires an explicit draft, review ID, title, reviewed task, and decision.
- Decisions are restricted to `accept`, `revise`, `split`, or `reject`.
- Drafts outside `task-runs/` are refused.
- Final reviews are created under `logics/reviews/`.
- Existing final reviews are not overwritten.
- The command does not update Loop state.
- The command does not push, merge, or call `controlled_git_flow.sh`.

## Risks

- Section extraction from drafts is intentionally lightweight and depends on simple Markdown headings.
- Humans still need to review the generated final file before committing in real workflows.
- Loop state advancement remains a separate manual or future guarded command.

## Decision

accept

## Required Follow-Up

Use `finalize-review` on the next real review draft, then update Loop state in a separate explicit task if needed.

## Next Recommended Task

Add a guarded Loop state advancement command or document the manual advancement process for finalized reviews.
