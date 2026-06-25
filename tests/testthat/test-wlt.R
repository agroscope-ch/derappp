test_that("We can generate WLT values from aquatic endpoints from derappp", {
  suppressMessages({
    library(units)
    library(dplyr)
  })

  f_aq_all <- wlt("Flutolanil", salt_water = "include")
  expect_equal(f_aq_all$wlt,
    set_units(set_units(0.397, "µg/L"), "mg/L"))

  f_aq_all_form_unique <- wlt("Flutolanil", salt_water = "include",
    formulations = "include-unique")
  expect_equal(f_aq_all_form_unique$wlt,
    set_units(set_units(0.397, "µg/L"), "mg/L"))

  f_aq_all_noform <- wlt("Flutolanil", salt_water = "include",
    formulations = "exclude")
  expect_equal(f_aq_all_noform$wlt,
    set_units(set_units(0.397, "µg/L"), "mg/L"))
  expect_equal(f_aq_all_noform$data |>
      filter(critical) |>
      pull(wlt_candidate),
    set_units(set_units(0.397, "µg/L"), "mg/L"))

  f_aq_nosalt <- wlt("Flutolanil", salt_water = "exclude")
  expect_equal(f_aq_nosalt$wlt,
    set_units(0.027, "mg/L"))
  expect_equal(f_aq_nosalt$data |>
      filter(critical) |>
      pull(wlt_candidate),
    set_units(0.027, "mg/L"))

  f_aq_special <- wlt("Flutolanil", salt_water = "special")
  expect_equal(f_aq_special$wlt,
    set_units(set_units(3.97, "µg/L"), "mg/L"))
  expect_equal(f_aq_special$data |>
      filter(critical) |>
      pull(wlt_candidate),
    set_units(set_units(3.97, "µg/L"), "mg/L"))

  expect_equal(
    f_aq_special$ratios_salt_nosalt[c("group", "AF_salt")],
    tibble(group = c("Aquatic algae", "Aquatic invertebrates", "Aquatic invertebrates",
      "Fish", "Fish"),
      AF_salt = c(NA, 25.188917, 5.23076923, NA, NA)))

  # Example including a "smaller than" value, but for the same test
  # a "greater than" value is also given, which is in fact smaller than
  # the "smaller than" value (x < endpoint < y), so the smaller value is
  # automatically preferred
  m_aq_all <- wlt("Metiram", salt_water = "include")
  expect_equal(m_aq_all$wlt,
    set_units(set_units(0.157, "µg/L"), "mg/L"))

  m_aq_special <- wlt("Metiram", salt_water = "special", formulations = "include")

  m_aq_nosalt <- wlt("Metiram", salt_water = "exclude")

  expect_equal(round(m_aq_special$ratios_salt_nosalt$ratio, 2),
    c(1.57, NA, 4.08, 8.64, NA, NA, 0.50))
  # As the wlt with salt water species is lower than the wlt without salt water
  # species by less than a factor of 10, the following wlt values are equal
  expect_equal(m_aq_nosalt$wlt, m_aq_special$wlt)

  # Example of a substance where we have a "smaller than" value and no salt
  # water species endpoints are available
  p_aq_special <- wlt("Pirimicarb", salt_water = "special", formulations = "include")

  expect_equal(p_aq_special$ratios_salt_nosalt, NA)

})

