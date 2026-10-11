Every decision that could change a result is recorded here, with the
alternatives considered and who made it. Entries are never deleted; a
reversed decision gets a new entry that supersedes the old one.

## D-001: Primary outcome is any sore throat at rest at 30 minutes

- **Date:** 2026-10-11 · **Decided by:** PI, confirmed with analyst
- **Decision:** Binary outcome, throat pain score > 0 at rest, 30 minutes
  after arrival in recovery.
- **Why:** This is the outcome the trial was powered on and the client's
  question is about incidence.
- **Alternatives:** Ordinal model of the 0–10 score (kept as a possible
  secondary analysis); swallowing pain (open question for the client).

## D-002: Unadjusted primary analysis

- **Date:** 2026-10-11 · **Decided by:** Analyst
- **Decision:** Unadjusted logistic regression at 30 minutes is primary;
  covariate-adjusted model is a sensitivity analysis.
- **Why:** Treatment was randomized. Adjustment covariates chosen after
  seeing Table 1 would be data-driven.
- **Alternatives:** Pre-specified adjustment for strong prognostic factors.

## D-003: Repeated measures estimand is population-averaged (GEE)

- **Date:** 2026-10-11 · **Decided by:** Analyst, agreed with PI
- **Decision:** Logistic GEE, exchangeable working correlation, robust SEs,
  treatment + assessment time.
- **Why:** The client asks whether licorice reduces sore throat in patients
  like these, a population question.
- **Alternatives:** Mixed model (see D-004).

## D-004: Report the mixed-model odds ratio beside the GEE, labeled

- **Date:** 2026-10-11 · **Decided by:** Analyst
- **Decision:** Fit a random-intercept logistic model and report its odds
  ratio as patient-level (conditional), not as the population effect.
- **Why:** The first fit gave a conditional OR far from the GEE's because
  between-patient variation is large (see RESEARCH_LOG.md 2026-10-11).
  Showing both prevents the larger number being quoted as the effect.

## D-005: Raw data is read-only and checksum-guarded

- **Date:** 2026-10-11 · **Decided by:** Analyst
- **Decision:** `scripts/02_make_analysis_data.R` refuses to run if the raw
  file's MD5 differs from the value recorded at receipt.
- **Why:** Edits to received data are invisible otherwise.

## D-006: Complete-case analysis for outcomes

- **Date:** 2026-10-11 · **Decided by:** Analyst
- **Decision:** The 2 patients with no post-operative outcomes are excluded
  from outcome models and kept in Table 1.
- **Why:** 2 of 235 patients; no plausible imputation model changes the
  conclusion. Revisit if the client reports post-randomization exclusions.
