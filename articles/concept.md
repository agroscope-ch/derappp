# Concept for the data repository

The idea of this data repository is to have a commonly maintained source
of consolidated data to be used in the environmental risk assessments of
plant protection products, that is

- validated by internal (at Agroscope) or external peer review
- version controlled, with the possibility to do comparisons to other
  versions
- reproducible, in the sense that each data point can be tracked to a
  source that is
  - publicly available and/or
  - internally available at Agroscope

At the time of this writing (March 4 2026), all endpoints contained in
the `derappp` data object can be tracked to a publicly available source.

Technically, the data are part of the R package `derappp` and are
immediately available to the user after installing and loading the
package.

## Previous work

A number of Agroscope projects and external projects have collected data
with similar aims. In the following, some of those projects are briefly
sketched and their strengths and weaknesses are discussed.

### PIERIS

The Pesticide and Intermediates Ecotoxicological Risk Information System
(PIERIS) originally developed at Agroscope and currently used by the
Federal Office for the Environment (FOEN) and Agroscope in the context
of product registration contains a comprehensive database of information
necessary for the environmental risk assessment of products, active
substances and their metabolites.

It has grown over time and new features and data fields have been added
to keep up with regulatory requirements. Therefore, it could be an
excellent starting point for the calculation of environmental risk
indicators or risk potentials.

Strong points:

- Available data for all registered active substances should be
  sufficient to do risk assessments
- Data were carefully evaluated, as the data entered were directly
  relevant to regulatory risk assessments
- Unpublished data on products is included, which may not be publicly
  available elsewhere. The data on solo formulations would be of
  interest for the evaluation of potentials of the active substances
  contained.

Weak points:

- Contains unpublished data, so it needs to be clarified if it can be
  used and/or published i.e. in supporting information. These
  unpublished data do not include product compositions, as only the
  active substance content is given in PIERIS, which is already publicly
  available e.g. in the Swiss Register of Plant Protection Products.
  They do include data on products that have potentially not been
  published elsewhere.
- Data on active substances are not up to date with current EFSA
  conclusions in many cases. They usually reflect the current study
  situation on the date when these products were evaluated by experts.
- For many data types, there is only one endpoint per active substance,
  e.g. for vapour pressure or water solubility. In other cases, there
  are two (Koc) or more columns (DT50xxx) but they have not been
  consistently used, e.g. the Koc column often has the lowest Koc, but
  it can also be a mean, and the mean Koc column has obviously a mean,
  but sometimes it has the lowest Koc.
- For ecotoxicological endpoints, only the type of source is recorded
  (GLP study, literature reference, …). In about 10 000 of the 27 000
  cases an additional reference code is given in the table, but this
  information is really short, and the type of source is not obvious.
  Likely, in many cases it refers to unpublished regulatory reports. In
  some cases, references to EFSA conclusions are made in comments. So
  all in all, the source referencing is incomplete and not consistently
  formatted.
- There is no version control in the sense that changes from one time
  point to the next are not tracked.

### PPDB/BPDB

Agroscope has a subscription to the Pesticide Property Database (PPDB)
and Biopesticide Properties Database (BPDB) which includes the delivery
of the complete database in MS Access format, containing the data
[publicly available](http://sitem.herts.ac.uk/aeru/ppdb/en/index.htm).

Strong points:

- Data available also on older active ingredients that are not on the
  market any more.
- Environmental fate and ecotoxicology in water and soil are covered.
- The data is publicly accessible on the Internet. A licence can be
  purchased for the use of the data as a database.
- Versioning is possible by using the various MS Access versions of the
  PPDB database.
- The subscribed version has detailed data in different soil types and
  pH ranges for substances for soil absorption and soil degradation
  parameters

Weak points:

- Generally, either one value or a conservative value is given for each
  category. For example, if there are several acute fish toxicity
  values, only the lowest value is given.
- The source is only given in categories (e.g. data used in regulatory
  assessments). The exact source where a specific endpoint can be found
  is not given and it is not intended by the maintainers of that
  database to add that information.
- Data can be changed from version to version without notice, e.g. the
  soil DT50 of certain copper salts was changed from 100 000 days to 0.1
  days.
- Decisions on which data were included are not documented
- Copyright issues may prevent extracts of the PPDB database to be
  published in the supporting information of scientific publications.

### OpenFoodTox

Data source maintained on behalf of EFSA with a web interface and some
Excel sheets published on [Zenodo](https://zenodo.org/records/8120114).
An [R package](https://github.com/agroscope-ch/openfoodtox) is
maintained in the Agroscope github account to facilitate programmatic
access to the data. Among other content, there is a large table of
so-called reference points,

Strong points:

- Only data listed in EFSA outputs are included, generally indicating a
  high degree of reliability
- The source (i.e. the corresponding EFSA output) is always given
- Reasonable table definitions with clear structure and column labels
- Creative Commons Attribution licence allowing to republish the
  complete dataset if the source is accredited.

Weak points:

- No environmental fate data included
- For each reference point, only one endpoint is used, which is usually
  the lowest endpoint in its category. Therefore, no geometric mean
  endpoints or even species sensitivity distributions can be calculated
  from these data.
- Names of biological species are generally in English instead of using
  the scientific names
- The latest version is from 13 September 2023 and it is unclear if and
  when an update with recent EFSA conclusions will be made

### EcoTox

Database maintained by the US EPA. Contains over one million results on
more than 12 000 chemicals at the time of this writing (June 2024).

Strong points:

- Large amount of data, many endpoints for many species for each
  substance
- Publicly available in the form of ASCII text file
- Using the data has recently been simplified by the
  \[https://github.com/andschar/standartox\] project

Weak points:

- Only primary sources are included. As far as we have seen so far, this
  means that data reported in GLP studies as given in EFSA conclusions
  or EU Renewal Assessment Reports are not included.

## Technical concept

The repository structure is that of an R package. Therefore, it is
sufficient to install the package to be able to work with the latest
version of the data.

The central data object for collection of reviewed, version controlled
and fully referenced data is the `derappp` object. It contains several
tables of data with primary keys and foreign keys, making it possible to
ensure referential integrity within the database.

### Peer review

The coordination of peer review currently takes place via e-mail
exchange among the contributors. In the future, it can make use of
issues in a code development system.

### Version control

Reviewing differences between versions is made possible by exporting the
content of each table in the JSON format which is readable for humans.
These JSON files are checked into the git version control system. Using
git and the associated tools to show differences between text files, the
versions can transparently be compared.

### Source referencing

Each endpoint has a reference to a source in the sources table. Chemical
identity information was collected using the packages ‘webchem’ ([Szöcs
et al. 2020](#ref-szocs2020webchem)) and ‘chents’ ([Ranke
2026](#ref-ranke2026chents)) from the Compendium of Pesticide Common
Names ([British Crop Protection Council 2024](#ref-BCPC_Compendium)),
the PubChem website ([National Center for Biotechnology Information
2024](#ref-PubChem)), the CAS Common Chemistry website ([CAS Division of
the American Chemical Society 2024](#ref-CAS_Common_Chemistry)) and the
envipath website ([enviPath UG & Co KG 2024](#ref-envipath)).

The preferred source of information are EFSA conclusions, e.g. EFSA
([2006](#ref-j.efsa.2006.51r)), respectively the Listings of Endpoints
(LoEP) that are published as Appendix to such EFSA conclusions, e.g.
EFSA ([2016](#ref-j.efsa.2016.4610_LoEP)). For the soil toxicity data,
the (draft) Renewal Assessment Reports were frequently consulted in
addition, as some details that we consider important are often lacking
in the LoEP published by EFSA.

## References

British Crop Protection Council. 2024. ‘Compendium of Pesticide Common
Names’. <http://www.bcpcpesticidecompendium.org/>.

CAS Division of the American Chemical Society. 2024. ‘CAS Common
Chemistry’. <https://commonchemistry.cas.org>.

EFSA. 2006. *Conclusion Regarding the Peer Review of the Pesticide Risk
Assessment of the Active Substance Cyprodinil*. EFSA conclusion.
European Food Safety Authority.
<https://doi.org/doi:10.2903/j.efsa.2006.51r>.

EFSA. 2016. *Appendix to: Peer Review of the Pesticide Risk Assessment
of the Active Substance Acetamiprid*. EFSA conclusion. European Food
Safety Authority. <https://doi.org/doi:10.2903/j.efsa.2016.4610>.

enviPath UG & Co KG. 2024. ‘Envipath: The Environmental Contaminant
Biotransformation Pathway Resource’. <https://envipath.org>.

National Center for Biotechnology Information. 2024. ‘PubChem’.
<https://pubchem.ncbi.nlm.nih.gov/>.

Ranke, Johannes. 2026. *Chents: Chemical Entities as r Objects*.
<https://pkgdown.jrwb.de/chents/>.

Szöcs, Eduard, Tamás Stirling, Eric R. Scott, Andreas Scharmüller, and
Ralf B. Schäfer. 2020. ‘webchem: An R Package to Retrieve Chemical
Information from the Web’. *Journal of Statistical Software* 93 (13):
1–17. <https://doi.org/10.18637/jss.v093.i13>.
