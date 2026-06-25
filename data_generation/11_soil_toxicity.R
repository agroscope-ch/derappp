# Read in soil toxicity data collected from EFSA conclusions, draft RARs and Review Reports

library(readxl)
library(units)
library(here)
library(tidyr)
library(tibble)

# Load cached data for checking
load(here('data_generation/cache/substances.rda'))
load(here('data_generation/cache/sources.rda'))
load(here('data_generation/cache/species.rda'))
load(here('data_generation/cache/effects.rda'))
load(here('data_generation/cache/effect_levels.rda'))

# The environment variable _derappp_input_ should point to a directory
# containing the files to be read in
derappp_input <- Sys.getenv("_derappp_input_")
if (derappp_input == "") {
  stop("You need to set the environment variable '_derapp_input_'")
} else {
  if (!dir.exists(derappp_input)) {
     stop("The directory ", derappp_input, " does not exist")
  }
}

directory <- "11_soil_toxicity"

check_and_add <- function(filename) {

  input_file <- file.path(derappp_input, directory, filename)
  git_file <- here("data_generation", directory, filename)

  copy_to_git <- derappp:::compare_with_git(input_file, git_file)

  new <- read_xlsx(input_file) |>
    mutate(across(duration, as.numeric)) |>
    mutate(across(starts_with("page"), as.character)) |>
    filter(selected) |> # keep only relevant entries because others were not fully sanitized
    mutate(duration = if_else(is.na(duration), set_units(NA, "d"), set_units(duration, "d"))) |>
    mutate(OM = if_else(is.na(OM), set_units(NA, "%"), set_units(OM, "%"))) |>
    left_join(species[c("species", "group", "derappp_species")],
              by = c(reported_species = "species")) |>
    select(substance, formulation,
      reported_species, derappp_species, group,
      test_nr, duration, OM,
      effect, effect_details,
      level, sign, value, unit,
      sk, page,
      sk_EFSA, page_EFSA,
      sk_RAR, page_RAR,
      selected,
      reason,
      note,
      recorded, checked, file)

  # Some custom splitting of the effect column
  new <- new |>
    mutate(
      effect = if_else(effect == "weight on day 28",
        "weight", effect),
      effect_details = if_else(effect == "weight on day 28",
        "observed on day 28", effect_details))

  # Check if substance names are registered
  unknown_substances <- setdiff(new$substance, substances$substance)
  if (length(unknown_substances > 0)) {
    stop("Please add the following unknown substances using '00_substances.R':\n",
      unknown_substances)
  }

  # Check if species are registered, add standard name and taxonomic group
  unknown_species <- setdiff(new$reported_species, species$species)
  if (length(unknown_species > 0)) {
    stop("Please add the following unknown species using '03_species.R':\n",
      unknown_species)
  }

  # Check if effects are correctly defined
  odd_effects <- setdiff(new$effect, c(effects$effect, NA))
  if (length(odd_effects) > 0) {
    stop("The following effects are not defined: ", odd_effects)
  }

  # Check if effect levels are correctly defined
  odd_effect_levels <- setdiff(new$level, c(effect_levels$level, NA))
  if (length(odd_effect_levels) > 0) {
    stop("The following effect levels are not defined: ", odd_effect_levels)
  }

  # Check if sources are registered
  unknown_source_keys <- setdiff(new$sk, sources$sk)
  if (length(unknown_source_keys > 0)) {
    stop("Please define the following unknown source keys using '01_sources.R':\n",
      unknown_source_keys)
  }

  soil_toxicity <- bind_rows(soil_toxicity, new)

  # Check for duplicates
  dup_columns <- c("substance", "formulation", "test_nr", "derappp_species", "effect", "duration", "level", "sign", "value")
  dup_index <- soil_toxicity |>
    select(any_of(dup_columns)) |>
    duplicated()

  if (any(dup_index)) {
    soil_toxicity[dup_index, dup_columns] |>
      left_join(soil_toxicity, by = dup_columns,
        relationship = "many-to-many") |>
      print()
    stop("Please remove duplications in the above entries")
  }

  # If the above checks are all ok, copy the input file to version control
  if (copy_to_git) {
    message("Copying to ", git_file)
    file.copy(input_file, git_file)
  }

  soil_toxicity <<- soil_toxicity
}


# Set up the table
soil_toxicity <- tibble(
  substance = character(0),
  formulation = character(0),
  reported_species = character(0),
  derappp_species = character(0),
  group = character(0),
  test_nr = character(0),
  duration = set_units(numeric(0), "d"),
  OM = set_units(numeric(0), "%"),
  effect = character(0),
  effect_details = character(0),
  level = character(0),
  sign = factor(character(0), levels = c(">", "=", "<")),
  value = numeric(0),
  unit = character(0),
  sk = character(0),
  page = character(0),
  sk_EFSA = character(0),
  page_EFSA = character(0),
  sk_RAR = character(0),
  page_RAR = character(0),
  selected = logical(0),
  reason = character(0),
  note = character(0),
  recorded = character(0),
  checked = character(0),
  file = character(0)
)

#debug(check_and_add)
#undebug(compare_with_git)
check_and_add("NABO_SQ_macroorganism_toxicity.xlsx")

save(soil_toxicity,
  file = here('data_generation/cache/soil_toxicity.rda'))

# Clean up
rm(
  derappp_input,
  directory,
  substances, species, sources,
  effects, effect_levels,
  check_and_add)
rm(soil_toxicity)
