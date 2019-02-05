# `system seeds`

&nbsp;

###### [Boris Steipe](https://orcid.org/0000-0002-1134-6758),
###### Department of Biochemistry and Department of Molecular Genetics,
###### University of Toronto
###### Canada
###### &lt;boris.steipe@utoronto.ca>

----

Defining "systems" from the Gene Ontology graph and seeding them with annotated genes.

----

## 1 About this document

This document describes the workflow to download Gene Ontology terms and Gene Ontology annotations, to parse these files, to filter annotated terms, and to output the results into a table. The procedures are quite general, the specific requirements we implement here are:

1. select GO terms for which between four and seven HGNC symbols have been annotated to the term or its descendants;
2. filter the terms by restrictions on the name, such as "proliferation", "development", or "morphogenesis", to remove processes that are only very broadly defined;
3. output term ID, annotated genes, name and definition to an html table, include links to the GO term and its annotated genes.

&nbsp;

## 2 GO and GOA Data

The [Gene Ontology (GO) Consortium](http://www.geneontology.org/) defines concepts (terms) that describe gene function, and the relationships between these concepts. GO terms are defined by curators. All [GO data is available](http://geneontology.org/page/use-and-license) under a [CC-BY 4.0 license](https://creativecommons.org/licenses/by/4.0/legalcode).

**The Gene Ontology (GO)** is distributed as a file of terms in [`.obo` format](http://owlcollab.github.io/oboformat/doc/GO.format.obo-1_2.html).This document describes work with [the 2019-01-24 point release of `go-basic.obo` ](http://www.geneontology.org/page/download-ontology). According to GO: "`go-basic.obo` [...] is the basic version of the GO filtered such that the graph is guaranteed to be acyclic, and annotations can be propagated up the graph. The relations included are is_a, part_of, regulates, negatively_regulates and positively_regulates. This version excludes relationships that cross the 3 main GO hierarchies. This is the version that should be used with most GO-based annotation tools." [(GO 2019)](http://www.geneontology.org/page/download-ontology).

**Gene Ontology Annotation (GOA)** files are submitted by GO Consortium members. `goa_human.gaf` is produced by the European Bioinformatics Institute. GOA are available  under a custom license that permits [copying and redistribution with attribution](http://geneontology.org/gene-associations/readme/goa_human.README).

This document describes work with [the 2019-01-14 point release of `goa_human.gaf`](http://geneontology.org/gene-associations/readme/goa_human.README).

&nbsp;

#### 2.1 Data semantics

##### 2.1.1 GO

The file `go-basic.obo` contains the actual ontology terms and definitions for a subset in the [Open Biology Ontology (OBO) format, version 1.2](http://owlcollab.github.io/oboformat/doc/GO.format.obo-1_2.html). This is a flat-file format designed to be human readable, extensible and minimally redundant. A document contains a header with metadata, and a series of "stanzas". Blank lines are ignored, as well as lines preceded with a `!` (comment lines).

Here is an example:

```text

[Term]
id: GO:0000001
name: mitochondrion inheritance
namespace: biological_process
def: "The distribution of mitochondria, including the mitochondrial genome, into daughter cells after mitosis or meiosis, mediated by interactions between mitochondria and the cytoskeleton." [GOC:mcc, PMID:10873824, PMID:11389764]
synonym: "mitochondrial inheritance" EXACT []
is_a: GO:0048308 ! organelle inheritance
is_a: GO:0048311 ! mitochondrion distribution

[Term]
id: GO:0000002
name: mitochondrial genome maintenance
namespace: biological_process
def: "The maintenance of the structure and integrity of the mitochondrial genome; includes replication and segregation of the mitochondrial chromosome." [GOC:ai, GOC:vw]
is_a: GO:0007005 ! mitochondrion organization

```

Note the `is_a` relationship that points to the parent term, `GO:0007005`, of which `GO:0000002` is a specialization. This means: the terms have parent-associations listed with them, but do not list child terms explicitly. Child terms are however implied by the parent-association.

Here is a list of keys encountered in `go-basic.obo`, the values we need for our objective are further defined below:

```text`
In header block only:
   "format-version:"
   "data-version:"
   "subsetdef:"
   "synonymtypedef:"
   "default-namespace:"
   "remark:"
   "ontology:"

In Term stanza:
   "id:"                 <<< Unique ID.
   "name:"               <<< Term name. Only one name per term allowed.
   "namespace:"          <<< One of: biological_process,
                         <<<         molecular_function,
                         <<<         cellular_component
   "alt_id:"
   "def:"                <<< definition in quoted text
   "synonym:"
   "comment:"
   "subset:"
   "xref:"
   "holds_over_chain:"
   "relationship:"
   "is_obsolete:"        <<< obsolete terms must have no "is_a" relationship
   "replaced_by:"
   "consider:"
   "is_a:"               <<< subclassing relationship: value is a GO term ID

In Typedef stanza only:
   "is_metadata_tag:"
   "is_class_level:"
   "transitive_over:"
   "is_transitive:"
```
For further details, see [here](http://owlcollab.github.io/oboformat/doc/GO.format.obo-1_2.html).

&nbsp;

##### 2.1.2 GOA

The file `goa-human.gaf` contains the gene-to-term annotations in the [GO Annotation File (GAF) Format 2.1](http://www.geneontology.org/page/go-annotation-file-gaf-format-21). A document contains a single line header `!gaf-version: 2.1`, and a series of annotations, one per line. Lines preceded with a `!` (comment lines) are ignored.

This is a tab-delimited file with 17 columns. Some fields have a cardinality > 1, the values in these fields are separated by a pipe character "|" implying OR, or a comma "," implying AND.

For the purpose of our requirements, we use only the following fields:

```text
Column: Content:
     1  DB The database that issued the ID in column 2, eg: "UniProtKB"
     2  DB Object ID - UniProt ID may be used for mapping to symbols
     3  DB Object symbol (HGNC symbol)
     5  GO ID
     7  Evidence code
    13  Taxon ID: must be "taxon:9606"
```

Evidence codes are crucial to the annotation process, they are detailed [here](http://www.geneontology.org/page/guide-go-evidence-codes).

&nbsp;

#### Preparations: packages, functions, files

To begin, we need to make sure the required packages are installed:

**`readr`** provides functions to read data which are particularly suitable for
large datasets. They are much faster than the built-in read.csv() etc. But caution: these functions return "tibbles", not data frames. ([Know the difference](https://cran.r-project.org/web/packages/tibble/vignettes/tibble.html).)
```R
if (! requireNamespace("readr")) {
  install.packages("readr")
}
```

**`stringr`** is a vectorized wrapper around `stringi` functions for string processing. I use  `stringr::str_match_all()` for parsing.
```R
if (! requireNamespace("stringr")) {
  install.packages("stringr")
}
```

Some of the data sets we process are quite large. A progress bar tells us
how we are progressing ...
```R
pBar <- function(i, l, nCh = 50) {
  # Draw a progress bar in the console
  # i: the current iteration
  # l: the total number of iterations
  # nCh: width of the progress bar
  ticks <- round(seq(1, l-1, length.out = nCh))
  if (i < l) {
    if (any(i == ticks)) {
      p <- which(i == ticks)[1]  # use only first, in case there are ties
      p1 <- paste(rep("#", p), collapse = "")
      p2 <- paste(rep("-", nCh - p), collapse = "")
      cat(sprintf("\r|%s%s|", p1, p2))
      flush.console()
    }
  }
  else { # done
    cat("\n")
  }
}
```

## 3 Data download and cleanup

&nbsp;

#### 3.1 Parse GO

GO data is distributed from  [GO - the Gene Ontology Consortium](http://geneontology.org/page/download-ontology). The page contains a link to the data, `<ctrl>-click` on the link to save-link-as ... in a sister directory to the current working directory called `data` then read and process the Gene Ontology:

```R
tmp <- readLines(file.path("..", "data", "go-basic.obo"))  # 544,524 lines

# remove empty lines
tmp <- tmp[ ! grepl("^$", tmp)]  # 497,171 lines, 47,353 removed
# remove comment lines
tmp <- tmp[ ! grepl("^!", tmp)]  # 497,171 lines, none removed

# following the convention of .gaf files, we replace the long namespace
# names with a single character
sel <- grepl("^namespace: biological_process", tmp)
tmp[sel] <- gsub("biological_process", "P", tmp[sel])

sel <- grepl("^namespace: molecular_function", tmp)
tmp[sel] <- gsub("molecular_function", "F", tmp[sel])

sel <- grepl("^namespace: cellular_component", tmp)
tmp[sel] <- gsub("cellular_component", "C", tmp[sel])

rm(sel)

# how many types of stanzas?
unique(tmp[grep("^\\[.*\\]$", tmp)])  # look for lines formatted as "[...]"
# [1] "[Term]"    "[Typedef]"

# How are these arranged in the file? Subset them
stanzaTypes <- tmp[grep("^\\[.*\\]$", tmp)]
rle(stanzaTypes)
#  Run Length Encoding
#    lengths: int [1:2] 47347 5
#    values : chr [1:2] "[Term]" "[Typedef]"
rm(stanzaTypes)
```

We have 47,347 "[Term]"s, followed by five "[Typedef]"s. We can thus construct an index vector of all "[Term]"s, and the first "[Typedef]". A Term stanza then runs from an index, to the next-index-minus-one.

```R
iTerms <- c(grep("^\\[Term]$", tmp), grep("^\\[Typedef]$", tmp)[1])

# validate
length(iTerms)
# [1] 47348  ... is 47,347 plus 1

# first term
tmp[(iTerms[1]):(iTerms[2] - 1)]

# last term
tmp[(iTerms[length(iTerms) - 1]):(iTerms[length(iTerms)] - 1)]

```

GO is a graph. To store the graph data, we need two tables: one table
to contain the nodes, one table to hold the edges:

How many terms?

```R
nTerms <- length(grep("^\\[Term]$", tmp)) - length(grep("^is_obsolete:", tmp))
```

How many edges? Fortunately, obsolete terms to not contain `is_a:` relationships. Thus we can assume that the number of edges is the same as the number of `is_a:` relationships in the data. (We ignore other relationships like "relationship: part_of")

```R
nEdges <- length(grep("^is_a:", tmp))
```
Two data frames will hold our data: GOterms contains the term data, GOedges contains the relationships.

```R
GOterms <- data.frame(id =   character(nTerms),
                      name = character(nTerms),
                      ns =   character(nTerms),
                      def =  character(nTerms),
                      stringsAsFactors = FALSE)

GOedges <- data.frame(parent = character(nEdges),
                      child  = character(nEdges),
                      stringsAsFactors = FALSE)
```
Process the data. We extract the text from `tmp`, collapse the lines into a single string, parse the data we need, and insert it into GOterms and GOedges. It is convenient to use a function:

```R
prsT <- function(patt, string) {
  # parse matches to "patt" from "string"
  return(stringr::str_match_all(string, patt)[[1]][ ,2])
}
```

We don't know in advance whether a term is obsolete or not. And we don't know how many `is_a` relations it has. But we don't want to grow the result data frame dynamically because that's slow. So we insert data into the data frames with two counters that we increment:

```R
iT <- 1  # Counter for terms
iE <- 1  # Counter for edges

N <- length(iTerms) - 1 # number of terms to process

cat(sprintf("\nprocessing %d terms:\n", N))
for (i in 1:N) {

  pBar(i, N)           # update progress bar

  thisT <- paste(tmp[(iTerms[i] + 1):(iTerms[i+1] - 1)], collapse = "|")

  if ( ! grepl("is_obsolete: true", thisT)) {

    id   <- prsT("^id: (GO:\\d+)\\|", thisT)
    name <- prsT("\\|name: (.+?)\\|", thisT)
    ns   <- prsT("\\|namespace: (.+?)\\|", thisT)
    def  <- prsT("\\|def: \"(.+?)\"", thisT)
    
    GOterms[iT, ] <- c(id, name, ns, def)

    m <- prsT("\\|is_a: (GO:\\d+) ", thisT)  # find all is_a relations
    if (length(m) > 0) {
      for (i in seq_along(m)) {
        GOedges[iE, ] <- c(m[i], GOterms$id[iT])
        iE <- iE + 1
      }
    } else {  # the root term has no is_a: relation
      GOedges[iE, ] <- c( paste0(GOterms$ns[iT], "_root"), GOterms$id[iT])
      iE <- iE + 1
    }
    iT <- iT + 1
  }
}

rownames(GOterms) <- GOterms$id
```

Validate: we should have three root terms and no empty IDs anywhere:

```R
(x <- GOedges[grep("root", GOedges$parent), ])
GOterms[x$child, "name"]

sum(GOterms$id == "")
sum(GOedges$parent == "")
sum(GOedges$child == "")

# cleanup the workspace
rm(def, i, iE, iT, iTerms, m, N, name, nEdges, ns, nTerms, thisT)

```

#### 3.2 Parse GOA

Download the most recent version of `goa_human.gaf` from the [GOA repository at the EBI](ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/HUMAN/), released 2019-01-14. This text-file (6.4 Mb compressed, 79.4 Mb uncompressed) contains gene names and GO terms:

```R
tmp <- readr::read_tsv(file.path("..", "data","goa_human.gaf"),
                  comment = "!",
                  col_types = "ccc-c-c-c---c----",
                  col_names = c("DB",                     # Database
                                "DB_Object_ID",           # UniProtID
                                "Symbol",                 # Gene symbol
                                #"Qualifier",              # -
                                "GO_ID",                  # GO ID
                                #"DB_Reference",           # -
                                "Evidence_Code",          # Evidence code
                                #"With_(or)_From",         # -
                                "Aspect",                 # GO Ontology
                                #"DB_Object_Name",         # -
                                #"DB_Object_Synonym",      # -
                                #"DB_Object_Type",         # -
                                "Taxon"                  # Tax ID
                                #"Date",                   # -
                                #"Assigned_By",            # -
                                #"Annotation_Extension",   # -
                                #"Gene_Product_Form_ID"    # -
                  ))  # 475,402 rows

sum(tmp$Taxon == "taxon:9606") # 474,865 ???
tmp[head(which(tmp$Taxon != "taxon:9606")), ]
#  DB        DB_Object_ID Symbol   GO_ID      Evidence_Code Aspect Taxon
#  <chr>     <chr>        <chr>    <chr>      <chr>         <chr>  <chr>
#  1 UniProtKB A1A4Y4   IRGM     GO:0042742 IMP    P   taxon:9606|taxon:33892
#  2 UniProtKB A1A4Y4   IRGM     GO:0075044 IMP    P   taxon:9606|taxon:33892
#  3 UniProtKB A1A4Y4   IRGM     GO:0075044 IMP    P   taxon:9606|taxon:11103
#  4 UniProtKB A1A4Y4   IRGM     GO:0098586 IMP    P   taxon:9606|taxon:11103
#  5 UniProtKB A6NMB1   SIGLEC16 GO:0098740 IDA    P   taxon:9606|taxon:1392869
#  6 UniProtKB O00182   LGALS9   GO:0098586 IMP    P   taxon:9606|taxon:11052

# Checking the UniProt entries shows these to be bona fide human proteins.
```

###### Filtering annotations by evidence codes

We don't consider all types of evidence good enough support for a gene's membership in a system. In particular, let's exclude [evidence derived from purely computational annotation](http://www.geneontology.org/page/guide-go-evidence-codes), without curatorial review, and evidence from high-throughput experiments. That does not mean we exclude this particular GO annotation outright - it may still be present as a curated, high-confidence annotation. But if high-throughput is all we have, then the annotation should not be included.


```R
# Which evidence codes are present?

sort(table(tmp$Evidence_Code), decreasing = TRUE)

#    TAS    IPI    IEA    IDA    IBA    ISS    IMP    HDA    NAS     ND
# 104552  93910  77926  74302  52376  24019  21533   9353   8137   1803
#    IGI    ISA     IC    IEP    ISM    EXP    RCA    HMP    HEP    IKR    ISO
#   1675   1449   1402    901    769    604    470    130     70     14      7

# To subset evidence codes that are based on curatorial assessment, we
# exclude annotations for:
# ---  High throughput experiments
# HTP: (High Throughput Experiment)
# HDA: (High Throughput Direct Assay)
# HMP: (High Throughput Mutant Phenotype)
# HGI: (High Throughput Genetic Interaction)
# HEP: (High Throughput Expression Pattern)
# --- Computational Annotation with no- or minimal curatorial input
# IEA: (Electronic annotation)
# ISS: (Sequence or structural Similarity)
# ISO: (Sequence Orthology)
# ISA: (Sequence Alignment)
# ISM: (Sequence Model)
# IGC: (Genomic Context)
# IBA: (Biological aspect of Ancestor)
# IBD: (Biological aspect of Descendant)
# IKR: (Key Residues)
# IRD: (Rapid Divergence)
# --- Lack of evidence
# NAS: (Non traceable author statement)
# ND : (No biological data available)

excludeEvidence = c("HTP", "HDA", "HMP", "HGI", "HEP", "IEA", "ISS",
                    "ISO", "ISA", "ISM", "IGC", "IBA", "IBD", "IKR",
                    "IRD", "NAS", "ND")

tmp <- tmp[ ! (tmp$Evidence_Code %in% excludeEvidence), ]  # 299,349 rows

```

###### Removing duplicates
At this point we have decent evidence for a GO annotation, and any evidence is good enough. We can remove annotations that have the same objectID, symbol, and GO ID. We create an extra column that combines these three values in a key, and then we remove duplicates.

```R
tmp$key <- sprintf("%s|%s|%s",
                   tmp$DB_Object_ID,
                   tmp$Symbol,
                   tmp$GO_ID)
tmp <- tmp[! duplicated(tmp$key), ]  # 134,867 annotations left
```
###### Removing outdated HGNC symbols
Next we need to ensure that the HGNC symbols for our annotations are current, and attempt to recover ones that are not. We read the reference HGNC dataset from GitHub. We then identify symbols that do not appear in `HGNC$symbol`. For these not-current symbols, we retrieve the UniProt IDs and for any that match current symbols we replace the old symbol with the current one.

```R
myURL <- paste0("https://github.com/hyginn/",
                "BCB420-2019-resources/blob/master/HGNC.RData?raw=true")
load(url(myURL))  # loads HGNC data frame

GOAsym <- unique(tmp$Symbol)
unkGOAsym <- GOAsym[ ! (GOAsym %in% HGNC$sym)]
x <- tmp[tmp$Symbol %in% unkGOAsym, c("DB_Object_ID", "Symbol")]

x <- HGNC[HGNC$UniProtID %in% unkUniID, c("sym", "UniProtID")]
x$key <- sprintf("%s|%s", x$DB_Object_ID, x$Symbol)
x <- x[! duplicated(x$key), c("DB_Object_ID", "Symbol")]
x <- x[! duplicated(x$DB_Object_ID), ]

x2 <- HGNC[HGNC$UniProtID %in% x$DB_Object_ID, c("UniProtID", "sym")]
x2 <- x2[! duplicated(x2$UniProtID), ]
colnames(x) <- c("UniProtID", "Symbol")

x3 <- merge(x, x2)

for (i in seq_len(nrow(x3))) {
  tmp$Symbol[tmp$Symbol == x3$Symbol[i]] <- x3$sym[i]
}

# Validate
GOAsym <- unique(tmp$Symbol)
unkGOAsym <- GOAsym[ ! (GOAsym %in% HGNC$sym)] # now only 131 unknown
# Remove the unknown, save only the annotations

GOA <- tmp[ (tmp$Symbol %in% HGNC$sym), c("Symbol", "GO_ID")]  # 134,491

GOA$key <- sprintf("%s|%s", GOA$Symbol, GOA$GO_ID)
GOA <- GOA[! duplicated(GOA$key), c("Symbol", "GO_ID")]  # 134,486 annotations

# cleanup the workspace
rm(x, x2, x3, tmp, excludeEvidence, GOAsym, i, id, myURL, unkGOAsym)
```

Next, we identify terms that have between 4 and 7 genes annotated to them and their descendants. The problem to solve here is that GO is a DAG. This means, if we propagate terms up towards the root from leaf-nodes, we might double count terms since a parent node could be reached via more than one path. We build a data structure in which each node is an element in a list, and which contains a vector of all genes that are annotated to it.

```R
GOgenes <- list()

# Compile cumulative gene lists for GO Terms
N <- nrow(GOA)
for (i in 1:N) {                               # for each annotation
  pBar(i, N)
  thisID <- GOA$GO_ID[i]                       # fetch term ...
  thisGene <- GOA$Symbol[i]                    # ... and gene
  if (length(GOgenes[[thisID]]$genes) == 0) {  # this is a new term
    GOgenes[[thisID]]$genes <- thisGene        # initialize with the gene symbol
  } else {                                     # else add gene symbol to vector
    GOgenes[[thisID]]$genes <- c(GOgenes[[thisID]]$genes, thisGene)
  }
}

```

Propagating gene symbols up the DAG can be done in a variant of Dijkstra's algorithm. We need to find Terms that are leafs in the DAG. Then we propagate their gene symbols to their parents and remove the term from consideration. Initially, we label all GO terms as "active". We define: a leaf is a term that is active and has no active children. If we find a leaf, we propagate the symbols annotated to it to its parents and set the term itself to "inactive". We iterate this process until there are no active terms left. At that time, every term is associated with the symbols that were originally annotated to it, plus the symbols that were annoated to any of its descendant nodes.

```R
GOterms$active <- TRUE  # add a column to flag active nodes

nCycles <- 0  # always use a safety net in while() loops

while (sum(GOterms$active) > 0 && nCycles < 20) {
  nCycles <- nCycles + 1
  cat(sprintf("Cycle %d: %d active terms.\n",
              nCycles,
              sum(GOterms$active)))

  idsToProcess <- which(GOterms$active)
  for (i in 1:length(idsToProcess)) {
    pBar(i, length(idsToProcess))

    # Identify leafs: a leaf is a node that is active, and not parent to
    # other active node(s).
    thisTerm <- GOterms$id[idsToProcess[i]]

    # find all the node's active children
    children <- GOedges$child[GOedges$parent == thisTerm]
    sel <- which((GOterms$id %in% children) & GOterms$active)
    activeChildren <- GOterms$id[sel]

    if (length(activeChildren) == 0) { # thisTerm is a leaf:
                                       # propagate annotated genes to parents
                                       # (if any exist), then set the term to
                                       #"inactive":
      # find the parents of thisTerm
      theseParents <- GOedges$parent[GOedges$child == thisTerm]
      for (parent in theseParents) {
        if (! grepl("root", parent)) {
          GOgenes[[parent]]$genes  <- unique(c(GOgenes[[parent]]$genes,
                                               GOgenes[[thisTerm]]$genes))
        }
      }
      # unset the "active" flag for this node
      GOterms[thisTerm, "active"] <- FALSE
    }
  }
}

```

We can now compile filtered lists of GOgenes:

```R
nMin <- 5
nMax <- 7
myIDs <- character()
for (id in names(GOgenes)) {
  nGenes <- length(GOgenes[[id]]$genes)
  if (nGenes >= nMin & nGenes <= nMax) {
    myIDs <- c(myIDs, id)
  }
}

# exclude some IDs (that we previously have worked on)

exclude <- c(
"GO:0001302", "GO:0001660", "GO:0001845", "GO:0002018", "GO:0002023", 
"GO:0002034", "GO:0002051", "GO:0002188", "GO:0002291", "GO:0002457", 
"GO:0002667", "GO:0003010", "GO:0003097", "GO:0003402", "GO:0006287", 
"GO:0006360", "GO:0006850", "GO:0007195", "GO:0010446", "GO:0010982", 
"GO:0022410", "GO:0030035", "GO:0032202", "GO:0034471", "GO:0035087", 
"GO:0038110", "GO:0038123", "GO:0038124", "GO:0038183", "GO:0042092", 
"GO:0042494", "GO:0042631", "GO:0042699", "GO:0043276", "GO:0044331", 
"GO:0044691", "GO:0045007", "GO:0048143", "GO:0051208", "GO:0051594", 
"GO:0061577", "GO:0061589", "GO:0061734", "GO:0070254", "GO:0070627", 
"GO:0071727", "GO:0072318", "GO:0072402", "GO:0072584", "GO:0097680", 
"GO:0099054", "GO:0099074", "GO:1903365", "GO:1903677", "GO:2001273"
)
myIDs <- myIDs[ ! (myIDs %in% exclude)]

# exclude IDs with names containing stop-words
stopWords <- c("proliferation",
               "development",
               "morphogenesis",
               "regression",
               "induction",
               "maturation",
               "formation",
               "growth",
               "*bolic process",
               "biosynthetic process",
               "behavior",
               "positive regulation of",
               "negative regulation of",
               "binding")

myNames <- GOterms[myIDs, c("id", "name")]
for (stopWord in stopWords) {
  myNames <- myNames[ ! grepl(stopWord, myNames$name), ]
}

head(myNames, 15)

# write text to output

amiGO <- "[http://amigo.geneontology.org/amigo/term/" 
uniProt <- "[https://www.uniprot.org/uniprot/"

out <- "<table>"
for (i in seq_along(myNames$id)) {
  out <- c(out, sprintf("<tr class=\"s%d\">", (i %% 2) + 1))
  thisID <-   myNames[i, "id"]
  thisName <- myNames[i, "name"]
  thisOntology <- GOterms[thisID, "ns"]
  out <- c(out, "<td>\n====NN<!-- Replace \"NN\" with your name -->====\n</td>")
  out <- c(out, sprintf("<td>%s%s %s] (%s)<br/>%s</td>",
                        amiGO, thisID, thisID, thisOntology, thisName))
  out <- c(out, "<td>")
  for (mySym in GOgenes[[thisID]]$genes) {
    thisUniProtID <- HGNC[mySym, "UniProtID"]
    out <- c(out, sprintf("%s%s %s] ", uniProt, thisUniProtID, mySym))
  }
  out <- c(out, "</td>")
  out <- c(out, "</tr>")
  out <- c(out, "")
}
out <- c(out, "</table>")

writeLines(out, con = "table.txt")

```
This Wikitext table is suitable for adoption of systems by curators. Curators choose a system to work on and expand system membership from the seed-genes that are provided in the table.


<!-- [END] -->
