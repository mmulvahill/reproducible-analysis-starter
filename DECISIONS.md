Every decision that could change a result is recorded here, with the
alternatives considered and who made it. Entries are never deleted; a
reversed decision gets a new entry that supersedes the old one. This file is
a hand-written log, so its numbers are typed; the report chapters compute
theirs.

## D-001: Primary outcome is any sore throat at rest at 30 minutes

- **Date:** 2026-10-10 · **Decided by:** Client (PI), confirmed with analyst
- **Decision:** Binary outcome, throat pain score > 0 at rest, 30 minutes
  after arrival in recovery.
- **Why:** The client's question is about whether patients get a sore
  throat at all, and this is the outcome they named as primary. (In this
  teaching example the client is fictional; check a real trial's protocol.)
- **Alternatives:** Ordinal model of the 0–10 score (possible secondary
  analysis); swallowing pain (open question for the client).

## D-002: Unadjusted primary analysis

- **Date:** 2026-10-10 · **Decided by:** Analyst
- **Decision:** Unadjusted logistic regression at 30 minutes is primary;
  covariate-adjusted model is a sensitivity analysis.
- **Why:** Treatment was randomized. Adjustment covariates chosen after
  seeing Table 1 would be data-driven.
- **Alternatives:** Pre-specified adjustment for strong prognostic factors.

## D-003: Repeated-measures estimand is population-averaged (GEE)

- **Date:** 2026-10-10 · **Decided by:** Analyst, agreed with PI, at planning
- **Decision:** Logistic GEE, exchangeable working correlation, robust SEs.
  A common-OR model summarizes all four assessments; a treatment × time
  model gives the OR at each assessment, which answers the client's
  question about whether the effect lasts.
- **Why:** The client asks whether licorice reduces sore throat in patients
  like these, a population question.
- **Alternatives:** Mixed model as the primary repeated-measures analysis
  (see D-004).

## D-004: Report the mixed-model odds ratio beside the GEE, labeled

- **Date:** 2026-10-10 · **Decided by:** Analyst, at planning
- **Decision:** Fit a random-intercept logistic model (adaptive quadrature)
  and report its odds ratio as patient-level (conditional), never as the
  population effect.
- **Why:** Repeated pain scores in the same patient are strongly
  correlated, so conditional and marginal ORs are expected to differ.
  Showing both, labeled, prevents the larger number being quoted as the
  effect.

## D-005: Raw data is read-only and checksum-guarded

- **Date:** 2026-10-10 · **Decided by:** Analyst
- **Decision:** `scripts/02_make_analysis_data.R` refuses to run if the raw
  file's MD5 differs from the value recorded at receipt.
- **Why:** Edits to received data are invisible otherwise.

## D-006: Complete-case analysis for outcomes, with bounds

- **Date:** 2026-10-10 · **Decided by:** Analyst
- **Decision:** The 2 patients with no post-operative outcomes (one per arm)
  are excluded from outcome models and kept in Table 1. Best- and
  worst-case imputation bounds are reported for the primary outcome.
- **Why:** Complete-case is valid if missingness is unrelated to outcome.
  With 2 of 235 missing, the bounds show directly whether any assumption
  about them could change the conclusion (Chapter 2).
