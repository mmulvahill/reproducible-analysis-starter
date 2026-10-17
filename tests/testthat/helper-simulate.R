# Simulated patient-level data with the same columns as clean_licorice()
# output, so whole-pipeline functions can be tested with a known truth and
# without the trial data.
#
# Any pain at each assessment is logistic in treatment and age (per 10 years
# above 50), with a patient random intercept. Patient 1 has no outcomes, like
# the two missing patients in the trial.
simulate_clean <- function(n_patients = 300,
                           log_or_treatment = -0.8,
                           log_or_age = 0.3,
                           baseline_logits = c(0.5, 0, -0.5, -1),
                           sd_patient = 1,
                           seed = 1) {
  withr::with_seed(seed, {
    pick <- function(levels) factor(sample(levels, n_patients, TRUE), levels = levels)
    clean <- data.frame(
      patient_id = seq_len(n_patients),
      treatment = factor(rep(c("Sugar", "Licorice"), length.out = n_patients),
                         levels = c("Sugar", "Licorice")),
      sex = pick(c("Male", "Female")),
      age = round(stats::runif(n_patients, 18, 85)),
      bmi = round(stats::rnorm(n_patients, 27, 4), 1),
      asa = pick(c("1", "2", "3")),
      mallampati = pick(c("1", "2", "3", "4")),
      smoking = pick(c("Current", "Past", "Never")),
      preop_pain = pick(c("No", "Yes")),
      surgery_size = pick(c("Small", "Medium", "Large"))
    )
    u <- stats::rnorm(n_patients, 0, sd_patient)
    for (i in seq_along(pain_columns)) {
      eta <- baseline_logits[i] +
        log_or_treatment * (clean$treatment == "Licorice") +
        log_or_age * (clean$age - 50) / 10 +
        u
      any_pain <- stats::rbinom(n_patients, 1, stats::plogis(eta))
      clean[[names(pain_columns)[i]]] <- any_pain * sample(1:10, n_patients, TRUE)
    }
    clean[1, names(pain_columns)] <- NA
    clean
  })
}
