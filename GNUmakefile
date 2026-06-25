PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
TGZ     := $(PKGNAME)_$(PKGVERS).tar.gz
RBIN ?= $(shell dirname "`which R`")

all: install

README.md: README.rmd
	Rscript -e "rmarkdown::render('README.rmd', output_format = 'github_document', output_options = list(html_preview = FALSE))"

pkgfiles = \
	.Rbuildignore \
	_pkgdown.yml \
	DESCRIPTION \
	NAMESPACE \
	NEWS.md \
	README.md \
	data/* \
	inst/REFERENCES.bib \
	R/* \
	tests/testthat.R \
	tests/testthat/*

roxy:
	$(RBIN)/Rscript -e "roxygen2::roxygenize(roclets = c('rd', 'collate', 'namespace'))"

$(TGZ): $(pkgfiles)
	"$(RBIN)/R" CMD build . 2>&1 | tee log/build.log

pd: README.md roxy
	"$(RBIN)/Rscript" -e "pkgdown::build_site(run_dont_run = TRUE, lazy = TRUE)"

pd_all: README.md roxy
	"$(RBIN)/Rscript" -e "pkgdown::build_site(run_dont_run = TRUE)"

build: roxy $(TGZ)

test: build
	NOT_CRAN=true "$(RBIN)/Rscript" -e 'options(cli.dynamic = TRUE); devtools::test()' 2>&1 | tee log/test.log
	sed -i -e "s/\r.*\r//" log/test.log

quickcheck: build
	_R_CHECK_CRAN_INCOMING_REMOTE_=false "$(RBIN)/R" CMD check $(TGZ) --no-tests

check: roxy build
	_R_CHECK_CRAN_INCOMING_REMOTE_=false "$(RBIN)/R" CMD check --as-cran --no-tests $(TGZ) 2>&1 | tee log/check.log

install: build
	"$(RBIN)/R" CMD INSTALL --no-multiarch $(TGZ)

winbuilder: build
	date
	@echo "Uploading to R-release on win-builder"
	curl -T $(TGZ) ftp://anonymous@win-builder.r-project.org/R-release/
	@echo "Uploading to R-devel on win-builder"
	curl -T $(TGZ) ftp://anonymous@win-builder.r-project.org/R-devel/

.PHONEY: roxy pd pd_all build test quickcheck check install winbuilder
