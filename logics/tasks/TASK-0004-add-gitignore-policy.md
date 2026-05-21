# TASK-0004: Add Gitignore Policy

## Metadata

- ID: TASK-0004
- Backlog: [BL-0001 Foundation](../backlog/BL-0001-foundation.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)
- Status: Completed
- Review: [REVIEW-0003 Gitignore Policy](../reviews/REVIEW-0003-gitignore-policy.md)

## Objective

Add a safe `.gitignore` policy for generated runtime outputs and local development artifacts.

## Scope

- Ignore generated `task-runs/` contents by default.
- Keep `task-runs/.gitkeep` trackable.
- Ignore local environment files while allowing `.env.example`.
- Ignore common local dependency, build, coverage, cache, and system artifacts.

## Completed Work

- Created `.gitignore`.
- Added explicit negation rules for `task-runs/.gitkeep` and `.env.example`.
- Left existing generated `task-runs/` directories in place.

## Verification

Run the checks listed in [REVIEW-0003 Gitignore Policy](../reviews/REVIEW-0003-gitignore-policy.md).
