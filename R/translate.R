utils::globalVariables(c("derappp", "pk", "pk_v1", "pk_v2"))
#' Translate substance names between namespaces
#'
#' @description
#' This function is **experimental** and its interface may change in future
#' versions without notice.
#'
#' @param x Either a character vector (see substances) or a table containing a character vector
#' If it is a table (a data.frame or a table derived from a data.frame such as a tibble),
#' there must be a column named according to the "from" argument described below.
#' @param substances A character vector of substance names or primary keys
#' referring to one or more substance(s)
#' @param from Namespace of the input, defaulting to "derappp"
#' @param to Desired namespace of the output, defaulting to "derappp"
#' @param \dots Currently not used
#' @return A tibble with a column for each namespace, named with the namespaces
#' involved.
#' @importFrom rlang := .data
#' @export
#' @examples
#' # Check which namespaces currently exist
#' unique(derappp$substance_keys$db)
#'
#' # Translate substance primary keys from the Swiss Register of Plant Protection Products
#' srppp_names <- c("1-Naphthylacetic acid", "Terbuthylazine", "Pyrethrine")
#' srppp_pk <- c("3", "1245", "323")
#'
#' # Then do the actual translation with derappp::translate_substances()
#' translation <- translate_substances(srppp_pk, from = "srppp")
#' print(translation)
#' translate_substances(srppp_names, from = "substance_de")
#'
#' # We get warned if a substance_de is not mapped and/or translation is incomplete
#' translate_substances(c(srppp_names, "Glyphosate", "Kupfer"), from = "substance_de")
#'
#' # There is also a method for data frames preserving all columns
#' input <- data.frame(x = 1:3, srppp = srppp_pk)
#' translate_substances(input, from = "srppp")
#' input_de <- data.frame(x = 1:3, substance_de = srppp_names)
#' translate_substances(input_de, from = "substance_de")
#'
#' # We can also translate back and get multiple matches for some names
#' translate_substances(translation$derappp, to = "srppp")
#'
#' # Or translate to another namespaces
#' translate_substances(srppp_pk, from = "srppp", to = "NABO_SQ")
#'
#' # An example with NABO Status Quo substances
#' translate_substances(c("Chlorothalonil R417888", "S-Metolachlor"),
#'   from = "NABO_SQ")
#'
#' # If we translate to a namespace that does not have a mapping for the
#' # substance, we get NA
#' translate_substances(c("Chlorothalonil R417888", "S-Metolachlor", "Diazinone"),
#'   from = "NABO_SQ", to = "srppp")
#'
#' # We only find exact matches (room for a future extension)
#' translate_substances(c("S-Metolachlor", "Glyphosat", "Glyphosate"),
#'   from = "derappp", to = "srppp")
translate_substances <- function(
  x,
  ...,
  from,
  to
) {
  UseMethod("translate_substances")
}

#' @export
#' @rdname translate_substances
translate_substances.character <- function(x, substances = x, ..., from, to) {
  if (missing(from)) {
    from <- "derappp"
  }
  if (missing(to)) {
    to <- "derappp"
  }

  # Get the translation mappings
  substance_keys <- derappp::derappp$substance_keys

  # Check arguments 'from' and 'to'
  if (!from %in% c("derappp", "substance_de", unique(substance_keys$db))) {
    stop("No substance keys for ", from, " in the loaded derappp version")
  }
  if (!to %in% c("derappp", unique(substance_keys$db))) {
    stop("No substance keys for ", from, " in the loaded derappp version")
  }

  # Get srppp pk values if from is 'substance_de' and set from to 'srppp'
  if (from == "substance_de") {
    from_substance_de <- TRUE
    substances_orig <- substances
    substances <- tibble(substance_de = substances) |>
      left_join(
        srppphist::srppp_substances_merged,
        by = "substance_de", 
        relationship = "many-to-many"
      ) |>
      mutate(pk = if_else(is.na(pk_v2), as.character(pk_v1), pk_v2)) |>
      pull(pk)
    from <- "srppp"

    # Warn about unmapped substance names
    unmapped <- data.frame(substances_orig, substances) |>
      filter(is.na(substances)) |>
      pull(substances_orig)
    if (length(unmapped) > 0) {
      warning("The following entries were not mapped to srppp keys: ",
              paste(unmapped, collapse = ", "))
    }
  } else {
    from_substance_de <- FALSE
  }

  ret_start <- tibble(substances)
  if (from == "derappp") {
    names(ret_start) <- "derappp"
    ret_from <- ret_start
  } else {
    substance_keys_from <- substance_keys |>
      filter(db == from) |>
      select(-db)

    if (from_substance_de) {
      ret_start$substance_de <- substances_orig
    }

    ret_from <- ret_start |>
      left_join(substance_keys_from, by = c(substances = "key")) |>
      rename(!!from := "substances", derappp := "substance")
  }

  if (to == "derappp") {
    ret <- ret_from
  } else {
    substance_keys_to <- substance_keys |>
      filter(db == to) |>
      select(-db)

    ret_to <- ret_from |>
      left_join(substance_keys_to, by = c(derappp = "substance")) |>
      rename(!!to := "key")

    ret <- ret_to
  }

  original_from <- if (from_substance_de) "substance_de" else from
  untranslated <- ret |>
    filter(is.na(.data[[to]])) |>
    pull(.data[[original_from]])

  if (length(untranslated) > 0) {
    warning("Translation was incomplete for ",
            paste(untranslated, collapse = ", "))
  }

  return(ret)
}

#' @export
#' @rdname translate_substances
translate_substances.data.frame <- function(x, ..., from, to) {
  data <- x
  column_names <- names(data)

  if (missing(from)) {
    from <- "derappp"
  }
  if (missing(to)) {
    to <- "derappp"
  }

  key_names <- unique(derappp::derappp$substance_keys$db)

  if (!from %in% column_names) {
    stop("A column named according to 'from' needs to be in the data")
  }

  translation <- translate_substances(data[[from]], from = from, to = to)

  ret <- data |>
    left_join(translation, by = from)

  return(ret)
}
