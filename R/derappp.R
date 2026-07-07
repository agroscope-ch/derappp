#' Data for environmental risk assessment of plant protection products
#'
#' @docType data
#' @format A number of tables collected in a [dm::dm] object
#' @examples
#' library(derappp) # This also loads the dm package
#' dm_draw(derappp)
#'
#' # The list of chemical entities ("chents")
#' derappp$chents
#'
#' # Some vapor pressures and water solubilities
#' # We need to convert to °C if we do not want Kelvin
#' library(units)
#' derappp$p0[1:2, ] |>
#'   mutate(T = set_units(T, "°C"))
#' derappp$p0[1, ] |>
#'   left_join(derappp$sources, by = "sk") |>
#'   select(substance, p0, T, reference)
#'
#' derappp$cwsat[1:3, ] |>
#'   left_join(derappp$sources, by = "sk") |>
#'   select(substance, cwsat, T, pH, reference) |>
#'   mutate(cwsat = set_units(cwsat, "g/L")) |>
#'   mutate(T = set_units(T, "°C"))
#'
#' # Join names used in the Swiss register
#' derappp$chents |>
#'   left_join(derappp$substance_keys, by = c(chent = "substance")) |>
#'   filter(db == "srppp") |>
#'   left_join(srppphist::srppp_active_substances, by = c(key = "pk")) |>
#'   select(chent, iso, smiles, substance_de)
#'
#' # Show some soil sorption data with units, use percent for readability
#' derappp$soil_sorption |>
#'   filter(substance %in% c("Acetamiprid", "Captan", "Copper", "Cyprodinil")) |>
#'   mutate(f_oc = set_units(f_oc, "%")) |>
#'   select(substance, soil_pH, f_oc, Koc, Kfoc, n, sk, selected, reason) |>
#'   print(n = Inf)
#'
#' # Show some soil degradation data with units
#' derappp$soil_degradation |>
#'   select(substance, DT50, kinetics, alpha, beta, k1, k2, g, tb, sk) |>
#'   print(n = 10)
#'
#' # Some aquatic toxicity data with units
#' head(derappp$aquatic_toxicity) |>
#'   select(substance, formulation, derappp_species, duration, effect, level, sign, value)
#'
#' # Species groupings and taxonomic IDs
#' derappp$species
"derappp"

#' List of chemical entities with additional information
#'
#' @docType data
#' @format A list of [chents::chent] objects, with class `derappp_chents`
#' @examples
#' # The chemical entities are stored as a list of chent objects, so we can
#' # access them by name
#' derappp_chents$Cyprodinil
#'
#' derappp_chents$Myclobutanil
#'
#' # The IUPAC name and source URL retrieved from the British Crop Protection
#' # Council (BCPC) are stored as fields in the
#' # `bcpc` element of the object, so we can easily access them
#' derappp_chents$Captan$bcpc[c("iupac_name", "source_url")]
#'
#' # The PubChem information is stored as a list, so we can check which fields are available
#' names(derappp_chents$Captan$pubchem)
#'
#' # For example, we can check the molecular formula
#' derappp_chents$Captan$pubchem$MolecularFormula
#'
#' # We also have a print method for the complete object showing the first few
#' # items
#' print(derappp_chents, n = 2)
"derappp_chents"

#' @rdname derappp_chents
#' @import chents
#' @export
#' @param x A list of [chents::chent] objects, with class `derappp_chents`
#' @param ... For compatibility with the generic
#' @param n Number of entries to show
print.derappp_chents <- function(x, n = 3, ...) {
  cat("<derappp_chents>\n")
  cat("A list of ", length(x), "<chent> objects\n")
  cat("Showing the first ", n, " entries:\n\n")
  for (i in seq_len(min(n, length(x)))) {
    print(x[[i]])
    cat("\n")
  }
}

#' List of references
#'
#' @docType data
#' @import RefManageR
#' @format A list of [RefManageR::BibEntry] objects
#' @examples
#' derappp_bib[1:10]
"derappp_bib"
