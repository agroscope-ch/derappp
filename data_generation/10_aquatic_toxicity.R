# Read in aquatic toxicity data collected from EFSA conclusions

library(readxl)
library(units)
library(here)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(tibble)

# Load cached data for checking
load(here("data_generation/cache/chents.rda"))
load(here("data_generation/cache/substances.rda"))
load(here("data_generation/cache/sources.rda"))
load(here("data_generation/cache/species.rda"))
load(here("data_generation/cache/effects.rda"))
load(here("data_generation/cache/effect_levels.rda"))
load(here("data_generation/cache/life_stages.rda"))

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

# Below very brief descriptions of aquatic test system types are given. For
# a more comprehensive discussion, see for example the book chapter
# "Ecotoxicological Effects" by T.P. Traas and C.J. van Leeuwen in the book
# Risk Assessment of Chemical: An Introduction (1996) Springer
aquatic_test_systems <- tribble( ~ test_system, ~ definition,
  "static", "Test organisms are exposed to the same test solution for the duration of the test",
  "semi-static", "The test solution is renewed or partially renewed during the duration of the test",
  "flow-through", "Test organisms are exposed to constantly or intermittently flowing test solution",
  "other", "Test systems that do not fall into the other categories")

directory <- "10_aquatic_toxicity"

check_and_add <- function(filename) {

  input_file <- file.path(derappp_input, directory, filename)
  git_file <- here("data_generation", directory, filename)

  copy_to_git <- if (file.exists(git_file)) {
    derappp:::compare_with_git(input_file, git_file)
  } else {
    TRUE
  }

  new_raw <- read_xlsx(input_file)

  # Add RAR columns if they are not present in the input
  has_RAR_columns <- all(c("sk_RAR", "page_RAR") %in% names(new_raw))
  if (!has_RAR_columns) {
    new_raw_with_RAR <- new_raw |>
      mutate(sk_RAR = NA, page_RAR = NA)
  } else {
    new_raw_with_RAR <- new_raw
  }
  new <- new_raw_with_RAR |>

    # Ascertain some column types
    mutate(across(c(page, sk_RAR, page_RAR, test_nr, test_system_details, life_stage),
                  as.character)) |>
    mutate(across(c(selected), as.logical)) |>

    # Filter out unneeded items
    filter(selected) |> # keep only relevant entries because others were not fully sanitized
    filter(!grepl("sediment", unit)) |> # ignore sediment based endpoints for now

    # Handle units for duration and value
    separate_wider_delim(duration, delim = " ", names = c("dur_val", "dur_unit")) |>
    mutate(dur_val = as.numeric(dur_val)) |>
    rowwise() |>  # set_units is not vectorised
    mutate(duration = set_units(dur_val, ifelse(is.na(dur_unit), "d", dur_unit), mode = "standard")) |>
    mutate(duration = set_units(duration, "d")) |>
    mutate(value = ifelse(is.na(value), set_units(NA, "mg/L"), set_units(value, unit, mode = "standard"))) |> # NA values need a unit, too
    mutate(value = set_units(value, "mg/L")) |> # Convert reported units to mg/L
    mutate(sign = if_else(is.na(sign), "=", sign)) |>
    mutate(file = filename) |>
    ungroup() |>

    # Select return columns
    select(substance, formulation, reported_species = species, test_nr,
      test_system, test_system_details,
      duration, life_stage,
      effect, effect_details,
      level, sign, value, measured,
      sk, page, sk_RAR, page_RAR, selected, reason, note, recorded, checked, file)

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
      paste(unknown_species, collapse = ", "))
  }
  new_with_standard_species <- new |>
    left_join(species[c("species", "group", "derappp_species")],
              by = c(reported_species = "species"))

  # Check if test systems are correctly defined
  odd_test_systems <- setdiff(new$test_system, c(aquatic_test_systems$test_system, NA))
  if (length(odd_test_systems) > 0) {
    stop("The following test systems are not defined: ", odd_test_systems)
  }

  # Check if life stages are correctly defined
  odd_life_stages <- setdiff(new$life_stage, c(life_stages$life_stage, NA))
  if (length(odd_life_stages) > 0) {
    stop("The following life stages are not defined: ", odd_life_stages)
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

  # Check for NA values in source key column
  missing_source_keys <- filter(new, is.na(sk))
  if (nrow(missing_source_keys) > 0) {
    stop("Please add source keys to the 'sk' column of the following entries:\n",
         missing_source_keys)
  }

  # Check if sources are registered
  unknown_source_keys <- setdiff(new$sk, sources$sk)
  if (length(unknown_source_keys > 0)) {
    stop("Please define the following unknown source keys using '01_sources.R':\n",
      unique(unknown_source_keys))
  }

  # Check if RAR sources are registered
  unknown_RAR_source_keys <- setdiff(new$sk_RAR, c(sources$sk, NA))
  if (length(unknown_RAR_source_keys > 0)) {
    stop("Please define the following unknown RAR source keys using '01_sources.R':\n",
      unique(unknown_RAR_source_keys))
  }


  # Correct concentrations of copper based endpoints
  # EFSA endpoints for copper compounds refer to elemental copper.
  # Concentrations are corrected here to refer to the listed substance.
  if (any(grepl("Expressed as copper", new_with_standard_species$note))) {

    # Bordeaux mixture is treated separately
    # In the EFSA conclusion from 2018, the copper content of the representative
    # WG formulation is given as 200 g Cu/kg (p. 7). The minimum purities of products
    # from five manufacturers is between 257 g/kg and 276 g/kg, based on the solid
    # contents without the water contribution (p. 8).

    # In the Swiss Register, it seems that sometimes the active substance content
    # is either expressed as the "Bordeaux mixture" content of the formulation (77%, W-2116, W-7065)
    # or as the copper content of the complete formulation (20%, W-7197).
    # All of the above numbers indicate to a typical copper content of 200 g Cu/kg in
    # the products evaluated in the EU and on the Swiss market, corresponding
    # to about 260 g/kg Copper in the "Bordeaux mixture" content of the formulation.

    # In derappp, Bordeaux mixture is defined as a mixture of Copper(II) sulfate and
    # Calcium hydroxide. In order to be able to convert toxicity values expressed
    # in terms of copper in terms of "Bordeaux mixture", we pragmatically use
    # an approximate copper content of 26% in the solid content of typical
    # formulations, taken from the EFSA conclusion from 2018 (p. 8)

    new_with_standard_species_and_copper_resolved <- new_with_standard_species |>
      left_join(chents[c("chent", "mw")], by = c(substance = "chent")) |>
      rowwise() |> # gsub does not support vectors as replacement
      mutate(
        original_value = value,
        value = if_else(grepl("Expressed as copper", note),
          case_when(
            substance == "Bordeaux mixture" ~ value/0.26, # Copper content in the "Bordeaux mixture" is ~ 26% (see above)
            .default = value * mw/63.55), # Convert values expressed as copper concentrations to derappp substance concentrations using molecular weights
          value),
        note = if_else(grepl("Expressed as copper", note),
          case_when(
            substance == "Bordeaux mixture" ~ "Expressed as the solids in Bordeaux mixture, assuming a content of 260 g Cu/kg in the solids",
            .default = gsub("Expressed as copper",
               paste0("Expressed as ", substance, " (", mw, " g/mol). ",
                 "Original value was ", original_value, " ", as.character(units(original_value)), ", expressed as copper"), note)),
            note))
  } else {
    new_with_standard_species_and_copper_resolved <- new_with_standard_species
  }

  aquatic_toxicity <- bind_rows(aquatic_toxicity, new_with_standard_species_and_copper_resolved) |>
    select(substance, formulation,
      derappp_species, group,
      test_nr, test_system, duration, life_stage, effect, effect_details, level,
      sign, value, measured,
      sk, page, sk_RAR, page_RAR, selected, reason, note, reported_species, recorded, checked, file)

  # Check for duplicates
  dup_columns <- c("substance", "formulation", "test_nr", "derappp_species", "effect", "duration", "level", "sign", "value")
  dup_index <- aquatic_toxicity |>
    select(any_of(dup_columns)) |>
    duplicated()

  if (any(dup_index)) {
    aquatic_toxicity[dup_index, dup_columns] |>
      left_join(aquatic_toxicity, by = dup_columns,
        relationship = "many-to-many") |>
      print()
    stop("Please remove duplications in the above entries")
  }

  # If the above checks are all ok, copy the input file to version control
  if (copy_to_git) {
    message("Copying to ", git_file)
    file.copy(input_file, git_file, overwrite = TRUE)
  }

  aquatic_toxicity <<- aquatic_toxicity
}

# Set up the table
aquatic_toxicity <- tibble(
  substance = character(0),
  formulation = character(0),
  derappp_species = character(0),
  group = character(0),
  test_nr = character(0),
  test_system = character(0),
  test_system_details = character(0),
  duration = set_units(numeric(0), "d"),
  life_stage = character(0),
  effect = character(0),
  effect_details = character(0),
  level = character(0),
  sign = factor(character(0), levels = c(">", "=", "<")),
  value = set_units(numeric(0), "mg/L"),
  measured = factor(character(0), levels = c("nom", "mm", "ini", "im", "geom")),
    # nom: nominal, mm: mean measured, ini or im: initial measured,
    # geom: geometric mean measured
  sk = character(0),
  page = character(0),
  sk_RAR = character(0),
  page_RAR = character(0),
  selected = logical(0),
  reason = character(0),
  reported_species = character(0),
  note = character(0),
  recorded = character(0),
  checked = character(0),
  file = character(0)
)

#debug(check_and_add)
#undebug(check_and_add)
check_and_add("1-naphthylacetic_acid_aquatic_toxicity.xlsx")
check_and_add("2,4-D_aquatic_toxicity.xlsx")
check_and_add("6-benzyladenine_aquatic_toxicity.xlsx")
check_and_add("abamectin_aquatic_toxicity.xlsx")
check_and_add("acetamiprid_aquatic_toxicity.xlsx")
check_and_add("ametoctradin_aquatic_toxicity.xlsx")
check_and_add("amidosulfuron_aquatic_toxicity.xlsx")
check_and_add("captan_aquatic_toxicity.xlsx")
check_and_add("copper_aquatic_toxicity.xlsx")
check_and_add("cyprodinil_aquatic_toxicity.xlsx")
check_and_add("ethephon_aquatic_toxicity.xlsx")
check_and_add("fenoxaprop-P-ethyl_aquatic_toxicity.xlsx")
check_and_add("fludioxonil_aquatic_toxicity.xlsx")
check_and_add("flufenacet_aquatic_toxicity.xlsx")
check_and_add("flutolanil_aquatic_toxicity.xlsx")
check_and_add("gibberellic_acid_aquatic_toxicity.xlsx")
check_and_add("gibberellins_aquatic_toxicity.xlsx")
check_and_add("indoxacarb_aquatic_toxicity.xlsx")
check_and_add("kaolin_aquatic_toxicity.xlsx")
check_and_add("lambda-cyhalothrin_aquatic_toxicity.xlsx")
check_and_add("laminarin_aquatic_toxicity.xlsx")
check_and_add("lenacil_aquatic_toxicity.xlsx")
check_and_add("mepanipyrim_aquatic_toxicity.xlsx")
check_and_add("mepiquat_chloride_aquatic_toxicity.xlsx")
check_and_add("methoxyfenozide_aquatic_toxicity.xlsx")
check_and_add("metiram_aquatic_toxicity.xlsx")
check_and_add("metrafenone_aquatic_toxicity.xlsx")
check_and_add("paraffin_oil_aquatic_toxicity.xlsx")
check_and_add("penoxsulam_aquatic_toxicity.xlsx")
check_and_add("pirimicarb_aquatic_toxicity.xlsx")
check_and_add("pyrethrins_aquatic_toxicity.xlsx")
check_and_add("pyrimethanil_aquatic_toxicity.xlsx")
check_and_add("tebuconazole_aquatic_toxicity.xlsx")
check_and_add("triclopyr_aquatic_toxicity.xlsx")
check_and_add("triclopyr-butotyl_aquatic_toxicity.xlsx")
check_and_add("trifloxystrobin_aquatic_toxicity.xlsx")
check_and_add("tritosulfuron_aquatic_toxicity.xlsx")
check_and_add("spinosad_aquatic_toxicity.xlsx")



save(aquatic_toxicity,
  file = here('data_generation/cache/aquatic_toxicity.rda'))
save(aquatic_test_systems,
     file = here('data_generation/cache/aquatic_test_systems.rda'))

# Clean up
rm(
  derappp_input,
  directory,
  chents, substances, species, sources,
  effects, effect_levels,
  aquatic_test_systems, life_stages,
  check_and_add)
rm(aquatic_toxicity)

