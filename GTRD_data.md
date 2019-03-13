# `GTRD data`

#### (GTRD data annotatation of human genes)

&nbsp;

###### [Boris Steipe](https://orcid.org/0000-0002-1134-6758), Department of Biochemistry and Department of Molecular Genetics, University of Toronto, Canada. &lt;boris.steipe@utoronto.ca&gt;

----

**If any of this information is ambiguous, inaccurate, outdated, or incomplete, please check the [most recent version](https://github.com/hyginn/BCB420.2019.STRING) of the package on GitHub and if the problem has not already been addressed, please [file an issue](https://github.com/hyginn/BCB420.2019.STRING/issues).**

----

## 1 About this document:

This document describes the workflow to download transcription regulation data from [the GTRD database](http://gtrd.biouml.org/), and to annotate our reference data set of [HGNC](https://www.genenames.org/) symbols with transcription factors in each gene's upstream regulatory region.

## 2 GTRD Data

GTRD is a collection of uniformly processed ChIP-seq data built with a [BioUML pipeline](http://wiki.biouml.org/index.php/GTRD). See the preceding link for source and processing details. In brief: sequenced reads from GEO, SRA and ENCODE transcription-factor ChIP-seq experiments are aligned to the GRCh38 reference genome, peak calling is performed, and the location and identity of the inferred transcription factor binding site, as well as the supporting experiments are recorded. GTRD data is informally licensed for non-commercial use with attribution.

This document describes work with [GTRD version 18.06  (2018-09-19)](http://gtrd.biouml.org/downloads/18.06/README) published in [(Yevshin _et al._ 2019)](https://academic.oup.com/nar/article/47/D1/D100/5184717).

&nbsp;

#### 2.1 Data semantics

GTRD data is available at various levels of post-processing. For our purposes of gene annotation, we use the GTRD "meta-clusters" which combine different peak-calling methods, cell lines, and experiments. Yevshin _et al._ consider these to be " non-redundant TFBS sets" (2019).

The file  `Homo_sapiens_meta_clusters.interval` contains the following columns:

1.  `CHROM`: Chromososome ID
2.  `START`: Cluster start (chromosomal coordinates)
3.  `END`:  Cluster start (chromosomal coordinates)
4.  `summit`: Distance of peak from `START`
5.  `uniprotId`: ... of transcription factor
6.  `tfTitle`:  "name" of transcription factor. Probably the HGNC symbol but this needs to be confirmed.
7.  `cell.set`: Identification of input data
8.  `treatment.set`:  Identification of input data
9.  `exp.set`:  Identification of input data
10. `peak-caller.set`: Algorithms that detected this peak
11. `peak-caller.count`: Number of peak callers that detected the peak
12. `exp.count`: Number of experiments
13. `peak.count`: Number of unified peaks

Columns 7 to 13 could be used to compute a confidence score for the peak. 


&nbsp;

## 3 Data download and processing

For the purpose of gene annotation, the most suitable GTRD file is `Homo_sapiens_meta_clusters.interval`.

1. Navigate to the [download directory of the **GTRD** database](http://gtrd.biouml.org/downloads/18.06/).
2. Download the following data file: (Warning: *very* large).
* `Homo_sapiens_meta_clusters.interval` (725 Mb)	(human TF binding sites inferred from meta clusters);
3. Uncompress the file and place it into a sister directory of your working directory which is called `data`. (It should be reachable with `file.path("..", "data", "GTRD")`). **Warning:**  `../data/GTRD/Homo_sapiens_meta_clusters.interval` is 7.67 Gb!

It is possible to read the entire file at once (Yufei Yang, personal communication) using `readr::read_tsv()` but it is much preferred to use shell commands to deal with very large files if they can be usefully split into smaller units.

```bash
$ ls -l
-rw-r--r--+  1 steipe  staff  7665693202  3 Feb 19:52 Homo_sapiens_meta_clusters.interval

$ wc -l Homo_sapiens_meta_clusters.interval
42733386 Homo_sapiens_meta_clusters.interval

$ head Homo_sapiens_meta_clusters.interval 
#CHROM	START	END	summit	uniprotId	tfTitle	cell.set	treatment.set	exp.set	peak-caller.set	peak-caller.count	exp.count	peak.count
chr1	184412	184499	43	A0AVK6	E2F8	GM12878 (female B-cells);K562 (myelogenous leukemia)		EXP040251;EXP040299	GEM;MACS;PICS;SISSRS	4	2	4
chr1	775205	775292	43	A0AVK6	E2F8	GM12878 (female B-cells)		EXP040299	GEM;PICS	2	1	2
chr1	778688	778741	26	A0AVK6	E2F8	GM12878 (female B-cells);K562 (myelogenous leukemia);LoVo (colorectal adenocarcinoma);MCF7 (Invasive ductal breast carcinoma)		EXP030137;EXP040251;EXP040284;EXP040299	GEM;MACS;PICS;SISSRS	4	4	11
chr1	788816	788903	43	A0AVK6	E2F8	K562 (myelogenous leukemia);MCF7 (Invasive ductal breast carcinoma)		EXP040251;EXP040284	GEM;PICS	2	2	2
chr1	827399	827486	43	A0AVK6	E2F8	GM12878 (female B-cells);K562 (myelogenous leukemia)		EXP040251;EXP040299	GEM;MACS;PICS;SISSRS	4	2	6
chr1	959188	959275	43	A0AVK6	E2F8	GM12878 (female B-cells);K562 (myelogenous leukemia)		EXP040251;EXP040299	GEM;MACS;PICS;SISSRS	4	2	5
chr1	1000883	1000915	16	A0AVK6	E2F8	K562 (myelogenous leukemia);LoVo (colorectal adenocarcinoma)		EXP030137;EXP040251	GEM;MACS;PICS;SISSRS	4	2	6
chr1	1000923	1001010	43	A0AVK6	E2F8	GM12878 (female B-cells);MCF7 (Invasive ductal breast carcinoma)		EXP040284;EXP040299	GEM;PICS	2	2	3
chr1	1019193	1019280	43	A0AVK6	E2F8	GM12878 (female B-cells)		EXP040299	GEM;MACS;PICS	3	1	3

$ cat Homo_sapiens_meta_clusters.interval | cut -f 1 | sort -u

chr1
chr10
chr11
chr12
chr13
chr14
chr15
chr16
chr17
chr18
chr19
chr2
chr20
chr21
chr22
chr3
chr4
chr5
chr6
chr7
chr8
chr9
chrMT
chrX
chrY

```
(The last command took 6.5 minutes to process - which is quite fast, considering that 42 million records were sorted and collapsed to unique keys.)

&nbsp;

A quick look at the "tail" of the file shows that the data is organized per transcription factor and for each transcription factor according to chromosomal coordinates. This is not ideal for processing since we would like to consider only peaks that actually are found in genes' regulatory regions. Therefore we should split the file into chromosomes. This is done efficiently by creating system commands in R.

```R
GTRDpath <- file.path("..", "data", "GTRD")
inFile <- file.path(GTRDpath, "Homo_sapiens_meta_clusters.interval")

chr <- paste0("chr", c("MT", "X", "Y", 1:22))

start <- Sys.time()
for (myChr in chr) {
  outFile <- file.path(GTRDpath, paste0(myChr, ".tsv"))
  myCmd <- sprintf("grep \"^%s\\t\" %s > %s",
                    myChr,
                    inFile,
                    outFile)
  system(myCmd)
}
Sys.time() - start
# Time difference of 32.80713 mins

list.files("../data/GTRD/", pattern = "\\.tsv")
#  [1] "chr1.tsv"  "chr10.tsv" "chr11.tsv" "chr12.tsv" "chr13.tsv" "chr14.tsv" "chr15.tsv" "chr16.tsv"
#  [9] "chr17.tsv" "chr18.tsv" "chr19.tsv" "chr2.tsv"  "chr20.tsv" "chr21.tsv" "chr22.tsv" "chr3.tsv" 
# [17] "chr4.tsv"  "chr5.tsv"  "chr6.tsv"  "chr7.tsv"  "chr8.tsv"  "chr9.tsv"  "chrMT.tsv" "chrX.tsv" 
# [25] "chrY.tsv" 
```

We now have input data that is convenient for processing and will not overwhelm memory: the largest file, `chr1.tsv` is 725,689,944 bytes - i.e. only 10% of the original.

&nbsp;

#### Preparations: packages, functions, files

To begin processing, we need to make sure the required packages are installed:

**`readr`** provides functions to read data which are particularly suitable for
large datasets. They are much faster than the built-in read.csv() etc. But caution: these functions return "tibbles", not data frames. ([Know the difference](https://cran.r-project.org/web/packages/tibble/vignettes/tibble.html).)
```R
if (! requireNamespace("readr")) {
  install.packages("readr")
}
```

&nbsp;

**`biomaRt`** biomaRt is a Bioconductor package that implements the RESTful API of biomart, the annotation framwork for model organism genomes at the EBI. It is a Bioconductor package, and as such it needs to be loaded via the **`BiocManager`**.
```R
if (! requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
if (! requireNamespace("biomaRt", quietly = TRUE)) {
  BiocManager::install("biomaRt")
}
```

&nbsp;

Here is a useful utility function that returns the index of the "best" appris transcript from a vector of appris annotations:
```R
bestAppris <- function(s) {
  # return the index of the best appris transcript in s
  # if there is a tie, return the first.

  apprisLevels <- paste0("principal", 1:5)
  # protect NA
  s[is.na(s)] <- "NA"

  myLev <- ""
  for (i in seq_along(apprisLevels)) {
    if (sum(which(s == apprisLevels[i])) > 0) {
      myLev <- apprisLevels[i]
      break()
    }
  }
  return(which(s == myLev)[1])
}

```

&nbsp;

Finally, we fetch the HGNC reference data from GitHub. 
```R
myURL <- paste0("https://github.com/hyginn/",
                "BCB420-2019-resources/blob/master/HGNC.RData?raw=true")
load(url(myURL))  # loads HGNC data frame

```
&nbsp;


## 3 Defining gene regulatory regions

The regulatory region of a gene is commonly taken as the region 1 kb upstream of a transcription start. Our gene transcription starts can be retrieved via biomart.

&nbsp;

```R

# select symbols for genes whose regulation we are interested in
myGeneTypes <- c("protein", "immunoglobulin", "rRNA", "tRNA", "TCR")
mySym <- HGNC$sym[HGNC$type %in% myGeneTypes]  # 20,297 symbols

# Get regulatory regions for these symbols: open a "Mart" object ...
myMart <- biomaRt::useMart("ensembl", dataset="hsapiens_gene_ensembl")

# filters    <- biomaRt::listFilters(myMart)
# attributes <- biomaRt::listAttributes(myMart)

# ... and retrieve data for our symbols
tmp <- biomaRt::getBM(filters = "hgnc_symbol",
                      attributes = c("strand",
                                     "chromosome_name",
                                     "transcript_end",
                                     "transcript_start",
                                     "transcript_appris",
                                     "hgnc_symbol"),
                      values = mySym,
                      mart = myMart)

# result?
length(unique(tmp$hgnc_symbol)) # 19599  = 96.5% coverage

# remove NAs
tmp <- tmp[ (! is.na(tmp$strand)) &
            (! is.na(tmp$chromosome_name)) &
            (! is.na(tmp$transcript_start)) &
            (! is.na(tmp$transcript_end)), ]
length(unique(tmp$hgnc_symbol)) # 19599

# remove records with patch and test coordinates
tmp <- tmp[tmp$chromosome_name %in% c("MT", "X", "Y", 1:22), ]
length(unique(tmp$hgnc_symbol)) # 19579

# check appris types: unique(tmp$transcript_appris)
# remove alternative transcripts
tmp <- tmp[ ! grepl("alternative", tmp$transcript_appris), ]
length(unique(tmp$hgnc_symbol)) # 19579 - no loss

# Caution!
# Transcript start and end are always given such that the start coordinate
# is smaller than the end coordinate. However, in order to find the
# start site, one MUST consider the direction. Direction is either +1 or -1.
# -1 is reverse: the regulatory region is 1kb _above_ the transcript end.

l <- length(unique(tmp$hgnc_symbol))
myRegions <- data.frame(sym = unique(tmp$hgnc_symbol),
                        chr = character(l),
                        start = numeric(l),
                        end = numeric(l),
                        stringsAsFactors = FALSE)
rownames(myRegions) <- myRegions$sym

for (sym in myRegions$sym) {
  sel <- which(tmp$hgnc_symbol == sym)

  # find the best transcript:
  iBest <- sel[bestAppris(tmp$transcript_appris[sel])]

  strand <- tmp$strand[iBest]
  chr <- paste0("chr", tmp$chromosome_name[iBest])

  if (strand == 1) {
    start <- tmp$transcript_start[iBest] - 1000
    end <- tmp$transcript_start[iBest]
  } else if (strand == -1) {
    start <- tmp$transcript_end[iBest]
    end <- tmp$transcript_end[iBest] + 1000
  } else {
    stop(sprintf("Undefined transcript direction for %s.", sym))
  }
  myRegions[sym, "chr"]   <- chr
  myRegions[sym, "start"] <- start
  myRegions[sym, "end"]   <- end
}

# set annotated regions at coordinates less than 1 to 1
myRegions[myRegions$start < 1, "start"] <- 1

chrOrder <- 1:25
myChrNames <- c(paste0("chr", 1:22), "chrX", "chrY", "chrMT")
names(chrOrder) <- myChrNames

# order by chr, then by start position
myRegions <- myRegions[order(chrOrder[myRegions$chr], myRegions$start), ]

head(myRegions)
#            sym  chr  start    end
#  OR4F5   OR4F5 chr1  68055  69055
#  OR4F29 OR4F29 chr1 451697 452697
#  OR4F16 OR4F16 chr1 686673 687673
#  SAMD11 SAMD11 chr1 924738 925738
#  NOC2L   NOC2L chr1 959290 960290
#  KLHL17 KLHL17 chr1 959587 960587

```

&nbsp;


## 4 Mapping ChiP-seq peaks to regulatory regions

In the section above, we defined the regulatory regions of genes in our HGNC resource, for which transcript start coordinates are available from biomart. Now we can use this to annotate GTRD ChIP-seq peaks for transcription factors with their target genes.

```R
# We read the ChIP-seq data chromosome by chromosome. We keep only peaks
# that have been annotated by all four peak-calling algorithms (that's about
# 25% of the total). We process peaks that are found in the regulatory regions.

# initialize tfList
tfList <- list()

for (chr in myChrNames) {  # for each chromosome ...
  cat(sprintf("Processing %s ...\n", chr))
  # read TF data
  FN <- file.path(GTRDpath, paste0(chr, ".tsv"))
  tfDat <- as.data.frame(readr::read_tsv(FN,
                                         col_names = c("chr",
                                                       "start",
                                                       "summit",
                                                       "UniProt",
                                                       "sym",
                                                       "nPeak"),
                                         col_types = "ci-icc----i--"))

  # require peak-caller.count (nPeak) to be 4
  tfDat <- tfDat[tfDat$nPeak == 4, ]

  # summit <- start + summit
  tfDat$summit <- tfDat$start + tfDat$summit

  # add column "inRegion" of FALSE values, to flag peaks that are
  # in the genes' regulatory regions
  tfDat$inRegion <- FALSE

  # subset regulatory regions: only include those for the current "chr"
  currentRegions <- myRegions[ myRegions$chr == chr, ]

  # for each currentRegion ...
  for (i in 1:nrow(currentRegions)) {

    #    set the peaks of the current chromosome that lie in this
    #    particular region to TRUE
    tfDat$inRegion[tfDat$summit >= currentRegions$start[i] &
                   tfDat$summit <= currentRegions$end[i]] <- TRUE
  }

  # subset to keep only peaks that lie in a regulatory region
  tfDat <- tfDat[tfDat$inRegion, ]

  # for each peak ...
  for (i in 1:nrow(tfDat)) {
    # Add all genes for which it is inRegion to tfList. (Regions may overlap,
    # so the peak could be annotated to more than one gene.)
    tf <- tfDat$sym[i]   # the current tf
    genes <- currentRegions$sym[tfDat$summit[i] >= currentRegions$start &
                                tfDat$summit[i] <= currentRegions$end ]
    if (length(genes > 0)) {           # (This actually should always be true.)
      if ( is.null(tfList[[tf]])) {    # new tf: initialize with this gene
        tfList[[tf]] <- genes
      } else {                         # tf exists: add gene to its targets
        tfList[[tf]] <- c(tfList[[tf]], genes)
      }
    }
  }
}

# sort() and unique() the genes
for (i in 1:length(tfList)) {
  tfList[[i]] <- sort(unique(tfList[[i]]))
}

save(tfList, file = "tfList-2019-03-13.RData")

```

&nbsp;

The resulting `tFlist-2019-03-13.RData` is available on the ABC assets server. Here is code to load it, and a few basic operations and statistics.

&nbsp;

```R
myURL <- paste0("http://steipe.biochemistry.utoronto.ca/abc/assets/",
                "tfList-2019-03-13.RData")
load(url(myURL))  # loads tfList object

str(tfList, list.len = 5)
# List of 635
# $ E2F8    : chr [1:758] "AATF" "ABCB6" "ABT1" "ACAP3" ...
# $ FEZF1   : chr [1:1009] "AAR2" "AARS2" "ABRAXAS2" "ABTB2" ...
# $ ZNF320  : chr [1:183] "AASDHPPT" "ABHD14A" "AFMID" "ALDH16A1" ...
# $ ZNF316  : chr [1:209] "AKAP13" "AKR1B10" "AMBRA1" "ANO5" ...
# $ ZSCAN5B : chr [1:33] "AGBL5" "ALOXE3" "ANG" "B4GAT1" ...
# [list output truncated]

nBar <- 30
x <- log10(unlist(lapply(tfList, length)))
hist(x,
     breaks = seq(min(x), max(x), length.out = nBar+1),
     col = colorRampPalette(c("#00EE00","#D9DEFF","#FCFEFF"),
                            bias = 1.3)(nBar),
     main = "Number of regulated genes per TF",
     xlab = "log10(nGenes)",
     ylab = "Counts")
abline(v = log10(c(10, 100, 1000)), col="#00AAFF")

```

![](genesPerTF.svg?sanitize=true "Genes per TF")
Figure: number of genes that have a GTRD annotated ChIP-seq peak in their regulatory region, for each of 635 human transcription factors.


&nbsp;

### 4.1 Inverting the list

The above list represents the original data but is not convenient for gene annotation. To annotate, we need to see which transcription factors bind to a gene's regulatory region. Therefore we need to "invert" the list to get transcription factors per gene.

```R
# "Invert" the list to get transcription factors per gene.
geneList <- list()
for (tf in names(tfList)) {
  genes <- tfList[[tf]]
  for (gene in genes) {
    if ( is.null(geneList[[gene]])) {   # new gene: initialize with this tf
      geneList[[gene]] <- tf
    } else {                            # gene exists: add tf to its regulators
      geneList[[gene]] <- c(geneList[[gene]], tf)
    }
  }
}

# sort() and unique() the transcription factors
for (i in 1:length(geneList)) {
  geneList[[i]] <- sort(unique(geneList[[i]]))
}

save(geneList, file = "geneList-2019-03-13.RData")

```

The resulting `geneList-2019-03-13.RData` is available on the ABC assets server. Here is code to load it, and a few basic operations and statistics.

&nbsp;

```R
myURL <- paste0("http://steipe.biochemistry.utoronto.ca/abc/assets/",
                "geneList-2019-03-13.RData")
load(url(myURL))  # loads geneList object

str(geneList, list.len = 5)
# List of 17864
#  $ HES4        : chr [1:82] "AR" "ATF2" "ATF3" "ATF4" ...
#  $ PUSL1       : chr [1:64] "AR" "BHLHE40" "CEBPA" "CEBPB" ...
#  $ ACAP3       : chr [1:69] "BHLHE40" "CEBPA" "CEBPB" "CEBPD" ...
#  $ ATAD3B      : chr [1:110] "AR" "ASCL2" "ATF2" "ATF3" ...
#  $ ATAD3A      : chr [1:128] "ARID4B" "ASCL2" "ATF1" "ATF3" ...
#   [list output truncated]

# Coverage:
100 * length(geneList) / nrow(myRegions)  # 91.2 %



nBar <- 30
x <- log10(unlist(lapply(geneList, length)))
hist(x,
     breaks = seq(min(x), max(x), length.out = nBar+1),
     col = colorRampPalette(c("#00EE00","#D9DEFF","#FCFEFF"),
                            bias = 1.3)(nBar),
     main = "Number of regulated genes per TF",
     xlab = "log10(nGenes)",
     ylab = "Counts")
abline(v = log10(c(10, 100, 1000)), col="#00AAFF")

```

![](TFperGene.svg?sanitize=true "Transcription factors per gene")
Figure: number of transcription factors that have a GTRD annotated ChIP-seq peak in a gene's regulatory region (1kb upstream of transcription start), for each of 19,579 human protein or structural RNA genes.

&nbsp;

## 5 Sample annotation

Annotate the example gene set, validate the annotation, and store the data in an edge-list format.

&nbsp;

```R

# The specification of the sample set is copy-paste from the 
# BCB420 resources project.

xSet <- c("AMBRA1", "ATG14", "ATP2A1", "ATP2A2", "ATP2A3", "BECN1", "BECN2",
          "BIRC6", "BLOC1S1", "BLOC1S2", "BORCS5", "BORCS6", "BORCS7",
          "BORCS8", "CACNA1A", "CALCOCO2", "CTTN", "DCTN1", "EPG5", "GABARAP",
          "GABARAPL1", "GABARAPL2", "HDAC6", "HSPB8", "INPP5E", "IRGM",
          "KXD1", "LAMP1", "LAMP2", "LAMP3", "LAMP5", "MAP1LC3A", "MAP1LC3B",
          "MAP1LC3C", "MGRN1", "MYO1C", "MYO6", "NAPA", "NSF", "OPTN",
          "OSBPL1A", "PI4K2A", "PIK3C3", "PLEKHM1", "PSEN1", "RAB20", "RAB21",
          "RAB29", "RAB34", "RAB39A", "RAB7A", "RAB7B", "RPTOR", "RUBCN",
          "RUBCNL", "SNAP29", "SNAP47", "SNAPIN", "SPG11", "STX17", "STX6",
          "SYT7", "TARDBP", "TFEB", "TGM2", "TIFA", "TMEM175", "TOM1",
          "TPCN1", "TPCN2", "TPPP", "TXNIP", "UVRAG", "VAMP3", "VAMP7",
          "VAMP8", "VAPA", "VPS11", "VPS16", "VPS18", "VPS33A", "VPS39",
          "VPS41", "VTI1B", "YKT6")

# which example genes have no annotated transcription factors
x <- which( ! (xSet %in% names(geneList)))
cat(sprintf("\t%s\t(%s)\n", HGNC[xSet[x], "sym"], HGNC[xSet[x], "name"]))

length(unique(unlist(geneList[xSet])))
# 385 - over half of TFs in the list


# How frequent ?
(fXsetTF <- sort(table(unlist(geneList[xSet])), decreasing = TRUE))

#   MYC      MAX      SP1    CREB1    RUNX1     ESR1     CTCF     SPI1       AR      ERG     RELA 
#    51       50       50       49       48       47       45       45       44       44       44 
#  E2F1    GABPA     ELF1      YY1   TFAP2C     FLI1     NFYA      SP2     USF1    FOXA1      JUN 
#    42       41       40       40       38       37       37       37       37       36       36 
# [...]


# How specific ? Divide the number of times a TF is found in xSetGet by the
# number of genes the transcription factor regulates overall. This is
# a crude approximation to calculating proper enrichment statistics.

fAllGenesTF <- unlist(lapply(tfList[names(fXsetTF)], length))
(specXsetTF <- sort((fXsetTF / fAllGenesTF), decreasing = TRUE))

#        INSM2        IRF9      ZNF529        ETS2     ZNF354B        PAX8         YY2       ZNF10 
#  0.333333333 0.333333333 0.333333333 0.250000000 0.125000000 0.111111111 0.071428571 0.066666667 
#       ZNF507      ZNF282       CSHL1      ZNF426       ZNF85        KLF8      ZNF697      ZNF410 
#  0.062500000 0.051282051 0.047619048 0.047619048 0.044444444 0.043478261 0.043478261 0.042253521 
#        [...]

# What are the top five?
HGNC[names(specXsetTF)[1:5], c("sym", "name")]
#               sym                                       name
#   INSM2     INSM2           INSM transcriptional repressor 2
#   IRF9       IRF9             interferon regulatory factor 9
#   ZNF529   ZNF529                    zinc finger protein 529
#   ETS2       ETS2 ETS proto-oncogene 2, transcription factor
#   ZNF354B ZNF354B                   zinc finger protein 354B

But note that these all appear only once in the set:

# What are the most specific TFs that appear five or more times in fXsetTF?
specXsetTF[names(fXsetTF)[fXsetTF >= 5]]
#          MYC         MAX         SP1       CREB1       RUNX1        ESR1        CTCF        SPI1 
#  0.005935754 0.005747787 0.005636979 0.006321765 0.005354752 0.005330611 0.005445964 0.005983247 
#        [...]

```

The TFs in the final set are all "general" transcription factors - at first glance, there is no indication that a set-specific regulatory transcription factor exists. This is expected, since the genes contribute to all stages of autophagic flux.

&nbsp;

## 6 References

&nbsp;

Example code for biomaRt was taken taken from `BIN-PPI-Analysis.R` in the [ABC-Units project](https://github.com/hyginn/ABC-units) (Steipe, 2016-2019). 

&nbsp;

* Yevshin, I., Sharipov, R., Kolmykov, S., Kondrakhin, Y., & Kolpakov, F. (2019). GTRD: a database on gene transcription regulation-2019 update. [Nucleic acids research, D1, D100-D105](https://academic.oup.com/nar/article/47/D1/D100/5184717).

&nbsp;

## 7 Acknowledgements

[Yufei Yang worked on GTRD data import](https://github.com/faye-yang/BCB420.2019.GTRD) as part of her BCB420 (Computational Systems Biology) data project.

Thanks to Simon Kågedal's very useful [PubMed to APA reference tool](http://helgo.net/simon/pubmed/).

User `Potherca` [posted on Stack](https://stackoverflow.com/questions/13808020/include-an-svg-hosted-on-github-in-markdown) how to use the parameter `?sanitize=true` to display `.svg` images in github markdown.

&nbsp;

&nbsp;

<!-- [END] -->
