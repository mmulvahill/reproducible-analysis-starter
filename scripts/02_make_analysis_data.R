# Raw -> analysis data. Run with `make data` (or Rscript from the repo root).
#
# data/raw is read-only: this script refuses to run if the raw file's bytes
# differ from the checksum recorded when it was received.

pkgload::load_all(here::here(), quiet = TRUE)

raw_path <- here::here("data", "raw", "licorice_gargle.csv")
expected_md5 <- "fe23d586f6bdc92a5db1342f8e41a283"

actual_md5 <- unname(tools::md5sum(raw_path))
if (!identical(actual_md5, expected_md5)) {
  stop(
    "data/raw/licorice_gargle.csv has changed (md5 ", actual_md5,
    ", expected ", expected_md5, "). Raw data is read-only: if a new ",
    "delivery arrived, save it as a new file and log it in DECISIONS.md.",
    call. = FALSE
  )
}

raw <- utils::read.csv(raw_path)
clean <- clean_licorice(raw)
long <- to_long(clean)

dir.create(here::here("data", "derived"), showWarnings = FALSE)
saveRDS(clean, here::here("data", "derived", "clean.rds"))
saveRDS(long, here::here("data", "derived", "long.rds"))

lineage <- data.frame(
  step = c("raw", "clean (one row per patient)", "long (patient x time)"),
  rows = c(nrow(raw), nrow(clean), nrow(long)),
  file = c(
    "data/raw/licorice_gargle.csv",
    "data/derived/clean.rds",
    "data/derived/long.rds"
  )
)
saveRDS(lineage, here::here("data", "derived", "lineage.rds"))

message(sprintf(
  "raw %d rows -> clean %d patients -> long %d patient-times",
  nrow(raw), nrow(clean), nrow(long)
))
