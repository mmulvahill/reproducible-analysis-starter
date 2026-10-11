# The model is trusted on real data only after it recovers a known effect
# from data simulated with the same structure.

test_that("fit_repeated recovers a known treatment effect and patient SD", {
  truth <- -0.8
  sim <- simulate_repeated(n_patients = 600, log_or_treatment = truth,
                           sd_patient = 2, seed = 42)
  fit <- fit_repeated(sim)
  est <- odds_ratio(fit)
  expect_lt(abs(est$log_or - truth), 3 * est$se)
  expect_lt(est$lower, exp(truth))
  expect_gt(est$upper, exp(truth))
  # Check the clustering too, not only the coefficient we care about: a model
  # that ignores patients can still land near the treatment effect.
  sd_hat <- attr(lme4::VarCorr(fit)$patient_id, "stddev")[[1]]
  expect_lt(abs(sd_hat - 2), 0.5)
})

test_that("fit_repeated finds no effect when there is none", {
  sim <- simulate_repeated(n_patients = 600, log_or_treatment = 0, seed = 7)
  est <- odds_ratio(fit_repeated(sim))
  expect_lt(abs(est$log_or), 3 * est$se)
})

test_that("fit_marginal recovers the effect when there is no patient clustering", {
  # With no random effect, marginal and conditional ORs coincide, so the
  # simulated truth is also the marginal truth.
  truth <- -0.8
  sim <- simulate_repeated(n_patients = 600, log_or_treatment = truth,
                           sd_patient = 0, seed = 3)
  est <- odds_ratio(fit_marginal(sim))
  expect_lt(abs(est$log_or - truth), 3 * est$se)
})

test_that("with patient clustering the marginal OR is closer to 1", {
  # The estimand matters: a conditional OR from a random-intercept model
  # is further from 1 than the population-averaged OR from the same data.
  sim <- simulate_repeated(n_patients = 600, log_or_treatment = -0.8,
                           sd_patient = 2, seed = 11)
  conditional <- odds_ratio(fit_repeated(sim))$log_or
  marginal <- odds_ratio(fit_marginal(sim))$log_or
  # Theory (Zeger et al. 1988) puts the ratio near 1 / sqrt(1 + 0.346 * 4),
  # about 0.65 for a patient SD of 2. Require a clear gap, not just any gap.
  expect_lt(abs(marginal), 0.85 * abs(conditional))
})

test_that("odds_ratio matches the textbook 2x2 calculation for a glm", {
  # 2x2: Sugar 30/50 with pain, Licorice 15/50. OR = (15/35) / (30/20).
  d <- data.frame(
    treatment = factor(rep(c("Sugar", "Licorice"), each = 50),
                       levels = c("Sugar", "Licorice")),
    pain_30min = c(rep(1, 30), rep(0, 20), rep(1, 15), rep(0, 35))
  )
  est <- odds_ratio(fit_single_timepoint(d))
  expect_equal(est$or, (15 / 35) / (30 / 20), tolerance = 1e-6)
  expect_equal(est$n_obs, 100)
})

test_that("odds_ratio refuses a term that is not in the model", {
  d <- data.frame(
    treatment = factor(c("Sugar", "Licorice", "Sugar", "Licorice"),
                       levels = c("Sugar", "Licorice")),
    pain_30min = c(1, 0, 0, 1)
  )
  expect_error(odds_ratio(fit_single_timepoint(d), "age"), "not in model")
})
