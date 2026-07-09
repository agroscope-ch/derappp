# This script generates the species table

# The process is not fully automated. If a new species is added and produces multiple
# matches with tnrs_match_names(), manual inspection and correction is needed.
# Currently, this is not checked after adding new species.

library(here)
library(rotl) # To access the Open Tree of Life taxonomic name resolution service (TNRS)

# We can load the result of this script from the last run if desired
#species <- readRDS(here('data_generation/cache/species.rds'))

# The following lines can be used for adding entries based on aquatic tox data
#aquatic_toxicity <- readRDS(here('data_generation/cache/aquatic_toxicity.rds'))
#aquatic_species <- unique(aquatic_toxicity$derappp_species)
#new_species <- setdiff(aquatic_species, species$species)

# The next command facilitates adding new lines to species_in
#cat(sprintf('  "%s", "", "",\n', new_species), sep = "")

# 'species_in' is intended for correctly spelled latin names and the
# corresponding organism groups. These names will then end up in the
# toxicity tables as 'derappp_species'.
# Species resolved only at the genus level are listed as " sp.".
# If only a higher level taxonomic group is available (family, order, class etc.),
# there is only a single word in the species column, e.g. "Cyclopoida".
source(here("data_generation/03_species/species_in.R"))

# Check for duplicates in species_in
if (any(duplicated(species_in$species))) {
  stop("Duplicate species found in species_in table.") }

# 'species_synonyms' contains misspelled or non-latin species names, synonyms or subspecies names
# e.g. "Anabaena flosaquae" is a synonym for "Dolichospermum flos-aquae",
# Most entries in species_synonyms$synonym are not found with tnrs_match_names() or are
# approximate_matches
# The synonyms will end up in the toxicity tables as 'reported_species'.
source(here("data_generation/03_species/synonyms.R"))

# Check for duplicates in syn
if (any(duplicated(species_synonyms$synonym))) {
  stop("Duplicate species found in synonym table.") }

# Check if synonyms are matched to species names in species_in
unmatched_synonyms <- setdiff(species_synonyms$species, species_in$species)
if (length(unmatched_synonyms) > 0) {
  stop(paste0("The following species in the 'syn' table are not found in the 'species_in' table:\n",
             paste("- ", unmatched_synonyms, collapse = "\n"))) }

# We also stop if we have correct species names that coincide with synonyms
overlapping_names <- intersect(species_synonyms$synonym, species_in$species)
if (length(overlapping_names) > 0) {
  stop(paste0("The following species are found in both 'syn' and 'species_in' tables. Please keep them only in one of them:\n",
              paste("- ", overlapping_names, collapse = "\n"))) }

# Check names using rotl's tnrs_match_names() function
species_in_to_check <- species_in |>
  mutate(species_to_check = sub(" sp.$", "", species))

species_resolved <- tnrs_match_names(species_in_to_check$species_to_check)

# Check for no match
no_matches <- species_resolved[species_resolved$number_matches == 0, ]
if (length(no_matches$search_string) > 0) {
  stop(paste("The following species could not be matched. Please correct their spelling in the 'species_in' table:\n",
             paste("- ", no_matches$search_string, collapse = "\n"))) }

# Check for remaining misspelled species
approximate_matches <- species_resolved[species_resolved$approximate_match, ]
if (length(approximate_matches$search_string) > 0) {
  stop(paste("Please add the following species to the 'syn' table and correct their spelling in the 'species_in' table:\n",
             paste("- ", approximate_matches$search_string, collapse = "\n"))) }
      # e.g. "ide" gives approximate_match - Error message above appears
      # -> in syn table add row: "Ide", "Leuciscus idus",
      # -> in species_in table: replace "Ide" with "Leuciscus idus"

# Define ambiguous matches for manual inspection
multiple_matches <- species_resolved[species_resolved$number_matches > 1, ]
multiple_match_strings <- multiple_matches$search_string

# Salmo guairdneri has two matches, one is a subspecies, the other is OK but includes domain information
inspect(species_resolved, taxon_name = multiple_match_strings[1])
species_resolved <- update(species_resolved, taxon_name = multiple_match_strings[1], new_row_number = 2)

# Gammarus species we are interested in e.g. G. pulex are Peracarida according to Wikipedia
inspect(species_resolved, taxon_name = multiple_match_strings[2])
species_resolved <- update(species_resolved, taxon_name = multiple_match_strings[2], new_row_number = 2)

# Cyclops is ok as it is, Tritia (row 2) is a snail genus
inspect(species_resolved, taxon_name = multiple_match_strings[3])

# Scenedesmus quadricauda is OK, S. quadricauda (row 2) is a synonym
inspect(species_resolved, taxon_name = multiple_match_strings[4])

# Selenastrum capricornutum and Raphidocelis subcapitata are both synonyms, so
# we keep the first entry
inspect(species_resolved, taxon_name = multiple_match_strings[5])

# In this entry, Selenastrum capricornutum is not termed a synonym, so we keep it
inspect(species_resolved, taxon_name = multiple_match_strings[6])

# Myriophyllum spicatum is OK, the alternative is a synonym
inspect(species_resolved, taxon_name = multiple_match_strings[7])

# Dito for E. canadensis
inspect(species_resolved, taxon_name = multiple_match_strings[8])

# Ceratophyllum demersum is OK, the alternative belongs to Opisthokonta (no plants)
inspect(species_resolved, taxon_name = multiple_match_strings[9])

# Dito for the genus Myriophyllum
inspect(species_resolved, taxon_name = multiple_match_strings[10])

# # Check a specific row to see if it has been correctly matched
#check_ott <- function(ott) {
#  tax_lineage(taxonomy_taxon_info(ott, include_lineage = TRUE))
#}

#check_ott(multiple_matches[1, "ott_id"])
#check_ott(165368)


# # Check the updated entries
# check_ott(species_resolved[1, "ott_id"])
# check_ott(species_resolved[7, "ott_id"])
# check_ott(species_resolved[13, "ott_id"])
#
#
# species_resolved[c("search_string", "ott_id")]

# For correctly spelled species in latin, join unique names and ott_ids
species_correct <- species_in_to_check |>
  mutate(species_checked_lower = tolower(species_to_check)) |>
  left_join(species_resolved, by = c(species_checked_lower = "search_string")) |>
  select(species, group, derappp_species = unique_name, ott_id, is_synonym, flags)

# For non-latin or misspelled species, first resolve synonyms, then join unique names and ott_ids
species_corrected <- species_synonyms |>
  left_join(species_in_to_check, by = join_by(species)) |>
  mutate(species_to_check_lower = tolower(species_to_check)) |>
  left_join(species_resolved, by = c(species_to_check_lower = "search_string")) |>
  select(species = synonym, group, derappp_species = unique_name, ott_id, is_synonym, flags)

species <- rbind(species_correct, species_corrected) |>
  arrange(species)


#------------------------------------------------------------------------------#
# Define salt water species
#------------------------------------------------------------------------------#
# List of species where we know from Wikipedia entries that they do not live in
# freshwater

salt_water_species <- c(

  # Algae
  "Skeletonema costatum",  # Diatom also living in brackish water (Wikipedia)

  # Aquatic invertebrates
  "Americamysis bahia", # synonym "Mysidopsis bahia"
  "Crassostrea virginica",
  "Crassostrea gigas",
  "Leptocheirus plumulosus",
  #"Neohelice granulate", # Not yet in derappp
  "Palaemon pugio", # synonym "Palaemonetes pugio"

  # Fish
  #"Menidia beryllina", # Estuaries and freshwater acc. Wikipedia
  "Cyprinodon variegatus"
  #"Gasterosteus aculeatus" # Often breeds in freshwater acc. Wikipedia
)


# add the information about salt water species to the species table
species <- species |>
  mutate(
    salt_water_species = if_else(
      derappp_species %in% salt_water_species, # Use derappp_species to catch synonyms
      TRUE,
      FALSE
    )
  )


# ---------------------------------------------------------------------------- #
# Save species table to cache ####
# ---------------------------------------------------------------------------- #
saveRDS(species, compress = FALSE,
  file = here("data_generation/cache",
    "species.rds"))

rm(
  species_in,
  species_synonyms,
  unmatched_synonyms,
  species_in_to_check,
  overlapping_names,
  species_resolved,
  approximate_matches,
  multiple_matches,
  multiple_match_strings,
  no_matches,
  species_correct,
  species_corrected,
  salt_water_species
)
rm(species)
