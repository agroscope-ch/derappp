
<!-- README.md is generated from README.rmd. Please edit that file -->

[![R-universe
status](https://agroscope-ch.r-universe.dev/badges/derappp)](https://agroscope-ch.r-universe.dev/derappp)
[![R-CMD-check](https://github.com/agroscope-ch/derappp/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/agroscope-ch/derappp/actions/workflows/R-CMD-check.yaml)

# derappp - Data for Environmental Risk Assessment of Plant Protection Products

Makes some public data for environmental risk assessment of plant
protection products accessible in R. Includes definitions of substances
in terms of well-defined chemical entities, if applicable. Also includes
source references including page numbers, most often referring to
secondary sources, as the original reports are usually unpublished. Uses
standardised scientific names for biological species and includes
physicochemical as well as ecotoxicological data. Data sources are
mainly conclusions from the European pesticide risk assessment peer
review process published by the European Food Safety Authority (EFSA)
and Renewal Assessment Reports (RARs), also published by EFSA. Note that
the use of the data included in this package for registration purposes
may be restricted by regulatory data protection, also known as data
exclusivity rules, as detailed for example in article 59 of Regulation
(EC) No 1107/2009.

## Documentation

A good point to start is the vignette [“Get
Started”](https://agroscope-ch.github.io/derappp/articles/derappp.html)
in the online documentation.

## Installation

You can install `derappp` from R-Universe using a the command

``` r
install.packages("derappp",
  repos = c(
    "https://agroscope-ch.r-universe.dev",  # For derappp and srppphist
    "https://jranke.r-universe.dev",        # For chents
    "https://cran.r-project.org"))
```

This will also install the dependencies
[`chents`](https://pkgdown.jrwb.de/chents/) and
[`srppphist`](https://agroscope-ch.github.io/srppphist/) that are not
published on CRAN.

## Concept and scope

Please have a look a the
[concept](https://agroscope-ch.github.io/derappp/articles/concept.html)
for details.
