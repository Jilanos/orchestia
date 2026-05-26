# Codex Prompt: TASK-0054 Job Offer Validation Docs

Objective: strengthen validation, documentation, examples, and release-readiness notes for the local `job-offer-analyzer` MVP.

Work only in:

```text
/home/paulm/ai-workspaces/job-offer-analyzer
```

Hard rules:

- Do not modify Orchestia.
- Use Python standard library only.
- Do not scrape LinkedIn.
- Do not scrape any job board.
- Do not automate browser access.
- Do not use LinkedIn APIs.
- Do not use external APIs.
- Do not use AI APIs.
- Do not install dependencies.
- Do not add package metadata.
- Do not push, merge, rebase, tag, or force push.
- Do not add a Git remote.
- Do not read secrets.
- Do not print environment variables.
- Keep changes minimal.
- Preserve CLI compatibility.

Authorized files in the project:

- `README.md`
- `src/job_offer_analyzer/__main__.py`
- `tests/test_smoke.py`
- `examples/job-offer-sample.md`
- `docs/product-brief.md`
- `docs/validation.md`
- `docs/limitations.md`

Implementation goals:

- Strengthen tests for existing parsing, scoring, and reporting behavior.
- Improve README clarity for the local manual-input workflow.
- Document the no-scraping policy explicitly.
- Add `docs/validation.md` with local validation commands and expected outcomes.
- Add `docs/limitations.md` with current known limitations and non-goals.
- Improve `docs/product-brief.md` if needed so it matches implemented behavior.
- Keep example input realistic and manually provided.
- Preserve the existing `analyze` command.
- Preserve the existing `report` command.
- Preserve `analyze --report` behavior if currently supported.
- Do not add new dependencies or external service integration.

Expected documentation:

- README usage examples.
- `analyze` command.
- `report` command.
- Manual input workflow.
- No-scraping policy.
- Current limitations.
- Validation commands.

Required checks:

```bash
python3 -m compileall src tests
python3 -m unittest discover -s tests
git diff --check
python3 -m src.job_offer_analyzer --help
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md
python3 -m src.job_offer_analyzer report examples/job-offer-sample.md
```

Acceptance criteria:

- All CLI commands are documented and tested.
- README clearly explains usage.
- No-scraping policy is explicit.
- Limitations are documented.
- Validation checklist exists.
- Example input is realistic.
- Tests cover parsing, scoring, and reporting basics.
- No external dependency is added.
- No API integration is added.
- No scraping or browser automation is added.
