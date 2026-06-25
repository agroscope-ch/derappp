library(srppphist)
library(dplyr)
library(stringr)

if (!exists("substances") | !exists("substance_keys")) {
  warning("You should create 'substance' and 'substance_keys' in 'data_generation/00_substances.R'")
}

srppp_map_auto <- substances |>
  mutate(name_join = str_to_lower(str_trim(substance))) |>
  left_join(
    srppphist::srppp_substances |>
      mutate(substance_join = str_to_lower(str_trim(substance_de))),
    by = c("name_join" = "substance_join")
  ) |>
  select(substance, pk)

# The following list is completed as needed
srppp_map_manual <- tribble(
  ~substance, ~pk,
  "Aluminium phosphide", "1110",
  "Aluminium sulfate", "1701",
  "Azadirachtin", "1265", # Azadirachtin A
  "Azadirachtin", "DB475BCA-9092-4B5E-ADED-C423D021C8A5",
  "Chlorantraniliprole", "1575",
  "Copper", "31403F9A-BB7F-4A16-BC4C-C9083ABDD1AB", # Kupfer
  "Copper(II) hydroxide", "897", # Kupfer (als Hydroxid)
  "Copper(II) hydroxide", "A9525EF1-C3E3-47D4-818D-886CE105775F", # Kupferhydroxid
  "Copper(II) sulfate", "926",   # Kupfer (als Sulfat)
  "Copper oxychloride", "898",   # Kupfer (als Oxychlorid)
  "Copper oxychloride", "9B6470F1-F00C-406A-B980-05FCEDD9BE73",   # Kupferoxychlorid
  "Cydia pomonella granulovirus", "834", # Cydia pomonella Granulovirus (Apfelwicklergranulose-Virus)
  "Cydia pomonella granulovirus", "215D748A-135D-4642-8540-16694070A4D3", #Apfelwicklergranulose-Virus
  "Difenoconazole", "894",
  "Emamectin benzoate", "5C0BFB4B-B7BF-41F4-8351-F6EEF8F45169",
  "Etoxazole", "1458",
  "Fatty acids, C7-18 and C18-unsatd., potassium salts", "C9775705-3E09-4EA1-86F5-A514C7F8412B", # Fettsäuren, C7-C18-und C18 ungesättigt, Kaliumsalze
  "Flurochloridone", "1168",
  "Gibberellic acid", "1175",
  "Gibberellins", "1174",
  "Glyphosate", "199",
  "Haloxyfop-P-methyl", "1176",
  "Horsetail extract", "1331",
  "Metaldehyde", "34CDA556-62F3-449F-8B48-22888FA69E77",
  "Methiocarb", "1193",
  "2-(1-Naphthyl) acetamide", "1106",
  "Paraffin oil", "1027",
  "Paraffin oil", "F976B504-5034-45E2-817D-0FEB04132757", # Paraffinöl
  "Paraffin oil", "1D7FC783-1AA4-47FD-B973-83867751B87B", # Also Paraffinöl
  "Pelargonic acid", "11510",
  "Pelargonic acid", "0B26FA4D-F418-468D-895E-8C368A55B504",
  "Piperonyl butoxide", "1025",
  "Potassium bicarbonate", "1532",
  # The following is not automatically mapped below, because Kaliumhydrogencarbonat
  # occurs twice in srppp_substances_merged from srppphist.
  "Potassium bicarbonate", "EE073DEB-EA92-40CA-AF20-94BBA34BDA7B",
  "Propamocarb hydrochloride", "1220",
  "Propamocarb hydrochloride", "8654D583-DB58-4B25-88B4-71556701D579",
  "Propyzamide", "863",
  "Pyrethrins", "323",
  "Soy lecithin", "988",
  "Sulfur", "338",
  "Zoxamide", "1404")

# Map for substances that have the same name in the old and the new XML versions
srppp_map_v1_v2 <- srppp_substances_merged[c("pk_v1", "pk_v2")] |>
  mutate(pk_v1 = as.character(pk_v1)) |>
  filter(!(is.na(pk_v1) | is.na(pk_v2)))

# Manual map, completed by v1 to v2 mapping
srppp_map_manual_complete <- srppp_map_manual  |>
  left_join(srppp_map_v1_v2, by = c(pk = "pk_v1")) |>
  pivot_longer(c(pk, pk_v2), names_to = "pk_version", values_to = "pk") |>
  filter(!is.na(pk)) |>
  select(-pk_version)

srppp_map_with_NA <- rbind(
  srppp_map_auto,
  srppp_map_manual_complete) |>
  distinct()

pk_unmapped <- srppp_map_with_NA |>
  filter(is.na(pk))

# Convenience function to check pk values
#srppp_pk("Aluminium")
srppp_pk <- function(string) {
  filter(srppp_substances_merged, grepl(string, substance_de)) |>
  select(pk_v1, pk_v2, substance_de)
}

# Add version 2 primary keys for manually mapped entries
srppp_map_complete <- srppp_map_with_NA |>
  filter(!is.na(pk))

# Add to table with substance keys
substance_keys <- substance_keys |>
  filter(db != "srppp") |> # Remove old entries
  rbind(
    tibble(
      substance = srppp_map_complete$substance,
      db = "srppp",
      key = srppp_map_complete$pk))

# Clean up
rm(pk_unmapped, srppp_map_auto, srppp_pk, srppp_map_complete,
   srppp_map_manual, srppp_map_v1_v2, srppp_map_manual_complete,
   srppp_map_with_NA)
