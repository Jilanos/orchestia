# TASK-0010: Harden Helper Scripts

## Metadata

- ID: TASK-0010
- Backlog: [BL-0002 MVP Hardening](../backlog/BL-0002-mvp-hardening.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)
- Status: Completed
- Review: [REVIEW-0009 Helper Script Hardening](../reviews/REVIEW-0009-helper-script-hardening.md)

## Objective

Harden the MVP helper scripts and update the README repository tree.

## Scope

- Update `scripts/run_codex_task.sh`.
- Update `scripts/collect_test_results.sh`.
- Update the README repository structure section.
- Record this task and review in Logics memory.

## Completed Work

- `run_codex_task.sh` now refuses `--execute` mode under `/mnt/c` while preserving non-execution warning behavior.
- `collect_test_results.sh` now verifies Git repository context and warns under `/mnt/c`.
- README repository structure now mentions `docs/mvp-roadmap.md` and `logics/templates/`.

## Verification

Run the checks listed in [REVIEW-0009 Helper Script Hardening](../reviews/REVIEW-0009-helper-script-hardening.md).
