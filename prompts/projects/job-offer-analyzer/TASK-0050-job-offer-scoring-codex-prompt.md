# Codex Prompt: TASK-0050 Job Offer Scoring

Objective: add transparent local scoring heuristics to the local `job-offer-analyzer` project.

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

- Add transparent local scoring heuristics for manually provided job offer files.
- Reuse the existing parsed fields.
- Keep output human-readable.
- Score:
  - technical fit
  - seniority fit
  - work mode fit
  - role clarity
  - red flag penalty
- Output a simple total score.
- Output a short recommendation.
- Update tests to cover scoring behavior.
- Update README, product brief, and sample input if needed.
- Keep scoring deterministic and explainable.

Expected scoring output sections:

- Score
- Technical fit
- Seniority fit
- Work mode fit
- Role clarity
- Red flag penalty
- Recommendation

Expected CLI behavior:

```bash
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md
```

Required checks:

```bash
python3 -m compileall src tests
python3 -m unittest discover -s tests
git diff --check
python3 -m src.job_offer_analyzer --help
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md
```
