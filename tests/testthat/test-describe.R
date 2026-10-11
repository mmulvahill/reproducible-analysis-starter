toy <- data.frame(
  arm = factor(c("A", "A", "B", "B")),
  age = c(40, 60, 30, 50),
  sex = factor(c("F", "M", "F", "F")),
  pain = c(0, 2, NA, 1)
)

test_that("table_one matches hand-computed means, SDs and percentages", {
  t1 <- table_one(toy, by = "arm", vars = c("age", "sex"))
  # A: mean 50, SD 14.1; B: mean 40, SD 14.1
  expect_equal(t1$A[t1$variable == "age"], "50.0 (14.1)")
  expect_equal(t1$B[t1$variable == "age"], "40.0 (14.1)")
  expect_equal(t1$A[t1$level == "F"], "1 (50.0%)")
  expect_equal(t1$B[t1$level == "F"], "2 (100.0%)")
})

test_that("pain_by_group excludes missing outcomes from the denominator", {
  out <- pain_by_group(toy, "pain", by = "arm")
  expect_equal(out$n, c(2L, 1L))
  expect_equal(out$events, c(1L, 1L))
  expect_equal(out$proportion, c(0.5, 1))
})
