.PHONY: all data results test lint numbers book clean

all: data results test lint numbers book

data: data/derived/clean.rds

data/derived/clean.rds: data/raw/licorice_gargle.csv scripts/02_make_analysis_data.R R/*.R
	Rscript scripts/02_make_analysis_data.R

# Every model is fitted here, once. The book only reads the saved results.
results: data/derived/results.rds

data/derived/results.rds: data/derived/clean.rds scripts/03_fit_models.R R/*.R
	Rscript scripts/03_fit_models.R

test:
	Rscript -e 'testthat::test_local(stop_on_failure = TRUE)'

lint:
	Rscript scripts/lint.R

numbers:
	Rscript scripts/check_inline_numbers.R

book: results
	quarto render

clean:
	rm -rf _book data/derived/*.rds
