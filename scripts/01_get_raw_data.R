# One-time: how data/raw/licorice_gargle.csv was obtained.
#
# Kept for provenance; you do not need to run it. The raw file is committed
# and never edited. If you do re-run it, 02_make_analysis_data.R will refuse
# to proceed unless the bytes match the checksum in data/raw/README.md.
#
# Source: medicaldata R package (MIT licence), dataset contributed by
# Amy S. Nowacki, "Licorice Gargle Dataset", TSHS Resources Portal (2017),
# from Ruetzler et al., Anesth Analg 2013;117:614-21.

if (!requireNamespace("medicaldata", quietly = TRUE)) {
  stop("install.packages('medicaldata') to re-fetch the raw data")
}

utils::write.csv(
  medicaldata::licorice_gargle,
  here::here("data", "raw", "licorice_gargle.csv"),
  row.names = FALSE
)
message("Wrote data/raw/licorice_gargle.csv; md5: ",
        tools::md5sum(here::here("data", "raw", "licorice_gargle.csv")))
