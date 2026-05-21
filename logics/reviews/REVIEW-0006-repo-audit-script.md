# REVIEW-0006: Repo Audit Script

## Metadata

- ID: REVIEW-0006
- Status: Accepted
- Task: [TASK-0007 Add Repo Audit Script](../tasks/TASK-0007-add-repo-audit-script.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)
- Backlog: [BL-0001 Foundation](../backlog/BL-0001-foundation.md)

## Checks

- `test -f scripts/audit_repo.sh`
- `bash -n scripts/audit_repo.sh`
- `bash scripts/audit_repo.sh`
- `find task-runs -type f -name "repo-audit.md" | sort | tail -1`
- `grep -R "audit_repo.sh" README.md docs/workflow.md`
- `grep -R "repo-audit.md" README.md docs/workflow.md`
- `git status --short`
- `git diff --stat`

## Result

The MVP now has a local repository audit script that collects reviewable Git and structure evidence into a Markdown report for ChatGPT Business review.

## Accepted

- The script is local, dependency-free, and non-destructive.
- The generated report is written under `task-runs/`.
- The report avoids environment variables and secret-file contents.
- README and workflow documentation explain how to run the audit.
- The repository audit prompt matches the generated report structure.

## Risks

- The audit report is not a security guarantee; it is a review aid.
- Generated reports are ignored by Git and should be summarized into Logics memory when findings matter.

## Next Step

Use `scripts/audit_repo.sh` before repository-level reviews and paste the generated report into ChatGPT Business with `prompts/repo_audit_prompt.md`.
