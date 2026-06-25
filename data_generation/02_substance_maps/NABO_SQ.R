if (!exists("substances") | !exists("substance_keys")) {
  warning("You should create 'substance' and 'substance_keys' in 'data_generation/00_substances.R'")
}

NABO_SQ_substances <- c(
  "2,6-Dichlorobenzamide", "2-Amino-4,6-dimethoxypyrimidine",
  "Amisulbrom", "Atrazine", "Atrazine-2-hydroxy", "Atrazine-desethyl", "Atrazine-desisopropyl",
  "Azoxystrobin",
  "Beflubutamid", "Benalaxyl", "Bixafen", "Boscalid",
  "Bupirimate", "Buprofezin", "Carbendazim",
  "Clofentezine",
  "Chlorantraniliprole", "Chloridazon",
  "Chlorothalonil R417888", "Chlorothalonil R611968", "Chlorothalonil-4-hydroxy",
  "Chlorotoluron", "Chlorpyrifos",
  "Clomazone", "Clothianidin", "Cyazofamid", "Cyproconazole", "Cyprodinil",
  "Cyprodinil CGA249287", "Cyprodinil CGA232449",
  "Desmedipham", "Desmethoxy-linuron",
  "Difenoconazole", "Diflufenican",
  "Dimethomorph", "Diuron", "Dodemorph",
  "Endosulfan sulfate",
  "Epoxiconazole", "Ethirimol", "Ethofumesate",
  "Fenarimol", "Fenpropidin", "Fenpropimorph",
  "Fenpyroximate", "Fipronil", "Fluazinam", "Fludioxonil", "Flufenacet",
  "Fluopicolide", "Fluopyram", "Fluoxastrobin", "Fluquinconazole", "Flurochloridone",
  "Flusilazole", "Fluxapyroxad",
  "Imazalil", "Imidacloprid", "Indoxacarb",
  "Isoproturon", "Isoproturon-didemethyl",
  "Linuron", "Lufenuron",
  "Mandipropamid", "Mepanipyrim",
  "Metalaxyl", "Metamitron", "Metconazole", "Methiocarb", "Metolachlor ESA",
  "Metolachlor OA", "Metrafenone", "Myclobutanil",
  "Napropamide",
  "Orbencarb", "Oryzalin",
  "Paclobutrazol", "Penconazole", "Pencycuron", "Pendimethalin", "Pethoxamid",
  "Phenmedipham", "Picoxystrobin", "Piperonyl butoxide",
  "Pirimicarb", "Prochloraz",
  "Propiconazole", "Propyzamide", "Proquinazid", "Prosulfocarb", "Pyraclostrobin",
  "Pyrifenox", "Pyrimethanil",
  "Quinoxyfen",
  "S-Metolachlor",
  "Tebuconazole", "Tebufenozide", "Tebufenpyrad", "Teflubenzuron",
  "Terbuthylazine", "Terbuthylazine-desethyl",
  "Thiabendazole", "Thiacloprid", "Thiamethoxam", "Triadimenol",
  "Trifloxystrobin", "Trifloxystrobin acid", "Triticonazole", "Zoxamide"
)

NABO_SQ_map <- tibble(pk = NABO_SQ_substances) |>
  mutate(substance = recode_values(pk,
    "Chlorothalonil R417888" ~ "R417888",
    "Chlorothalonil R611968" ~ "R611968",
    "Cyprodinil CGA249287" ~ "CGA249287",
    "Cyprodinil CGA232449" ~ "CGA232449",
    default = pk)
  )

# Add to table with chent keys
substance_keys <- substance_keys |>
  filter(db != "NABO_SQ") |> # Remove old entries
  rbind(
    tibble(
      substance = NABO_SQ_map$substance,
      db = "NABO_SQ",
      key = NABO_SQ_map$pk))

# Clean up
rm(NABO_SQ_substances, NABO_SQ_map)
