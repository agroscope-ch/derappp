# List of chemical entities with additional information

List of chemical entities with additional information

## Usage

``` r
derappp_chents

# S3 method for class 'derappp_chents'
print(x, n = 3, ...)
```

## Format

A list of
[chents::chent](https://pkgdown.jrwb.de/chents/reference/chent.html)
objects, with class `derappp_chents`

## Arguments

- x:

  A list of
  [chents::chent](https://pkgdown.jrwb.de/chents/reference/chent.html)
  objects, with class `derappp_chents`

- n:

  Number of entries to show

- ...:

  For compatibility with the generic

## Examples

``` r
# The chemical entities are stored as a list of chent objects, so we can
# access them by name
derappp_chents$Cyprodinil
#> <pai> with ISO common name $iso Cyprodinil 
#> <chent>
#> Identifier $identifier Cyprodinil 
#> InChI Key $inchikey HAORKNGNJCEJBX-UHFFFAOYSA-N 
#> SMILES string $smiles:
#>                             PubChem 
#> "CC1=CC(=NC(=N1)NC2=CC=CC=C2)C3CC3" 
#> Molecular weight $mw: 225.3 
#> PubChem synonyms (up to 10):
#>  [1] "Cyprodinil"                                        
#>  [2] "121552-61-2"                                       
#>  [3] "4-Cyclopropyl-6-methyl-N-phenylpyrimidin-2-amine"  
#>  [4] "Unix"                                              
#>  [5] "4-Cyclopropyl-6-methyl-N-phenyl-2-pyrimidinamine"  
#>  [6] "2-Pyrimidinamine, 4-cyclopropyl-6-methyl-N-phenyl-"
#>  [7] "HSDB 7019"                                         
#>  [8] "Chorus"                                            
#>  [9] "DTXSID1032359"                                     
#> [10] "42P6T6OFWZ"                                        

derappp_chents$Myclobutanil
#> <pai> with ISO common name $iso Myclobutanil 
#> <chent>
#> Identifier $identifier Myclobutanil 
#> InChI Key $inchikey HZJKXKUJVSEEFU-UHFFFAOYSA-N 
#> SMILES string $smiles:
#>                                 PubChem 
#> "CCCCC(CN1C=NC=N1)(C#N)C2=CC=C(C=C2)Cl" 
#> Molecular weight $mw: 288.8 
#> PubChem synonyms (up to 10):
#>  [1] "MYCLOBUTANIL"      "88671-89-0"        "Systhane"         
#>  [4] "Rally"             "Nova"              "Synthane 12E"     
#>  [7] "Nova (pesticide)"  "Systhane 6 Flo"    "Nova W"           
#> [10] "(+-)-Myclobutanil"

# The IUPAC name and source URL retrieved from the British Crop Protection
# Council (BCPC) are stored as fields in the
# `bcpc` element of the object, so we can easily access them
derappp_chents$Captan$bcpc[c("iupac_name", "source_url")]
#> $iupac_name
#> [1] "N-[(trichloromethyl)thio]-3a,4,7,7a-tetrahydrophthalimide1979 Rules:3a,4,7,7a-tetrahydro-N-[(trichloromethyl)thio]phthalimide"
#> 
#> $source_url
#> [1] "https://pesticidecompendium.bcpc.org/captan.html"
#> 

# The PubChem information is stored as a list, so we can check which fields are available
names(derappp_chents$Captan$pubchem)
#>  [1] "CID"                "MolecularFormula"   "MolecularWeight"   
#>  [4] "SMILES"             "ConnectivitySMILES" "InChI"             
#>  [7] "InChIKey"           "IUPACName"          "XLogP"             
#> [10] "TPSA"               "Complexity"         "Charge"            
#> [13] "HBondDonorCount"    "HBondAcceptorCount" "synonyms"          

# For example, we can check the molecular formula
derappp_chents$Captan$pubchem$MolecularFormula
#> [1] "C9H8Cl3NO2S"

# We also have a print method for the complete object showing the first few
# items
print(derappp_chents, n = 2)
#> <derappp_chents>
#> A list of  358 <chent> objects
#> Showing the first  2  entries:
#> 
#> <pai> without ISO common name
#> <chent>
#> Identifier $identifier 1-Decanol 
#> InChI Key $inchikey MWKFXSUHUHTGQN-UHFFFAOYSA-N 
#> SMILES string $smiles:
#>       PubChem 
#> "CCCCCCCCCCO" 
#> Molecular weight $mw: 158.3 
#> PubChem synonyms (up to 10):
#>  [1] "1-DECANOL"       "Decan-1-ol"      "Decyl alcohol"   "112-30-1"       
#>  [5] "n-Decyl alcohol" "n-Decanol"       "Capric alcohol"  "Nonylcarbinol"  
#>  [9] "Antak"           "Royaltac"       
#> 
#> <pai> with ISO common name $iso 1-Methylcyclopropene 
#> <chent>
#> Identifier $identifier 1-Methylcyclopropene 
#> InChI Key $inchikey SHDPRTQPPWIEJG-UHFFFAOYSA-N 
#> SMILES string $smiles:
#>   PubChem 
#> "CC1=CC1" 
#> Molecular weight $mw: 54.1 
#> PubChem synonyms (up to 10):
#>  [1] "1-Methylcyclopropene"    "3100-04-7"              
#>  [3] "SmartFresh"              "EthylBloc"              
#>  [5] "1-MCP"                   "Cyclopropene, 1-methyl-"
#>  [7] "J6UJO23JGU"              "INVINSA"                
#>  [9] "DTXSID2035643"           "CHEBI:132592"           
#> 
```
