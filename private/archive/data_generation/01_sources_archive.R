# Load cached substance data
load(here('data_generation/cache/substances.rda'))

library(RefManageR)
library(lubridate, warn.conflicts = FALSE)
library(dplyr, warn.conflicts = FALSE)
library(lubridate)
library(stringr)
library(tidyr)
library(purrr, include.only = "pwalk")

derappp_sources <- Sys.getenv("_derappp_sources_")
derappp_input <- Sys.getenv("_derappp_input_")

# Code that was used to copy EFSA conclusions including LoEP to derappp location
# from groundwater indicator project folder and to rename them based on the DOI
if (FALSE) {

  # Path with EFSA conclusions from the groundwater indicator project
  psm_gw_dir <- file.path(
    "~/mnt/Data-Work-RE/41_AssessmentPPP-RE",
    "412.34_Projekte/029_PSM-Indikatoren - Grundwasser/05 - EFSA Conclusions")

  psm_gw_files <- dir(psm_gw_dir, "*.pdf")

  for (candidate_file in psm_gw_files) {
    full_path <- file.path(psm_gw_dir, candidate_file)
    doi <- try(pdftools::pdf_info(full_path)$keys[["WPS-ARTICLEDOI"]])
    if (!is.null(doi) & !inherits(doi, "try-error")) {
      doi_suffix <- gsub("10.2903/", "", doi)
      new_path <- file.path(derappp_sources, "10.2903", paste0(doi_suffix, ".pdf"))
      file.copy(full_path, new_path)
      candidate_loep <- gsub(".pdf", "_LoEP.pdf", full_path)
      if (file.exists(candidate_loep)) {
        new_loep_path <- file.path(derappp_sources, "10.2903",
          paste0(doi_suffix, "_LoEP.pdf"))
        file.copy(candidate_loep, new_loep_path)
      }
    }
  }
  rm(candidate_file, psm_gw_files, psm_gw_dir)
  rm(get_doi)
  rm(full_path, doi, doi_suffix, new_path, candidate_loep, new_loep_path)
}

# Code used to copy EFSA conclusions including LoEP to derappp location
# from derappp sources folder and to rename them based on the DOI
if (FALSE) {
  source_files <- dir(derappp_sources, "*.pdf")

  for (candidate_file in source_files) {
    full_path <- file.path(derappp_sources, candidate_file)
    doi <- try(pdftools::pdf_info(full_path)$keys[["WPS-ARTICLEDOI"]])
    if (!is.null(doi) & !inherits(doi, "try-error")) {
      doi_suffix <- gsub("10.2903/", "", doi)
      new_path <- file.path(derappp_sources, "10.2903", paste0(doi_suffix, ".pdf"))
      if (!file.exists(new_path)) file.copy(full_path, new_path)
      candidate_loep <- gsub(".pdf", "_LoEP.pdf", full_path)
      if (file.exists(candidate_loep)) {
        new_loep_path <- file.path(derappp_sources, "10.2903",
          paste0(doi_suffix, "_LoEP.pdf"))
        if (!file.exists(candidate_loep)) file.copy(candidate_loep, new_loep_path)
      }
    }
  }
  rm(candidate_file, source_files)
  rm(full_path, doi, doi_suffix, new_path, candidate_loep, new_loep_path)
}

# Code originally intended to copy RAR archives referred to in the NABO soil
# fauna tox data from Jhoniels personal folder to the derappp source folder
# and unpack them to a folder named after a useful scheme.
# The copying was finally done manually, as it was not possible to reliably
# extract the year on the front page of the DAR/RAR documents from the PDF
# files
if (FALSE) {
  jhoniels_RAR_folder <- file.path(
    gsub("412.34_Projekte/054_derappp/05_Daten/Input",
      "412.33_Mitarbeitende/pejh/DataBases/Important_Files/RARs",
      derappp_input))
  #dir.exists(jhoniels_RAR_folder)

  zip_files <- dir(jhoniels_RAR_folder, "*.zip")
  actives <- gsub("[_\\.].*", "", zip_files)

}

# Code to generate source keys and the bibtex entries for the files referred to
# in Jhoniels input files
pejh_files <- file.path(
  "~/mnt/Data-Work-RE/41_AssessmentPPP-RE",
  "412.33_Mitarbeitende/pejh/",
  "DataBases/Important_Files")
nabo_macro_path <- file.path(pejh_files, "NABO_MACRO.xlsx")

nabo_macro <- readxl::read_xlsx(nabo_macro_path)

# EU Assessment report files in source folder
ar_pdfs <- list.files(
  path = file.path(derappp_sources, "EU_DAR_dRAR"),
  pattern = "*.pdf", recursive = TRUE) |>
  as_tibble() |>
  separate_wider_delim(1, "/", names = c("folder", "file"))

correspondence_DAR_dRAR <- nabo_macro |>
  select(RAR_document) |>
  filter(!is.na(RAR_document)) |>
  unique() |>
  mutate(RAR_pdf = paste0(RAR_document, ".pdf")) |>
  left_join(ar_pdfs, by = c(RAR_pdf = "file"))

correspondence_DAR_dRAR |>
  filter(is.na(folder)) |>
  select(RAR_document, folder) |>
  print(n = Inf)

generate_bibentry_code_DAR_dRAR <- function(document, folder) {

  # Get the document type from the folder name
  type_short <- gsub(".*_([DR]AR)_.*", "\\1", folder)
  type <- case_match(type_short,
    "DAR" ~ "Draft Assessment Report (DAR)",
    "RAR" ~ "Draft Renewal Assessment Report (dRAR)",
  )

  # Define year in all cases, and date if an ISO date is in the document name
  date_from_document <- str_extract(document, "\\d{4}-\\d{2}-\\d{2}")
  year_from_folder <- gsub(".*_(20..)", "\\1", folder)

  if (is.na(date_from_document)) {
    year <- year_from_folder
  } else {
    year <- year(date_from_document)
  }

  cat("  BibEntry(\n")
  cat("    key = '", gsub(" ", "_", document), "',\n", sep = "")
  cat("    title = '", gsub("_", " ", document), "',\n", sep = "")
  cat("    series = '", gsub("_", " ", folder), "',\n", sep = "")
  cat("    bibtype = 'Report',\n", sep = "")
  cat("    institution = 'European Commission',\n", sep = "")
  cat("    author = 'Anonymous',\n", sep = "")
  cat("    type = '", type, "',\n", sep = "")
  cat("    year = '", year, "',\n", sep = "")
  if (!is.na(date_from_document)) {
    cat("    date = '", date_from_document, "',\n", sep = "")
  }
  cat("    file = 'EU_DAR_dRAR/", folder, "/", document, ".pdf',\n", sep = "")
  cat("  ),\n")

  invisible(NULL)
}

# All files found have a folder and we generate bibentries
capture.output(
  file = here("data_generation/sources/derappp_bib_soil_fauna_toxicity.R"),
  {
    cat("derappp_bib_soil_fauna_toxicity <- c(\n")
    correspondence_DAR_dRAR |>
      filter(!is.na(folder)) |>
      select(document = RAR_document, folder = folder) |>
      pwalk(generate_bibentry_code_DAR_dRAR)
    cat("NULL)\n")
  })

# Clean up
rm(
  substances,
  ar_pdfs, correspondence_DAR_dRAR,
  pejh_files, nabo_macro_path, nabo_macro,
  generate_bibentry_code_DAR_dRAR
)
