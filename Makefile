.PHONY: all data test lint numbers book clean

all: data test lint numbers book

data: data/derived/clean.rds

data/derived/clean.rds: data/raw/licorice_gargle.csv scripts/02_make_analysis_data.R R/*.R
	Rscript scripts/02_make_analysis_data.R

test:
	Rscript -e 'testthat::test_local(stop_on_failure = TRUE)'

lint:
	Rscript scripts/lint.R

numbers:
	Rscript scripts/check_inline_numbers.R

book: data
	quarto render

clean:
	rm -rf _book data/derived/*.rds
