# HGNCdata.R
#
# Purpose: Prepare a reference file of human gene symbols and other data
#          from the HGNC.
# Version: 1.0
# Date:    2019-01-18
# Author: Boris Steipe (ORCID: 0000-0002-1134-6758)
# License: (c) Author (2019) + MIT
#
# ToDo:
#
# Notes:
#
# ==============================================================================

# WARNING: SIDE EFFECTS
# Executing this script will execute code it contains.

# ====  PARAMETERS  ============================================================

DATADIR <- file.path("..", "data")


# ====  PACKAGES  ==============================================================

if (! requireNamespace("readr", quietly = TRUE)) {
  install.packages("readr")
}
#  library(help = readr)


# ====  INTRODUCTION  ==========================================================

# The HGNC (Human Gene Nomeclature Committee) is the authoritative source for
# recognized genes. Source data is downloaded from the custom download page
# at https://www.genenames.org/cgi-bin/download. The goal of the script is
# to collect the relevant human gene symbols, synonyms and database identifiers,
# clean and validate the source data, and save the resulting dataframe as a
# compressed, binary file. This file HGNC.RData can be used as a tool to
# identify, map, and annotate diverse database identifiers.
#

# ====  PROCESS  ===============================================================

#  == Download the source data:
#
#  1: Navigate to https://www.genenames.org/cgi-bin/download
#
#  2: Select the following column data
#
#     - Approved Symbol
#     - Approved Name
#     - Locus Type
#     - Previous symbols
#     - Synonyms
#     - Chromosome
#     - Ensembl Gene ID
#     - NCBI Gene ID (external)
#     - OMIM ID (external)
#     - RefSeq (external)
#     - UniProt ID (external)
#     - Ensembl ID (external)
#     - UCSC ID (external)
#
#  3: Select status: approved
#
#  4: Do not select "chromosome" - this selects all by default.
#
#  5: Output settings:
#     - Order by approved symbol
#     - Output format text
#     - uncheck "Use HGNC Database identifier"
#
#  6: Click on Submit
#
#  The data will be loaded into your browser window.
#  This will take a few minutes.
#
#  7: Save the data as "HGNC_data.tsv" in your data directory
#
#
# == Read the source data:
#
tmp <- readr::read_tsv(file.path(DATADIR, "HGNC_data.tsv"))

# statistics:
nrow(tmp)  # 41624
ncol(tmp)  # 16
colnames(tmp)

# [1] "HGNC ID"                         "Approved symbol"
# [3] "Approved name"                   "Status"
# [5] "Previous symbols"                "Synonyms"
# [7] "Chromosome"                      "Accession numbers"
# [9] "RefSeq IDs"                      "Locus type"
# [11] "NCBI Gene ID(supplied by NCBI)"  "OMIM ID(supplied by OMIM)"
# [13] "RefSeq(supplied by NCBI)"        "UniProt ID(supplied by UniProt)"
# [15] "Ensembl ID(supplied by Ensembl)" "UCSC ID(supplied by UCSC)"

# == Validation

any(duplicated(tmp$`Approved symbol`))  # Are all symbols unique? Yes.
sum(is.na(tmp$`Approved symbol`))       # Any NA? No.
all(tmp$`RefSeq IDs` == tmp$`RefSeq(supplied by NCBI)`) # No. Why?

# For example ...
tmp$`RefSeq IDs`[3]                  # "NM_014576"
tmp$`RefSeq(supplied by NCBI)`[3]    # "NM_001198818"

# Navigate to https://ncbi.nlm.nih.gov. The two pages show two transcript
# variants of the same gene.
#
# Which column is more complete?
sum(! is.na(tmp$`RefSeq IDs`))   # 26291
sum(! is.na(tmp$`RefSeq(supplied by NCBI)`))  # 39231

# We will use the NCBI supplied data in principle.
# Are there any HGNC versions that are not included there?
sel <- (! is.na(tmp$`RefSeq IDs`)) & is.na(tmp$`RefSeq(supplied by NCBI)`)
sum(sel) # 53

# Inspect at the NCBI:
head(which(sel))
# [1] 2057 2059 2060 2273 2923 6213


tmp$`RefSeq IDs`[head(which(sel))]
# ... manual inspection at the NCBI:
# "NM_001187"    "NM_182481"    "NM_181704" : Homo sapiens BAGE family members
# "NM_033341" : This RefSeq was removed because it is now thought
#               that this gene is a pseudogene.
# "NM_024886" : This RefSeq was removed because currently it is thought
#               that it is annotated with an incorrect coding
# "NM_001366603" : Homo sapiens DERPC transcript variant 6
# Conclusion: while some additional family members could be annotated, overall
# the NCBI data is more current and removes errors. We will use the NCBI
# RefSeq IDs and keep the HGNC-RefSeq IDs only for legacy mapping.

# == Analysis
#
# check which Locus types appear in this data
(x <- unique(tmp$`Locus type`))  # 26 types
#  [1] "gene with protein product"  "RNA, long non-coding"
#  [3] "pseudogene"                 "virus integration site"
#  [5] "readthrough"                "phenotype only"
#  [7] "unknown"                    "region"
#  [9] "endogenous retrovirus"      "fragile site"
#  [11] "immunoglobulin gene"        "immunoglobulin pseudogene"
#  [13] "RNA, micro"                 "RNA, ribosomal"
#  [15] "RNA, transfer"              "complex locus constituent"
#  [17] "protocadherin"              "RNA, cluster"
#  [19] "RNA, misc"                  "RNA, small nuclear"
#  [21] "RNA, small cytoplasmic"     "RNA, small nucleolar"
#  [23] "RNA, Y"                     "T cell receptor gene"
#  [25] "T cell receptor pseudogene" "RNA, vault"

# Select Locus Types  of interest

myLocusTypes <- c("gene with protein product"
#                 , "pseudogene"
#                 , "readthrough"
#                 , "unknown"
#                 , "endogenous retrovirus"
                  , "immunoglobulin gene"
                  , "RNA, micro"
                  , "RNA, transfer"
                  , "protocadherin"
                  , "RNA, misc"
                  , "RNA, small cytoplasmic"
                  , "RNA, Y"
#                 , "T cell receptor pseudogene"
                  , "RNA, long non-coding"
#                 , "virus integration site"
#                 , "phenotype only"
#                 , "region"
#                 , "fragile site"
#                 , "immunoglobulin pseudogene"
                  , "RNA, ribosomal"
#                 , "complex locus constituent"
                  , "RNA, cluster"
                  , "RNA, small nuclear"
                  , "RNA, small nucleolar"
                  , "T cell receptor gene"
                  , "RNA, vault")

# Which status codes are there?
unique(tmp$`Status`)  # All are "approved"


#  == Subsetting

# subset rows with gene types of interest
tmp <- tmp[tmp$`Locus type` %in% myLocusTypes, ]
nrow(tmp) # 27087 of previously 41624

# subset columns of interest, re-order, and change tibble to data frame:
HGNC <- data.frame(sym = tmp$`Approved symbol`,
#                  tmp$`HGNC ID`,
                   name = tmp$`Approved name`,
#                  tmp$`Status`,
                   UniProtId = tmp$`UniProt ID(supplied by UniProt)`,
                   RefSeqID = tmp$`RefSeq(supplied by NCBI)`,
                   EnsID = tmp$`Ensembl ID(supplied by Ensembl)`,
                   UCSCID = tmp$`UCSC ID(supplied by UCSC)`,
                   GeneID= tmp$`NCBI Gene ID(supplied by NCBI)`,
                   OMIMIDc= tmp$`OMIM ID(supplied by OMIM)`,
                   acc = tmp$`Accession numbers`,
                   chr = tmp$`Chromosome`,
                   type = tmp$`Locus type`,
                   prev = tmp$`Previous symbols`,
                   synonym = tmp$`Synonyms`,
                   RefSeqOld = tmp$`RefSeq IDs`,
                   stringsAsFactors = FALSE)


# == Cleanup

# add rownames:
rownames(HGNC) <- HGNC$sym

# clean up some types
unique(HGNC$type)

HGNC$type <- gsub("gene with protein product", "protein",        HGNC$type)
HGNC$type <- gsub("immunoglobulin gene",       "immunoglobulin", HGNC$type)
HGNC$type <- gsub("T cell receptor gene",      "TCR",            HGNC$type)
HGNC$type <- gsub("RNA, transfer",             "tRNA",           HGNC$type)
HGNC$type <- gsub("RNA, ribosomal",            "rRNA",           HGNC$type)
HGNC$type <- gsub("RNA, micro",                "miRNA",          HGNC$type)
HGNC$type <- gsub("RNA, long non-coding",      "lncRNA",         HGNC$type)
HGNC$type <- gsub("RNA, small nuclear",        "snRNA",          HGNC$type)
HGNC$type <- gsub("RNA, small nucleolar",      "snoRNA",         HGNC$type)
HGNC$type <- gsub("RNA, small cytoplasmic",    "scRNA",          HGNC$type)
HGNC$type <- gsub("RNA, Y",                    "Y RNA",          HGNC$type)
HGNC$type <- gsub("RNA, vault",                "vtRNA",          HGNC$type)


# == Final Check

str(HGNC)
# 'data.frame':	27087 obs. of  14 variables:
#   $ sym      : chr  "A1BG" "A1BG-AS1" "A1CF" "A2M" ...
#   $ name     : chr  "alpha-1-B glycoprotein" "A1BG antisense RNA 1"  ...
#   $ UniProtId: chr  "P04217" NA "Q9NQ94" "P01023" ...
#   $ RefSeqID : chr  "NM_130786" "NR_015380" "NM_001198818" "NM_000014" ...
#   $ EnsID    : chr  "ENSG00000121410" "ENSG00000268895" "ENSG00000148584"  ...
#   $ UCSCID   : chr  "uc002qsd.5" "uc002qse.3" "uc057tgv.1" "uc001qvk.2" ...
#   $ GeneID   : num  1 503538 29974 2 144571 ...
#   $ OMIMIDc  : chr  "138670" NA "618199" "103950" ...
#   $ acc      : chr  NA "BC040926" "AF271790" "BX647329, X68728, M11313" ...
#   $ chr      : chr  "19q13.43" "19q13.43" "10q11.23" "12p13.31" ...
#   $ type     : chr  "protein" "lncRNA" "protein" "protein" ...
#   $ prev     : chr  NA "NCRNA00181, A1BGAS, A1BG-AS" NA NA ...
#   $ synonym  : chr  NA "FLJ23569" "ACF, ASP, ACF64, ACF65, APOBEC1CF" ...
#   $ RefSeqOld: chr  "NM_130786" "NR_015380" "NM_014576" "NM_000014" ...

# == Save result
save(HGNC, file = "HGNC.RData")


# [END]
