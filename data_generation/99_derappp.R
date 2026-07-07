# Finally the central data object is created

library(here)
library(dplyr, warn.conflicts = FALSE)
library(dm, warn.conflicts = FALSE)
library(derappp)
library(jsonlite)

# Define tables to include
derappp_tables <- c("chents",
  "substances", "substance_compositions", "substance_keys",
  "sources",
  "p0", "cwsat", "hydrolysis",
  "soil_sorption",
  "species",
  "effects", "effect_levels",
  "life_stages",
  "aquatic_test_systems",
  "aquatic_toxicity",
  "soil_toxicity",
  "soil_degradation")

# ------------------------------------------------------------------------------
# Load data generated in previous script in 'data_generation'
for (table in derappp_tables) {
  load(here(paste0("data_generation/cache/", table, ".rda")))
}

derappp_table_list <- mget(derappp_tables)

# Escape non-ASCII characters in character columns (with help of Google Gemini)
escape_non_ascii <- function(x) {
  if (is.character(x)) {
    # "byte" to "ascii" with sub="byte" converts non-ASCII to <xx> or <U+xxxx> format
    return(iconv(x, to = "ASCII", sub = "byte"))
  }
  return(x) # Leave numeric, logical, etc., untouched
}

escape_df <- function(df) {
  df[] <- lapply(df, escape_non_ascii)
  return(df)
}

derappp_table_list_ascii <- lapply(derappp_table_list, escape_df)

derappp <-
  derappp_table_list_ascii |>
  as_dm() |>
  dm_add_pk(chents, chent) |>
  dm_add_uk(chents, smiles) |>
  dm_add_uk(chents, pubchem) |>
  dm_add_uk(chents, inchikey) |>
  dm_add_pk(sources, sk) |>
  dm_add_pk(substances, substance) |>
  dm_add_fk(substance_compositions, substance, substances) |>
  dm_add_fk(substance_compositions, chent, chents) |>
  dm_add_fk(substance_keys, substance, substances) |>
  dm_add_pk(species, species) |>
  dm_add_fk(p0, sk, sources) |>
  dm_add_fk(p0, substance, substances) |>
  dm_add_fk(cwsat, sk, sources) |>
  dm_add_fk(cwsat, substance, substances) |>
  dm_add_fk(hydrolysis, sk, sources) |>
  dm_add_fk(hydrolysis, substance, substances) |>
  dm_add_fk(soil_sorption, sk, sources) |>
  dm_add_fk(soil_sorption, substance, substances) |>
  dm_add_fk(soil_degradation, sk, sources) |>
  dm_add_fk(soil_degradation, substance, substances) |>
  dm_add_pk(aquatic_test_systems, test_system) |>
  dm_add_pk(effects, effect) |>
  dm_add_pk(effect_levels, level) |>
  dm_add_pk(life_stages, life_stage) |>
  dm_add_fk(aquatic_toxicity, sk, sources) |>
  dm_add_fk(aquatic_toxicity, substance, substances) |>
  dm_add_fk(aquatic_toxicity, reported_species, species, species) |>
  dm_add_fk(aquatic_toxicity, test_system, aquatic_test_systems) |>
  dm_add_fk(aquatic_toxicity, effect, effects) |>
  dm_add_fk(aquatic_toxicity, level, effect_levels) |>
  dm_add_fk(aquatic_toxicity, life_stage, life_stages) |>
  dm_add_fk(soil_toxicity, sk, sources) |>
  dm_add_fk(soil_toxicity, substance, substances) |>
  dm_add_fk(soil_toxicity, reported_species, species, species) |>
  dm_add_fk(soil_toxicity, effect, effects) |>
  dm_add_fk(soil_toxicity, level, effect_levels) |>
  dm_set_colors(
    darkorange = sources,
    magenta = chents,
    darkviolet = substances:substance_keys,
    darkgreen = species,
    lightgreen = c(effects, effect_levels),
    lightblue = c(aquatic_test_systems, life_stages),
    darkblue = c(p0, cwsat, hydrolysis,
                 soil_sorption, soil_degradation,
                 aquatic_toxicity, soil_toxicity),
    )

# We check if keys are unique and if foreign keys can be resolved
dm_examine_constraints(derappp)

# Save the object to the data directory of the package, so it will
# be available once the package is loaded
save(
  derappp,
  file = here("data/derappp.rda"),
  compress = "xz"
)

# For human readable version control, we write text representations of all
# tables using jsonlite
tables_to_split <- c("aquatic_toxicity", "soil_toxicity")

# Unlink previously generated files so we do not miss deletions
unlink(here("json", "*.json"))
for (json_subdirectory in tables_to_split) {
  unlink(here("json", json_subdirectory, "*.json"))
}

# Export the tables that can be dumped in a single file
for (table_name in setdiff(derappp_tables, tables_to_split))  {
  table <- get(table_name)
  write_json(table,
    path = here("json", paste0(table_name, ".json")),
    digits = I(8), # significant digits
    force = TRUE, # drop units
    pretty = TRUE)
}

# Export the tables that need to be split into multiple files
for (table_name in tables_to_split)  {
  table <- get(table_name)
  for (substance in unique(table$substance)) {
    write_json(filter(table, substance == !!substance),
      path = here("json", table_name, paste0(substance, ".json")),
      digits = I(8), # significant digits
      force = TRUE, # drop units
      pretty = TRUE)
  }
}

# Clean up workspace
rm(list = derappp_tables)
rm(table, substance, table_name, tables_to_split, json_subdirectory)
rm(derappp, derappp_tables, derappp_table_list, derappp_table_list_ascii)
rm(escape_non_ascii, escape_df)

