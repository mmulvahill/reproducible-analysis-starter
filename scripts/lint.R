# Lint every R and Quarto file the project ships; exit non-zero on any lint.

lints <- lintr::lint_dir(
  ".",
  pattern = "\\.(R|qmd)$",
  exclusions = list("renv", "_book", "data")
)
print(lints)
quit(status = as.integer(length(lints) > 0))
