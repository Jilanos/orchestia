# Job Offer Analyzer Orchestration

## Purpose

Register `job-offer-analyzer` as the first new real mini project validation case after Orchestia `v0.2-alpha`.

The project builds a local job offer analyzer for descriptions manually copied by the user from LinkedIn or other job boards.

## Project Path

```text
/home/pmondou/ai-workspaces/job-offer-analyzer
```

## Current Status

- Local project repository initialized.
- Foundation primary need accepted.
- Parsing primary need accepted.
- Scoring primary need accepted.
- Reporting primary need accepted.
- Local project commits:
  - `6df941b Initialize job offer analyzer`
  - `22d431b Improve job offer parsing`
  - `c37d597 Add job offer scoring`
  - `dc6792f Add job offer reporting`
- Current Loop state: [LS-0002 Job Offer Analyzer](../logics/loop-states/LS-0002-job-offer-analyzer.md).
- Next primary need: [PN-0008 Job Offer Validation Docs](../logics/primary-needs/PN-0008-job-offer-validation-docs.md).

## Initial Need

[IN-0002 Job Offer Analyzer](../logics/initial-needs/IN-0002-job-offer-analyzer.md)

Analyze manually provided job offers copied from LinkedIn or other job boards. The MVP must work from user-provided text files, Markdown files, or pasted job descriptions only.

## Primary Need Decomposition

- [PN-0004 Job Offer Analyzer Foundation](../logics/primary-needs/PN-0004-job-offer-analyzer-foundation.md): complete.
- [PN-0005 Job Offer Parsing](../logics/primary-needs/PN-0005-job-offer-parsing.md): complete.
- [PN-0006 Job Offer Scoring](../logics/primary-needs/PN-0006-job-offer-scoring.md): complete.
- [PN-0007 Job Offer Reporting](../logics/primary-needs/PN-0007-job-offer-reporting.md): complete.
- [PN-0008 Job Offer Validation Docs](../logics/primary-needs/PN-0008-job-offer-validation-docs.md): planned.

## Completed Foundation Work

- Created local Git repository.
- Added Python standard-library CLI.
- Added sample manually provided job offer Markdown file.
- Added smoke tests.
- Added README and product brief.
- Verified CLI help and sample analysis.
- Committed local project foundation.

## Completed Parsing Work

- Prepared [REQ-0006 Job Offer Parsing](../logics/requests/REQ-0006-job-offer-parsing.md), [BL-0008 Job Offer Parsing](../logics/backlog/BL-0008-job-offer-parsing.md), and [TASK-0046 Implement Job Offer Parsing](../logics/tasks/TASK-0046-implement-job-offer-parsing.md).
- Ran controlled auto-loop evidence capture at `task-runs/20260525T130053Z-auto-loop/`.
- Executed Codex with `codex exec --sandbox workspace-write` against `/home/pmondou/ai-workspaces/job-offer-analyzer`.
- Added heuristic parsing for title, company, location, contract type, work mode, seniority, technologies, languages, missions, requirements, red flags, and recommendation.
- Updated the sample job offer, README, product brief, and smoke tests.
- Committed local project parsing work as `22d431b Improve job offer parsing`.
- Finalized [REVIEW-0043 Job Offer Parsing Execution](../logics/reviews/REVIEW-0043-job-offer-parsing-execution.md) with decision `accept`.

## Completed Scoring Work

- Prepared [REQ-0007 Job Offer Scoring](../logics/requests/REQ-0007-job-offer-scoring.md), [BL-0009 Job Offer Scoring](../logics/backlog/BL-0009-job-offer-scoring.md), and [TASK-0050 Implement Job Offer Scoring](../logics/tasks/TASK-0050-implement-job-offer-scoring.md).
- Ran autonomous-loop evidence capture at `task-runs/20260526T084858Z-autonomous-loop/`.
- Executed Codex with `codex exec --sandbox workspace-write` against `/home/pmondou/ai-workspaces/job-offer-analyzer`.
- Completed one autonomous cycle with decision `accept`.
- Added deterministic local scoring for technical fit, seniority fit, work mode fit, role clarity, red flag penalty, total score, and recommendation.
- Updated README, product brief, and smoke tests.
- Committed local project scoring work as `c37d597 Add job offer scoring`.
- Finalized [REVIEW-0045 Job Offer Scoring Execution](../logics/reviews/REVIEW-0045-job-offer-scoring-execution.md) with decision `accept`.
- Finalized [REVIEW-0046 Autonomous Loop Job Offer Analyzer](../logics/reviews/REVIEW-0046-autonomous-loop-job-offer-analyzer.md) with decision `accept`.
- The autonomous-loop stopped after the accepted scoring cycle because the next reporting prompt is not prepared yet; LS-0002 was advanced after review.

## Completed Reporting Work

- Prepared [REQ-0008 Job Offer Reporting](../logics/requests/REQ-0008-job-offer-reporting.md), [BL-0010 Job Offer Reporting](../logics/backlog/BL-0010-job-offer-reporting.md), and [TASK-0052 Implement Job Offer Reporting](../logics/tasks/TASK-0052-implement-job-offer-reporting.md).
- Ran autonomous-loop evidence capture at `task-runs/20260526T090931Z-autonomous-loop/`.
- Executed Codex with `codex exec --sandbox workspace-write` against `/home/pmondou/ai-workspaces/job-offer-analyzer`.
- Completed one autonomous cycle with decision `accept`.
- Added deterministic local Markdown reporting through a `report` command, `analyze --report`, and optional local `--output` file support.
- Reports include extracted fields, score details, strengths, weaknesses, red flags, recruiter questions, recommendation, and next actions.
- Updated README, product brief, and smoke tests.
- Committed local project reporting work as `dc6792f Add job offer reporting`.
- Finalized [REVIEW-0047 Job Offer Reporting Execution](../logics/reviews/REVIEW-0047-job-offer-reporting-execution.md) with decision `accept`.
- Finalized [REVIEW-0048 Autonomous Loop Job Offer Reporting](../logics/reviews/REVIEW-0048-autonomous-loop-job-offer-reporting.md) with decision `accept`.
- The autonomous-loop stopped after the accepted reporting cycle because the next validation/docs prompt is not prepared yet; LS-0002 was advanced after review.

## Next Planned Task

Prepare the validation/docs request, backlog item, task, and Codex prompt.

## Constraints And Non-Goals

- Python standard library first.
- Local CLI first.
- Local files only.
- No external API.
- No AI API call.
- No dependency install.
- No browser automation.
- No package publishing yet.
- No project remote yet.

## No Scraping Policy

No scraping is allowed.

The project must not:

- scrape LinkedIn or any other job board;
- automate browser access;
- log in to LinkedIn;
- use LinkedIn APIs;
- collect personal data from LinkedIn;
- bypass platform rules;
- use browser cookies or credentials.

All input must be manually provided by the user as local text, Markdown, or pasted job descriptions.

The PN-0005 parsing execution, PN-0006 scoring execution, and PN-0007 reporting execution preserved this policy. No scraping, browser automation, LinkedIn API, external API, dependency install, package metadata, project remote, project push, or project merge was added.

## Validation Commands

```bash
cd /home/pmondou/ai-workspaces/job-offer-analyzer
python3 -m compileall src tests
python3 -m unittest discover -s tests
python3 -m src.job_offer_analyzer --help
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md
python3 -m src.job_offer_analyzer report examples/job-offer-sample.md
git diff --check
```

The PN-0005, PN-0006, and PN-0007 validations also verified that the project has no Git remote and that `src` and `tests` do not contain forbidden implementation imports for scraping or browser automation libraries.

## Known Risks

- Parser output is more structured but still heuristic.
- Keyword, language, and seniority detection can overmatch or miss unusual phrasing.
- Score values are deterministic but still heuristic and should be presented as prioritization hints.
- Future validation/docs work needs explicit criteria and tests.
- Reporting questions are deterministic and generic until user-defined criteria are added.
- Compliance boundaries must remain visible in every future task.
