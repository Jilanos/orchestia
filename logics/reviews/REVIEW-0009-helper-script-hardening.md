# REVIEW-0009: Helper Script Hardening

## Metadata

- ID: REVIEW-0009
- Status: Accepted
- Task: [TASK-0010 Harden Helper Scripts](../tasks/TASK-0010-harden-helper-scripts.md)
- Backlog: [BL-0002 MVP Hardening](../backlog/BL-0002-mvp-hardening.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)

## Checks

- `test -f scripts/run_codex_task.sh`
- `test -f scripts/collect_test_results.sh`
- `test -f README.md`
- `bash -n scripts/run_codex_task.sh`
- `bash -n scripts/collect_test_results.sh`
- `bash scripts/run_codex_task.sh logics/tasks/TASK-0001-initial-scaffold.md`
- `bash scripts/collect_test_results.sh`
- `bash scripts/collect_test_results.sh -- bash -n scripts/run_codex_task.sh`
- `grep -R "docs/mvp-roadmap.md" README.md`
- `grep -R "logics/templates" README.md`
- `git status --short`
- `git diff --stat`

## Result

The helper scripts now apply safer path and Git-context checks while preserving the existing local MVP workflow.

## Accepted

- `run_codex_task.sh` still prints a copyable command by default and does not execute Codex without `--execute`.
- `run_codex_task.sh` refuses execution mode under `/mnt/c`.
- `collect_test_results.sh` checks that it is running inside a Git repository.
- `collect_test_results.sh` still handles missing and provided test commands correctly.
- README repository structure reflects the roadmap and templates.

## Risks

- The `/mnt/c` execution refusal was not exercised from a mounted Windows path in this run.
- Generated test result directories remain local and ignored by Git.

## Next Step

Continue MVP hardening with a lightweight validation checklist or a sample end-to-end task run.
