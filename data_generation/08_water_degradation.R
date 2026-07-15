# Script to load water degradation data from Excel input sheets

library(here)
library(readxl)
library(units)

# Load substances and already integrated data for checking
load(here('data_generation/cache/substances.rda'))
load(here('data_generation/cache/sources.rda'))

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

check_and_add <- function(filename) {

  input_file <- file.path(derappp_input, "08_water_degradation", filename)

  if (!file.exists(input_file)) stop(input_file, " does not exist")

  git_file <- file.path(here("data_generation/08_water_degradation", filename))
  file_is_in_git <- FALSE

  if (file.exists(git_file)) {
    message(filename, " is already under version control")
    if (tools::md5sum(input_file) != tools::md5sum(git_file)) {
      stop(
        "The file is under version control but has been changed in the input directory\n",
        "Please check if the change should be kept. If yes, remove the old version in the git repository, e.g. using\n",
        "git rm data_generation/xls/", filename, "\n",
        "and check the diff in the JSON representation after running 99_derappp.R")
    } else {
      file_is_in_git <- TRUE
    }
  }

new <- read_xlsx(input_file) |>
  mutate(across(c(everything()), as.character)) |>
  mutate(across(c(selected), as.logical)) |>
  mutate(across(c(DT50, alpha, beta, k1, k2, g, tb, page),~na_if(.x, "NA"))) |>
  mutate(across(c(DT50, alpha, beta, k1, k2, g, tb), as.numeric)) |>
  filter(selected) |> # keep only relevant entries because others were not fully sanitized
  rowwise() |>  # set_units is not vectorised
  mutate(across(beta:k2, ~ set_units(.x, "1/d", mode = "standard"))) |>
  mutate(across(c(DT50, tb), ~ set_units(.x, "d", mode = "standard"))) |>
  mutate(across(c(alpha, g), ~ set_units(.x, "", mode = "standard"))) |>
  mutate(file = filename) |>
  select(substance, DT50, kinetics, alpha, beta, k1, k2, g, tb, sk,
         page, reason, note, recorded, checked, file) |>
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

  soil_degradation <- bind_rows(soil_degradation, new)

  # Check for duplicates
  dup_columns <- c("substance", "DT50", "sk")
  dup_index <- soil_degradation |>
    select(any_of(dup_columns)) |>
    duplicated()

  if (any(dup_index)) {
    soil_degradation[dup_index, dup_columns] |>
      left_join(soil_degradation, by = dup_columns,
                relationship = "many-to-many") |>
      print()
    stop("Please remove duplications in the above entries")
  }

  # If the above checks are all ok, copy the input file to version control
  if (!file_is_in_git) {
    message("Copying to ", git_file)
    file.copy(input_file, git_file)
  }

  soil_degradation <<- soil_degradation
}

# Set up the table
soil_degradation <- tibble(
  substance = character(0),
  DT50      = set_units(numeric(0), "d", mode = "standard"),
  kinetics  = character(0),
  alpha     = set_units(numeric(0), "", mode = "standard"),# dimensionless
  beta      = set_units(numeric(0), "1/d", mode = "standard"),
  k1        = set_units(numeric(0), "1/d", mode = "standard"),
  k2        = set_units(numeric(0), "1/d", mode = "standard"),
  g         = set_units(numeric(0), "", mode = "standard"),# dimensionless
  tb        = set_units(numeric(0), "d", mode = "standard"),
  sk        = character(0),
  page      = character(0),
  reason    = character(0),
  note      = character(0),
  recorded  = character(0),
  checked   = character(0),
  file      = character(0)
)


#debug(check_and_add)
check_and_add("soil_degradation_EFSA_PEC_soil_roan_luel_first_ai.xlsx")
check_and_add("soil_degradation_EFSA_PEC_soil_luel_additional_ai.xlsx")

save("soil_degradation", file = here("data_generation/cache/",
                                  "soil_degradation.rda"))

# Clean up
rm(
  derappp_input, check_and_add,
  soil_degradation, substances, sources
)

