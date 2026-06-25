# Define general terms used in endpoint tables

library(here)
library(tibble)

# Effects
# These are the currently supported categories
effects <- tribble( ~ effect, ~ definition,
  "behaviour", NA,
  "behavior", NA,
  "biomass", NA,
  "body weight", NA,
  "development", NA,
  "development rate", NA,
  "emergence", NA,
  "growth", NA,
  "growth rate", NA,
  "hatchability", NA,
  "immobilisation", NA,
  "mortality", NA,
  "reproduction", NA,
  "survival", NA,
  "weight", NA,
  "yield", NA,
  "other", NA,
  "others", NA)

# Effect levels
effect_levels <- tribble( ~ level, ~ definition,
  "EC10", "Concentration at which 10 percent effect size is expected",
  "EC20", "Concentration at which 20 percent effect size is expected",
  "EC50", "Concentration at which 50 percent effect size is expected",

  "ER10", "Rate at which 10 percent effect size is expected",
  "ER20", "Rate at which 20 percent effect size is expected",
  "ER50", "Rate at which 50 percent effect size is expected",

  "LC10", "Concentration at which 10 percent mortality is expected",
  "LC50", "Concentration at which 50 percent mortality is expected",

  "LR50", "Rate at which 50 percent mortality is expected",

  "NOEC", "No observed effect concentration",
  "NOER", "No observed effect rate")

# Life stages
life_stages <- tribble( ~ life_stage, ~ definition,
  "early life stage", NA,
  "embryo", NA,
  "larval", NA,
  "juvenile", NA,
  "full life cycle", NA)

save(effects,
  file = here('data_generation/cache/effects.rda'))
save(effect_levels,
  file = here('data_generation/cache/effect_levels.rda'))
save(life_stages,
  file = here('data_generation/cache/life_stages.rda'))

rm(effects, effect_levels, life_stages)
