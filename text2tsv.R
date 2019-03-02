# text2tsv.R
#
# Purpose: Parse structured text describing system components and produce
#          tsv output, suitable to be copy/pasted into three Excel spreadsheets:
#          - a system
#          - a systemComponent table
#          - a component table
#
#          This file assiste you in moving information from Wikitext to
#          an Excel spreadsheet in which you keep initial collected data.
#
# Version: 1.0
# Date:    2019-03-01
# Author:  Boris Steipe <boris.steipe@utoronto.ca>
# ORCID:                <https://orcid.org/0000-0002-1134-6758>
# License: MIT
#
# Input:   A text file containing Wikitext formatted systems facts.
#          Each fact is expressed in the following structured pattern:
#'''COMPONENT''' [SYMBOL] (NAME) is a component of ''SYSTEM''. NOTES. {{#pmid: <PMID>|LABEL}}
#
#          COMPONENT is mandatory.
#          SYMBOL is optional, if absent it will be NA.
#          NAME is optional, if absent the COMPONENT will be the NAME.
#          SYSTEM is mandatory. Moreover, every SYSTEM must itself have an
#           associated fact.
#          Notes are all taken together, not split into separate facts.
#          Publications are identified by their PMID.
#          The first PMID is the reference publication
#
# Output:  tab-separated text printed to the console. The output can be copied
#          and pasted into an Excel spreadsheet.
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
  facts$symb[i] <- getMatch("\\[([^\\]]+)\\]", s)          #   [text]
  facts$name[i] <- getMatch("\\(([^\\)]+)\\)", s)          #   (text)
  facts$syst[i] <- getMatch("[^']''([^']+)''[^']", s)      # '''text'''
  facts$pmid[i] <- getMatch("\\{\\{#pmid:\\s*([0-9]+)", s) #{{#pmid: text
  facts$note[i] <- getMatch("\\.\\s+(.+)$", s)             #  . text

  facts$note[i] <- gsub("\\.*\\s*\\{\\{#pmid:\\s*", " (pmid:", facts$note[i])
  facts$note[i] <- gsub("\\s*\\|.+?\\}\\}", "). ", facts$note[i])
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

# write output to console, copy and paste into spreadsheet

# write TSV output for the systems table
# (type <ctrl>-l to clear the console)
mySys <- unique(facts$syst)
sel <- facts$comp %in% mySys
cat(sprintf("\n%s\t%s", c(SYSCODE, facts$comp), c(NA, facts$name)))
cat("\n\n")


# write TSV output for the systemsComponent table
# (type <ctrl>-l to clear the console)
for (i in 1:l) {
  cat(sprintf("\n%s\t%s\t%s\t%s\t%s\t%s",
              facts$syst[i],
              facts$comp[i],
              "TAS",
              facts$pmid[i],
              "",
              facts$note[i]))
}
cat("\n\n")


# write TSV output for the component table
# (type <ctrl>-l to clear the console)
for (i in 1:l) {
  cat(sprintf("\n%s\t%s\t%s\t%s\t%s\t%s",
              facts$comp[i],
              facts$name[i],
              facts$type[i],
              "",
              facts$symb[i],
              HGNC[facts$symb[i], "UniProtID"]))
}
cat("\n\n")

# edit spreadsheet:
#  - Add definitions and descriptions to the systems table.
#  - Split up notes: keep notes that describe the role/function of the component
#                    in the system context in the systemComponent table. Put
#                    notes that describe the component itself in the component
#                    table.
#  - Add a SyRO role to each systemComponent.
#  - Add a molecule type to each atomic component:
#    (protein | RNA | lipid | metabolite)

# Next code to follow: turn spreadsheet into JSON.



# ====  TESTS  =================================================================
if (FALSE) {
# Enter your function tests here...
#
}


# [END]
