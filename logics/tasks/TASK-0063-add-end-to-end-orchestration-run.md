# TASK-0063: Add End-To-End Orchestration Run

## Objective

Implement the first v0.3 end-to-end orchestration runner that can chain need intake evidence, Logics draft evidence, task prompt generation, local Codex execution, checks, review evidence, policy-based acceptance, advancement evidence, and controlled auto-push.

## Context

v0.3 moves Orchestia toward cockpit-driven orchestration. The cockpit can create need intakes and Logics drafts, autonomous-loop can execute Codex locally, and `controlled_git_flow.sh` can guard push and merge. This task adds the first global runner while keeping merge and browser execution out of scope.

## Authorized Scope

- `scripts/orchestia_loop.sh`
- `scripts/orchestia_ui.py`
- `README.md`
- `docs/workflow.md`
- `docs/local-cockpit.md`
- `docs/cockpit-driven-orchestration.md`
- `docs/mvp-roadmap.md`
- `docs/end-to-end-orchestration-run.md`
- `logics/tasks/TASK-0063-add-end-to-end-orchestration-run.md`
- `logics/reviews/REVIEW-0058-end-to-end-orchestration-run.md`

## Implementation Summary

- Added `orchestration-run` to `scripts/orchestia_loop.sh`.
- Added run policy, summary, events, cycle, review, prompt, Logics draft, advancement, and Git-flow evidence under `task-runs/*-orchestration-run/`.
- Added explicit policy flags for Codex execution, Logics promotion package, prompt generation, auto-accept, advancement evidence, and controlled auto-push.
- Delegated push to `scripts/controlled_git_flow.sh auto-push`.
- Refused `main/master` as auto-push branches.
- Added cockpit pages for orchestration run list, run detail, start request, instruction append, and stop request.
- Kept cockpit execution as request-only with a command preview.

## Validation Commands

```bash
bash -n scripts/orchestia_loop.sh
python3 -m py_compile scripts/orchestia_ui.py

bash scripts/orchestia_loop.sh orchestration-run \
  task-runs/orchestration-run-disposable/need-intake/need-intake.md \
  --workspace task-runs/orchestration-run-disposable/workspace \
  --max-cycles 1 \
  --execute-codex \
  --auto-promote-logics \
  --auto-generate-task-prompts \
  --auto-accept-if-checks-pass \
  --advance-if-next-ready \
  --auto-push \
  --remote origin \
  --push-branch integration \
  --test "python3 -m unittest discover -s tests"

python3 scripts/orchestia_ui.py --host 127.0.0.1 --port 8765
curl -fsS http://127.0.0.1:8765/orchestration-runs
curl -fsS http://127.0.0.1:8765/orchestration/start
curl -fsS -X POST http://127.0.0.1:8765/orchestration/start ...

git diff --check
```

## Result

- Result: accepted.
- Disposable validation completed with Codex execution, passing tests, auto-accept, advancement evidence, and controlled auto-push to a local bare remote.
- No GitHub remote was used for validation.
- No merge was implemented or performed.
- No real project was modified.
