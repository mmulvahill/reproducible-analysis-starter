# Sourced at the top of every chapter. Loads project functions and the
# derived data written by `make data`. Chapters never read data/raw.

pkgload::load_all(here::here(), quiet = TRUE)

derived <- here::here("data", "derived")
if (!file.exists(file.path(derived, "clean.rds"))) {
  stop("Derived data not found. Run `make data` first.", call. = FALSE)
}

clean <- readRDS(file.path(derived, "clean.rds"))
long <- readRDS(file.path(derived, "long.rds"))
lineage <- readRDS(file.path(derived, "lineage.rds"))
