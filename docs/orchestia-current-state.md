# Orchestia Current State

## Purpose

This file is the compact current-state reference for future Orchestia tasks. Update it when release state or validated capabilities materially change, so prompts can cite this file instead of repeating long project history.

## Repository State

- Repository: `~/ai-workspaces/orchestia`
- Primary branch: `master`
- Current v0.3 baseline commit: `e9c3175 Add end-to-end orchestration run`
- Latest known commit before TASK-0065: `b81113f Add compact Codex operating context`
- Remote: `origin https://github.com/Jilanos/orchestia.git`
- Latest release tag: `v0.2-beta`
- Active development line: `v0.3`

## Validated v0.2-beta Capabilities

- Logics records track initial needs, primary needs, requests, backlog items, tasks, and reviews.
- Local autonomous-loop execution can run Codex with explicit CLI authorization.
- Controlled Git flow can push guarded integration branches without merging.
- The local cockpit provides inspection pages, need intake drafts, iteration timelines, token evidence, and safe instruction/stop files.
- `job-offer-analyzer` completed an end-to-end local MVP and was published to GitHub on branch `integration`.

## job-offer-analyzer Reference State

- Repository: `~/ai-workspaces/job-offer-analyzer`
- Branch: `integration`
- Remote: `origin https://github.com/Jilanos/job-offer-analyzer.git`
- Published commit: `96efb67 Add validation and documentation`
- Publication branch: `integration`
- Product boundary: manual-input job offer analysis only; no scraping, browser automation, LinkedIn API, external APIs, or added dependencies.

## Active v0.3 Capabilities

- v0.3 is active.
- `scripts/orchestia_loop.sh orchestration-run` exists.
- `orchestration-run` is implemented.
- `orchestration-run` can connect need intake or Loop state evidence to Logics drafts, prompt evidence, Codex execution, tests, review evidence, Loop advancement evidence, and controlled auto-push when explicitly authorized.
- Default `orchestration-run` behavior is dry-run evidence and command preview.
- Auto-push refuses protected `main` and `master` branches by default.
- Cockpit routes exist for:
  - `/orchestration-runs`
  - `/orchestration-run`
  - `/orchestration/start`

## Known v0.3 Limitations

- Final tracked Logics promotion is not fully automated.
- Multi-cycle next-state selection remains intentionally limited.
- Browser-triggered execution must remain explicit, guarded, and validated before expansion.
- Token usage is evidence-based and may be unavailable when runs do not record it.
- Publication and merge actions remain separate controlled workflows.

## Next Focus

- Token-efficient operation through shared compact prompt references.
- Real local workspace validation for `orchestration-run` without GitHub remotes.

## How Future Prompts Should Use This

Future prompts should use this file as the compact baseline for repository and capability state.

Use this file as the compact baseline:

```text
Use docs/orchestia-current-state.md for current repository, release, and validated capability context.
Only restate task-specific state that differs from that document.
```
