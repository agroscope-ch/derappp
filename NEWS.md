## version 0.9.3 

- Import from `dm` instead of depending on it (issue #4) to avoid noise when loading `derappp`
- Some chemical entities were added
- Add some aggregated soil sorption and degradation endpoints prepared by @Lutzeli
- Make it possible to specify mean values in soil sorption tables, thanks to @Lutzeli
- Add more aquatic toxicity data mostly prepared by @MarcelMagro
- Fix handling of change detection in binary input files
- Add Romualdus Kasteel as a reviewer, this was previously overlooked
- Use Kelvin instead of degree C for storing temperature columns, as it is recommended by the units package and avoids warnings about non-ASCII characters
- Avoid non-ASCII characters in the derappp object and declare some encodings in data generation
- Use RDS instead of RData formt for caching data in the data generation to reduce noise in the git logs caused by RData files storing the R minor version

## version 0.9.2 (2026-07-02)

Release to the public.
