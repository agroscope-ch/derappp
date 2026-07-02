# Data for environmental risk assessment of plant protection products

Data for environmental risk assessment of plant protection products

## Usage

``` r
derappp
```

## Format

A number of tables collected in a
[dm::dm](https://dm.cynkra.com/reference/dm.html) object

## Examples

``` r
library(derappp) # This also loads the dm package
dm_draw(derappp)
%0


aquatic_test_systems
aquatic_test_systemstest_systemaquatic_toxicity
aquatic_toxicitysubstancetest_systemlife_stageeffectlevelskreported_speciesaquatic_toxicity:test_system->aquatic_test_systems:test_system
effect_levels
effect_levelslevelaquatic_toxicity:level->effect_levels:level
effects
effectseffectaquatic_toxicity:effect->effects:effect
life_stages
life_stageslife_stageaquatic_toxicity:life_stage->life_stages:life_stage
sources
sourcesskaquatic_toxicity:sk->sources:sk
species
speciesspeciesaquatic_toxicity:reported_species->species:species
substances
substancessubstanceaquatic_toxicity:substance->substances:substance
chents
chentschentsmilespubcheminchikeycwsat
cwsatsubstanceskcwsat:sk->sources:sk
cwsat:substance->substances:substance
hydrolysis
hydrolysissubstanceskhydrolysis:sk->sources:sk
hydrolysis:substance->substances:substance
p0
p0substanceskp0:sk->sources:sk
p0:substance->substances:substance
soil_degradation
soil_degradationsubstancesksoil_degradation:sk->sources:sk
soil_degradation:substance->substances:substance
soil_sorption
soil_sorptionsubstancesksoil_sorption:sk->sources:sk
soil_sorption:substance->substances:substance
soil_toxicity
soil_toxicitysubstancereported_specieseffectlevelsksoil_toxicity:level->effect_levels:level
soil_toxicity:effect->effects:effect
soil_toxicity:sk->sources:sk
soil_toxicity:reported_species->species:species
soil_toxicity:substance->substances:substance
substance_compositions
substance_compositionssubstancechentsubstance_compositions:chent->chents:chent
substance_compositions:substance->substances:substance
substance_keys
substance_keyssubstancesubstance_keys:substance->substances:substance

# The list of chemical entities ("chents")
derappp$chents
#> # A tibble: 358 × 8
#>    chent                 ai    iso      mw smiles pubchem inchikey bcpc_activity
#>    <chr>                 <lgl> <chr> <dbl> <chr>    <int> <chr>    <chr>        
#>  1 1-Decanol             TRUE  NA    158.  CCCCC…    8174 MWKFXSU… NA           
#>  2 1-Methylcyclopropene  TRUE  NA     54.1 CC1=C…  151080 SHDPRTQ… plant growth…
#>  3 1-Naphthylacetic acid TRUE  NA    186.  C1=CC…    6862 PRPINYU… NA           
#>  4 2,4-D                 TRUE  2,4-D 221.  C1=CC…    1486 OVSKIKF… herbicides   
#>  5 2,4-DB                TRUE  2,4-… 249.  C1=CC…    1489 YIVXMZJ… herbicides   
#>  6 2,6-Dichlorobenzamide FALSE NA    190.  C1=CC…   16183 JHSPCUH… NA           
#>  7 2-(1-Naphthyl) aceta… TRUE  NA    185.  C1=CC…    6861 XFNJVKM… NA           
#>  8 2-Amino-4,6-dimethox… FALSE NA    155.  COC1=…  118946 LVFRCHI… NA           
#>  9 6-Benzyladenine       TRUE  NA    225.  C1=CC…   62389 NWBJYWH… NA           
#> 10 Acequinocyl           TRUE  Aceq… 384.  CCCCC…   93315 QDRXWCA… acaricides   
#> # ℹ 348 more rows

# Some vapor pressures and water solubilities
library(units)
#> udunits database from /usr/share/xml/udunits/udunits2.xml
derappp$p0[1:2, ]
#> # A tibble: 2 × 8
#>   substance   sign           p0    T purity sk                     page comment
#>   <chr>       <lgl>        [Pa] [°C] <chr>  <chr>                 <int> <chr>  
#> 1 Acetamiprid NA    0.000000173   50 ≥99.9% j.efsa.2016.4610_LoEP     2 NA     
#> 2 Captan      NA    0.0000042     20 99.8%  j.efsa.2020.6230_LoEP     3 NA     
derappp$p0[1, ] |>
  left_join(derappp$sources, by = "sk") |>
  select(substance, p0, T, reference)
#> # A tibble: 1 × 4
#>   substance            p0    T reference                                        
#>   <chr>              [Pa] [°C] <chr>                                            
#> 1 Acetamiprid 0.000000173   50 "EFSA. _Appendix to: Peer review of the pesticid…

derappp$cwsat[1:3, ] |>
  left_join(derappp$sources, by = "sk") |>
  select(substance, cwsat, T, pH, reference) |>
  mutate(cwsat = set_units(cwsat, "g/L", mode = "standard"))
#> # A tibble: 3 × 5
#>   substance   cwsat    T    pH reference                                        
#>   <chr>       [g/L] [°C] <dbl> <chr>                                            
#> 1 Acetamiprid  4.25   25     5 "EFSA. _Appendix to: Peer review of the pesticid…
#> 2 Acetamiprid  2.95   25     7 "EFSA. _Appendix to: Peer review of the pesticid…
#> 3 Acetamiprid  3.96   25     9 "EFSA. _Appendix to: Peer review of the pesticid…

# Join names used in the Swiss register
derappp$chents |>
  left_join(derappp$substance_keys, by = c(chent = "substance")) |>
  filter(db == "srppp") |>
  left_join(srppphist::srppp_active_substances, by = c(key = "pk")) |>
  select(chent, iso, smiles, substance_de)
#> # A tibble: 377 × 4
#>    chent                    iso   smiles                           substance_de 
#>    <chr>                    <chr> <chr>                            <chr>        
#>  1 1-Decanol                NA    CCCCCCCCCCO                      1-Decanol    
#>  2 1-Decanol                NA    CCCCCCCCCCO                      1-Decanol    
#>  3 1-Naphthylacetic acid    NA    C1=CC=C2C(=C1)C=CC=C2CC(=O)O     1-Naphthylac…
#>  4 1-Naphthylacetic acid    NA    C1=CC=C2C(=C1)C=CC=C2CC(=O)O     1-Naphthylac…
#>  5 2,4-D                    2,4-D C1=CC(=C(C=C1Cl)Cl)OCC(=O)O      2,4-D        
#>  6 2,4-D                    2,4-D C1=CC(=C(C=C1Cl)Cl)OCC(=O)O      2,4-D        
#>  7 2-(1-Naphthyl) acetamide NA    C1=CC=C2C(=C1)C=CC=C2CC(=O)N     2-(1-naphthy…
#>  8 2-(1-Naphthyl) acetamide NA    C1=CC=C2C(=C1)C=CC=C2CC(=O)N     1-Naphthylac…
#>  9 2-(1-Naphthyl) acetamide NA    C1=CC=C2C(=C1)C=CC=C2CC(=O)N     1-Naphthylac…
#> 10 6-Benzyladenine          NA    C1=CC=C(C=C1)CNC2=NC=NC3=C2NC=N3 6-benzyladen…
#> # ℹ 367 more rows

# Show some soil sorption data with units
derappp$soil_sorption |>
  filter(substance %in% c("Acetamiprid", "Captan", "Copper", "Cyprodinil")) |>
  select(substance, soil_pH, f_oc, Koc, Kfoc, n, sk, selected, reason) |>
  print(n = Inf)
#> # A tibble: 10 × 9
#>    substance   soil_pH    f_oc    Koc   Kfoc      n sk           selected reason
#>    <chr>         <dbl>     [1] [L/kg] [L/kg]  <dbl> <chr>        <lgl>    <chr> 
#>  1 Acetamiprid     5.7  0.0043   NA    138.   0.842 j.efsa.2016… NA       EFSA …
#>  2 Acetamiprid     7.6  0.0104   NA    130.   0.825 j.efsa.2016… NA       EFSA …
#>  3 Acetamiprid     7.1  0.0157   NA     71.1  0.893 j.efsa.2016… NA       EFSA …
#>  4 Acetamiprid     7.7  0.0139   NA    122.   0.835 j.efsa.2016… NA       EFSA …
#>  5 Acetamiprid     7.1  0.0439   NA     71.4  0.907 j.efsa.2016… NA       EFSA …
#>  6 Captan         NA   NA        76.8   NA   NA     j.efsa.2020… NA       EFSA …
#>  7 Cyprodinil      5.6 NA        NA   2098.   0.816 j.efsa.2025… NA       EFSA …
#>  8 Cyprodinil      6.7 NA        NA   1794.   0.787 j.efsa.2025… NA       EFSA …
#>  9 Cyprodinil      7.3 NA        NA   1593    0.833 j.efsa.2025… NA       EFSA …
#> 10 Cyprodinil      7   NA        NA   1678.   0.874 j.efsa.2025… NA       EFSA …

# Show some soil degradation data with units
derappp$soil_degradation |>
  select(substance, DT50, kinetics, alpha, beta, k1, k2, g, tb, sk) |>
  print(n = 10)
#> # A tibble: 71 × 10
#>    substance       DT50 kinetics alpha  beta      k1       k2   g  tb sk        
#>    <chr>            [d] <chr>      [1] [1/d]   [1/d]    [1/d] [1] [d] <chr>     
#>  1 Amisulbrom      12.6 SFO      NA     NA   NA      NA        NA  NA j.efsa.20…
#>  2 Azoxystrobin   262   SFO      NA     NA   NA      NA        NA  NA j.efsa.20…
#>  3 Benalaxyl      128.  SFO      NA     NA   NA      NA        NA  NA j.efsa.20…
#>  4 Bixafen       3014.  HS       NA     NA    0.0081  0.00023  NA  53 j.efsa.20…
#>  5 Boscalid       227.  SFO      NA     NA   NA      NA        NA  NA Boscalid_…
#>  6 Bupirimate     119.  FOMC      1.12  58.4 NA      NA        NA  NA j.efsa.20…
#>  7 Buprofezin     166.  SFO      NA     NA   NA      NA        NA  NA j.efsa.20…
#>  8 Carbendazim     78   SFO      NA     NA   NA      NA        NA  NA j.efsa.20…
#>  9 Chloridazon     78.5 SFO      NA     NA   NA      NA        NA  NA j.efsa.20…
#> 10 Chlorotoluron  107.  SFO      NA     NA   NA      NA        NA  NA Chlorotol…
#> # ℹ 61 more rows

# Some aquatic toxicity data with units
head(derappp$aquatic_toxicity) |>
  select(substance, formulation, derappp_species, duration, effect, level, sign, value)
#> # A tibble: 6 × 8
#>   substance formulation        derappp_species duration effect level sign  value
#>   <chr>     <chr>              <chr>                [d] <chr>  <chr> <chr> [mg/…
#> 1 Abamectin Abamectin (purity… Pimephales pro…        4 NA     LC50  =     14.7 
#> 2 Abamectin Abamectin (purity… Oncorhynchus m…        4 NA     LC50  =      7   
#> 3 Abamectin Abamectin 1.8% EC  Oncorhynchus m…        4 NA     LC50  =      2.5 
#> 4 Abamectin NA                 Danio rerio            4 NA     LC50  =     49   
#> 5 Abamectin NA                 Oncorhynchus m…       72 NA     NOEC  =      0.52
#> 6 Abamectin Abamectin (purity… Daphnia magna          2 NA     EC50  =      0.56

# Species groupings and taxonomic IDs
derappp$species
#> # A tibble: 199 × 7
#>    species      group derappp_species ott_id is_synonym flags salt_water_species
#>    <chr>        <chr> <chr>            <int> <lgl>      <chr> <lgl>             
#>  1 Acipenser t… Fish  Acipenser tran… 3.79e5 FALSE      ""    FALSE             
#>  2 Americamysi… Aqua… Americamysis b… 3.34e5 FALSE      ""    TRUE              
#>  3 American fl… Fish  Jordanella flo… 8.23e4 FALSE      ""    FALSE             
#>  4 American wa… Aqua… Elodea canaden… 1.07e6 FALSE      ""    FALSE             
#>  5 Amphiascus … Aqua… Amphiascus ten… 5.95e5 FALSE      ""    FALSE             
#>  6 Anabaena fl… Aqua… Dolichospermum… 3.69e5 FALSE      "sib… FALSE             
#>  7 Anabaena fl… Aqua… Dolichospermum… 3.69e5 FALSE      "sib… FALSE             
#>  8 Anabaena va… Aqua… Trichormus var… 5.24e5 TRUE       "inc… FALSE             
#>  9 Ankistrodes… Aqua… Ankistrodesmus… 7.28e5 FALSE      ""    FALSE             
#> 10 Aphanizomen… Aqua… Aphanizomenon … 8.94e5 FALSE      "sib… FALSE             
#> # ℹ 189 more rows
```
