# Raw data (read-only)

Files here are exactly as received. Never edit them; every change happens in
code (`scripts/02_make_analysis_data.R`), which refuses to run if a raw
file's checksum changes.

| File | Received | Source | MD5 |
|---|---|---|---|
| `licorice_gargle.csv` | 2026-10-10 | `medicaldata` R package (MIT); Nowacki, "Licorice Gargle Dataset", TSHS Resources Portal (2017); Ruetzler et al., *Anesth Analg* 2013;117:614–21 | `fe23d586f6bdc92a5db1342f8e41a283` |

Codebook: `?medicaldata::licorice_gargle`.

A new delivery is saved as a new file (e.g. `licorice_gargle_2026-11-02.csv`),
added to this table, and logged in DECISIONS.md.
