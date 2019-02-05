# `curation process`

&nbsp;

###### [Boris Steipe](https://orcid.org/0000-0002-1134-6758),
###### Department of Biochemistry and Department of Molecular Genetics,
###### University of Toronto
###### Canada
###### &lt;boris.steipe@utoronto.ca&gt;

----

Curation of a molecular system.

----

&nbsp;

### Requirements

----
**A [system](http://steipe.biochemistry.utoronto.ca/abc/assets/BIN-SYS-Concepts.pdf) maps a set of collaborating components to its emergent behaviour.**
----

"System" is a concept. In order to understand biology, we apply the concept to observables.

* We identify and annotate *components*,
* we collect evidence of their *collaboration*,
* we analyze the system's *behaviour*.

In this document we outline the curation workflow.

#### System and attributes

* Open the `BCB420-2019-resources` project in RStudio and **Pull** the most recent version of the repo from GitHub.
* Choose a system from [*the table*](http://steipe.biochemistry.utoronto.ca/abc/students/index.php/BCB420_2019_Biocuration_table). Caution: not all GO terms are suitable for system annotation. In general, terms in the (P) ontology are better suited, but there are exceptions.
* Give the system a name. This can be (but doesn't have to be) the associated GO term;
* Define a code tag for your system. This shall be a five-character initialism derived from the first two significant words of the name. The first three characters shall come from the first word and the last two characters from the second word. For example: the code for the "phagosome-lysosome fusion system" is `PHALY`.
* In RStudio, source `.Rprofile` to load the provided utility functions.
* Type `initSysXl()` to create a spreadsheet for your initial curation. The spreadsheet will be called `BCB420-2019-System-XXXXX-0.0.xlsx`.
* Rename the spreadsheet to replace `XXXXX` with your system code and set the version number to `0.1`.
* Open the spreadsheet, orient yourself, and add contents.
** Define the system. Write a concise definition.
** Describe the system's context. Under which circumstances is the system active? How is it important? Is it a subsystem of a larger system? Is its establishment contingent on specific tissue types? Or on stages of the cell cycle? What selective advantage does it confer that has shaped its membership and function?

&nbsp;

#### Literature

You will need a good, recent, expert review on your system to work with - unless you are summarizing a system for which you yourself have expert knowledge. Chose your system so that a good review is available.

&nbsp;

#### Components

All automated data annotation processes are TBD.

<!--

* Start from the seed genes that were annotated by GOA;
** add genes that are suggested by STRING. Use the STRINGneighbours tool. I suggest you start by adding genes that are linked to two or more seed genes with high-confidence edges. ...
** add genes that are pathway members. Use the Reactome tool;
** add genes that are coregulated/co-expressed. Use the GEO tool. ...
** add genes that are members of a physical complex. Use the Complex tool. ...
** add genes that are suggested in the literature. Search in PubMed. ...
* for each addition, of genes, state the evidence code and information source.

* annotate boundary ...
* annotate complement ...
-->
&nbsp;

#### Deliverables

TBD

&nbsp;




<!-- END -->
