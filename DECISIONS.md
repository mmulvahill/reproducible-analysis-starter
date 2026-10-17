Every decision that could change a result is recorded here, with the
alternatives considered and who made it. Entries are never deleted; a
reversed decision gets a new entry that supersedes the old one. **Timing**
says whether any results had been seen when the decision was made: a change
made after seeing results is post hoc, and is marked as such here and in
the analysis plan. This file is a hand-written log, so its numbers are
typed; the report chapters compute theirs.

## D-001: Primary outcome is any sore throat at rest at 30 minutes

- **Date:** 2026-10-10 · **Decided by:** Client (PI), confirmed with analyst
- **Timing:** At planning, before any outcome was examined.
- **Decision:** Binary outcome, throat pain score > 0 at rest, 30 minutes
  after arrival in recovery.
- **Why:** The client's question is about whether patients get a sore
  throat at all, and this is the outcome they named as primary. (In this
  teaching example the client is fictional; check a real trial's protocol.)
- **Alternatives:** Ordinal model of the 0–10 score (possible secondary
  analysis); swallowing pain (open question for the client).

## D-002: Unadjusted primary analysis

- **Date:** 2026-10-10 · **Decided by:** Analyst
- **Timing:** At planning, before any outcome was examined.
- **Decision:** Unadjusted logistic regression at 30 minutes is primary;
  covariate-adjusted model is a sensitivity analysis (D-007).
- **Why:** Treatment was randomized. Adjustment covariates chosen after
  seeing Table 1 would be data-driven.
- **Alternatives:** Pre-specified adjustment for strong prognostic factors.

## D-003: Repeated-measures estimand is population-averaged (GEE)

- **Date:** 2026-10-10 · **Decided by:** Analyst, agreed with PI
- **Timing:** At planning, before any outcome was examined.
- **Decision:** Logistic GEE with treatment and assessment time,
  exchangeable working correlation, robust SEs. One common odds ratio
  summarizes the four assessments.
- **Why:** The client asks whether licorice reduces sore throat in patients
  like these, a population question.
- **Alternatives:** Mixed model as the primary repeated-measures analysis
  (see D-004).

## D-004: Report the mixed-model odds ratio beside the GEE, labeled

- **Date:** 2026-10-10 · **Decided by:** Analyst
- **Timing:** At planning, before any outcome was examined.
- **Decision:** Fit a random-intercept logistic model and report its odds
  ratio as patient-level (conditional), never as the population effect.
- **Why:** Repeated pain scores in the same patient are strongly
  correlated, so conditional and marginal ORs are expected to differ.
  Showing both, labeled, prevents the larger number being quoted as the
  effect.

## D-005: Raw data is read-only and checksum-guarded

- **Date:** 2026-10-10 · **Decided by:** Analyst
- **Timing:** At receipt of the data.
- **Decision:** `scripts/02_make_analysis_data.R` refuses to run if the raw
  file's MD5 differs from the value recorded at receipt.
- **Why:** Edits to received data are invisible otherwise.

## D-006: Complete-case analysis for outcomes, with bounds

- **Date:** 2026-10-10 · **Decided by:** Analyst
- **Timing:** At planning, before any outcome was examined. The count of
  missing patients was known from the data check.
- **Decision:** The 2 patients with no post-operative outcomes (one per arm)
  are excluded from outcome models and kept in Table 1. Best- and
  worst-case imputation bounds are reported for the primary outcome.
- **Why:** Complete-case is valid if missingness is unrelated to outcome.
  With 2 of 235 missing, the bounds show directly whether any assumption
  about them could change the conclusion (Chapter 2).
- **Alternatives:** Multiple imputation, which with 2 patients and no
  outcome data for them adds assumptions without adding information.

## D-007: Covariates for the adjusted sensitivity analysis

- **Date:** 2026-10-10 · **Decided by:** Analyst
- **Timing:** At planning, before any outcome was examined. Excluding
  preoperative pain and Mallampati class used baseline counts only (how
  many patients were in each category), not outcomes and not imbalance
  between arms.
- **Decision:** Adjust for sex, age, BMI, smoking, ASA status and surgery
  size (`adjustment_covariates` in `R/models.R`). Mallampati class and
  preoperative pain are not adjusted for.
- **Why:** These six are baseline factors with a plausible link to
  postoperative sore throat, so adjusting for them can improve precision.
  Female sex and smoking are commonly reported risk factors. Age, BMI and
  ASA status describe the patient's general and airway condition. Surgery
  size stands in for how long the double-lumen tube stays in place. They
  were chosen from subject-matter knowledge, not from the trial's outcomes
  or from imbalance between arms. Preoperative pain is excluded because
  only 2 of 235 patients had any, so its coefficient would be unstable.
  Mallampati class is excluded because it predicts a difficult intubation
  rather than sore throat itself, and class 4 has a single patient, so as a
  four-level factor it would add unstable coefficients. Collapsing classes
  would be another choice made from the data, which isn't worth it for a
  sensitivity analysis.
- **Alternatives:** Adjusting for every baseline variable; choosing
  covariates by imbalance in Table 1 (rejected, D-002).

## D-008: Fit the mixed model by adaptive quadrature (post hoc)

- **Date:** 2026-10-10 · **Decided by:** Analyst
- **Timing:** After results were seen. Prompted by an independent review in
  a fresh session.
- **Decision:** Fit the D-004 random-intercept model by adaptive
  Gauss–Hermite quadrature (25 points) instead of the Laplace approximation,
  `lme4`'s default. The estimand and its labeling are unchanged.
- **Why:** With four binary observations per patient and a large patient
  standard deviation (about 2.75 on the log-odds scale), the Laplace
  approximation is known to be biased. The odds ratio moved from about 0.13
  to 0.14; the reported GEE estimand (D-003) is unaffected.
- **Alternatives:** Keep Laplace and note the bias; a Bayesian fit.

## D-009: Add the odds ratio at each assessment (post hoc)

- **Date:** 2026-10-10 · **Decided by:** Analyst
- **Timing:** After results were seen. Prompted by an independent review in
  a fresh session, which found that the client's question "does the effect
  last past the recovery room?" was not answered: the plan's common odds
  ratio (D-003) assumes one effect at every assessment.
- **Decision:** Add a GEE with a treatment-by-time interaction and report
  the population-averaged odds ratio at each assessment, with robust 95%
  CIs. Reported descriptively, with no multiplicity adjustment. The common
  odds ratio stays as the planned summary.
- **Why:** It answers the question the client asked. Because it was added
  after the results were seen, it is labeled post hoc wherever it appears.
- **Alternatives:** A single test of the treatment-by-time interaction,
  which says whether the effect varies but not whether it lasts.
