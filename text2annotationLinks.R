# text2annotationLinks.R
#
# Purpose: Parse structured text describing system components and produce
#          wikitext for a table of genes, suitable to be copy/pasted into
#          a Wikipage. Cross-references from the HGNC resource create
#          links to the respective source databases, to look for
#          annotations of related genes.
#
# Version:  1.0
#
# Versions: 1.0 First release
#
# Date:    2019-03-05
# Author:  Boris Steipe <boris.steipe@utoronto.ca>
# ORCID:                <https://orcid.org/0000-0002-1134-6758>
# License: MIT
#
# Input:   - A text file containing Wikitext formatted systems facts.
#            Each fact is expressed in the following structured pattern:
#'''COMPONENT''' [SYMBOL] (NAME) is a component of ''SYSTEM''. NOTES. {{#pmid: <PMID>|LABEL}}
#
#            COMPONENT is mandatory.
#            SYMBOL is optional, if absent it will be NA.
#            NAME is optional, if absent the COMPONENT will be the NAME.
#            SYSTEM is mandatory. Moreover, every SYSTEM must itself have an
#             associated fact.
#            Notes are all taken together, not split into separate facts.
#            Publications are identified by their PMID.
#            The first PMID is the reference publication
#
#
#
# Output:  - Wikitext for a table containing hyperlinks to gene information,
#            sorted by subsystems occur in, for:
#            - Symbol
#            - Name
#            - UniProt
#            - ensembl
#            - UCSC
#            - NCBI gene
#            - AmiGO 2
#
# ToDo:
# Notes:
#
# ==============================================================================

# WARNING: SIDE EFFECTS
# Executing this script will execute code it contains.

# ====  PARAMETERS  ============================================================

FN      <- "PHALY_facts.txt"
SYSCODE <- "PHALY"

# ====  PACKAGES AND DATA  =====================================================

load("HGNC.RData")


# ====  FUNCTIONS  =============================================================

getMatch <- function(patt, s) {
	# Purpose:
	#     wraps a regex search-and-capture into a single function call
	# Parameters:
	#     patt: a (Perl) regular expression
	#     s:    a string to parse
	# Value:
	#     result: One string or NA. Either the first substring of s that
	#             matches the pattern, or NA if there is no match

	m <- regexec(patt, s, perl = TRUE)
	x <- regmatches(s, m)[[1]][2]
	if (length(x) == 0) {
	  x <- NA_character_
	}

	return(x)
}



# ====  PROCESS  ===============================================================

txt <- readLines(FN)

# use only lines with a COMPONENT
txt <- txt[grepl("'''([^']+)'''", txt)]

# sanity checks:
# must have a ''SYSTEM''
stopifnot(all(grepl("[^']''([^']+)''[^']", txt)))
txt[which(! grepl("[^']''([^']+)''[^']", txt))]

# verify
head(txt)
tail(txt)

l <- length(txt)
facts <- data.frame(comp = character(l),
                    symb = character(l),
                    name = character(l),
                    syst = character(l),
                    pmid = character(l),
                    note = character(l),
                    type = character(l),
                    stringsAsFactors = FALSE)

# parse:

for (i in 1:l) {
  s <- txt[i]
  facts$comp[i] <- getMatch("'''([^']+)'''", s)            # '''text'''

  s2 <- getMatch("'''[^']+'''([^\\.]+)\\.", s)
  facts$symb[i] <- getMatch("\\[([^\\]]+)\\]", s2)          #   [text] in s2

  #   (text) in s2 only. If NA, use facts$comp[i]
  facts$name[i] <- getMatch("\\(([^\\)]+)\\)", s2)
  if (is.na(facts$name[i])) {
    facts$name[i] <- facts$comp[i]
  }

  facts$syst[i] <- getMatch("[^']''([^']+)''[^']", s)      # ''text''

  # pmid or "Unpublished"
  facts$pmid[i] <- getMatch("\\{\\{#pmid:\\s*([0-9]+)", s) #{{#pmid: text
  if (is.na(facts$pmid[i])) {
    facts$pmid[i] <- getMatch("\\{\\{(Unpublished)", s)
  }
  facts$note[i] <- getMatch("\\.\\s+(.+)$", s)             #  . text

  facts$note[i] <- gsub("\\.*\\s*\\{\\{#pmid:\\s*", " (pmid:", facts$note[i])
  facts$note[i] <- gsub("\\.*\\s*\\{\\{Unpublished", " (Unpublished", facts$note[i])
  facts$note[i] <- gsub("\\s*\\|.+?\\}\\}\\s?(\\.?)", "). ", facts$note[i])
}

# Check:
stopifnot(all( ! is.na(facts$comp)))  # no NA in components
stopifnot(all( ! is.na(facts$syst)))  # no NA in system
for (i in 1:l) {
  if( ! facts$syst[i] %in% c(facts$comp, SYSCODE)) {
    stop(sprintf("(fact: %d) SYSTEM \"%s\" not listed as a COMPONENT.",
                 i, facts$syst[i]))
  }
  if( (! is.na(facts$symb[i])) && (! facts$symb[i] %in% HGNC$sym)) {
    stop(sprintf("(fact: %d) SYMBOL \"%s\" not in HGNC$sym. Use valid symbol.",
                 i, facts$symb[i]))
  }
}

# composed or atomic types?
for (i in 1:l) {
  if (facts$comp[i] %in% facts$syst) {
    facts$type[i] <- "composed"
  } else {
    facts$type[i] <- "atomic"
  }
}

# keep only facts with symbols
facts <- facts[ ! is.na(facts$symb), ]

# unique (Sub)-systems
mySys <- unique(facts$syst)


# prepare output
tableHeader <- c("{{Smallvspace}}",
                 "<table>",
                 "  ",
                 "  <tr class=\"sh\">",
                 "  <td><b>Symbol</b></td>",
                 "  <td><b>Name</b></td>",
                 "  <td><b>UniProt</b></td>",
                 "  <td><b>ensembl</b></td>",
                 "  <td><b>UCSC</b></td>",
                 "  <td><b>NCBI gene</b></td>",
                 "  <td><b>AmiGO</b></td>",
                 "  </tr>",
                 "  <tr><td colspan=\"7\" class=\"sp\"></td></tr>",
                 "  ")

tableFooter <- c("  ",
                 "</table>",
                 "  ",
                 "{{Vspace}}",
                 "  ")

out <- character()

for (i in seq_along(mySys)) {
  out <- c(out, sprintf("=====%s=====",mySys[i]))
  out <- c(out, tableHeader)

  iGenes <- which(facts$syst == mySys[i])
  for(j in seq_along(iGenes)) {

    symb <- facts$symb[iGenes[j]]
    name <- facts$name[iGenes[j]]
    uprt <- HGNC[symb, "UniProtID"]
    ensb <- HGNC[symb, "EnsID"]
    ucsc <- HGNC[symb, "UCSCID"]
    ncbi <- HGNC[symb, "GeneID"]

    out <- c(out, sprintf("  <tr class=\"s%d\">", j %% 2 + 1))
    out <- c(out, sprintf("    <td>[https://www.genenames.org/tools/search/#!/all?query=%s '''%s''']</td>", symb, symb))
    out <- c(out, sprintf("    <td>%s</td>", name))
    out <- c(out, sprintf("    <td>[https://www.uniprot.org/uniprot/%s %s]</td>", uprt, uprt))
    out <- c(out, sprintf("    <td>[https://useast.ensembl.org/Homo_sapiens/Gene/Summary?g=%s %s]</td>", ensb, ensb))
    out <- c(out, sprintf("    <td>[http://genome.ucsc.edu/cgi-bin/hgGene?hgg_gene=%s&org=human %s]</td>", ucsc, ucsc))
    out <- c(out, sprintf("    <td>[https://www.ncbi.nlm.nih.gov/gene/%s %s]</td>", ncbi, ncbi))
    out <- c(out, sprintf("    <td>[http://amigo.geneontology.org/amigo/gene_product/UniProtKB:%s %s]</td>", uprt, symb))
    out <- c(out, "  </tr>")
  }

  out <- c(out, tableFooter)
}

# clear console (<ctrl>-l), write output to console, copy and paste into Wiki page
cat(out, sep ="\n")



# ====  TESTS  =================================================================
if (FALSE) {
# Enter your function tests here...
#
}


# [END]
