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
  # Adaptive quadrature, not the Laplace default: with a large patient SD
  # and four binary observations per patient, Laplace is biased.
  lme4::glmer(
    any_pain ~ treatment + time + (1 | patient_id),
    family = stats::binomial(),
    data = long,
    nAGQ = 25
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

#' Population-averaged model with a treatment-by-time interaction, so the
#' odds ratio can differ at each assessment (does the effect last?).
fit_marginal_by_time <- function(long) {
  long <- long[order(long$patient_id, long$time), ]
  geepack::geeglm(
    any_pain ~ treatment * time,
    id = patient_id,
    family = stats::binomial(),
    corstr = "exchangeable",
    data = long
  )
}

#' Treatment odds ratio at each assessment from `fit_marginal_by_time()`,
#' with robust Wald 95% CIs.
odds_ratio_by_time <- function(fit, treatment_term = "treatmentLicorice") {
  b <- stats::coef(fit)
  v <- stats::vcov(fit)
  times <- levels(fit$data$time)
  rows <- lapply(times, function(t) {
    w <- stats::setNames(numeric(length(b)), names(b))
    w[treatment_term] <- 1
    interaction <- paste0(treatment_term, ":time", t)
    if (interaction %in% names(b)) w[interaction] <- 1
    est <- sum(w * b)
    se <- sqrt(drop(t(w) %*% v %*% w))
    data.frame(
      time = t,
      or = exp(est),
      lower = exp(est - stats::qnorm(0.975) * se),
      upper = exp(est + stats::qnorm(0.975) * se)
    )
  })
  do.call(rbind, rows)
}

#' Best- and worst-case bounds for patients with a missing outcome
#'
#' Refits the single-time-point model with every missing outcome set to the
#' value least and most favourable to licorice. If both bounds agree with the
#' complete-case result, the missing data cannot change the conclusion.
missing_outcome_bounds <- function(clean, outcome = "pain_30min") {
  miss <- is.na(clean[[outcome]])
  scenario <- function(licorice_value, sugar_value) {
    d <- clean
    d[[outcome]][miss & d$treatment == "Licorice"] <- licorice_value
    d[[outcome]][miss & d$treatment == "Sugar"] <- sugar_value
    odds_ratio(fit_single_timepoint(d, outcome))
  }
  rbind(
    cbind(scenario = "Complete case", odds_ratio(fit_single_timepoint(clean, outcome))),
    cbind(scenario = "Best case for licorice", scenario(0, 1)),
    cbind(scenario = "Worst case for licorice", scenario(1, 0))
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
