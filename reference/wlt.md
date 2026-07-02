# Calculate a weighted laboratory toxicity (WLT)

This is an implementation of the method used for deriving WLT values in
the Swiss National Pesticide Risk Indicator project (Korkaric et al.
2020, 2022 and 2023). In the original project, the method was applied
manually. This method facilitates the derivation of updated WLT values
for substances for which the relevant data has been integrated into the
`derappp` package.

## Usage

``` r
wlt(
  substance,
  medium = c("surface water"),
  smaller_than = c("warn", "keep", "ignore"),
  formulations = c("include", "include-unique", "exclude"),
  salt_water = c("include", "special", "exclude"),
  max_AF_salt = Inf
)
```

## Arguments

- substance:

  A substance name

- medium:

  The medium for which the assessment is made

- smaller_than:

  How to handle "smaller than" values (e.g. an endpoint specified as \<
  2 mg/L). Default is to warn if such an endpoint is in the endpoints
  specified as 'selected' in the input data, and belonging to the
  'preferred' endpoints as determined based on endpoint level and
  exposure duration by this function.

- formulations:

  Per default, all formulation data are included. When this argument is
  set to "include-unique", only data on formulations for which no
  comparable (based on species, duration and effect level), but
  ultimately based on expert judgement) endpoint is available are
  included. If set to "exclude", data from formulations are ignored. If
  set to "manual", formulation data to include can be specified using
  the argument "include".

- salt_water:

  Per default, salt water species are included in the assessment for
  surface water. If this argument is set to "special", endpoints from
  salt water species receive a special treatment (see details). If set
  to "exclude", data from an internal list with species not living in
  freshwater are ignored.

- max_AF_salt:

  Maximum factor to increase the assessment factor based on the
  comparison of salt water to freshwater species

## Details

Currently, only surface water WLT values can be derived, and only the
aquatic toxicity table in this package is supported as data source.

Default assessment factors (AF) are as in the EU regulation describing
the Uniform Principles of Risk Assessment (EC 2011), and as detailed in
the EFSA aquatic risk assessment guidance (EFSA 2013).

The special treatment of salt water species is based on the ratio
between salt water and freshwater organisms of the lowest endpoints
within each taxonomic group and separately for short-term and long-term
data.

If this ratio is greater than 10, the AF of the freshwater species in
the group is increased by one tenth of this ratio, up to an optional
maximum factor.

WLT candidates are determined by dividing the preferred endpoint for
each test by the appropriate (AF) which is equal to the TER trigger
value defined in the Uniform Principles (EC 2011), also taking into
account the details and additions (e.g. for macrophytes) as defined in
the EFSA guidance (EFSA 2013).

## References

EC (2011) COMMISSION REGULATION (EU) No 546/2011 Annex Part A 2.5.2.2.

EFSA (2013) Guidance on tiered risk assessment for plant protection
products for aquatic organisms in edge-of-field surface waters,
[doi:10.2903/j.efsa.2013.3290](https://doi.org/10.2903/j.efsa.2013.3290)

Korkaric M, Hanke I, Grossar D, Neuweiler R, Christ B, Wirth J,
Hochstrasser M, Dubuis PH, Kuster T, Breitenmoser S, Egger B, Perren S,
Schürch S, Aldrich A, Jeker L, Poiger T, Daniel O (2020) Datengrundlage
und Kriterien für eine Einschränkung der PSM-Auswahl im ÖLN: Schutz der
Oberflächengewässer, der Bienen und des Grundwassers (Metaboliten),
sowie agronomische Folgen der Einschränkungen. Agroscope Science, 106,
2020, 1-31. [doi:10.34776/as106g](https://doi.org/10.34776/as106g)

Korkaric M, Ammann L, Hanke I, Schneuwly J, Lehto M, Poiger T, de Baan
L, Daniel O, Blom JF (2022) Neue Pflanzenschutzmittel-Risikoindikatoren
für die Schweiz. Agrarforschung Schweiz 13, 1-10,
[doi:10.34776/afs13-1](https://doi.org/10.34776/afs13-1)

Korkaric M, Lehto M, Poiger T, de Baan L, Mathis M, Ammann L, Hanke I,
Balmer M, Blom JF (2023) Risikoindikatoren für Pflanzenschutzmittel:
weiterführende Analysen zur Berechnung. Agroscope Science, 154, 1-48,
[doi:10.34776/as154g](https://doi.org/10.34776/as154g)

## Examples

``` r
f_wlt <- wlt("Flutolanil")
f_wlt$wlt
#> 0.000397 [mg/L]
f_wlt$ratios_salt_nosalt
#> # A tibble: 5 × 6
#>   group                 category salt_FALSE salt_TRUE ratio AF_salt
#>   <chr>                 <chr>        [mg/L]    [mg/L] <dbl>   <dbl>
#> 1 Aquatic algae         pp            0.32  NA         NA     NA   
#> 2 Aquatic invertebrates lt_fi         0.1    0.000397 252.    25.2 
#> 3 Aquatic invertebrates st_fi         0.068  0.0013    52.3    5.23
#> 4 Fish                  lt_fi         0.04  NA         NA     NA   
#> 5 Fish                  st_fi         0.027 NA         NA     NA   
f_wlt$data
#> # A tibble: 17 × 20
#>    group    category species formulation test_nr test_system duration life_stage
#>    <chr>    <chr>    <chr>   <chr>       <ord>   <chr>            [d] <chr>     
#>  1 Aquatic… pp       Selena… ""          12      static             3 NA        
#>  2 Aquatic… pp       Selena… "Moncut 40… 13      static             3 NA        
#>  3 Aquatic… pp       Selena… "Moncut 40… 13      static             3 NA        
#>  4 Aquatic… lt_fi    Americ… ""          10      flow-throu…       28 NA        
#>  5 Aquatic… lt_fi    Americ… ""          10      flow-throu…       28 NA        
#>  6 Aquatic… lt_fi    Chiron… ""          11      static            28 NA        
#>  7 Aquatic… lt_fi    Daphni… ""          8       semi-static       21 NA        
#>  8 Aquatic… lt_fi    Daphni… ""          8       semi-static       21 NA        
#>  9 Aquatic… st_fi    Americ… ""          9       static             4 NA        
#> 10 Aquatic… st_fi    Daphni… ""          7       static             2 NA        
#> 11 Fish     lt_fi    Pimeph… ""          5       flow-throu…       30 early lif…
#> 12 Fish     lt_fi    Pimeph… ""          6       flow-throu…       NA full life…
#> 13 Fish     lt_fi    Pimeph… ""          5       flow-throu…       30 early lif…
#> 14 Fish     st_fi    Danio … ""          4       semi-static        4 larval    
#> 15 Fish     st_fi    Lepomi… ""          2       static             4 NA        
#> 16 Fish     st_fi    Oncorh… ""          1       static             4 NA        
#> 17 Fish     st_fi    Pimeph… ""          3       static             4 NA        
#> # ℹ 12 more variables: effect <chr>, effect_details <chr>, level <chr>,
#> #   sign <chr>, value [mg/L], measured <chr>, selected <lgl>, reason <chr>,
#> #   wlt_candidate [mg/L], critical <lgl>, sk <chr>, page <chr>

# Repeat the analysis without the special treatment for salt water organisms
f_wlt_special <- wlt("Flutolanil", salt_water = "special")
f_wlt_special$wlt
#> 0.00397 [mg/L]
```
