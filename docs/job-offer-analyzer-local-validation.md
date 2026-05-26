# Job Offer Analyzer Local Validation

## Project Path

```text
/home/paulm/ai-workspaces/job-offer-analyzer
```

## Latest Project Commit

```text
96efb67 Add validation and documentation
```

## Validation Commands

```bash
python3 -m compileall src tests
python3 -m unittest discover -s tests
git diff --check
python3 -m src.job_offer_analyzer --help
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md
python3 -m src.job_offer_analyzer report examples/job-offer-sample.md
test -z "$(git remote)"
test -f docs/validation.md
test -f docs/limitations.md
```

## Validation Results

- `python3 -m compileall src tests`: passed.
- `python3 -m unittest discover -s tests`: passed, 8 tests.
- `git diff --check`: passed.
- CLI help command: passed.
- CLI sample analysis command: passed.
- CLI sample report command: passed.
- Project remote check: passed; no remote remains.
- `docs/validation.md`: present.
- `docs/limitations.md`: present.
- Forbidden implementation imports check for `requests`, `BeautifulSoup`, `selenium`, `playwright`, and `scrapy`: passed.

## Supported Commands

```bash
python3 -m src.job_offer_analyzer --help
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md --report
python3 -m src.job_offer_analyzer report examples/job-offer-sample.md
python3 -m src.job_offer_analyzer report examples/job-offer-sample.md --output report.md
```

## No-Scraping Confirmation

The local MVP analyzes manually provided local text or Markdown files only. It does no scraping, no browser automation, no LinkedIn API calls, no external API calls, no AI API calls, and no dependency installation.

## Known Limitations

- Parsing is heuristic and works best with clear labels and headings.
- Scoring is deterministic but generic and not matched against a custom user profile.
- Reports are advisory local summaries, not authoritative career, legal, immigration, tax, or compensation advice.
- Technology, language, seniority, and red flag detection are limited to built-in local heuristics.

## Readiness Status

The local MVP is complete for IN-0002. It is ready for local use and controlled publication planning if desired.

## Next Recommended Task

Prepare controlled publication or cockpit-driven usage if desired.
