# Script to define the sources that can be referenced in the other tables
# Has to be run after defining or updating substances in 00_substances.R
#
# Defines the following objects stored in the package:
# 'data/derappp_bib.rda'   BibEntry object used to generate the source table
# 'vignettes/derappp.bib'  BibTex file for use in package vignettes
#
# Defines the following objects cached in 'data_generation/cache'
# for further use in the scripts in 'data_generation':
# 'substance_keys'    Initial mappings to latest EFSA conclusions from OpenFoodTox
# 'sources'           The source table to include in derappp

# After running this script, you need to run 02_substance_maps.R to add the mappings
# to other data sources to 'substance_keys'

library(here)
library(RefManageR)
# install.packages("OpenFoodTox", repos = c("https://agroscope-ch.r-universe.dev", "https://cran.r-project.org"))
library(OpenFoodTox)
library(lubridate, warn.conflicts = FALSE)
library(dplyr, warn.conflicts = FALSE)
library(yaml)
library(withr) # with_options()

# Load cached substance data
load(here('data_generation/cache/substances.rda'))


# The environment variable _derappp_sources_ should point to a directory
# containing the source files
derappp_sources <- Sys.getenv("_derappp_sources_")
if (derappp_sources == "") {
  stop("You need to set the environment variable '_derapp_sources_'")
} else {
  if (!dir.exists(derappp_sources)) {
     stop("The directory ", derappp_sources, " does not exist")
  }
}

# ------------------------------------------------------------------------------
# Create mappings to latest EFSA conclusions and to the latest EFSA conclusions
# partial assessments (confirmatory data, assessments for bees, aquatics, seed
# coatings). The starting point is the substance mapping and bibliographic
# information available in OpenFoodTox

# Get latest full EFSA conclusions (excluding partial assessments)
regexp_partial_conclusion <- "onfirmatory|bees|aquatic|seed"

oft_latest_efsa_conclusions_full <- oft$efsa_outputs |>
  filter(OutputType == "Conclusion on Pesticides Peer Review"|
           DOI == "doi:10.2903/j.efsa.2018.5152") |> # Include conclusion on copper compounds (falsely classified a "EFSA opinion")
  filter(!grepl(regexp_partial_conclusion, Title)) |>
  arrange(Published) |>
  select(Substance, Published) |>
  group_by(Substance) |>
  summarize(latest = max(Published)) |>
  left_join(oft$efsa_outputs, by = c("Substance", latest = "Published")) |>
  select(Substance, OutputID, Published = latest, Title, DOI, URL)

oft_latest_efsa_conclusions_partial <- oft$efsa_outputs |>
  filter(OutputType == "Conclusion on Pesticides Peer Review") |>
  filter(grepl(regexp_partial_conclusion, Title)) |>
  arrange(Published) |>
  select(Substance, Published) |>
  group_by(Substance) |>
  summarize(latest = max(Published)) |>
  left_join(oft$efsa_outputs, by = c("Substance", latest = "Published")) |>
  select(Substance, OutputID, Published = latest, Title, DOI, URL)

# We include some older EFSA conclusions for the following reasons:
# Captan 2009: Contains endpoints based on nominal concentrations that are
# considered relevant for surface water assessments based on PECini
# Only use the row with Substance == "Captan", as we already keep entries for
# two Captan products that also point to the DOI from 2009.
oft_latest_efsa_conclusions_manual <- oft$efsa_outputs |>
  filter(Substance == "Captan" & DOI == "doi:10.2903/j.efsa.2009.296r") |>
  select(Substance, OutputID, Published, Title, DOI, URL)

oft_latest_efsa_conclusions <- rbind(
  oft_latest_efsa_conclusions_partial,
  oft_latest_efsa_conclusions_manual,
  oft_latest_efsa_conclusions_full) |>
  arrange(Substance, Published) |>
  filter(!DOI == "doi:10.2903/j.efsa.2012.2758") |> # Methiocarb outdated confirmatory
  filter(!DOI == "doi:10.2903/j.efsa.2012.2601") # Thiamethoxam superseded

# Copy to "latest_efsa_conclusions" and overwrite outdated or erroneous entries
latest_efsa_conclusions <- oft_latest_efsa_conclusions

# Fluoxastrobin 2005: An update was published in 2007
latest_efsa_conclusions[latest_efsa_conclusions$Substance == "Fluoxastrobin",
  "Published"] <-
  tibble(as.Date("2007-07-25"))

# Trinexapac 2006: Even though the the substance name in the title of the 2006
# conclusion is trinexapac, all data in there refers to trinexapac-ethyl unless
# specified otherwise.
latest_efsa_conclusions <- bind_rows(latest_efsa_conclusions,
  tibble(Substance = "Trinexapac-ethyl", OutputID = NA, Published = as.Date("2006-01-10"),
    Title = "Conclusion regarding the peer review of the pesticide risk assessment of the active substance Trinexapac",
    DOI = "doi:10.2903/j.efsa.2006.57r",
    URL = "http://dx.doi.org/10.2903/j.efsa.2006.57r"))

# Add rows for some EFSA conclusions not yet included in OpenFoodTox, the latest version is from 2023
source(here("data_generation/01_sources/efsa_conclusions_after_openfoodtox.R"))

efsa_map_auto <- substances |>
  mutate(lower_case_name = gsub("\\s+", "", tolower(substance))) |>
  left_join(
    mutate(latest_efsa_conclusions, lower_case_substance = gsub("\\s+", "", tolower(Substance))),
    by = c(lower_case_name = "lower_case_substance"), relationship = "many-to-many") |>
  select(substance, DOI)

# Flurochloridone 2010
# According to the flurochloridone data sheet of the BCPC (accessed 2025-02-24),
# the ISO definition of flurochloridone has meanwhile been relaxed to simply
# designate a mixture of the trans and cis isomers, with the comment:
# "The proportion of isomers was originally defined as a 3:1 ratio."
# Therefore, the IUPAC name used in OpenFoodtox (explicitly not stating
# a ratio) can be mapped to our definition which is based on the ISO definition.
efsa_map <- efsa_map_auto |>
  mutate(DOI = recode_values(substance,
  "Flurochloridone" ~ "doi:10.2903/j.efsa.2010.1869", # ISO definition has been updated
  "Triclopyr-butotyl" ~ "doi:10.2903/j.efsa.2024.8177", # 2024 conclusion not in OpenFoodTox
  "Copper oxychloride" ~ "doi:10.2903/j.efsa.2018.5152", # substance not in OpenFoodTox
  "Copper(II) chloride" ~ "doi:10.2903/j.efsa.2018.5152", # substance not in OpenFoodTox
  "Copper(II) hydroxide" ~ "doi:10.2903/j.efsa.2018.5152", # substance not in OpenFoodTox
  "Copper(II) nitrate" ~ "doi:10.2903/j.efsa.2018.5152", # substance not in OpenFoodTox
  "Copper(II) sulfate" ~ "doi:10.2903/j.efsa.2018.5152", # substance not in OpenFoodTox
  default = DOI)
)

# Check for unmapped chemical entities
efsa_map <- efsa_map |>
  filter(!is.na(DOI)) |>
  select(substance, DOI)

# Initialize table with substance name and mappings to latest EFSA conclusions
substance_keys <- tibble(
  substance = efsa_map$substance,
  db = "efsa_conclusions",
  key = efsa_map$DOI) |>
  arrange(substance, key)

# ------------------------------------------------------------------------------
# Create the derappp bibliography

# Start derappp bibliography with a self reference to this package
derappp_bibentry <- as.BibEntry(citation("derappp"))
derappp_bibentry$key <- "derappp"

# Add citations of packages used in the data generation scripts,
# and internet sources used
derappp_bib_ini <- c(
  derappp_bibentry,
  as.BibEntry(citation("webchem")),
  as.BibEntry(citation("chents")),
  BibEntry(
    key = "BCPC_Compendium",
    bibtype = "online",
    author = "{British Crop Protection Council}",
    year  = "2024",
    title = "Compendium of Pesticide Common Names",
    url = "http://www.bcpcpesticidecompendium.org/"),
  BibEntry(
      key = "PubChem",
      bibtype = "online",
      author = "{National Center for Biotechnology Information}",
      year  = "2024",
      title = "PubChem",
      url = "https://pubchem.ncbi.nlm.nih.gov/"),
  BibEntry(
      key = "CAS_Common_Chemistry",
      bibtype = "online",
      author = "{CAS Division of the American Chemical Society}",
      year  = "2024",
      title = "CAS Common Chemistry",
      url = "https://commonchemistry.cas.org"),
  BibEntry(
      key = "envipath",
      bibtype = "online",
      author = "{enviPath UG & Co KG}",
      year  = "2024",
      title = "envipath: The Environmental Contaminant Biotransformation Pathway Resource",
      url = "https://envipath.org"),
  BibEntry(
      key = "PPDB_Agroscope_2024-07-01",
      bibtype = "reference",
      editor = "{University of Hertfordshire}",
      year  = "2024",
      title = "Pesticide Properties DataBase, Agroscope subscription"
  ),
  BibEntry(
    key = "PIERIS_2024-06-05",
    bibtype = "reference",
    editor = "Agroscope",
    year = "2024",
    title = "Pesticides and Intermediates Ecotoxicological Risk Information System"
  )
)

# Initialise bibliography of EFSA conclusions with OpenFoodTox R package
derappp_bib_efsa <- as.BibEntry(citation("OpenFoodTox"))

# The same EFSA conclusion is listed for different substances in OFT, here
# we only keep entries that are mapped to the substances in the package
# and remove the duplicates
efsa_conclusions_used <- latest_efsa_conclusions |>
  filter(DOI %in% unique(efsa_map$DOI)) |>
  select(OutputID, Published, Title, DOI, URL) |>
  distinct()

purrr::pwalk(efsa_conclusions_used,
  function(OutputID, Published, Title, DOI, URL) {
    doi_suffix <- gsub("doi:10.2903/", "", DOI)
    rel_path <- file.path("10.2903", paste0(doi_suffix, ".pdf"))
    full_path <- file.path(derappp_sources, rel_path)
    if (file.exists(full_path)) {
      bib <- BibEntry(bibtype = "Report", key = doi_suffix,
        author = "EFSA", type = "EFSA conclusion",
        institution = "European Food Safety Authority",
        title = Title, date = Published,
        doi = DOI, url = URL,
        file = rel_path,
        oft_id = OutputID
        )
      derappp_bib_efsa <<- c(derappp_bib_efsa, bib)
      candidate_loep_rel_path <- gsub(".pdf", "_LoEP.pdf", rel_path)
      candidate_loep_full_path <- file.path(derappp_sources, candidate_loep_rel_path)
      if (file.exists(candidate_loep_full_path)) {
        loep_bib <- bib
        loep_bib$key <- paste0(doi_suffix, "_LoEP")
        loep_bib$title <- paste("Appendix to:", Title)
        loep_bib$file <- candidate_loep_rel_path
        efsa_journal_pub <- gsub(".*\\.", "", bib$doi)
        # The following url pattern is only sometimes correct, sometimes Appendix-A (with dash)
        # should be used, and sometimes it is Appendix B. Here we assume Appendix_A.
        # In addition, using URLencode with reserved = TRUE to encode special characters like "/"
        # leads to warnings when using format() on the BibEntry object later on, and to stray characters in the formatted output,
        # so the line with URLencode() was commented out for now, as we do not have reliable URLs anyways.
        # To get a reliable URL, one would need to scrape it from the EFSA website based on the OutputID.
        # So we just provide the link to the supporting information where the link is provided for now.
        #loep_bib$url <- paste0("https://efsa.onlinelibrary.wiley.com/action/downloadSupplement?doi=",
          #URLencode(gsub("doi:", "", bib$doi), reserved = TRUE), "&file=efs2", efsa_journal_pub, "-sup-0001-Appendix_A.pdf")
        #  gsub("doi:", "", bib$doi), "&file=efs2", efsa_journal_pub, "-sup-0001-Appendix_A.pdf")
        loep_bib$url <- paste0("https://efsa.onlinelibrary.wiley.com/doi/",
          gsub("doi:", "", bib$doi), "#support-information-section")
        derappp_bib_efsa <<- c(derappp_bib_efsa, loep_bib)
      }
    } else {
      message("Missing EFSA conclusion: ", gsub("doi:", "https://dx.doi.org/", DOI))
    }
  })

derappp_bib_rar_sssd_rr <- c(
  BibEntry(
    key = "Boscalid_RAR_2018_LoEP",
    bibtype = "Report",
    institution = "European Food Safety Authority",
    author = "Anonymous",
    type = "Renewal Assessment Report",
    title = "Draft Renewal Assessment Report under Regulation (EC) 1107/2009 - Boscalid List of Endpoints",
    date = "2018-11-09",
    url = "https://www.efsa.europa.eu/en/consultations/call/190125",
    file = "Boscalid_RAR_2017/boscalid_RAR_22_LoEP_2018-11-09.pdf"
  ),
  BibEntry(
    key = "Fluopyram_Bayer_SSSD_2021_MCA_Sec_7",
    bibtype = "Report",
    institution = "European Food Safety Authority",
    author = "Anonymous",
    type = "Sanitised Supplementary Summary Dossier",
    title = "1st Amendment of Summary of the fate and behaviour in the environment for fluopyram",
    date = "2021-06-25",
    url = "https://open.efsa.europa.eu/questions/EFSA-Q-2017-00125",
    file = "Fluopyram_Bayer_SSSD_2021/D_P-MCA_Section_7_02_M-770117_0005411077.pdf"
  ),
  BibEntry(
    key = "Beflubutamid_RR_2007",
    bibtype = "Report",
    institution = "European Commission",
    author = "Anonymous",
    type = "Review report",
    title = "Review report for the active substance beflubutamid",
    date = "2007-04-19",
    file = "EU_Review_Reports/Beflubutamid_RR_2007.pdf"
  ),
  BibEntry(
    key = "Chlorotoluron_RR_2005",
    bibtype = "Report",
    institution = "European Commission",
    author = "Anonymous",
    type = "Review report",
    title = "Review report for the active substance chlorotoluron",
    date = "2005-02-15",
    file = "EU_Review_Reports/Chlorotoluron_RR_2007.pdf"
  ),
  BibEntry(
    key = "Chlorotoluron_dRAR_23-LoEP_2021-07-29",
    bibtype = "Report",
    institution = "European Commission",
    author = "Anonymous",
    type = "Review report",
    title = "Combined Draft Renewal Assessment Report prepared according to
    Regulation (EC) No 1107/200 and Proposal for Harmonised Classification and
    Labelling (CLH Report) according to Regulation (EC) No 1272/2008
    CHLOROTOLURON List of End Points",
    date = "2021-07-29",
    file = "EU_DAR_dRAR/Chlorotoluron_RAR_2021/Chlorotoluron_dRAR_23-LoEP_2021-07-29.pdf"
  ),
  BibEntry(
    key = "Chlorpyrifos_RAR_60_LoEP_2017-07-03",
    bibtype = "Report",
    institution = "European Commission",
    author = "Anonymous",
    type = "Review report",
    title = "Level 2 (Appendix 1) CHLORPYRIFOS Appendix 1. List of end points",
    date = "2017-07-03",
    file = "EU_DAR_dRAR/Chlorpyrifos_RAR_2017/Chlorpyrifos_RAR_60_LoEP_2017-07-03.pdf"
  ),
  BibEntry(
    key = "Diflufenican_RAR_12_List_of_endpoints_2018-07-19",
    bibtype = "Report",
    institution = "European Commission",
    author = "Anonymous",
    type = "Review report",
    title = "Renewal Assessment Report prepared according to the Commission
    Regulation (EU) No 1107/2009 Diflufenican List of Endpoints",
    date = "2018-07-19",
    file = "EU_DAR_dRAR/Diflufenican_RAR_2018/Diflufenican_RAR_12_List_of_endpoints_2018-07-19.pdf"
  ),
  BibEntry(
    key = "Fenarimol_RR_2007",
    bibtype = "Report",
    institution = "European Commission",
    author = "Anonymous",
    type = "Review report",
    title = "Review report for the active substance fenarimol",
    date = "2007-01-05",
    file = "EU_Review_Reports/Fenarimol_RR_2007.pdf"
  ),
  BibEntry(
    key = "Flusilazole_RR_2007",
    bibtype = "Report",
    institution = "European Commission",
    author = "Anonymous",
    type = "Review report",
    title = "Review report for the active substance flusilazole",
    date = "2007-01-05",
    file = "EU_Review_Reports/Flusilazole_RR_2007.pdf"
  ),
  BibEntry(
    key = "Prosulfocarb_RR_2007",
    bibtype = "Report",
    institution = "European Commission",
    author = "Anonymous",
    type = "Review report",
    title = "Review report for the active substance prosulfocarb",
    date = "2007-09-10",
    file = "EU_Review_Reports/Prosulfocarb_RR_2007.pdf"
  ),
  BibEntry(
    key = "Pyraclostrobin_RAR_31_LoEP_2018-02-15",
    bibtype = "Report",
    institution = "European Commission",
    author = "Anonymous",
    type = "Review report",
    title = "Renewal Assessment Report Pyraclostrobin List of end points",
    date = "2018-02-15",
    file = "EU_DAR_dRAR/Pyraclostrobin_RAR_2018/Pyraclostrobin_RAR_31_LoEP_2018-02-15.pdf"
  ),
  BibEntry(
    key = "Quinoxyfen_RR_2003",
    bibtype = "Report",
    institution = "European Commission",
    author = "Anonymous",
    type = "Review report",
    title = "Review report for the active substance quinoxyfen",
    date = "2003-11-27",
    file = "EU_Review_Reports/Quinoxyfen_RR_2003.pdf"
  ),
  BibEntry(
    key = "Thiamethoxam_RR_2006",
    bibtype = "Report",
    institution = "European Commission",
    author = "Anonymous",
    type = "Review report",
    title = "Review report for the active substance thiamethoxam",
    date = "2006-07-14",
    file = "EU_Review_Reports/Thiamethoxam_RR_2006.pdf"
  ),
  BibEntry(
    key = "BAS_550_01_F_Document_MCP_Section_10_update_3_sanitized",
    bibtype = "Report",
    institution = "European Food Safety Authority",
    author = "Anonymous",
    type = "Sanitised Supplementary Summary Dossier",
    title = "BAS 550 01 F Document M-CP, Section 10 Ecotoxicological Studies on the Plant Protection Product",
    date = "2017-05-31",
    url = "https://open.efsa.europa.eu/questions/EFSA-Q-2016-00678",
    file = "Dimethomorph_BASF_SSSD_2017/BAS 550 01 F/BAS 550 01 F Document MCP Section 10 update 3_sanitized.pdf"
  )
)

# DAR/RAR documents referred to in Jhoniels soil toxicity data files
# These were generated using the script
# 'private/archive/data_generation/01_sources_archive.R?
# which is currently not intended for publication as it contains private paths.
source(here("data_generation/01_sources/derappp_bib_soil_fauna_toxicity.R"))

# DAR/RAR documents referred to in the aquatic toxicity data files
source(here("data_generation/01_sources/derappp_bib_aquatic_toxicity.R"))

derappp_bib <- c(derappp_bib_ini, derappp_bib_efsa, derappp_bib_rar_sssd_rr,
  derappp_bib_soil_fauna_toxicity,
  derappp_bib_aquatic_toxicity)

WriteBib(derappp_bib, file = here("inst/REFERENCES.bib"))
save(derappp_bib, file = here("data/derappp_bib.rda"), compress = "bzip2")

# Create a table of sources for referencing in the derappp object
# We need to set the console width for this call, as the result will
# otherwise depend on the current width of the console.
source_table_list <- with_options(list(width = 80L),
  lapply(derappp_bib, function(x) {
    tibble(
      sk = x$key,
      reference = sub("\\[.*?\\] ", "", format(x, "text")),
      year = if (is.null(x$year)) as.character(year(x$date))
        else as.character(x$year),
      url = x$url,
      file = x$file
    )
  }))

# The source table will be included in the derappp dm object created in
# 99_derappp.R
sources <- dplyr::bind_rows(source_table_list)

# Save results for use in other scripts in 'data_generation'
save("substance_keys", file = here("data_generation/cache/",
  "substance_keys.rda"))
save("sources", file = here("data_generation/cache/",
  "sources.rda"))

# Clean up
rm(
  oft_latest_efsa_conclusions_full,
  oft_latest_efsa_conclusions_partial,
  oft_latest_efsa_conclusions_manual,
  oft_latest_efsa_conclusions)
rm(
  regexp_partial_conclusion,
  latest_efsa_conclusions,
  efsa_conclusions_used,
  efsa_map,
  efsa_map_auto)
rm(derappp_sources,
  derappp_bibentry,
  derappp_bib_ini, derappp_bib_efsa, derappp_bib_rar_sssd_rr,
  derappp_bib_soil_fauna_toxicity,
  derappp_bib_aquatic_toxicity,
  source_table_list,
  derappp_bib,
  substances, substance_keys, sources
)

