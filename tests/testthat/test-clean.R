# Known-answer tests: a tiny hand-built raw dataset whose clean and long
# forms we can write down by hand.

toy_raw <- function() {
  data.frame(
    preOp_gender = c(0, 1, 1),
    preOp_asa = c(1, 2, 3),
    preOp_calcBMI = c(22.5, 30.1, 27.0),
    preOp_age = c(45, 60, 71),
    preOp_mallampati = c(1, 2, 4),
    preOp_smoking = c(1, 2, 3),
    preOp_pain = c(0, 0, 1),
    treat = c(0, 1, 1),
    intraOp_surgerySize = c(1, 2, 3),
    pacu30min_throatPain = c(0, 3, NA),
    pacu90min_throatPain = c(2, 0, NA),
    postOp4hour_throatPain = c(0, 0, NA),
    pod1am_throatPain = c(1, 0, NA)
  )
}

test_that("clean_licorice labels codes exactly as the codebook says", {
  clean <- clean_licorice(toy_raw())
  expect_equal(nrow(clean), 3)
  expect_equal(as.character(clean$treatment), c("Sugar", "Licorice", "Licorice"))
  expect_equal(as.character(clean$sex), c("Male", "Female", "Female"))
  expect_equal(as.character(clean$smoking), c("Current", "Past", "Never"))
  expect_equal(as.character(clean$surgery_size), c("Small", "Medium", "Large"))
  expect_equal(as.character(clean$preop_pain), c("No", "No", "Yes"))
  expect_equal(clean$pain_30min, c(0, 3, NA))
})

test_that("an unexpected code errors instead of silently becoming NA", {
  raw <- toy_raw()
  raw$treat[2] <- 2
  expect_error(clean_licorice(raw), "treat.*not in the codebook: 2")
})

test_that("out-of-range values are refused, naming the rows", {
  raw <- toy_raw()
  raw$pacu30min_throatPain[1] <- 11
  expect_error(clean_licorice(raw), "pain_30min.*rows: 1")
})

test_that("a missing column is refused by name", {
  raw <- toy_raw()
  raw$treat <- NULL
  expect_error(clean_licorice(raw), "missing columns: treat")
})

test_that("to_long gives one row per observed patient-time", {
  long <- to_long(clean_licorice(toy_raw()))
  # Patients 1 and 2 have four scores each; patient 3 has none.
  expect_equal(nrow(long), 8)
  expect_equal(sum(long$any_pain), 3)
  expect_equal(levels(long$time), c("30 min", "90 min", "4 h", "Day 1 AM"))
  expect_false(3 %in% long$patient_id)
})
