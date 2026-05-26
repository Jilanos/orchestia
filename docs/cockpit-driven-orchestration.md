# Cockpit-Driven Orchestration

## Purpose

Define the Orchestia `v0.3` cockpit-driven orchestration model before implementation. The goal is to let the local cockpit drive more of the workflow while preserving explicit human confirmations, review gates, and controlled Git boundaries.

## UI Pages

- Dashboard: current system status and human action required.
- Needs: draft intakes and Logics initial needs.
- Need draft detail: inspect a draft and prepare Logics drafts.
- Logics draft review: compare generated draft records before promotion.
- Task prompt draft: prepare and inspect task-specific Codex prompt drafts.
- Loop launch: preview autonomous-loop command and require confirmation.
- Loop run status: refreshed run state, evidence, errors, blockers, and instructions.
- Iterations: timeline across tasks, reviews, and task-runs.
- Tokens: evidence-based usage summaries.
- Reviews: draft and finalized review records.
- Controlled publication: handoff and dry-run previews.

## Allowed Cockpit Actions

- Create need intake drafts under `task-runs/`.
- Generate Logics draft files under `task-runs/`.
- Promote reviewed Logics drafts only after explicit confirmation.
- Prepare task prompt drafts.
- Launch autonomous-loop only with explicit confirmation.
- Append autonomous-loop instructions.
- Append autonomous-loop stop requests.
- Finalize reviews with explicit review ID, reviewed task, and decision.
- Prepare controlled Git flow handoff reports and dry-run previews.

## Forbidden Cockpit Actions

- No hidden Codex execution.
- No arbitrary command execution.
- No unreviewed final Logics mutation.
- No push or merge without controlled Git flow guardrails and explicit confirmation.
- No force push, rebase, tag, branch deletion, or protected-branch bypass.
- No secret, `.env`, SSH key, token, credential, hidden dotfile, or `.git` exposure.
- No external API or billing API calls.

## Need Intake To Logics Draft Flow

1. User submits a need intake form.
2. Cockpit writes a draft under `task-runs/<timestamp>-need-intake/`.
3. Cockpit generates draft Logics records under the same task-runs evidence directory.
4. User reviews generated drafts.
5. Promotion to final Logics records requires explicit confirmation and collision checks.
6. Promotion evidence is recorded.

## Task Prompt Preparation Flow

1. User selects a planned task or backlog item.
2. Cockpit shows authorized scope, out-of-scope actions, acceptance criteria, checks, and watch points.
3. Cockpit prepares a prompt draft under `task-runs/` or a project prompt path after confirmation.
4. User reviews the prompt before any execution.

## Autonomous-Loop Launch Flow

1. Cockpit reads Loop state, workspace, prepared prompt, test command, and execution flags.
2. Cockpit shows a command preview and risk summary.
3. User explicitly confirms launch.
4. The backend invokes only the allowed `autonomous-loop` command shape.
5. Evidence is written under `task-runs/`.
6. UI refreshes status and links to cycle evidence.

## Instruction And Stop Flow

- Instructions append to `task-runs/*-autonomous-loop/instructions.md`.
- Stop requests append to `task-runs/*-autonomous-loop/stop-request.md`.
- Both actions timestamp text and do not execute commands by themselves.

## Token Usage Evidence Flow

- Cockpit scans local evidence files.
- Machine-readable token records should be preferred when available.
- Missing values are shown as unavailable.
- The UI does not estimate usage or call billing APIs.

## Review Finalization Flow

1. User selects a review draft.
2. Cockpit requires review ID, reviewed task, title, and decision.
3. Decision must be one of `accept`, `revise`, `split`, or `reject`.
4. Existing final reviews cannot be overwritten.
5. Finalization does not advance Loop state unless a separate explicit advancement action is implemented and confirmed.

## Controlled Publication Flow

- Cockpit can prepare controlled Git flow handoff and dry-run evidence.
- Execute push and merge remain explicit and guarded.
- Protected branches remain blocked unless a separate reviewed policy allows otherwise.
- Publication records must cite evidence and resulting remote refs.

## Safety Constraints

- Bind to localhost by default.
- Validate all paths relative to the repository or selected workspace.
- Refuse hidden, `.git`, secret-like, oversized, and binary-looking files.
- Keep write actions narrow and auditable.
- Record action evidence under `task-runs/`.
- Keep human control over blockers, ambiguous next needs, decisions, execute authorization, push, and merge.

## Implementation Phases

1. Need intake to Logics draft generation.
2. Draft promotion with collision checks and review evidence.
3. Task prompt draft preparation.
4. Confirmed autonomous-loop launch.
5. Run status refresh and token evidence improvements.
6. Review finalization from UI.
7. Controlled Git flow handoff preparation.
8. v0.3 negative-path validation and release readiness.
