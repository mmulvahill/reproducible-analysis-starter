# Model fitting, effect extraction, and a simulator with known truth.

#' Sanity-check model: logistic regression of any pain at one time point
#'
#' Unadjusted, because treatment was randomized (DECISIONS.md D-002).
fit_single_timepoint <- function(clean, outcome = "pain_30min") {
  data <- clean[!is.na(clean[[outcome]]), ]
  data$any_pain <- as.integer(data[[outcome]] > 0)
  stats::glm(any_pain ~ treatment, family = stats::binomial(), data = data)
}

#' Conditional model: mixed-effects logistic regression over all time points
#'
#' Random intercept per patient accounts for repeated measures. Returns a
#' conditional (patient-level) odds ratio, reported alongside the marginal
#' model to show how the estimand changes the number (DECISIONS.md D-004).
fit_repeated <- function(long) {
  lme4::glmer(
    any_pain ~ treatment + time + (1 | patient_id),
    family = stats::binomial(),
    data = long
  )
}

#' Population-averaged model: GEE logistic regression, exchangeable working
#' correlation, robust standard errors. Returns a marginal odds ratio, the
#' pre-specified estimand for the repeated-measures question (DECISIONS.md
#' D-003).
fit_marginal <- function(long) {
  long <- long[order(long$patient_id, long$time), ]
  geepack::geeglm(
    any_pain ~ treatment + time,
    id = patient_id,
    family = stats::binomial(),
    corstr = "exchangeable",
    data = long
  )
}

#' Odds ratio with Wald 95% CI for one coefficient of a glm, glmer or
#' geeglm fit
odds_ratio <- function(fit, term = "treatmentLicorice") {
  est <- stats::coef(summary(fit))
  if (!term %in% rownames(est)) {
    stop("Term '", term, "' not in model", call. = FALSE)
  }
  se_col <- intersect(c("Std. Error", "Std.err"), colnames(est))[1]
  b <- est[term, "Estimate"]
  se <- est[term, se_col]
  z <- b / se
  data.frame(
    term = term,
    log_or = b,
    se = se,
    or = exp(b),
    lower = exp(b - stats::qnorm(0.975) * se),
    upper = exp(b + stats::qnorm(0.975) * se),
    p_value = 2 * stats::pnorm(-abs(z)),
    n_obs = length(stats::fitted(fit))
  )
}

#' Simulate repeated binary pain outcomes from the main model's structure
#'
#' Used to check that `fit_repeated()` recovers a known treatment effect
#' before we trust it on the real data.
simulate_repeated <- function(n_patients = 500,
                              log_or_treatment = -0.8,
                              baseline_logits = c(0.5, 0, -0.5, -1),
                              sd_patient = 1,
                              seed = 1) {
  withr::with_seed(seed, {
    treated <- rep(c(0, 1), length.out = n_patients)
    u <- stats::rnorm(n_patients, 0, sd_patient)
    grid <- expand.grid(
      patient_id = seq_len(n_patients),
      time_index = seq_along(baseline_logits)
    )
    eta <- baseline_logits[grid$time_index] +
      log_or_treatment * treated[grid$patient_id] +
      u[grid$patient_id]
    data.frame(
      patient_id = grid$patient_id,
      treatment = factor(
        ifelse(treated[grid$patient_id] == 1, "Licorice", "Sugar"),
        levels = c("Sugar", "Licorice")
      ),
      time = factor(unname(time_labels)[grid$time_index], levels = unname(time_labels)),
      any_pain = stats::rbinom(nrow(grid), 1, stats::plogis(eta))
    )
  })
}
