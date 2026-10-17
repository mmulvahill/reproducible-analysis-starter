# Raw -> clean. Every recode lives here, never in a chapter.

#' Clean the raw data: one row per unit, labeled, validated against the
#' codebook
#'
#' A placeholder until the project's cleaning is written, with known-answer
#' tests. It refuses to run, so uncleaned data never reaches the report.
clean_data <- function(raw) {
  stop("clean_data() is not written yet. Write it in R/clean.R, with ",
       "known-answer tests, before running `make data`.", call. = FALSE)
}

#' Recode a numeric column to a factor, refusing codes the codebook lacks
#'
#' `factor()` silently turns an unexpected code into NA. That is how a
#' miscoded value disappears from an analysis, so this errors instead.
recode_factor <- function(x, levels, labels = levels, name = "x") {
  unexpected <- setdiff(unique(x[!is.na(x)]), levels)
  if (length(unexpected) > 0) {
    stop(
      sprintf(
        "Column '%s' has codes not in the codebook: %s",
        name, paste(sort(unexpected), collapse = ", ")
      ),
      call. = FALSE
    )
  }
  factor(x, levels = levels, labels = labels)
}
