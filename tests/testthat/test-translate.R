test_that("We can translate substance identifiers", {
  # Translate substance primary keys from the Swiss Register
  # First get some primary keys (there is no function for this at the moment)
  # There is a mix of German an English in the "German" srppp substance names
  srppp_names <- c("1-Naphthylacetic acid", "Terbuthylazine", "Pyrethrine")
  srppp_pk <- c("3", "1245", "323")

  # This is unified in derappp, so we only have English names
  derappp_names = c("1-Naphthylacetic acid", "Terbuthylazine", "Pyrethrins")

  # Then do the actual translation with derappp::translate_substances()
  translation <- translate_substances(srppp_pk, from = "srppp")

  expect_equal(
    translation,
    tibble(
      srppp = srppp_pk,
      derappp = derappp_names))

  # We can also translate back from the derappp names, but we can get more than
  # one identifier per name, i.e. the old integer id, and, in many cases, an
  # UUID, so for getting only version 1 identifiers, we filter by number of characters
  back_translation <- translate_substances(translation$derappp, to = "srppp") |>
    filter(nchar(srppp) != 36L)
  expect_equal(
    back_translation,
    tibble(
      derappp = derappp_names,
      srppp = srppp_pk))

  # An example with NABO Status Quo substances
  nabo_translation <- translate_substances(c("Chlorothalonil R417888", "S-Metolachlor"),
    from = "NABO_SQ")
  expect_equal(
    nabo_translation$derappp,
    c("R417888", "S-Metolachlor"))

  # If we translate from or to a namespace that does not have the substance, we get NA
  expect_warning({
    na_translation <- translate_substances(
      c("Chlorothalonil R417888", "S-Metolachlor", "Diazinone"),
      from = "NABO_SQ", to = "srppp")},
    "Translation was incomplete")

  expect_equal(
    na_translation$srppp,
    c(NA, "1349", NA),
    ignore_attr = TRUE)

  # We only find exact matches
  expect_warning({
    na_translation_even_if_exists <- translate_substances(
      c("R417888", "S-Metolachlor", "Glyphosat", "Glyphosate"),
      from = "derappp", to = "srppp")},
    "Translation was incomplete")

  expect_equal(
    na_translation_even_if_exists$srppp,
    c(NA, "1349", NA, 199, "7B9F385E-0CFF-48B1-B32A-F7618D2A25D0"),
    ignore_attr = TRUE)

  # Check the dataframe method
  input <- data.frame(x = 1:3, srppp = srppp_pk)
  expect_snapshot(translate_substances(input, from = "srppp"))

  input_de <- data.frame(x = 1:3, substance_de = srppp_names)
  expect_snapshot(translate_substances(input_de, from = "substance_de"))

  # We get two warnings - one for unmapped substance_de entries, one for incomplete translations
  expect_warning(
    expect_warning(
      translate_substances(c(srppp_names, "Glyphosate", "Kupfer"), from = "substance_de"),
      "not mapped to srppp keys"),
    "incomplete")

})
