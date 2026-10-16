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
  expect_lt(abs(patient_sd(fit) - 2), 0.5)
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

test_that("fit_marginal recovers the true marginal OR when patients cluster", {
  # The marginal truth is not the simulation's conditional log OR: integrate
  # the patient random effect out at each time, then average over times.
  sd_patient <- 2
  baseline <- c(0.5, 0, -0.5, -1)
  conditional <- -0.8
  marginal_p <- function(eta) {
    stats::integrate(
      function(u) stats::plogis(eta + u) * stats::dnorm(u, 0, sd_patient),
      -Inf, Inf
    )$value
  }
  true_log_or <- mean(vapply(baseline, function(b) {
    stats::qlogis(marginal_p(b + conditional)) - stats::qlogis(marginal_p(b))
  }, numeric(1)))

  # n is large enough that a conditional estimate (about -0.8) would fail.
  sim <- simulate_repeated(n_patients = 3000, log_or_treatment = conditional,
                           baseline_logits = baseline,
                           sd_patient = sd_patient, seed = 5)
  est <- odds_ratio(fit_marginal(sim))
  expect_lt(abs(est$log_or - true_log_or), 3 * est$se)
})

test_that("time-specific GEE odds ratios equal the per-time 2x2 odds ratios", {
  # With a saturated mean model the GEE point estimates reproduce the
  # observed proportions, so each time's OR is the simple 2x2 OR.
  sim <- simulate_repeated(n_patients = 300, seed = 9)
  by_time <- odds_ratio_by_time(fit_marginal_by_time(sim))
  for (t in levels(sim$time)) {
    d <- sim[sim$time == t, ]
    p <- tapply(d$any_pain, d$treatment, mean)
    two_by_two <- (p[["Licorice"]] / (1 - p[["Licorice"]])) /
      (p[["Sugar"]] / (1 - p[["Sugar"]]))
    expect_equal(by_time$or[by_time$time == t], two_by_two, tolerance = 1e-4)
  }
})

test_that("missing-outcome bounds bracket the complete-case estimate", {
  d <- data.frame(
    treatment = factor(rep(c("Sugar", "Licorice"), each = 50),
                       levels = c("Sugar", "Licorice")),
    pain_30min = c(rep(1, 30), rep(0, 19), NA, rep(1, 15), rep(0, 34), NA)
  )
  b <- missing_outcome_bounds(d)
  expect_equal(b$scenario,
               c("Complete case", "Best case for licorice", "Worst case for licorice"))
  expect_lt(b$or[2], b$or[1])
  expect_gt(b$or[3], b$or[1])
  expect_equal(b$n_obs, c(98, 100, 100))
})

test_that("bounds reuse the complete-case result instead of refitting", {
  d <- data.frame(
    treatment = factor(rep(c("Sugar", "Licorice"), each = 50),
                       levels = c("Sugar", "Licorice")),
    pain_30min = c(rep(1, 30), rep(0, 19), NA, rep(1, 15), rep(0, 34), NA)
  )
  primary <- odds_ratio(fit_single_timepoint(d))
  expect_equal(missing_outcome_bounds(d), missing_outcome_bounds(d, complete_case = primary))
  # Whatever is passed in is what the table reports.
  marker <- transform(primary, or = 99)
  expect_equal(missing_outcome_bounds(d, complete_case = marker)$or[1], 99)
})

test_that("the adjusted model is the glm the analysis plan describes", {
  clean <- simulate_clean(seed = 31)
  direct <- stats::glm(
    I(pain_30min > 0) ~ treatment + sex + age + bmi + smoking + asa + surgery_size,
    family = stats::binomial(),
    data = clean
  )
  fit <- fit_single_timepoint(clean, covariates = adjustment_covariates)
  expect_equal(unname(stats::coef(fit)), unname(stats::coef(direct)))
  expect_equal(odds_ratio(fit)$n_obs, sum(!is.na(clean$pain_30min)))
})

test_that("the adjusted model recovers planted treatment and age effects", {
  # No patient random effect, so the simulated log ORs are exactly what a
  # correctly specified single-time-point model estimates.
  truth <- c(treatment = -0.8, age = 0.3)
  clean <- simulate_clean(n_patients = 2000, log_or_treatment = truth[["treatment"]],
                          log_or_age = truth[["age"]], sd_patient = 0, seed = 33)
  fit <- fit_single_timepoint(clean, covariates = adjustment_covariates)
  est <- odds_ratio(fit)
  expect_lt(abs(est$log_or - truth[["treatment"]]), 3 * est$se)
  # Age is simulated per 10 years; the model's coefficient is per year.
  age <- odds_ratio(fit, "age")
  expect_lt(abs(10 * age$log_or - truth[["age"]]), 3 * 10 * age$se)
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
