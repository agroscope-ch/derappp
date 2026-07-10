# The script defines or amends the following objects in
# 'data_generation/cache' for further use in the other scripts in
# 'data_generation':
#
# 'substance_keys'  Table of keys to other databases
#
# It has to be run after running 01_sources.R_

# ------------------------------------------------------------------------------
# Append substance mappings to further data sources. Edit these scripts if
# you get warnings from running them

# ------------------------------------------------------------------------------
# Load data generated in previous runs
substance_keys <- readRDS(here('data_generation/cache/substance_keys.rds'))
substances <- readRDS(here('data_generation/cache/substances.rds'))
chents <- readRDS(here('data_generation/cache/chents.rds'))

source(here('data_generation/02_substance_maps/srppp.R'))
source(here('data_generation/02_substance_maps/NABO_SQ.R'))

# ------------------------------------------------------------------------------
# Save the table of keys to other data sources
saveRDS(substance_keys, compress = FALSE,
  file = here("data_generation/cache/",
    "substance_keys.rds"))

# Clean up
rm(chents, substances, substance_keys)
