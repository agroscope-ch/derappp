# Translate substance names between namespaces

This function is **experimental** and its interface may change in future
versions without notice.

## Usage

``` r
translate_substances(x, ..., from, to)

# S3 method for class 'character'
translate_substances(x, substances = x, ..., from, to)

# S3 method for class 'data.frame'
translate_substances(x, ..., from, to)
```

## Arguments

- x:

  Either a character vector (see substances) or a table containing a
  character vector If it is a table (a data.frame or a table derived
  from a data.frame such as a tibble), there must be a column named
  according to the "from" argument described below.

- ...:

  Currently not used

- from:

  Namespace of the input, defaulting to "derappp"

- to:

  Desired namespace of the output, defaulting to "derappp"

- substances:

  A character vector of substance names or primary keys referring to one
  or more substance(s)

## Value

A tibble with a column for each namespace, named with the namespaces
involved.

## Examples

``` r
# Check which namespaces currently exist
unique(derappp$substance_keys$db)
#> [1] "efsa_conclusions" "srppp"            "NABO_SQ"         

# Translate substance primary keys from the Swiss Register of Plant Protection Products
srppp_names <- c("1-Naphthylacetic acid", "Terbuthylazine", "Pyrethrine")
srppp_pk <- c("3", "1245", "323")

# Then do the actual translation with derappp::translate_substances()
translation <- translate_substances(srppp_pk, from = "srppp")
print(translation)
#> # A tibble: 3 × 2
#>   srppp derappp              
#>   <chr> <chr>                
#> 1 3     1-Naphthylacetic acid
#> 2 1245  Terbuthylazine       
#> 3 323   Pyrethrins           
translate_substances(srppp_names, from = "substance_de")
#> # A tibble: 3 × 3
#>   srppp                                substance_de          derappp            
#>   <chr>                                <chr>                 <chr>              
#> 1 6F14D297-81BA-4AA0-9636-D65F2F1A0BD6 1-Naphthylacetic acid 1-Naphthylacetic a…
#> 2 736564C2-CA47-4979-AC4A-917F2B97B61A Terbuthylazine        Terbuthylazine     
#> 3 7639690D-56F7-455F-9CFB-33D3C620FE91 Pyrethrine            Pyrethrins         

# We get warned if a substance_de is not mapped and/or translation is incomplete
translate_substances(c(srppp_names, "Glyphosate", "Kupfer"), from = "substance_de")
#> Warning: The following entries were not mapped to srppp keys: Glyphosate
#> Warning: Translation was incomplete for Glyphosate
#> # A tibble: 5 × 3
#>   srppp                                substance_de          derappp            
#>   <chr>                                <chr>                 <chr>              
#> 1 6F14D297-81BA-4AA0-9636-D65F2F1A0BD6 1-Naphthylacetic acid 1-Naphthylacetic a…
#> 2 736564C2-CA47-4979-AC4A-917F2B97B61A Terbuthylazine        Terbuthylazine     
#> 3 7639690D-56F7-455F-9CFB-33D3C620FE91 Pyrethrine            Pyrethrins         
#> 4 NA                                   Glyphosate            NA                 
#> 5 31403F9A-BB7F-4A16-BC4C-C9083ABDD1AB Kupfer                Copper             

# There is also a method for data frames preserving all columns
input <- data.frame(x = 1:3, srppp = srppp_pk)
translate_substances(input, from = "srppp")
#>   x srppp               derappp
#> 1 1     3 1-Naphthylacetic acid
#> 2 2  1245        Terbuthylazine
#> 3 3   323            Pyrethrins
input_de <- data.frame(x = 1:3, substance_de = srppp_names)
translate_substances(input_de, from = "substance_de")
#>   x          substance_de                                srppp
#> 1 1 1-Naphthylacetic acid 6F14D297-81BA-4AA0-9636-D65F2F1A0BD6
#> 2 2        Terbuthylazine 736564C2-CA47-4979-AC4A-917F2B97B61A
#> 3 3            Pyrethrine 7639690D-56F7-455F-9CFB-33D3C620FE91
#>                 derappp
#> 1 1-Naphthylacetic acid
#> 2        Terbuthylazine
#> 3            Pyrethrins

# We can also translate back and get multiple matches for some names
translate_substances(translation$derappp, to = "srppp")
#> # A tibble: 6 × 2
#>   derappp               srppp                               
#>   <chr>                 <chr>                               
#> 1 1-Naphthylacetic acid 3                                   
#> 2 1-Naphthylacetic acid 6F14D297-81BA-4AA0-9636-D65F2F1A0BD6
#> 3 Terbuthylazine        1245                                
#> 4 Terbuthylazine        736564C2-CA47-4979-AC4A-917F2B97B61A
#> 5 Pyrethrins            323                                 
#> 6 Pyrethrins            7639690D-56F7-455F-9CFB-33D3C620FE91

# Or translate to another namespaces
translate_substances(srppp_pk, from = "srppp", to = "NABO_SQ")
#> Warning: Translation was incomplete for 3, 323
#> # A tibble: 3 × 3
#>   srppp derappp               NABO_SQ       
#>   <chr> <chr>                 <chr>         
#> 1 3     1-Naphthylacetic acid NA            
#> 2 1245  Terbuthylazine        Terbuthylazine
#> 3 323   Pyrethrins            NA            

# An example with NABO Status Quo substances
translate_substances(c("Chlorothalonil R417888", "S-Metolachlor"),
  from = "NABO_SQ")
#> # A tibble: 2 × 2
#>   NABO_SQ                derappp      
#>   <chr>                  <chr>        
#> 1 Chlorothalonil R417888 R417888      
#> 2 S-Metolachlor          S-Metolachlor

# If we translate to a namespace that does not have a mapping for the
# substance, we get NA
translate_substances(c("Chlorothalonil R417888", "S-Metolachlor", "Diazinone"),
  from = "NABO_SQ", to = "srppp")
#> Warning: Translation was incomplete for Chlorothalonil R417888, Diazinone
#> # A tibble: 3 × 3
#>   NABO_SQ                derappp       srppp
#>   <chr>                  <chr>         <chr>
#> 1 Chlorothalonil R417888 R417888       NA   
#> 2 S-Metolachlor          S-Metolachlor 1349 
#> 3 Diazinone              NA            NA   

# We only find exact matches (room for a future extension)
translate_substances(c("S-Metolachlor", "Glyphosat", "Glyphosate"),
  from = "derappp", to = "srppp")
#> Warning: Translation was incomplete for Glyphosat
#> # A tibble: 4 × 2
#>   derappp       srppp                               
#>   <chr>         <chr>                               
#> 1 S-Metolachlor 1349                                
#> 2 Glyphosat     NA                                  
#> 3 Glyphosate    199                                 
#> 4 Glyphosate    7B9F385E-0CFF-48B1-B32A-F7618D2A25D0
```
