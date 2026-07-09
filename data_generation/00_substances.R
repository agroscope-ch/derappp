# ------------------------------------------------------------------------------
# Intro

# This script reads in names of active ingredients and transformation products
# from the YAML file 'data_generation/substances/chents.yml', retrieves chemical
# information from the compendium of pesticide common names of the British Crop
# Protection Council (BCPC) and the PubChem project, and creates a list of
# chemical entities with chemical identity information.

# For active ingredients that are mixtures of several chemical entities,
# the compositional information is read from
# 'data_generation/substances/ingredients/defined_mixtures.yml'. Other, undefined ingredients
# are read in from 'data_generation/substances/ingredients/others.yml'.

# The script defines or amends the following objects in
# 'data_generation/cache' for further use in the other scripts in
# 'data_generation':
#
# 'chents'      Table of chemical entities to be in included in 'derappp'
# 'substances'  Table of substances to be in included in 'derappp'
# 'substance_compositions'  Table of substance compositions for 'derappp'

# In addition, the script amends to the following object stored in the package:
#
# 'data/derappp_chents.rda'   List of objects containing chemical information

# The 'chents.yml' file defines if the chent is regarded an active ingredient,
# (currently every chent that is not a transformation product). Only for active
# ingredients, the BCPC compendium is queried.

# The YAML also contains SMILES codes for the cases where the names are not
# sufficient to retrieve the correct chemical structure from PubChem.

# You should run this script if you added entries to one of the above YAML files.

# Then you need to run '01_sources.R' and '02_substance_maps.R'

# ------------------------------------------------------------------------------
# Load packages
library(here)
library(dplyr, warn.conflicts = FALSE)
library(dm)
library(tibble)
library(yaml)
library(purrr)
library(tidyr)
if (packageVersion("chents") < "0.4.0") {
    stop("Please install the current version of the 'chents' package")
}

# We need a dev version of webchem from later November 2025 or later in order
# to find derivatives like 2,4-D-dimethylammonium with bcpc_query
#install.packages("webchem", repos = c("https://ropensci.r-universe.dev", "https://cloud.r-project.org"))
library(chents)

# Load the YAML file
chents_to_include_list <- read_yaml(here("data_generation/00_substances/chents.yml"))

# Convert the list to a data frame
# Only designate substances as actives (active ingredients) that are not
# transformation products, stereoisomers contained in active ingredients
# or synergists.
# This will be used to decide if BCPC is queried for an iso common name,
# which does not exist for transformation products, stereoisomers or synergists.
chents_to_include <- map(chents_to_include_list,
  function(.x) {
    if (is.character(.x)) {
      ret <- tibble(Name = .x)
    } else {
      ret <- tibble(
        Name = names(.x),
        TP = pluck(.x, 1, "TP", .default = NA),
        stereoisomer = pluck(.x, 1, "stereoisomer", .default = NA),
        synergist = pluck(.x, 1, "synergist", .default = NA),
        smiles = pluck(.x, 1, "smiles", .default = NA),
        source = pluck(.x, 1, "source", .default = NA),
        comment = pluck(.x, 1, "comment", .default = NA)
      ) |>
        mutate(active = !TP & !stereoisomer & !synergist, .before = TP) |>
        select(-TP, -stereoisomer)
    }
    return(ret)
  }) |>
  list_rbind() |>
  mutate(active = if_else(is.na(active), TRUE, FALSE))

# ------------------------------------------------------------------------------
# Load the current list of chemical entities stored in the package
load(here("data/derappp_chents.rda"))
chent_names <- sort(names(derappp_chents))

# Path to the log file used later in this script
chents_log <- here("data_generation/log/01_chents.log")

# If you want to rebuild the complete list of chents, uncomment the next three
# lines and run the complete script. Then comment them again for incremental
# updates
#derappp_chents <- list()
#chent_names <- character()
#unlink(chents_log)

new_chent_names <- setdiff(chents_to_include[["Name"]], chent_names)
obsolete_chent_names <- setdiff(chent_names, chents_to_include[["Name"]])

# If we have changed an entry in chents.yml, we can manually define this
#new_chent_names <- "Piperonyl butoxide"

# We remove list entries with obsolete chent names (names that are not in the
# Excel file of chents to include)
derappp_chents[obsolete_chent_names] <- NULL

# For some active ingredients with an ISO common name (e.g. acetamiprid), the
# InChIKeys retrieved from BCPC and PubChem do not match.
# Studying the PubChem entries for these compounds, we find that the
# stereochemical information of these compounds (E/Z configuration)
# is not represented in their PubChem entries, while the BCPC
# IUPAC names and InChIKeys do specify these configurations.
#
# For buprofezin, the description of the PubChem entry correctly specifies
# the Z-configuration of the double bond, while the corresponding
# CAS number is marked as deprecated, and the unspecific CAS number
# is given.

# To address such issues, an optional SMILES code containing stereochemical
# information was added to the YAML file with the chemical entities to include.

# ------------------------------------------------------------------------------
# Loop over new chemical entity names and create chent objects

# This loop creates objects of R6 class chents::pai for active ingredients,
# fetching information from BCPC, if available, and from PubChem. For
# transformation products, objects of R6 class chents::chent are created, only
# fetching information from PubChem. If RDKit is installed and configured, a
# molecular weight and a 2D graph is created for each chemical entity.

capture.output(
  file = chents_log, append = TRUE, type = "message", {

    for (chent_name in new_chent_names) {

      cat("chent", chent_name, "\n") # for the Console
      message("\nchent ", chent_name)

      # Write a message containing the line in chents_to_include
      chent_to_include <- dplyr::filter(chents_to_include,
        Name == chent_name)
      message(paste(as.character(chent_to_include), collapse = " | "))

      active <- chent_to_include[["active"]]

      if (active) { # For actives we use R6 class `pai`
        # If no SMILES is specified, we trust the normal route of trying
        # BCPC, and then pubchem using the retrieved InChIKey if available
        if (is.na(chent_to_include[["smiles"]])) {
          derappp_chents[[chent_name]] <- pai$new(chent_name)
        } else {
          derappp_chents[[chent_name]] <- try(pai$new(chent_name,
            pubchem_from = "smiles",
            smiles = chent_to_include[["smiles"]]))
            if (inherits(derappp_chents[[chent_name]], "try-error")) {
              derappp_chents[[chent_name]] <- pai$new(chent_name,
                pubchem = FALSE,
                smiles = chent_to_include[["smiles"]])
            }
        }
      } else { # For transformation products, stereoisomers and synergists, we use  R6 class
        # `chent`. Again, if no SMILES is given, we trust the default retrieved
        # from pubchem
        if (is.na(chent_to_include[["smiles"]])) {
          derappp_chents[[chent_name]] <- chent$new(chent_name)
        } else {
          derappp_chents[[chent_name]] <- try(chent$new(chent_name,
            pubchem_from = "smiles",
            smiles = chent_to_include[["smiles"]]))
          if (inherits(derappp_chents[[chent_name]], "try-error")) {
            derappp_chents[[chent_name]] <- chent$new(chent_name,
              pubchem = FALSE,
              smiles = chent_to_include[["smiles"]])
          }
        }
      }
    }
  }
)
class(derappp_chents) <- c("derappp_chents", class(derappp_chents))

save(
  derappp_chents,
  file = here("data/derappp_chents.rda"),
  compress = "xz"
  )

# ------------------------------------------------------------------------------
# Tabulate the most important information for each chemical entity

# First create a list of tibbles, each containing one row. These tibbles
# are then combined to the desired table

# We prefer any user defined SMILES, then PubChem (including stereochemistry),
# then PubChem with connectivity only (no stereochemistry)
smiles_preference <- c("user", "PubChem", "PubChem_Connectivity")

# Regarding ISO common names, we reject ISO name entries at BCPC with the status
# "ISO common name not required" (e.g. copper oxychloride), and "Parent – ISO" (e.g.
# triclopyr-butotyl which is name derived from an ISO common name) as these are
# not really ISO common names.

# The chents table created below will be included in the derappp dm object
# created in 99_derappp.R
chents <- lapply(derappp_chents, function(x) {
    available_smiles <- names(x$smiles)
    smiles_preferred_i <- min(match(available_smiles, smiles_preference))
    smiles_preferred <- smiles_preference[smiles_preferred_i]
    inchikey <- if (!is.na(x$inchikey) && webchem::is.inchikey(x$inchikey)) {
      as.character(x$inchikey) }
    else {
      as.character(NA)
    }
    tibble(
      ai = inherits(x, "pai"),
      iso = if (is.null(x$iso) || attr(x$iso, "status") %in%
          c("ISO common name not required", "Parent – ISO")) as.character(NA) else as.character(x$iso),
      mw = as.numeric(x$mw),
      smiles = as.character(x$smiles[smiles_preferred]),
      pubchem = if (is.null(x$pubchem)) NA_integer_ else as.integer(x$pubchem$CID),
      inchikey = inchikey,
      bcpc_activity = if (is.null(x$bcpc$activity)) NA_character_ else paste(x$bcpc$activity, collapse = ", ")
    )
  }) |>
  purrr::list_rbind(names_to = "chent") |>
  arrange(chent)

# Check if we have any "chemical entities" without a defined SMILES
if (any(is.na(chents$smiles))) {
  filter(chents, is.na(smiles))
}

# ------------------------------------------------------------------------------
# Some substances are mixtures of several chemical entities
# Their composition is defined in the file read in below
ingredient_mixture_list <- read_yaml(here("data_generation/00_substances/ingredients/defined_mixtures.yml"))

ingredient_mixtures_to_include <- map(ingredient_mixture_list,
  function(mixture) {
    map(mixture$chents,
      function(chent) {
        tibble(
          min = chent$min,
          max = chent$max,
          doi = mixture$doi,
          page = mixture$page
        )
      }) |>
      list_rbind(names_to = "chent")
  }) |>
  list_rbind( names_to = "substance")


# ------------------------------------------------------------------------------
# Other ingredients without information on the composition
other_ingredients <- read_yaml(here("data_generation/00_substances/ingredients/others.yml"))

substance_compositions <- chents |>
  select(substance = chent, chent = chent) |>
  mutate(
    min = 1, max = 1,
    doi = NA, page = NA) |>
  rbind(ingredient_mixtures_to_include) |>
  rbind(tibble(substance = other_ingredients, chent = NA, min = NA, max = NA, doi = NA, page = NA)) |>
  arrange()

substance_compositions  |>
  filter(min == 1) # Chemical entities become ingredients with one component
substance_compositions  |>
  filter(min < 1) # Ingredients defined as mixtures have one line for each component
substance_compositions  |>
  filter(is.na(min)) # The remaining ingredients have no information

substances <- substance_compositions  |>
  group_by(substance) |>
  summarize(n_chents = sum(!is.na(chent))) |>
  mutate(type = as.factor(case_when(
      n_chents == 1 ~ "chent",
      n_chents > 1  ~ "mixture",
      n_chents == 0 ~ "undefined")))

# ------------------------------------------------------------------------------
# Save results for use in other scripts in 'data_generation'
chents$mw <- round(chents$mw, 3)
saveRDS(chents, compress = FALSE,
  file = here("data_generation/cache/",
    "chents.rds"))
saveRDS(substance_compositions, compress = FALSE,
  file = here("data_generation/cache/",
    "substance_compositions.rds"))
saveRDS(substances, compress = FALSE,
  file = here("data_generation/cache/",
    "substances.rds"))

# ------------------------------------------------------------------------------
# Clean up
if (length(new_chent_names) > 0) {
  rm(chent_to_include, active)
}
rm(
  chents_to_include,
  chent_name,
  chents_to_include_list,
  chent_names, new_chent_names, obsolete_chent_names,
  smiles_preference,
  chents_log,
  ingredient_mixture_list,
  ingredient_mixtures_to_include,
  other_ingredients,
  substance_compositions,
  substances,
  chents,
  derappp_chents
  )

