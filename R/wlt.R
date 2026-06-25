utils::globalVariables(c(
  "AF",
  "AF_available",
  "AF_salt",
  "category",
  "critical",
  "derappp_species",
  "duration",
  "effect",
  "effect_details",
  "formulation",
  "group",
  "level",
  "life_stage",
  "preference",
  "measured",
  "page",
  "ratio",
  "reason",
  "salt",
  "salt_FALSE",
  "salt_TRUE",
  "selected",
  "sk",
  "species",
  "test_nr",
  "test_system",
  "value",
  "wlt_candidate",
  "wlt_candidate_other"
))
#' Calculate a weighted laboratory toxicity (WLT)
#'
#' This is an implementation of the method used for deriving WLT values
#' in the Swiss National
#' Pesticide Risk Indicator project (Korkaric et al. 2020, 2022 and 2023).
#' In the original project, the method was applied manually. This
#' method facilitates the derivation of updated WLT values for substances for which
#' the relevant data has been integrated into the `derappp` package.
#'
#' Currently, only surface water WLT values can be derived, and only
#' the aquatic toxicity table in this package is supported as data source.
#'
#' Default assessment factors (AF) are as in the EU regulation describing
#' the Uniform Principles of Risk Assessment (EC 2011), and as detailed in the
#' EFSA aquatic risk assessment guidance (EFSA 2013).
#'
#' The special treatment of salt water species is based on the ratio between
#' salt water and freshwater organisms of the lowest endpoints within each
#' taxonomic group and separately for short-term and long-term data.
#'
#' If this ratio is greater than 10, the AF of the freshwater
#' species in the group is increased by one tenth of this ratio, up to
#' an optional maximum factor.
#'
#' WLT candidates are determined by dividing the preferred endpoint for each
#' test by the appropriate (AF) which is equal to the
#' TER trigger value defined in the Uniform Principles (EC 2011), also taking
#' into account the details and additions (e.g. for macrophytes) as defined in
#' the EFSA guidance (EFSA 2013).
#'
#' @references
#' EC (2011) COMMISSION REGULATION (EU) No 546/2011 Annex Part A 2.5.2.2.
#'
#' EFSA (2013) Guidance on tiered risk assessment for plant protection products
#' for aquatic organisms in edge-of-field surface waters, \doi{10.2903/j.efsa.2013.3290}
#'
#' Korkaric M, Hanke I, Grossar D, Neuweiler R, Christ B, Wirth J, Hochstrasser M, Dubuis PH, Kuster T, Breitenmoser S, Egger B, Perren S, Schürch S, Aldrich A, Jeker L, Poiger T, Daniel O (2020)
#' Datengrundlage und Kriterien für eine Einschränkung der PSM-Auswahl im ÖLN: Schutz der Oberflächengewässer, der Bienen und des Grundwassers (Metaboliten), sowie agronomische Folgen der Einschränkungen.
#' Agroscope Science, 106, 2020, 1-31.
#' \doi{10.34776/as106g}
#'
#' Korkaric M, Ammann L, Hanke I, Schneuwly J, Lehto M, Poiger T, de Baan L, Daniel O, Blom JF (2022)
#' Neue Pflanzenschutzmittel-Risikoindikatoren für die Schweiz.
#' Agrarforschung Schweiz 13, 1-10,
#' \doi{10.34776/afs13-1}
#'
#' Korkaric M, Lehto M, Poiger T, de Baan L, Mathis M, Ammann L, Hanke I, Balmer M, Blom JF (2023)
#' Risikoindikatoren für Pflanzenschutzmittel: weiterführende Analysen zur Berechnung.
#' Agroscope Science, 154, 1-48, \doi{10.34776/as154g}
#'
#' @param substance A substance name
#' @param medium The medium for which the assessment is made
#' @param smaller_than How to handle "smaller than" values (e.g. an endpoint
#' specified as < 2 mg/L). Default is to warn if such an endpoint is in the
#' endpoints specified as 'selected' in the input data, and belonging to the
#' 'preferred' endpoints as determined based on endpoint level and exposure
#' duration by this function.
#' @param salt_water Per default, salt water species are included in the assessment
#' for surface water. If this argument is set to "special", endpoints from
#' salt water species receive a special treatment (see details). If set to
#' "exclude", data from an internal list with species not living in freshwater
#' are ignored.
#' @param max_AF_salt Maximum factor to increase the assessment factor based
#' on the comparison of salt water to freshwater species
#' @param formulations Per default, all formulation data are included. When
#' this argument is set to "include-unique", only data on formulations for which
#' no comparable (based on species, duration and effect level), but ultimately
#' based on expert judgement) endpoint is available are included. If set to
#' "exclude", data from formulations are ignored. If set to "manual", formulation
#' data to include can be specified using the argument "include".
#' @importFrom units set_units
#' @importFrom dplyr recode_values case_when filter if_else mutate n select slice_min pull
#' @importFrom tidyr pivot_wider
#' @export
#' @examples
#' f_wlt <- wlt("Flutolanil")
#' f_wlt$wlt
#' f_wlt$ratios_salt_nosalt
#' f_wlt$data
#'
#' # Repeat the analysis without the special treatment for salt water organisms
#' f_wlt_special <- wlt("Flutolanil", salt_water = "special")
#' f_wlt_special$wlt
wlt <- function(
  substance,
  medium = c("surface water"),
  smaller_than = c("warn", "keep", "ignore"),
  formulations = c("include", "include-unique", "exclude"),
  salt_water = c("include", "special", "exclude"),
  max_AF_salt = Inf
) {
  derappp <- derappp::derappp

  medium <- match.arg(medium)
  smaller_than <- match.arg(smaller_than)
  salt_water <- match.arg(salt_water)
  formulations <- match.arg(formulations)

  # List of species where we know from Wikipedia entries that they do not
  # live in freshwater. Load "salt_water_species"
  salt_water_species <- derappp::derappp$species |>
    filter(salt_water_species == TRUE) |>
    pull(derappp_species)

  if (medium == "surface water") {
    # Threshold for long-term exposure of fish and invertebrates
    threshold_lt_fi <- set_units(10, "d")

    # Get substance data, order groups and and categorize
    # Category explanations:
    # - st_fi: short-term exposure of fish or invertebrates
    # - lt_fi: long-term exposure of fish or invertebrates
    # - pp: primary producers
    # Endpoints without a category will not get an assessment factor
    tox_with_cat <- derappp$aquatic_toxicity |>
      filter(substance == !!substance) |>
      mutate(
        test_nr = factor(test_nr, ordered = TRUE, levels = unique(test_nr))
      ) |>
      mutate(
        category = case_when(
          # Acute (short-term) endpoints of fish and invertebrates
          group %in%
            c("Fish", "Aquatic invertebrates") &
            (duration < threshold_lt_fi) &
            level %in% c("LC50", "EC50") ~ "st_fi",

          # Long-term exposure of fish and invertebrates
          group %in%
            c("Fish", "Aquatic invertebrates") &
            (duration > threshold_lt_fi |
              grepl("chronic", note) |
              life_stage %in%
                c(
                  "early life stage",
                  "larval",
                  "juvenile",
                  "full life cycle"
                )) &
            level %in% c("EC10", "NOEC") ~ "lt_fi",

          # Aquatic algae
          group %in%
            c("Aquatic algae", "Aquatic cyanobacteria") &
            duration < set_units(5, "d") &
            level == "EC50" ~ "pp",

          # Aquatic macrophytes (EFSA guidance p. 17 says 7-14 days)
          group %in%
            c("Aquatic algae", "Aquatic macrophytes") &
            duration > set_units(6, "d") &
            duration < set_units(15, "d") &
            level == "EC50" ~ "pp",
          .default = NA
        )
      )

    # Add default assessment factors
    # COMMISSION REGULATION (EU) No 546/2011 Annex Part A 2.5.2.2.
    # EFSA aquatic RA guidance j.efsa.2013.3290 p. 17 for details
    tox_AF <- tox_with_cat |>

      mutate(
        AF = recode_values(
          category,
          "st_fi" ~ 100,
          "lt_fi" ~ 10,
          "pp" ~ 10, # for macrophytes, the AF is given in the EFSA guidance
          default = NA
        ),
        AF_available = !is.na(AF), # for sorting of endpoints in the final table
        salt = if_else(
          derappp_species %in% salt_water_species,
          TRUE,
          FALSE
        )
      )

    tox_AF_with_pref <- tox_AF |>
      mutate(
        preference = case_when(
          # Prefer EC10 over NOEC for long-term exposure of fish and invertebrates
          category == "lt_fi" & level == "EC10" ~ 1L,
          category == "lt_fi" & level == "NOEC" ~ 2L,

          # Prefer EC50 and LC50 values for acute exposure of fish and invertebrates
          category == "st_fi" & level %in% c("EC50", "LC50") ~ 1L,

          # Prefer growth rate EC50 for algae over yield and biomass EC50
          category == "pp" & level == "EC50" & effect == "growth rate" ~ 1L,
          category == "pp" & level == "EC50" & effect == "yield" ~ 2L,
          category == "pp" & level == "EC50" & effect == "biomass" ~ 3L,

          .default = Inf # Always prefer endpoints with a defined preference
        )
      )

    min_nowarn <- function(x) suppressWarnings(min(x, na.rm = TRUE))

    # For each test, select the preferred endpoint type
    # This will often reduce the number of rows
    # In a first step, the critical wlt candidate is selected
    # based on all data with 'selected' set to TRUE and an AF available
    # The tibble 'tox_preferred' can later be modified, but should always
    # have a column 'critical' pointing to the critical endpoint for the wlt
    # Columns 'selected' and 'reason' should be updated to keep track of the
    # selection process
    tox_preferred <- tox_AF_with_pref |>
      mutate(
        selected = selected & AF_available,
        reason = if_else(
          AF_available,
          reason,
          paste(reason, ", no assessment factor available")
        )
      ) |>
      group_by(test_nr) |>
      slice_min(preference) |> # Can be more than one per test_nr
      slice_min(value) |> # Use the lowest endpoint in case of ambiguity (e.g. EC10 for two different response types)
      mutate(wlt_candidate = value / AF) |>
      group_by(selected) |>
      mutate(critical = selected & wlt_candidate == min_nowarn(wlt_candidate))

    # Check for remaining ambiguity (same preference and same endpoint value)
    # Should generally not occur, because EC10 values for different response types
    # would be different, and NOECs for more than one response should be on the
    # same line in the derappp data.
    tox_preferred_ambiguous <- tox_preferred |>
      group_by(test_nr) |>
      summarise(n = n()) |>
      filter(n > 1)
    if (nrow(tox_preferred_ambiguous) > 1) {
      stop(
        "More than one endpoint with the highest preference and the same value for test(s) ",
        paste(tox_preferred_ambiguous$test_nr, collapse = ", ")
      )
    }

    if (smaller_than == "warn") {
      # Warn if we have "smaller than" values in the selected and preferred endpoints
      tox_smaller_than <- filter(tox_preferred, sign == "<" & selected)
      if (nrow(tox_smaller_than) > 0) {
        warning(
          "There are 'smaller than' values in the data for ",
          substance,
          ", please check their relevance\n"
        )
      }
    }
    if (smaller_than == "ignore") {
      tox_preferred <- tox_preferred |>
        mutate(
          selected = selected & sign != "<",
          reason = if_else(
            sign != "<",
            reason,
            paste(reason, ", ignoring 'smaller than' values as requested")
          )
        ) |>
        group_by(selected) |>
        mutate(critical = selected & wlt_candidate == min_nowarn(wlt_candidate))
    }

    # Treatment of formulation data
    if (formulations == "exclude") {
      tox_preferred <- tox_preferred |>
        mutate(
          selected = if_else(selected & is.na(formulation), TRUE, FALSE),
          reason = if_else(
            selected & is.na(formulation),
            reason,
            paste0(reason, ", Formulation data excluded on request")
          )
        ) |>
        group_by(selected) |>
        mutate(critical = selected & wlt_candidate == min_nowarn(wlt_candidate))
    }
    if (formulations == "include-unique") {
      tox_preferred_others <- tox_preferred |>
        filter(is.na(formulation))

      # Take the formulation endpoints, look for matching endpoints
      # from testing unformulated substances, and keep only
      # formulation endpoints without matches ("unique")
      tox_preferred_formulations_unique <- tox_preferred |>
        filter(!is.na(formulation)) |>
        left_join(
          tox_preferred_others,
          by = c("derappp_species", "category"),
          suffix = c("", "_other"),
          relationship = "many-to-many"
        ) |>
        mutate(
          selected = selected & is.na(wlt_candidate_other),
          reason = if_else(
            is.na(wlt_candidate_other),
            paste0(
              reason,
              ", formulation endpoint without corresponding active substance endpoint"
            ),
            paste0(
              reason,
              ", formulation endpoint excluded, has corresponding active substance endpoint"
            )
          )
        )

      tox_preferred <- tox_preferred_others |>
        rbind(tox_preferred_formulations_unique[names(tox_preferred_others)]) |>
        group_by(selected) |>
        mutate(critical = selected & wlt_candidate == min_nowarn(wlt_candidate))
    }

    tox_critical <- tox_preferred |>
      filter(critical)

    tox_preferred_nosalt <- tox_preferred |>
      mutate(
        selected = selected & !salt,
        reason = if_else(
          salt,
          paste0(
            reason,
            ", endpoint from salt water species excluded on request"
          ),
          reason
        )
      ) |>
      group_by(selected) |>
      mutate(critical = selected & wlt_candidate == min_nowarn(wlt_candidate))

    tox_critical_nosalt <- tox_preferred_nosalt |>
      filter(critical)

    if (salt_water == "exclude") {
      tox_preferred <- tox_preferred_nosalt
      tox_critical <- tox_critical_nosalt
    }

    # Do we have any selected results from salt water species?
    salt_available <- sum(tox_preferred$salt & tox_preferred$selected) > 0

    # Implementation of the special treatment of salt water species as documented
    # in the document "Risikoscore-Berechnung Oberflächengewässer" by Muris
    # Korkaric, version from 13.1.2022.
    # A maximum assessment factor of 5000 was proposed in that document.
    # It is unclear if acute assessments were also considered in this proposal,
    # as 5000 would be a much more extreme proposal with respect to 10 than
    # with respect to 100. The following assumes that the difference between
    # salt water and freshwater species should be cut off at 50, because the maximum
    # AF of 5000 was proposed in the context of a default AF of 100 (long-term exposure).
    if (salt_available) {
      ratios_salt_nosalt <- tox_preferred |>
        filter(selected) |>
        group_by(salt, group, category) |>
        summarize(
          wlt_candidate = suppressWarnings(min(wlt_candidate, na.rm = TRUE)),
          .groups = "drop"
        ) |>
        pivot_wider(
          names_from = salt,
          names_prefix = "salt_",
          values_from = wlt_candidate
        ) |>
        mutate(
          ratio = as.numeric(salt_FALSE / salt_TRUE),
          AF_salt = if_else(ratio < 10, 1, pmin(ratio / 10, max_AF_salt))
        )
    } else {
      ratios_salt_nosalt <- NA
    }

    if (salt_water == "special" & salt_available) {
      tox_preferred <- tox_preferred_nosalt |>
        left_join(ratios_salt_nosalt, by = c("group", "category")) |>
        mutate(AF = if_else(!salt & !is.na(AF_salt), AF * AF_salt, AF)) |> # Adjust AF within group and category
        mutate(wlt_candidate = value / AF) |> # Recalculate WLT candidates
        group_by(selected) |>
        mutate(critical = selected & wlt_candidate == min_nowarn(wlt_candidate))

      tox_critical <- tox_preferred |>
        filter(critical)
    }

    pref_columns <- c("test_nr", "level", "effect") # used for joining

    tox_final <- tox_AF_with_pref |>
      select(-AF, -selected, -reason) |> # Join the final AF, potentially adjusted using salt water species
      left_join(
        tox_preferred[c(
          pref_columns,
          "selected",
          "reason",
          "AF",
          "AF_available",
          "wlt_candidate",
          "critical"
        )],
        by = pref_columns
      ) |>
      mutate(formulation = if_else(is.na(formulation), "", formulation)) |>
      select(
        group,
        category,
        species = derappp_species,
        formulation,
        test_nr,
        test_system,
        duration,
        life_stage,
        effect,
        effect_details,
        level,
        sign,
        value,
        measured,
        selected,
        reason,
        wlt_candidate,
        critical,
        sk,
        page
      ) |>
      arrange(group, category, species, formulation, selected)

    # For selecting an aquatic PEC, we need to set the WLT type
    # As soon as one of the critical values (usually it will be only one)
    # is not from a plant or an algae species, we need to consider the more
    # conservative PEC total which is considered relevant for aquatic animals
    if (
      all(
        tox_critical[["group"]] %in%
          c("Aquatic algae", "Aquatic cyanobacteria", "Aquatic macrophytes")
      )
    ) {
      wlt_type <- "PLANT"
    } else {
      wlt_type <- "ANIMAL"
    }

    ret <- list(
      wlt = unique(tox_critical[["wlt_candidate"]]),
      wlt_type = wlt_type,
      ratios_salt_nosalt = ratios_salt_nosalt,
      data = tox_final
    )

    class(ret) <- "wlt"
    return(ret)
  }
}
