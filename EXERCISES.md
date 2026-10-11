# Exercises

Short things to try, each showing one idea. They work with Claude Code; most
also work by hand.

## 1. Watch a typed number get refused

Open `chapters/06-first-look.qmd` and add a sentence with a number typed in,
e.g. "About 19% of licorice patients had a sore throat." Then run:

```bash
make numbers
```

With Claude Code, ask Claude to make that edit instead: the hook flags it
straight away and Claude rewrites it with inline R.

## 2. Break the cleaning code and let the tests catch it

In `R/clean.R`, change `recode_factor(raw$treat, c(0, 1), ...)` to plain
`factor(raw$treat, levels = c(0, 1), ...)`. Run `make test`. Which test
fails, and what bug would have slipped through without it?

## 3. Try to edit the raw data

Change any value in `data/raw/licorice_gargle.csv` and run `make data`.
Then restore it with `git checkout data/raw/licorice_gargle.csv`.

## 4. Add a secondary outcome the right way

Ask Claude Code:

> Add pain on swallowing at thirty minutes as a secondary outcome.

Good behavior to look for: it proposes a DECISIONS.md entry, asks before
changing the analysis plan, adds a function with a known-answer test, and
reports which checks passed. If it does not, what would you add to
`CLAUDE.md` so it does next time?

## 5. Fit a model the safe way

Ask Claude Code to fit a proportional-odds model of the full 0–10 pain
score at thirty minutes, and to write a simulation-recovery test *before*
running it on the trial data. Does the test pass? Does the odds ratio
answer the same question as the logistic model's?

## 6. Get an independent review

Start a **new** Claude Code session and run `/review-analysis`. Compare what
it finds with what you would have caught. Why a new session?

## 7. Start your own project

Follow "Starting your own project" in the README with a dataset you know
well (not identifiable data on a personal account).
