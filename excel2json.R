# excel2json.R
#
# Purpose: Read an Excel file with systems information.
#          Produce an intermediate version of a systems data model as a set
#          of data frames in a list. Write a textual representation of the data
#          model in json format to a text file.
#
#          After defining the parameters, you can source the script to
#          produce its output, and copy, paste the json from the into
#          text output into a Wikipage.
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
# Input:   An Excel file with a "systemComponent" spreadsheet containing
#          columns named "systemCode" and "componentCode"
#
# Output:  A json data structure written to a text file to console
#
# ToDo:
# Notes:
#
# ==============================================================================

# WARNING: SIDE EFFECTS
# Executing this script will execute code it contains.

# ====  PARAMETERS  ============================================================

list.files(pattern = "\\.xlsx")
FN      <- "BCB420-2019-System-PHALY-0.3.xlsx"

OUTFILE <- "myDB.json"

# controlled vocabulary for
molTypes <- c("protein",
              "RNA",
              "lipid",
              "metabolite",
              "concept",
              "other")

# The following columns are mandatory in the input; no NA's are allowed
noNA <- matrix(c(     "system", "code"), ncol = 2)
noNA <- rbind(noNA, c("system", "name"))
noNA <- rbind(noNA, c("system", "def"))
noNA <- rbind(noNA, c("system", "description"))

noNA <- rbind(noNA, c("systemComponent", "systemCode"))
noNA <- rbind(noNA, c("systemComponent", "componentCode"))
noNA <- rbind(noNA, c("systemComponent", "evidence"))
noNA <- rbind(noNA, c("systemComponent", "evidenceSource"))
noNA <- rbind(noNA, c("systemComponent", "role"))
noNA <- rbind(noNA, c("systemComponent", "notes"))

noNA <- rbind(noNA, c("component", "code"))
noNA <- rbind(noNA, c("component", "name"))
noNA <- rbind(noNA, c("component", "type"))


# ====  PACKAGES AND DATA  =====================================================

if ( ! requireNamespace("readxl", quietly=TRUE)) {
  install.packages("readxl")
}

if ( ! requireNamespace("jsonlite", quietly=TRUE)) {
  install.packages("jsonlite")
}

if ( ! requireNamespace("qrandom", quietly=TRUE)) {
  install.packages("qrandom")
}

load("HGNC.RData")


# ====  FUNCTIONS  =============================================================

fixNA <- function(x) {
  # replace all "NA" and "" cells in all dataframes of a list with NA

  for (mySheet in names(x)) {
    s <- x[[mySheet]]
    for (i in 1:ncol(s)) {
      v <- s[ , i]
      v[(v == "NA") | (v == "")] <- NA
      s[ , i] <- v
    }
    x[[mySheet]] <- s
  }
  return(x)
}



# ====  PROCESS  ===============================================================

XL <- list()
XL$system <- as.data.frame(readxl::read_xlsx(FN,
                                           sheet = "system",
                                           skip = 1))
XL$systemComponent  <- as.data.frame(readxl::read_xlsx(FN,
                                            sheet = "systemComponent",
                                            skip = 1))
XL$component <- as.data.frame(readxl::read_xlsx(FN,
                                            sheet = "component",
                                            skip = 1))

XL <- fixNA(XL)



# ======== Sanity checks =======================================================


#check that no mandatory columns contain any NAs
for (i in 1:nrow(noNA)) {
  if (any(is.na(XL[[noNA[i, 1]]][ , noNA[i, 2]]))) {
    stop(sprintf("NA encountered in mandatory column \"%s\" of sheet \"%s\".",
                 noNA[i, 2],
                 noNA[i, 1]))
  }
}

# check that all system$code are unique
if ( any(duplicated(XL$system$code))) {
  s1 <- XL$system$code[duplicated(XL$system$code)]
  stop(sprintf("%s \"%s\" %s",
               "system$code(s)",
               paste(s1, collapse = ", "),
               "duplicated in the column."))
}

# check that all component$code are unique
if ( any(duplicated(XL$component$code))) {
  s1 <- XL$component$code[duplicated(XL$component$code)]
  stop(sprintf("%s \"%s\" %s",
               "component$code(s)",
               paste(s1, collapse = ", "),
               "duplicated in the column."))
}

# check that all systemComponent$systemCode are defined in system$code
if ( ! all(unique(XL$systemComponent$systemCode) %in% XL$system$code)) {
  s1 <- unique(XL$systemComponent$systemCode)
  s2 <- XL$system$code
  stop(sprintf("%s \"%s\" %s",
               "systemComponent$systemCode(s)",
               paste(s1[ ! s1 %in% s2], collapse = ", "),
               "not defined in system$code."))
}

# check that all systemComponent$componentCode are defined in component$code
if ( ! all(unique(XL$systemComponent$componentCode) %in% XL$component$code)) {
  s1 <- unique(XL$systemComponent$componentCode)
  s2 <- XL$component$code
  stop(sprintf("%s \"%s\" %s",
               "systemComponent$componentCode(s)",
               paste(s1[ ! s1 %in% s2], collapse = ", "),
               "not defined in component$code."))
}

# check that all atomic component$molType are defined and in the controlled
# vocabulary molTypes
for (i in 1:nrow(XL$component)) {
  if (XL$component$type[i] == "atomic" &&
      ! (XL$component$molType[i] %in% molTypes)) {
    stop(sprintf("%s \"%s\" of component \"%s\" %s",
                 "molType",
                 XL$component$molType[i],
                 XL$component$code[i],
                 "is not in the controlled vocabulary for the molType column."))
  }
}

# check that all protein component$molType have a valid HGNC symbol annotated
for (i in 1:nrow(XL$component)) {
  if (  (XL$component$molType[i] %in% "protein") &&
      ! (XL$component$sym[i] %in% HGNC$sym)) {
    stop(sprintf("%s \"%s\" of component \"%s\" %s",
                 "symbol",
                 XL$component$sym[i],
                 XL$component$code[i],
                 "is not a symbol in the HGNC resource."))
  }
}

# ======== Sanity checks completed =============================================

myDB <- initSysDB()

# ======== Process Spreadsheets ================================================

for (i in 1:nrow(XL$system)) {
  # process systems
  myDB$system[nrow(myDB$system) + 1, ] <- data.frame(
    ID = fetchQQ(1),
    code = XL$system$code[i],
    name = XL$system$name[i],
    def = XL$system$def[i],
    description = XL$system$description[i],
    stringsAsFactors = FALSE)
}

for (i in 1:nrow(XL$component)) {
  # process components
  thisComponentID <- fetchQQ(1)
  myDB$component[nrow(myDB$component) + 1, ] <- data.frame(
    ID = thisComponentID,
    code = XL$component$code[i],
    componentType = XL$component$type[i],
    stringsAsFactors = FALSE)

  if (XL$component$type[i] == "atomic") {
  # store data for atomic component
    # componentMolecule
    thisMoleculeID <- fetchQQ(1)
    myDB$componentMolecule[nrow(myDB$componentMolecule) + 1, ] <- data.frame(
      ID = fetchQQ(1),
      componentID = thisComponentID,
      moleculeID  = thisMoleculeID,
      stringsAsFactors = FALSE)

    # molecule
    myDB$molecule[nrow(myDB$molecule) + 1, ] <- data.frame(
      ID = thisMoleculeID,
      name = XL$component$name[i],
      moleculeType = XL$component$molType[i],
      structure = "TBD",
      stringsAsFactors = FALSE)

    if ( ! is.na(XL$component$sym[i])) {  # symbol is not NA
    # store data for a gene
      thisGeneID <- fetchQQ(1)
    # geneProduct table
      myDB$geneProduct[nrow(myDB$geneProduct) + 1, ] <- data.frame(
        ID = fetchQQ(1),
        geneID = thisGeneID,
        moleculeID  = thisMoleculeID,
        stringsAsFactors = FALSE)

    # gene table
      myDB$gene[nrow(myDB$gene) + 1, ] <- data.frame(
        ID = thisGeneID,
        symbol = XL$component$sym[i],
        name = XL$component$name[i],
        stringsAsFactors = FALSE)
    }
  }

  # note table
  if ( ! is.na(XL$component$notes[i])) {
    myDB$note[nrow(myDB$note) + 1, ] <- data.frame(
      ID = fetchQQ(1),
      targetID = thisComponentID,
      typeID = getIDforKey(myDB$type, "name", "genericNote"),
      note = XL$component$notes[i],
      stringsAsFactors = FALSE)
  }
}

for (i in 1:nrow(XL$systemComponent)) {
  # process the systemComponent join table
  myDB$systemComponent[nrow(myDB$systemComponent) + 1, ] <- data.frame(
    ID = fetchQQ(1),
    systemID = getIDforKey(myDB$system,
                           "code",
                           XL$systemComponent$systemCode[i]),
    componentID = getIDforKey(myDB$component,
                              "code",
                              XL$systemComponent$componentCode[i]),
    evidenceType = XL$systemComponent$evidence[i],
    evidenceSource = XL$systemComponent$evidenceSource[i],
    role = XL$systemComponent$role[i],
    notes = XL$systemComponent$notes[i],
    stringsAsFactors = FALSE)
}

# ======== Write output ========================================================

x <- jsonlite::toJSON(myDB)
x <- gsub('],"', '],\n\n"', x)
x <- gsub(':\\[\\{', ':[{\n', x)
x <- gsub("\\},\\s*\\{", "\n},\n{\n", x)
x <- gsub('","', '",\n"', x)
writeLines(x, con = OUTFILE)

# Note: Validate your output!  https://jsonlint.com/

# confirm:
identical(jsonlite::fromJSON(OUTFILE), myDB)
# must be TRUE


# ====  TESTS  =================================================================
if (FALSE) {
# Enter your function tests here...
#
}


# [END]
