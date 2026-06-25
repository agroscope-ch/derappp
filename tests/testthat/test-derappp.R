library(tibble)

test_that("the derappp data object is internally consistent",{
  failed_constraints <- dm::dm_examine_constraints(derappp::derappp) |>
    as_tibble() |>
    filter(!is_key)

  # We do not have pubchem IDs and InChIKey values for 8 pyrethroid stereoisomers
  known_failed_constraints <- tribble(
      ~table, ~kind, ~columns, ~ref_table, ~is_key, ~problem,
     "chents", "UK", "pubchem", NA_character_, FALSE, "has 8 missing values",
     "chents", "UK", "inchikey", NA_character_, FALSE, "has 8 missing values") |>
     mutate(columns = dm:::new_keys(columns))

  expect_equal(failed_constraints, known_failed_constraints)

  # Check if groups are the same in aquatic_toxicity and species table
  # For current data from derappp, they are, but this makes sure it stays like this
  # in case derappp changes
  inconsistent_groups <- derappp$aquatic_toxicity |>
    left_join(derappp$species, by = c("derappp_species" = "species")) |>
    filter(group.x != group.y) |>
    select(derappp_species, group.x, group.y)
  expect_equal(nrow(inconsistent_groups), 0L)

})
