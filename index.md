# derappp - Data for Environmental Risk Assessment of Plant Protection Products

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

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

The dependencies `chents` and `srppphist` as well as version 2.05 of
srppp are not on CRAN, so you can install using the sequence

``` r

pak::pak("jranke/chents")
pak::pak("agroscope-ch/srppp")
pak::pak("agroscope-ch/srppphist")
pak::pak("agroscope-ch/derappp")
```

You can also use `remotes::install_github` instead of
[`pak::pak`](https://pak.r-lib.org/reference/pak.html) if you prefer.

Once the `derappp` package is built at R-Universe (there is currently a
build issue), it will be possible to install it from there using a
single command:

``` r

install.packages("derappp",
  repos = c(
    "https://agroscope-ch.r-universe.dev",  # For derappp and srppphist
    "https://jranke.r-universe.dev",        # For chents
    "https://cran.r-project.org"))
```

This will also install the dependencies
[`chents`](https://pkgdown.jrwb.de/chents/) and
[`srppphist`](https://agroscope-ch.github.io/srppphist/).

## Concept and scope

Please have a look a the
[concept](https://agroscope-ch.github.io/derappp/articles/concept.html)
for details.
