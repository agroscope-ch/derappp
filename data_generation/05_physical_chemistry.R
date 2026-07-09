library(here)
library(tibble)
library(units)
library(dplyr, warn.conflicts = FALSE)

# Vapour pressure in Pa
p0 <- tribble(
  ~substance, ~sign, ~p0, ~T, ~purity, ~sk, ~page, ~comment,
  "Acetamiprid", NA, 1.73e-7, 50, "≥99.9%",
  "j.efsa.2016.4610_LoEP", 2L, NA,
  "Captan", NA, 4.2e-6, 20, "99.8%",
  "j.efsa.2020.6230_LoEP", 3L, NA,
  "Captan", NA, 2.01e-4, 50, "98.95%",
  "j.efsa.2020.6230_LoEP", 3L, NA,
  "Copper oxychloride", NA, 0, 20, NA,
  "j.efsa.2013.3235_LoEP", 6L, "Expected to be negligible",
  "Cyprodinil", NA, 4.9e-4, 25, NA,
  "j.efsa.2006.51r", 39L,
  "Midpoint of the range given for crystal modification A"
  ) |>
  mutate(p0 = set_units(p0, "Pa")) |>
  mutate(T = set_units(T, "°C")) |>
  mutate(T = set_units(T, "K"))

# Declare encoding for columns with non-ASCII characters
Encoding(p0$purity) <- "UTF-8"

# Water solubility in mg/L
cwsat <- tribble(
  ~substance, ~sign, ~cwsat, ~T, ~pH, ~purity, ~sk, ~page, ~comment,
  "Acetamiprid", NA, 4250, 25, 5, "≥99%",
  "j.efsa.2016.4610_LoEP", 2L, NA,
  "Acetamiprid", NA, 2950, 25, 7, "≥99%",
  "j.efsa.2016.4610_LoEP", 2L, NA,
  "Acetamiprid", NA, 3960, 25, 9, "≥99%",
  "j.efsa.2016.4610_LoEP", 2L, NA,
  "Captan", NA, 4.8, 20, 5, "99.8%",
  "j.efsa.2020.6230_LoEP", 3L, NA,
  "Captan", NA, 5.2, 20, 7, "99.8%",
  "j.efsa.2020.6230_LoEP", 3L, NA,
  "Captan", NA, NA, 20, 9, "99.8%",
  "j.efsa.2020.6230_LoEP", 3L, "Rapid hydrolysis",
  "Copper oxychloride", NA, 1.19, 20, 6.55, NA,
  "j.efsa.2013.3235_LoEP", 6L,
  "pH value is midpoint of pH range 6.5-6.6",
  "Copper oxychloride", NA, 101e3, 20, 3.1, NA,
  "j.efsa.2013.3235_LoEP", 6L, NA,
  "Copper oxychloride", NA, 0.525, 20, 10.1, NA,
  "j.efsa.2013.3235_LoEP", 6L, NA,
  "Cyprodinil", NA, 20, 25, 5, NA,
  "j.efsa.2006.51r", 39L, "HPLC method",
  "Cyprodinil", NA, 13, 25, 7, NA,
  "j.efsa.2006.51r", 39L, "HPLC method",
  "Cyprodinil", NA, 15, 25, 9, NA,
  "j.efsa.2006.51r", 39L, "HPLC method",
  ) |>
  mutate(cwsat = set_units(cwsat, "mg/L")) |>
  mutate(T = set_units(T, "°C")) |>
  mutate(T = set_units(T, "K"))

# Declare encoding for columns with non-ASCII characters
Encoding(cwsat$purity) <- "UTF-8"

# Hydrolysis half-life
hydrolysis <- tribble(
  ~substance, ~sign, ~DT50, ~unit, ~T, ~pH, ~sk, ~page, ~comment,
  "Captan", NA, 18.4, "h", 25, 5,
  "j.efsa.2020.6230_LoEP", 48L, "[14C-trichloromethyl] label",
  "Captan", NA, 11.7, "h", 25, 5,
  "j.efsa.2020.6230_LoEP", 48L, "[14C-ring] label",
  "Captan", NA, 4.8, "h", 25, 7,
  "j.efsa.2020.6230_LoEP", 48L, "[14C-trichloromethyl] label",
  "Captan", NA, 4.6,  "h", 25, 7,
  "j.efsa.2020.6230_LoEP", 48L, "[14C-ring] label",
  "Captan", NA, 7.8, "min", 25, 9,
  "j.efsa.2020.6230_LoEP", 48L, "[14C-trichloromethyl] label",
  "Captan", NA, 8.1, "min", 25, 9,
  "j.efsa.2020.6230_LoEP", 48L, "[14C-ring] label",
  ) |>
  mutate(T = set_units(T, "°C")) |>
  mutate(T = set_units(T, "K")) |>
  rowwise() |> # for mixed units
  mutate(DT50 = set_units(DT50, unit, mode = "standard")) |>
  mutate(DT50 = if_else(is.na(DT50), set_units(NA, "h"), set_units(DT50, "h"))) |>
  ungroup() |>
  select(-unit)

# ------------------------------------------------------------------------------
# Save results for later inclusion in 'data_generation/99_derappp.R'
tables <- c("p0", "cwsat", "hydrolysis")
for (table in tables) {
  saveRDS(get(table), compress = FALSE,
    file = here("data_generation/cache/", paste0(table, ".rds")))
}

# ------------------------------------------------------------------------------
# Clean up
rm(list = tables)
rm(table, tables)
