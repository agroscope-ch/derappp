# Open an EFSA list of endpoints for a substance

For this to work as intended, you need to specify an environment
variable `_derappp_sources_` that points to the directory where the EFSA
journal PDF files and other sources are stored.

## Usage

``` r
loep(string, open = interactive())
```

## Arguments

- string:

  A part of a substance name

- open:

  Should the file be opened using
  [utils::browseURL](https://rdrr.io/r/utils/browseURL.html) if present?

## Value

If successful, a path to a list of endpoints (invisible)

## Details

If more than one substance matches the string given, the user can
interactively select one of them. If more than one EFSA conclusion is
linked to the substance, the user can again select one. If there is a
separate list of endpoints (EFSA conclusions starting from generally
have one) and it is available on the path, it is opened instead of the
main EFSA conclusion.

## Examples

``` r
# The function only works if the environment variable _derappp_sources_ has
# the path to a directory with the EFSA journal pdf files.
if (Sys.getenv("_derappp_sources_") != "") {
  loep("Difluf")
  loep("Diflubenzuron")
}
```
