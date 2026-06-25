# These EFSA conclusions were published after the latest OpenFoodTox data extraction (2022-09-30)

# We are not complete here, but for 2024 and 2025, the EFSA conclusions for
# substances deemed relevant for the update of the Swiss National Risk Indicators
# are included.

# Kaolin 2022
latest_efsa_conclusions <- bind_rows(latest_efsa_conclusions,
  tibble(Substance = "Kaolin", OutputID = NA, Published = as.Date("2022-11-17"),
    Title = "Peer review of the pesticide risk assessment of the active substance aluminium silicate calcined (kaolin calcined)",
    DOI = "doi:10.2903/j.efsa.2022.7637",
    URL = "http://dx.doi.org/10.2903/j.efsa.2022.7637"))

# Ethephon 2023
latest_efsa_conclusions[latest_efsa_conclusions$Substance == "Ethephon",
  c("OutputID", "Published", "Title", "DOI", "URL")] <-
  tibble(NA, as.Date("2023-01-31"),
    "Peer review of the pesticide risk assessment of the active substance ethephon",
    "doi:10.2903/j.efsa.2023.7742", "http://dx.doi.org/10.2903/j.efsa.2023.7742")

# S-Metolachlor 2023
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "S-Metolachlor", OutputID = NA, Published = as.Date("2023-02-28"),
    Title = "Peer review of the pesticide risk assessment of the active substance S-metolachlor",
    DOI = "doi:10.2903/j.efsa.2023.7852",
    URL = "http://dx.doi.org/10.2903/j.efsa.2023.7852"))

# Metiram 2023
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Metiram", OutputID = NA, Published = as.Date("2023-04-27"),
    Title = "Peer review of the pesticide risk assessment of the active substance metiram",
    DOI = "doi:10.2903/j.efsa.2023.7937",
    URL = "http://dx.doi.org/10.2903/j.efsa.2023.7937"))

# Metrafenone 2023
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Metrafenone", OutputID = NA, Published = as.Date("2023-05-22"),
    Title = "Peer review of the pesticide risk assessment of the active substance metrafenone",
    DOI = "doi:10.2903/j.efsa.2023.8012",
    URL = "http://dx.doi.org/10.2903/j.efsa.2023.8012"))

# Flutolanil 2023
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Flutolanil", OutputID = NA,
    Published = as.Date("2023-06-07"),
    Title = "Peer review of the pesticide risk assessment of the active substance flutolanil",
    DOI = "doi:10.2903/j.efsa.2023.7997",
    URL = "http://dx.doi.org/10.2903/j.efsa.2023.7997"))

# Folpet 2023
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Folpet", OutputID = NA,
    Published = as.Date("2023-08-18"),
    Title = "Peer review of the pesticide risk assessment of the active substance folpet",
    DOI = "doi:10.2903/j.efsa.2023.8139_LoEP",
    URL = "http://dx.doi.org/10.2903/j.efsa.2023.8139"))

# Dimethomorph 2023
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Dimethomorph", OutputID = NA,
    Published = as.Date("2023-06-23"),
    Title = "Peer review of the pesticide risk assessment of the active substance dimethomorph",
    DOI = "doi:10.2903/j.efsa.2023.8032",
    URL = "http://dx.doi.org/10.2903/j.efsa.2023.8032"))

# Trinexapac-ethyl 2023
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Trinexapac-ethyl", OutputID = NA,
    Published = as.Date("2023-06-28"),
    Title = "Updated peer review of the pesticide risk assessment of the active substance trinexapac (variant evaluated trinexapac‐ethyl)",
    DOI = "doi:10.2903/j.efsa.2023.8082",
    URL = "http://dx.doi.org/10.2903/j.efsa.2023.8082"))

# Glyphosate 2023
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Glyphosate", OutputID = NA,
    Published = as.Date("2023-07-06"),
    Title = "Peer review of the pesticide risk assessment of the active substance glyphosate",
    DOI = "doi:10.2903/j.efsa.2023.8164",
    URL = "http://dx.doi.org/10.2903/j.efsa.2023.8164"))

# Mepanipyrim 2023
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Mepanipyrim", OutputID = NA,
    Published = as.Date("2023-08-09"),
    Title = "Updated peer review of the pesticide risk assessment of the active substance mepanipyrim",
    DOI = "doi:10.2903/j.efsa.2023.8196",
    URL = "http://dx.doi.org/10.2903/j.efsa.2023.8196"))

# Metalaxyl-M 2023
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Metalaxyl-M", OutputID = NA,
    Published = as.Date("2023-10-31"),
    Title = "Peer review of the pesticide risk assessment of the active substance metalaxyl-M (amendment of approval conditions)",
    DOI = "doi:10.2903/j.efsa.2023.8373_LoEP",
    URL = "https://doi.org/10.2903/j.efsa.2023.8373"))

# Sulfur 2023
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Sulfur", OutputID = NA,
    Published = as.Date("2022-12-21"),
    Title = "Peer review of the pesticide risk assessment of the active substance sulfur",
    DOI = "doi:10.2903/j.efsa.2023.7805_LoEP",
    URL = "http://dx.doi.org/10.2903/j.efsa.2023.7805"))

# Tritosulfuron 2023
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Tritosulfuron", OutputID = NA,
    Published = as.Date("2023-08-09"),
    Title = "Peer review of the pesticide risk assessment of the active substance tritosulfuron",
    DOI = "doi:10.2903/j.efsa.2023.8142",
    URL = "http://dx.doi.org/10.2903/j.efsa.2023.8142"))

# Triclopyr 2024
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Triclopyr", OutputID = NA,
    Published = as.Date("2024-08-12"),
    Title = "Peer review of the pesticide risk assessment of the active substance triclopyr (variant triclopyr-butotyl)",
    DOI = "doi:10.2903/j.efsa.2024.8177",
    URL = "http://dx.doi.org/10.2903/j.efsa.2024.8177"))

# Amidosulfuron 2024
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Amidosulfuron", OutputID = NA,
    Published = as.Date("2024-09-04"),
    Title = "Peer review of the pesticide risk assessment of the active substance amidosulfuron",
    DOI = "doi:10.2903/j.efsa.2024.8984",
    URL = "http://dx.doi.org/10.2903/j.efsa.2024.8984"))

# Lenacil 2024
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Lenacil", OutputID = NA,
    Published = as.Date("2024-07-05"),
    Title = "Peer review of the pesticide risk assessment of the active substance lenacil",
    DOI = "doi:10.2903/j.efsa.2024.8860",
    URL = "http://dx.doi.org/10.2903/j.efsa.2024.8860"))

# Paraffin oil 2024
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Paraffin oil", OutputID = NA,
    Published = as.Date("2024-07-23"),
    Title = "Peer review of the pesticide risk assessment of the active substance paraffin oil (CAS 8042-47-5, chain lengths C17-C31)",
    DOI = "doi:10.2903/j.efsa.2024.8913",
    URL = "http://dx.doi.org/10.2903/j.efsa.2024.8913"))

# Mepiquat 2024
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Mepiquat chloride", OutputID = NA,
    Published = as.Date("2024-07-24"),
    Title = "Peer review of the pesticide risk assessment of the active substance mepiquat",
    DOI = "doi:10.2903/j.efsa.2024.8923",
    URL = "http://dx.doi.org/10.2903/j.efsa.2024.8923"))

# Flufenacet 2024
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Flufenacet", OutputID = NA,
    Published = as.Date("2024-08-18"),
    Title = "Peer review of the pesticide risk assessment of the active substance flufenacet",
    DOI = "doi:10.2903/j.efsa.2024.8997",
    URL = "http://dx.doi.org/10.2903/j.efsa.2024.8997"))

# Pyrimethanil 2024
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Pyrimethanil", OutputID = NA,
    Published = as.Date("2024-10-07"),
    Title = "Peer review of the pesticide risk assessment of the active substance pyrimethanil",
    DOI = "doi:10.2903/j.efsa.2024.8998",
    URL = "http://dx.doi.org/10.2903/j.efsa.2024.8998"))

# Fludioxonil 2024
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Fludioxonil", OutputID = NA,
    Published = as.Date("2024-11-04"),
    Title = "Peer review of the pesticide risk assessment of the active substance fludioxonil",
    DOI = "doi:10.2903/j.efsa.2024.9047",
    URL = "http://dx.doi.org/10.2903/j.efsa.2024.9047"))

# Penoxsulam 2024
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Penoxsulam", OutputID = NA,
    Published = as.Date("2024-10-29"),
    Title = "Peer review of the pesticide risk assessment of the active substance penoxsulam",
    DOI = "doi:10.2903/j.efsa.2024.9055",
    URL = "http://dx.doi.org/10.2903/j.efsa.2024.9055"))

# Fenoxaprop-P-ethyl 2024
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Fenoxaprop-P-ethyl", OutputID = NA,
    Published = as.Date("2024-11-13"),
    Title = "Peer review of the pesticide risk assessment of the active substance fenoxaprop-P-ethyl",
    DOI = "doi:10.2903/j.efsa.2024.9053",
    URL = "http://dx.doi.org/10.2903/j.efsa.2024.9053"))

# Pirimicarb 2024
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Pirimicarb", OutputID = NA,
    Published = as.Date("2024-10-21"),
    Title = "Peer review of the pesticide risk assessment of the active substance pirimicarb",
    DOI = "doi:10.2903/j.efsa.2024.9046",
    URL = "http://dx.doi.org/10.2903/j.efsa.2024.9046"))

# Gibberellic acid 2024
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Gibberellic acid", OutputID = NA,
    Published = as.Date("2024-11-19"),
    Title = "Peer review of the pesticide risk assessment of the active substance gibberellic acid (GA3)",
    DOI = "doi:10.2903/j.efsa.2024.9065",
    URL = "http://dx.doi.org/10.2903/j.efsa.2024.9065"))

# Gibberellins 2024
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Gibberellins", OutputID = NA,
    Published = as.Date("2024-11-19"),
    Title = "Peer review of the pesticide risk assessment of the active substance gibberellins (GA4 and GA7)",
    DOI = "doi:10.2903/j.efsa.2024.9066",
    URL = "http://dx.doi.org/10.2903/j.efsa.2024.9066"))

# Spinosad 2025
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Spinosad", OutputID = NA,
    Published = as.Date("2025-01-10"),
    Title = "Peer review of the pesticide risk assessment of the active substance spinosad",
    DOI = "doi:10.2903/j.efsa.2025.9193",
    URL = "http://dx.doi.org/10.2903/j.efsa.2025.9193"))

# Clomazone 2025
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Clomazone", OutputID = NA,
    Published = as.Date("2025-02-21"),
    Title = "Peer review of the pesticide risk assessment of the active substance clomazone",
    DOI = "doi:10.2903/j.efsa.2025.9206",
    URL = "http://dx.doi.org/10.2903/j.efsa.2025.9206"))

# Cyprodinil 2025
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Cyprodinil", OutputID = NA,
    Published = as.Date("2025-02-06"),
    Title = "Peer review of the pesticide risk assessment of the active substance cyprodinil",
    DOI = "doi:10.2903/j.efsa.2025.9209",
    URL = "http://dx.doi.org/10.2903/j.efsa.2025.9209"))

# Daminozide 2025
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Daminozide", OutputID = NA,
    Published = as.Date("2025-02-21"),
    Title = "Peer review of the pesticide risk assessment of the active substance daminozide",
    DOI = "doi:10.2903/j.efsa.2025.9210",
    URL = "http://dx.doi.org/10.2903/j.efsa.2025.9210"))

# Pyraclostrobin 2025
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Pyraclostrobin", OutputID = NA,
    Published = as.Date("2025-03-06"),
    Title = "Peer review of the pesticide risk assessment of the active substance pyraclostrobin",
    DOI = "doi:10.2903/j.efsa.2025.9257",
    URL = "http://dx.doi.org/10.2903/j.efsa.2025.9257"))

# Maltodextrin 2025
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Maltodextrin", OutputID = NA,
    Published = as.Date("2025-03-11"),
    Title = "Peer review of the pesticide risk assessment of the active substance maltodextrin",
    DOI = "doi:10.2903/j.efsa.2025.9294",
    URL = "http://dx.doi.org/10.2903/j.efsa.2025.9294"))

# Pelargonic acid 2025
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Pelargonic acid", OutputID = NA,
    Published = as.Date("2025-06-19"),
    Title = "Updated peer review of the pesticide risk assessment of the active substance pelargonic acid (nonanoic acid)",
    DOI = "doi:10.2903/j.efsa.2025.9408",
    URL = "http://dx.doi.org/10.2903/j.efsa.2025.9408"))

# Pendimethalin 2025
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Pendimethalin", OutputID = NA,
    Published = as.Date("2025-07-11"),
    Title = "Peer review of the pesticide risk assessment of the active substance pendimethalin in light of confirmatory data submitted",
    DOI = "doi:10.2903/j.efsa.2025.9511",
    URL = "http://dx.doi.org/10.2903/j.efsa.2025.9511"))

# Maleic hydrazide 2025
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Maleic hydrazide", OutputID = NA,
    Published = as.Date("2025-07-14"),
    Title = "Peer review of the pesticide risk assessment of the active substance maleic hydrazide",
    DOI = "doi:10.2903/j.efsa.2025.9522",
    URL = "http://dx.doi.org/10.2903/j.efsa.2025.9522"))

# Fosetyl 2025
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Fosetyl", OutputID = NA,
    Published = as.Date("2025-08-06"),
    Title = "Peer review of the pesticide risk assessment of the active substance fosetyl",
    DOI = "doi:10.2903/j.efsa.2025.9513",
    URL = "http://dx.doi.org/10.2903/j.efsa.2025.9513"))

# Metalaxyl-M 2025
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Metalaxyl-M", OutputID = NA,
    Published = as.Date("2025-07-29"),
    Title = "Peer review of the pesticide risk assessment of the active substance metalaxyl-M (amendment of approval conditions)",
    DOI = "doi:10.2903/j.efsa.2025.9573",
    URL = "http://dx.doi.org/10.2903/j.efsa.2025.9573"))

# Prothioconazole 2025
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Prothioconazole", OutputID = NA,
    Published = as.Date("2025-08-28"),
    Title = "Peer review of the pesticide risk assessment of the active substance prothioconazole",
    DOI = "doi:10.2903/j.efsa.2025.9593",
    URL = "http://dx.doi.org/10.2903/j.efsa.2025.9593"))

# Pinoxaden 2025
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Pinoxaden", OutputID = NA,
    Published = as.Date("2025-09-08"),
    Title = "Peer review of the pesticide risk assessment of the active substance pinoxaden in light of confirmatory data submitted",
    DOI = "doi:10.2903/j.efsa.2025.9622",
    URL = "http://dx.doi.org/10.2903/j.efsa.2025.9622"))

# Diflufenican 2026
latest_efsa_conclusions <- rbind(latest_efsa_conclusions,
  tibble(Substance = "Diflufenican", OutputID = NA,
    Published = as.Date("2026-02-11"),
    Title = "Peer review of the pesticide risk assessment of the active substance diflufenican",
    DOI = "doi:10.2903/j.efsa.2026.9758",
    URL = "http://dx.doi.org/10.2903/j.efsa.2026.9758"))

