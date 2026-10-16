# The report reads one results list. These tests check that it holds every
# estimate the chapters use, that estimates shown in more than one place
# agree, and that warnings from model fits are kept.

test_that("analysis_results holds every estimate the report reads", {
  clean <- simulate_clean(seed = 21)
  results <- analysis_results(clean, to_long(clean))
  expect_named(results, c(
    "by30", "or30", "or_adj", "bounds", "or_marginal", "by_time", "lasts",
    "or_conditional", "sd_patient", "models", "warnings"
  ))
  # The bounds table's complete-case row must match the primary result.
  expect_equal(results$bounds[1, names(results$or30)], results$or30,
               ignore_attr = TRUE)
  expect_identical(results$lasts, all(results$by_time$upper < 1))
  expect_equal(
    results$or_adj,
    odds_ratio(fit_single_timepoint(clean, covariates = adjustment_covariates))
  )
})

test_that("the warning log keeps a warning and still lets it through", {
  fits <- new_warning_log()
  expect_warning(
    value <- fits$record("Toy model", {
      warning("fitted probabilities numerically 0 or 1 occurred")
      42
    }),
    "numerically 0 or 1"
  )
  expect_equal(value, 42)
  fits$record("Quiet model", 1)
  expect_equal(fits$models(), c("Toy model", "Quiet model"))
  expect_equal(fits$table()$model, "Toy model")
  expect_match(fits$table()$warning, "numerically 0 or 1")
})

test_that("a separated logistic fit's warning reaches the results", {
  # Age perfectly separates pain from no pain, so glm warns. That warning
  # must end up in the report, not vanish in a hidden chunk. (A binary
  # treatment that separates the outcome gives no warning at all, only an
  # absurd odds ratio: another reason to read the estimates.)
  d <- data.frame(
    treatment = factor(rep(c("Sugar", "Licorice"), 20), levels = c("Sugar", "Licorice")),
    age = 1:40,
    pain_30min = rep(c(0, 4), each = 20)
  )
  fits <- new_warning_log()
  suppressWarnings(fits$record("Separated", fit_single_timepoint(d, covariates = "age")))
  expect_match(fits$table()$warning, "numerically 0 or 1", all = FALSE)
  expect_true(all(fits$table()$model == "Separated"))
})

test_that("fit_warnings_note reports warnings, or says there were none", {
  results <- list(
    models = c("A", "B"),
    warnings = data.frame(model = "B", warning = "did not converge")
  )
  expect_output(fit_warnings_note(results, "A"), "No warnings")
  expect_output(fit_warnings_note(results, c("A", "B")), "B:\\*\\* did not converge")
})

test_that("fit_warnings_note refuses a model label it does not know", {
  results <- list(models = "Mixed model", warnings = data.frame(model = character(),
                                                                warning = character()))
  expect_error(fit_warnings_note(results, "Mixed modle"), "Unknown model label")
})
