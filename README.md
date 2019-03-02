# `BCB420-2019 Resources`

&nbsp;

###### [Boris Steipe](https://orcid.org/0000-0002-1134-6758),
###### Department of Biochemistry and Department of Molecular Genetics,
###### University of Toronto
###### Canada
###### &lt;boris.steipe@utoronto.ca&gt;

----

This repository contains course material for the 2019 course in Computational Systems Biology at the University of Toronto. It is unlikely to be useful to anyone not actively participating in the course.

----

### Utilities

`source()` these files to use the functions.

* `toBrowser.R`: Render a markdown file to html in `tempdir()` and display it in the user's default browser.

&nbsp;

### Data resources, templates and scripts

&nbsp;

* `HGNC.RData`: reference symbols and identifiers for human genes from the Human Gene Nomenclature Committee.
* `HGNCdata.R`: The script that produced `HGNC.RData` (for reference)
* `dataModel.md`: Introduction to the systemDB database schema. Type ```toBrowser("dataModel.md")``` to study it.
* `dataSources.md`: Overview of data sources for the data project. Type ```toBrowser("dataSources.md")``` to access the document.
* `exampleGeneSet.md`: background to a set of genes associated with the phagosome-lysosome fusion system. This forms our example set for data annotation as a basis to develop data integration workflows.  Type ```toBrowser("exampleGeneSet.md")``` to study it.

&nbsp;

* `PHALY_facts.txt`: a sample file of facts from the PHALY system, in a structured text format.
* `text2tsv.R`: an R script to parse a file of structured-text system facts and write tsv text to console that is suitable to be copy/pasted into an Excel spreadsheet for preparation of the systems database.
* `BCB420-2019-System-XXXXX-0.0.xlsx`: an Excel spreadsheet template with a sheets to hold a system table, a system components table, and a components table.
* `BCB420-2019-System-PHALY-0.1.xlsx`: an Excel spreadsheet example, filled with data from the PHALY system.


<!-- END -->
