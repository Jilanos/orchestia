# TASK-0007: Add Repo Audit Script

## Metadata

- ID: TASK-0007
- Backlog: [BL-0001 Foundation](../backlog/BL-0001-foundation.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)
- Status: Completed
- Review: [REVIEW-0006 Repo Audit Script](../reviews/REVIEW-0006-repo-audit-script.md)

## Objective

Add a safe local repository audit script for the Orchestia MVP.

## Scope

- Create `scripts/audit_repo.sh`.
- Add concise usage notes to `README.md` and `docs/workflow.md`.
- Align `prompts/repo_audit_prompt.md` with the generated audit report.
- Record this task and review in Logics memory.

## Completed Work

- Added a dependency-free Bash audit script that verifies Git context, warns under `/mnt/c`, and writes a timestamped `task-runs/.../repo-audit.md` report.
- The report includes current directory, branch, remotes, recent commits, status, diff stat, tracked files, key file checks, and suggested manual checks.
- Updated documentation and the repository audit prompt for the new audit output.

## Verification

Run the checks listed in [REVIEW-0006 Repo Audit Script](../reviews/REVIEW-0006-repo-audit-script.md).
