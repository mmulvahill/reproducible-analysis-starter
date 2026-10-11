# reproducible-analysis-starter

A project template for statistical consulting work that stays
reproducible and checkable when an AI assistant writes much of the code.
It ships with a complete worked example, a reanalysis of a public
randomized trial, so you can see every piece in use before you copy it.

**Rendered example report:** https://mmulvahill.github.io/reproducible-analysis-starter/

## What is in it

| Piece | Where | Why |
|---|---|---|
| Lab notebook + client report in one | Quarto book: `index.qmd`, `chapters/` | Plan, results and record live together and render from code |
| No typed numbers | `scripts/check_inline_numbers.R` | Every number in the prose comes from inline R, so text cannot drift from results |
| Decision record | `DECISIONS.md` | Every choice that could change a result, with reasons and alternatives |
| Research log | `RESEARCH_LOG.md` | Append-only record of what happened and what it changed |
| Read-only raw data | `data/raw/` + checksum in `scripts/02_make_analysis_data.R` | Received data is never edited; all cleaning is code |
| Functions in a package | `R/`, `DESCRIPTION` | One home for every function the report uses |
| Tests | `tests/testthat/` | Known-answer tests on tiny hand-built data; simulation-recovery tests for every model |
| Lint + pre-commit | `.lintr`, `.pre-commit-config.yaml` | Machines check style so review time goes to substance |
| CI and publishing | `.github/workflows/` | Every push is checked; the book on GitHub Pages always matches the code |
| Instructions for Claude | `CLAUDE.md`, `.claude/` | Your standards, written once, read every session, partly enforced by hooks |

## Quick start

You need R (4.1 or later), [Quarto](https://quarto.org/docs/get-started/),
and the packages listed in `DESCRIPTION`:

```r
install.packages(c("geepack", "lme4", "tidyr", "withr", "ggplot2", "here",
                   "knitr", "lintr", "pkgload", "rmarkdown", "testthat"))
```

Then, from the repo root:

```bash
make all            # or, without make (e.g. Windows): Rscript run_all.R
```

Open `_book/index.html`.

## Using it with Claude Code

Open the folder and run `claude`. Claude Code reads `CLAUDE.md`
automatically. The project also sets up:

- **Skills:** `/log-decision`, `/log-research`, and `/review-analysis` (run
  the review in a *fresh* session so the reviewer did not write the work).
- **A hook** that runs the typed-number check after every file edit and shows
  Claude any violation.
- **Permission rules** that block Claude's file tools from editing
  `data/raw/` or reading `data/phi/`. These are guardrails, not a security
  boundary: a shell command could still reach those files. Keep identifiable
  data off any machine or account not approved for it.

## Using it with Claude in a browser

No Claude Code yet? Create a Project on claude.ai and paste `CLAUDE.md` into
its instructions. You lose the hooks and the automatic test runs, so run
`make all` yourself before trusting anything. **Do not paste identifiable
patient data into a personal account.**

## Pinning package versions

`chapters/10-reproducibility.qmd` records `sessionInfo()`, which says what
was used but cannot restore it. For your own project, run `renv::init()`
once, commit `renv.lock`, and have collaborators run `renv::restore()`.

## Starting your own project

1. Click **Use this template** on GitHub (or copy the folder).
2. Replace `data/raw/` with your data and record its checksum.
3. Rename the package in `DESCRIPTION` and replace the functions in `R/`
   and their tests.
4. Rewrite `chapters/01-question.qmd` and `chapters/03-methods.qmd` *before*
   looking at outcomes. Clear `DECISIONS.md` and `RESEARCH_LOG.md`.
5. To publish the book: Settings → Pages → Source: GitHub Actions.

Try the exercises in [EXERCISES.md](EXERCISES.md) first.

## Data

The worked example uses the licorice gargle trial (Ruetzler et al.,
*Anesth Analg* 2013;117:614–21) as distributed in the
[`medicaldata`](https://github.com/higgi13425/medicaldata) R package (MIT
licence), contributed by Amy S. Nowacki. The "client" is fictional.

## Licence

MIT.
