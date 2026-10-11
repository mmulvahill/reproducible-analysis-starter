# Raw -> clean -> long. Every recode lives here, never in a chapter.

raw_columns <- c(
  "preOp_gender", "preOp_asa", "preOp_calcBMI", "preOp_age",
  "preOp_mallampati", "preOp_smoking", "preOp_pain", "treat",
  "intraOp_surgerySize", "pacu30min_throatPain", "pacu90min_throatPain",
  "postOp4hour_throatPain", "pod1am_throatPain"
)

pain_columns <- c(
  pain_30min = "pacu30min_throatPain",
  pain_90min = "pacu90min_throatPain",
  pain_4h = "postOp4hour_throatPain",
  pain_pod1 = "pod1am_throatPain"
)

time_labels <- c(
  pain_30min = "30 min",
  pain_90min = "90 min",
  pain_4h = "4 h",
  pain_pod1 = "Day 1 AM"
)

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

#' Clean the raw licorice gargle trial data (one row per patient)
#'
#' @param raw Data frame as read from data/raw/licorice_gargle.csv.
#' @return One row per patient with labeled factors and pain scores.
clean_licorice <- function(raw) {
  missing_cols <- setdiff(raw_columns, names(raw))
  if (length(missing_cols) > 0) {
    stop(
      "Raw data is missing columns: ", paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }

  clean <- data.frame(
    patient_id = seq_len(nrow(raw)),
    treatment = recode_factor(
      raw$treat, c(0, 1), c("Sugar", "Licorice"), "treat"
    ),
    sex = recode_factor(
      raw$preOp_gender, c(0, 1), c("Male", "Female"), "preOp_gender"
    ),
    age = raw$preOp_age,
    bmi = raw$preOp_calcBMI,
    asa = recode_factor(raw$preOp_asa, 1:3, name = "preOp_asa"),
    mallampati = recode_factor(
      raw$preOp_mallampati, 1:4, name = "preOp_mallampati"
    ),
    smoking = recode_factor(
      raw$preOp_smoking, 1:3, c("Current", "Past", "Never"), "preOp_smoking"
    ),
    surgery_size = recode_factor(
      raw$intraOp_surgerySize, 1:3, c("Small", "Medium", "Large"),
      "intraOp_surgerySize"
    )
  )

  for (new_name in names(pain_columns)) {
    clean[[new_name]] <- raw[[pain_columns[[new_name]]]]
  }

  validate_clean(clean)
  clean
}

#' Check the clean data against the codebook; error with the offending rows
validate_clean <- function(clean) {
  check_range <- function(column, low, high) {
    x <- clean[[column]]
    bad <- which(!is.na(x) & (x < low | x > high))
    if (length(bad) > 0) {
      stop(
        sprintf(
          "'%s' outside [%s, %s] in rows: %s",
          column, low, high, paste(bad, collapse = ", ")
        ),
        call. = FALSE
      )
    }
  }
  check_range("age", 18, 100)
  check_range("bmi", 10, 60)
  for (column in names(pain_columns)) check_range(column, 0, 10)

  if (anyDuplicated(clean$patient_id) > 0) {
    stop("patient_id is not unique", call. = FALSE)
  }
  invisible(TRUE)
}

#' Reshape to one row per patient per time point
#'
#' @return Columns patient_id, treatment, time (ordered factor), pain,
#'   any_pain (pain > 0). Rows with a missing pain score are dropped.
to_long <- function(clean) {
  long <- tidyr::pivot_longer(
    clean,
    cols = tidyr::all_of(names(pain_columns)),
    names_to = "time",
    values_to = "pain"
  )
  long$time <- factor(
    time_labels[long$time],
    levels = unname(time_labels)
  )
  long$any_pain <- as.integer(long$pain > 0)
  long <- long[!is.na(long$pain), ]
  as.data.frame(long[, c("patient_id", "treatment", "time", "pain", "any_pain")])
}
