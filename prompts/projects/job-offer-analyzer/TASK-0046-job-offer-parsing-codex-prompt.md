# Codex Prompt: TASK-0046 Job Offer Parsing

Objective: improve parsing of manually provided job offer text in the local `job-offer-analyzer` project.

Work only in:

```text
/home/pmondou/ai-workspaces/job-offer-analyzer
```

Hard rules:

- Follow the no scraping policy for LinkedIn and all job boards.
- Do not modify Orchestia.
- Do not scrape LinkedIn.
- Do not automate browser access.
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

- Improve parsing of manually provided job offer text.
- Add a small internal data structure if useful.
- Keep output human-readable.
- Support Markdown and plain text inputs.
- Detect common headings and labels.
- Extract or infer:
  - title
  - company
  - location
  - contract type
  - work mode
  - seniority
  - missions
  - requirements
  - technologies or keywords
  - languages
  - red flags
- Update sample input with realistic sections.
- Update tests to cover parser behavior.
- Update README usage if needed.
- Keep parsing transparent and heuristic.

Expected CLI behavior:

```bash
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md
```

Output should include clear sections:

- Title
- Company
- Location
- Contract
- Work mode
- Seniority
- Technologies
- Languages
- Missions
- Requirements
- Red flags
- Recommendation

Do not require perfect parsing. Use transparent heuristic output.

Required checks:

```bash
python3 -m compileall src tests
python3 -m unittest discover -s tests
git diff --check
python3 -m src.job_offer_analyzer --help
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md
```
