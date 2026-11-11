# Changelog

## version 0.9.4.9002

- The source files specifying bibliographic entries for DAR and RAR
  documents were merged, leading to the elimination of one duplicate
  (boscalid RAR LoEP from 2018).
- Add test durations or indications of test duration where it was not
  specified. Such indications can be “Chronic” or “chronic” in the
  notes, or one of the life stages “early life stage”, “larval”,
  “juvenile” or “full life cycle”, because these are checked for in the
  `wlt` function. The specification of a duration satisfying these rules
  is now checked when reading in the aquatic toxicity data
- [`wlt()`](https://agroscope-ch.github.io/derappp/reference/wlt.md):
  Add derappp notes to the `data` component of the returned object.
  Also, look for “chronic” or “Chronic” in notes in cases the duration
  is not specified
- Add aquatic toxicity for paraffin oil including data from the 2009
  EFSA conclusions, but deselected, although it is not always clear why
  they do not appear in any of the current RARs and EFSA conclusions,
  but we follow EFSA decisions on dropping data in newer EFSA
  conclusions, unless we have specific reasons
- Add aquatic toxicity for fosetyl-aluminium. In the title of the EFSA
  conclusion from 2025, only “fosetyl” is mentioned, but in the endpoint
  list, there is a comment in the very beginning that the data relate to
  the variant fosetyl-aluminium
- Add aquatic toxicity for buprofezin, clomazone, daminozide, maleic
  hydrazide, maltodextrin, pelargonic acid, pyraclostrobin and
  pyrethrins

## version 0.9.4

- A unit conversion error sneaked in that lead to aquatic toxicity
  endpoints in µg/L to be read in with the wrong units. Thanks to
  [@Lutzeli](https://github.com/Lutzeli) and
  [@MarcelMagro](https://github.com/MarcelMagro) for independently
  spotting and fixing the error
  ([\#14](https://github.com/agroscope-ch/derappp/issues/14) and
  [\#15](https://github.com/agroscope-ch/derappp/issues/15)).
- Add more aquatic toxicity endpoints from EFSA conclusions, add and
  update the necessary definitions.

## version 0.9.3

- Add aquatic toxicity endpoints from EFSA conclusions for a number of
  active substances we are working on in different projects. Add or
  update the necessary definitions of chents, substances, species and
  sources.
- Improve the return value of the `wlt` function for the case of no data
  in derappp. The list component `wlt` is now length 1 instead of length
  0, and the `type` component is NA.
- Import from `dm` instead of depending on it (issue
  [\#4](https://github.com/agroscope-ch/derappp/issues/4)) to avoid
  noise when loading `derappp`
- Some chemical entities were added
- Add some aggregated soil sorption and degradation endpoints prepared
  by [@Lutzeli](https://github.com/Lutzeli)
- Make it possible to specify mean values in soil sorption tables,
  thanks to [@Lutzeli](https://github.com/Lutzeli)
- Add more aquatic toxicity data mostly prepared by
  [@MarcelMagro](https://github.com/MarcelMagro)
- Fix handling of change detection in binary input files
- Add Romualdus Kasteel as a reviewer, this was previously overlooked
- Use Kelvin instead of degree C for storing temperature columns, as it
  is recommended by the units package and avoids warnings about
  non-ASCII characters
- Avoid non-ASCII characters in the derappp object and declare some
  encodings in data generation
- Use RDS instead of RData format for caching data in the data
  generation to reduce noise in the git logs caused by RData files
  storing the R minor version

## version 0.9.2 (2026-07-02)

Release to the public.
