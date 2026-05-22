# TASK-0034: Add Review Finalization Support

## Status

Complete

## Objective

Add a human-approved `finalize-review` command to `scripts/orchestia_loop.sh` that converts a local review draft under `task-runs/` into a versioned Logics review.

## Context

`git-flow-review-draft` creates ignored Markdown drafts under `task-runs/`. Those drafts are useful for review preparation, but final Logics reviews must be explicitly versioned and decisions must remain human-owned.

## Authorized Scope

- `scripts/orchestia_loop.sh`
- README, workflow, and roadmap documentation
- New task and review records for this work

## Out Of Scope

- Modifying `scripts/controlled_git_flow.sh`
- Updating Loop state automatically
- Making review decisions automatically
- Pushing or merging from `finalize-review`
- Creating final reviews without an explicit decision

## Expected Steps

1. Add `finalize-review` to `scripts/orchestia_loop.sh`.
2. Require `--draft`, `--review-id`, `--review-title`, `--reviewed-task`, and `--decision`.
3. Restrict decisions to `accept`, `revise`, `split`, or `reject`.
4. Refuse drafts outside `task-runs/`.
5. Refuse to overwrite existing Logics review files.
6. Create final review Markdown under `logics/reviews/`.
7. Update concise documentation.

## Verification Commands

```bash
bash -n scripts/orchestia_loop.sh
bash scripts/orchestia_loop.sh
grep -R "finalize-review" README.md docs/workflow.md scripts/orchestia_loop.sh
```

Functional verification used a temporary `REVIEW-9999` file created from a temporary draft under `task-runs/`, then removed the temporary final review before commit.

## Acceptance Criteria

- `finalize-review` requires an explicit decision.
- Allowed decisions are `accept`, `revise`, `split`, and `reject`.
- Drafts must be under `task-runs/`.
- Final reviews are created under `logics/reviews/`.
- Existing reviews are not overwritten.
- Loop state is not updated.
- No push or merge is performed.

## Result

Implemented. Review finalization is now available as a human-approved step separate from draft creation, Loop state advancement, and Git automation.
