# Codex Prompt: TASK-0052 Job Offer Reporting

Objective: add transparent local Markdown reporting to the local `job-offer-analyzer` project.

Work only in:

```text
/home/pmondou/ai-workspaces/job-offer-analyzer
```

Hard rules:

- Follow the no scraping policy for LinkedIn and all job boards.
- Do not modify Orchestia.
- Do not scrape LinkedIn.
- Do not automate browser access.
- Do not use LinkedIn APIs.
- Do not use external APIs.
- Do not use AI APIs.
- Do not install dependencies.
- Use Python standard library only.
- Keep changes minimal.
- Preserve CLI compatibility.
- Do not push or merge.
- Do not add a Git remote.
- Do not read secrets.
- Do not print environment variables.
- Do not add package metadata.

Authorized files in the project:

- `README.md`
- `src/job_offer_analyzer/__main__.py`
- `tests/test_smoke.py`
- `examples/job-offer-sample.md`
- `docs/product-brief.md`

Implementation goals:

- Add transparent local Markdown reporting for manually provided job offer files.
- Reuse the existing parser and scoring helpers.
- Preserve the existing `analyze` command.
- Add a simple report command or report option.
- Print the report to stdout by default.
- If file output is simple, support a local `--output report.md` option, but do not make file output mandatory.
- Include parsed fields, scoring details, red flags, recommendation, recruiter questions, and next action suggestions.
- Keep output deterministic and heuristic.
- Update tests to cover report behavior.
- Update README, product brief, and sample input if needed.

Expected reporting output sections:

- Job Offer Report
- Summary
- Extracted Fields
- Score
- Strengths
- Weaknesses
- Red Flags
- Recruiter Questions
- Recommendation
- Next Actions

Suggested CLI behavior:

```bash
python3 -m src.job_offer_analyzer report examples/job-offer-sample.md
```

Alternative compatible behavior is acceptable if this also works:

```bash
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md --report
```

Required checks:

```bash
python3 -m compileall src tests
python3 -m unittest discover -s tests
git diff --check
python3 -m src.job_offer_analyzer --help
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md
python3 -m src.job_offer_analyzer report examples/job-offer-sample.md
```
