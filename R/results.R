# Every result the report uses, computed once.
#
# scripts/03_fit_models.R calls analysis_results() and saves the list to
# data/derived/results.rds. Chapters and index.qmd only read and format it,
# so a model is fitted once per change, not once per page, and the summary
# can never disagree with the chapter it summarises.

#' Fit every model and compute every estimate the report uses
#'
#' @param clean One row per patient, from `clean_licorice()`.
#' @param long One row per patient-time, from `to_long()`.
#' @return A named list of estimates (data frames and single values), plus
#'   `models` (the label of every fit) and `warnings` (one row per warning
#'   raised while fitting, by model).
analysis_results <- function(clean, long) {
  fits <- new_warning_log()

  # Thirty minutes (Chapter 6, summary)
  by30 <- pain_by_group(clean, "pain_30min")
  or30 <- fits$record("Primary (30 min)", odds_ratio(fit_single_timepoint(clean)))
  or_adj <- fits$record(
    "Adjusted sensitivity (30 min)",
    odds_ratio(fit_single_timepoint(clean, covariates = adjustment_covariates))
  )

  # Missing outcomes (Chapter 2)
  bounds <- fits$record(
    "Missing-outcome bounds",
    missing_outcome_bounds(clean, complete_case = or30)
  )

  # All four assessments (Chapter 7, summary)
  or_marginal <- fits$record("GEE, common OR", odds_ratio(fit_marginal(long)))
  by_time <- fits$record(
    "GEE, OR at each assessment",
    odds_ratio_by_time(fit_marginal_by_time(long))
  )
  fit_glmm <- fits$record("Mixed model", fit_repeated(long))

  list(
    by30 = by30,
    or30 = or30,
    or_adj = or_adj,
    bounds = bounds,
    or_marginal = or_marginal,
    by_time = by_time,
    lasts = all(by_time$upper < 1),
    or_conditional = odds_ratio(fit_glmm),
    sd_patient = patient_sd(fit_glmm),
    models = fits$models(),
    warnings = fits$table()
  )
}

#' Collect warnings from model fits without hiding them
#'
#' `record(model, expr)` evaluates `expr`, notes any warning against `model`,
#' and lets the warning carry on so it still prints in the console. A warning
#' from a fit is a finding (CLAUDE.md), so it is kept for the report.
new_warning_log <- function() {
  models <- character()
  seen <- data.frame(model = character(), warning = character())
  list(
    record = function(model, expr) {
      models <<- c(models, model)
      withCallingHandlers(expr, warning = function(w) {
        seen[nrow(seen) + 1, ] <<- list(model, conditionMessage(w))
      })
    },
    models = function() models,
    table = function() seen
  )
}

#' Markdown note listing warnings from the named model fits
#'
#' For a chunk with `results: asis`, so each Results chapter says plainly
#' whether its models raised warnings.
fit_warnings_note <- function(results, models) {
  # A misspelt label would otherwise report "no warnings" for a model that
  # was never checked.
  unknown <- setdiff(models, results$models)
  if (length(unknown) > 0) {
    stop("Unknown model label(s): ", paste(unknown, collapse = ", "), call. = FALSE)
  }
  w <- results$warnings[results$warnings$model %in% models, ]
  if (nrow(w) == 0) {
    return(cat("*No warnings from the model fits in this chapter.*\n"))
  }
  cat(
    "::: {.callout-important}\n## Model fit warnings\n",
    paste0("- **", w$model, ":** ", w$warning, "\n"),
    ":::\n",
    sep = ""
  )
}
