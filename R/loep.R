utils::globalVariables(c("db", "substance", "key"))
#' Open an EFSA list of endpoints for a substance
#'
#' For this to work as intended, you need to specify an environment variable
#' `_derappp_sources_` that points to the directory where the EFSA
#' journal PDF files and other sources are stored.
#'
#' If more than one substance matches the string given, the user can
#' interactively select one of them. If more than one EFSA conclusion
#' is linked to the substance, the user can again select one.
#' If there is a separate list of endpoints (EFSA conclusions starting from
#' generally have one) and it is available on the path, it is opened instead
#' of the main EFSA conclusion.
#'
#' @param string A part of a substance name
#' @param open Should the file be opened using [utils::browseURL] if present?
#' @return If successful, a path to a list of endpoints (invisible)
#' @examples
#' # The function only works if the environment variable _derappp_sources_ has
#' # the path to a directory with the EFSA journal pdf files.
#' if (Sys.getenv("_derappp_sources_") != "") {
#'   loep("Difluf")
#'   loep("Diflubenzuron")
#' }
#' @export
loep <- function(string, open = interactive()) {
  # Get matching substances
  subs <- derappp::derappp$substances |>
    filter(grepl(string, substance, ignore.case = TRUE))

  # If in interactive use, have the user select a matching substance
  if (interactive()) {
    if (nrow(subs) == 0) {
      stop("No substances found in the derappp substance list")
      return(NULL)
    }
    if (nrow(subs) > 1) {
      subs <- subs |>
        dplyr::mutate(row = row_number()) |>
        select(row, everything())
      print(subs)
      selected <- as.numeric(readline("Select a row: "))
      subs <- subs |>
        dplyr::filter(row == selected)
    }
  } else {
    # If not interactive, select the first substance
    subs <- subs |>
      slice(1)
  }

  # Get the EFSA list of endpoints for the substance
  loep <- subs |>
    left_join(derappp::derappp$substance_keys, by = "substance") |>
    filter(db == "efsa_conclusions") |>
    select(substance, key)

  # If interactive and more than one list of endpoints, have the user select one
  if (interactive()) {
    if (nrow(loep) == 0) {
      stop("No EFSA list of endpoints found for the substance")
      return(NULL)
    }
    if (nrow(loep) > 1) {
      loep <- loep |>
        dplyr::mutate(row = row_number()) |>
        select(row, everything())
      print(loep)
      selected <- as.numeric(readline("Select a row: "))
      loep <- loep |>
        dplyr::filter(selected == row)
    }
  } else {
    # If not interactive, select the first list of endpoints
    loep <- loep |>
      slice(1)
  }

  # Open the EFSA list of endpoints
  source_dir <- Sys.getenv("_derappp_sources_")
  if (source_dir == "") {
    stop("The path to the derappp sources is not set")
    return(NULL)
  } else {
    if (!dir.exists(source_dir)) {
      stop("The path to the derappp sources does not exist")
      return(NULL)
    }
  }
  path <- file.path(
    Sys.getenv("_derappp_sources_"),
    paste0(gsub("doi:", "", loep$key), ".pdf")
  )
  loep_path <- file.path(
    Sys.getenv("_derappp_sources_"),
    paste0(gsub("doi:", "", loep$key), "_LoEP.pdf")
  )

  if (file.exists(path)) {
    # Check if there is a separate list of endpoints for the substance
    if (file.exists(loep_path)) {
      path <- loep_path
    }
    if (open) {
      browseURL(path)
    }
    message(path)
    invisible(path)
  } else {
    stop("The EFSA list of endpoints was not found")
  }
}
