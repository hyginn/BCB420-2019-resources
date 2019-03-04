# excel2tree.R
#
# Purpose: Read an Excel file with systems information.
#          Produce a tree of the components showing the system's
#          hierarchical composition.
#
#          After defining the parameters, you can source the script to
#          produce its output, and copy, paste that into a Wikipage.
#
# Version:  1.0
#
# Versions: 1.0 First release
#
# Date:    2019-03-04
# Author:  Boris Steipe <boris.steipe@utoronto.ca>
# ORCID:                <https://orcid.org/0000-0002-1134-6758>
# License: MIT
#
# Input:   An Excel file with a "systemComponent" spreadsheet containing
#          columns named "systemCode" and "componentCode"
#
# Output:  a tree printed to the console.
#
# ToDo:
# Notes:
#
# ==============================================================================

# WARNING: SIDE EFFECTS
# Executing this script will execute code it contains.

# ====  PARAMETERS  ============================================================

list.files(pattern = "\\.xlsx")
FN      <- "BCB420-2019-System-PHALY-0.2.xlsx"

SEP <- ":" # A character that does not appear in system or component codes
DEPTHMAX <- 20  # a safety net to cacth cyclical expansion



# ====  PACKAGES AND DATA  =====================================================

if ( ! requireNamespace("readxl", quietly=TRUE)) {
  install.packages("readxl")
}


# ====  FUNCTIONS  =============================================================

makeLines <- function(x) {
  # replace components of x with graphical elements for printing
  # a "tree", for all but the last component.
  l <- length(x)
  if (l == 1) {
    x <- c(" --", x)
  } else {
    x <- c(rep("   ", l - 1), "|__", x[l])
  }
  return(paste0(x, collapse = ""))
}


# ====  PROCESS  ===============================================================

mySys <- readxl::read_xlsx(FN,
                           sheet = "systemComponent",
                           skip = 1)[ , c("systemCode", "componentCode")]

# escape special characters if necessary
if (SEP %in% unlist(strsplit("\\^$.|?*+()[{", ""))) {
  patt <- paste0("\\", SEP)
} else {
  patt <- SEP
}

# replace all NA with ""
mySys$systemCode[is.na(mySys$systemCode)] <- ""
mySys$componentCode[is.na(mySys$componentCode)] <- ""

# check that patt does not appear in the column text (that would lead to
# erroneous strsplit()s ):
if (any(grepl(patt, mySys$systemCode)) ||
    any(grepl(patt, mySys$componentCode))) {
  stop("SEP character must not appear in systemCode or componentCode columns.")
}

# add root nodes to table
roots <- unique(mySys$systemCode)
roots <- roots[ ! (roots %in% mySys$componentCode)]
if (length(roots) > 0) {
  for (root in roots) {
    mySys[nrow(mySys) + 1, ] <-c("", root)
  }
}

mySys$sMap <- mySys$systemCode
mySys$cMap <- mySys$componentCode
hier <- character(length(mySys$systemCode))

nLev <- 0
while(any(mySys$componentCode != "") && nLev < DEPTHMAX) {
  nLev <- nLev + 1
  # add component to hierarchy
  hier <- paste(mySys$componentCode, hier, sep = SEP)
  # replace component with system
  mySys$componentCode <- mySys$systemCode
  # replace system with parent
  for (i in 1:nrow(mySys)) {
    sel <- which(mySys$systemCode[i] == mySys$cMap)[1]
    mySys$systemCode[i] <- mySys$sMap[sel]
    if (is.na(mySys$systemCode[i])) {
      mySys$systemCode[i] <- ""
    }
  }
}
if (nLev == DEPTHMAX) {
  stop("Cyclical system definition. DEPTHMAX exceeded")
}

# trim separators from termini
hier <- gsub(paste0("^", SEP, "+"), "", hier)
hier <- gsub(paste0(SEP, "+", "$"), "", hier)

# sort and strsplit
hier <- strsplit(sort(hier), SEP)

# replace components with graphical elements
hier <- unlist(lapply(hier, makeLines))

# Add wikitext
hier <- c("<source lang=\"text\">",
          hier,
          "</source>")


# cat result
cat(hier, sep = "\n")



# ====  TESTS  =================================================================
if (FALSE) {
# Enter your function tests here...
#
}


# [END]
