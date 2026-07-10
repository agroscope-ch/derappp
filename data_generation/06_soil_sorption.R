# Script to load soil adsorption data from Excel input sheets

library(here)
library(readxl)
library(units)

# Load substances and already integrated data for checking
substances <- readRDS(here('data_generation/cache/substances.rds'))
sources <- readRDS(here('data_generation/cache/sources.rds'))

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

directory <- "06_soil_sorption"

check_and_add <- function(filename) {

  input_file <- file.path(derappp_input, directory, filename)
  git_file <- here("data_generation", directory, filename)

  copy_to_git <- derappp:::compare_with_git(input_file, git_file)

  new <- read_xlsx(input_file) |>
    mutate(across(c(page), as.character)) |>
    mutate(across(c(selected), as.logical)) |>
    mutate(across(c(soil_pH, f_clay, f_sand, f_silt, f_om, f_oc, Kd, Koc, Kf, Kfoc, n), as.numeric)) |>
    filter(selected) |> # keep only relevant entries because others were not fully sanitized
    rowwise() |>  # set_units is not vectorised
    mutate(across(f_clay:f_oc, ~ set_units(.x))) |>
    mutate(across(Kd:Kfoc, ~ set_units(.x, "L/kg", mode = "standard"))) |>
    mutate(file = filename) |>
    select(substance,
      soil_type, soil_name, soil_pH, pH_medium,
      f_clay, f_sand, f_silt, f_om, f_oc,
      Kd, Koc, Kf, Kfoc, n,
      sk, page, reason, note, recorded, checked, file) |>
    ungroup()

  # Check if substance names are registered
  unknown_substances <- setdiff(new$substance, substances$substance)
  if (length(unknown_substances > 0)) {
    stop("Please add the following unknown substances using '00_substances.R':\n",
      unknown_substances)
  }

  # Check if sources are registered
  unknown_source_keys <- setdiff(new$sk, sources$sk)
  if (length(unknown_source_keys > 0)) {
    stop("Please define the following unknown source keys using '01_sources.R':\n",
      unknown_source_keys)
  }

  soil_sorption <- bind_rows(soil_sorption, new)

  # Check for duplicates
  dup_columns <- c("substance", "soil_name", "Kd", "Koc", "Kf", "Kfoc", "n", "value")
  dup_index <- soil_sorption |>
    select(any_of(dup_columns)) |>
    duplicated()

  if (any(dup_index)) {
    soil_sorption[dup_index, dup_columns] |>
      left_join(soil_sorption, by = dup_columns,
        relationship = "many-to-many") |>
      print()
    stop("Please remove duplications in the above entries")
  }

  # If the above checks are all ok, copy the input file to version control
  if (copy_to_git) {
    message("Copying to ", git_file)
    file.copy(input_file, git_file, overwrite = TRUE)
  }

  soil_sorption <<- soil_sorption
}

# Set up the table
soil_sorption <- tibble(
  substance = character(0),
  soil_type = character(0),
  soil_name = character(0),
  soil_pH = numeric(0),
  f_clay = set_units(numeric(0)),
  f_sand = set_units(numeric(0)),
  f_silt = set_units(numeric(0)),
  f_om = set_units(numeric(0)),
  f_oc = set_units(numeric(0)),
  Kd = set_units(numeric(0), "L/kg", mode = "standard"),
  Koc = set_units(numeric(0), "L/kg", mode = "standard"),
  Kf = set_units(numeric(0), "L/kg", mode = "standard"),
  Kfoc = set_units(numeric(0), "L/kg", mode = "standard"),
  n = numeric(0),
  sk = character(0),
  page = character(0),
  selected = logical(0),
  reason = character(0),
  note = character(0),
  recorded = character(0),
  checked = character(0),
  file = character(0)
)

#debug(check_and_add)
check_and_add("acetamiprid_soil_sorption.xlsx")
check_and_add("captan_soil_sorption.xlsx")
check_and_add("copper_oxychloride_soil_sorption.xlsx")
check_and_add("cyprodinil_soil_sorption.xlsx")

saveRDS(soil_sorption, compress = FALSE,
  file = here("data_generation/cache/",
    "soil_sorption.rds"))

# Clean up
rm(
  derappp_input,
  directory,
  check_and_add,
  soil_sorption, substances, sources
)

