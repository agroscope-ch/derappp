# The script defines or amends the following objects in
# 'data_generation/cache' for further use in the other scripts in
# 'data_generation':
#
# 'substance_keys'  Table of keys to other databases

# ------------------------------------------------------------------------------
# Append substance mappings to further data sources. Edit these scripts if
# you get warnings from running them

# ------------------------------------------------------------------------------
# Load data generated in previous runs
load(here('data_generation/cache/substance_keys.rda'))
load(here('data_generation/cache/substances.rda'))
load(here('data_generation/cache/chents.rda'))

source(here('data_generation/02_substance_maps/srppp.R'))
source(here('data_generation/02_substance_maps/NABO_SQ.R'))

# ------------------------------------------------------------------------------
# Save the table of keys to other data sources
save("substance_keys", file = here("data_generation/cache/",
  "substance_keys.rda"))

# Clean up
rm(chents, substances, substance_keys)

