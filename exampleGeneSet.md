# `example gene set`

&nbsp;

###### [Boris Steipe](https://orcid.org/0000-0002-1134-6758),
###### Department of Biochemistry and Department of Molecular Genetics,
###### University of Toronto
###### Canada
###### &lt;boris.steipe@utoronto.ca&gt;

----

Background on defining a set of genes associated with the phagosome / lysosome fusion system. This set is the standard example gene set for our data anotation exercises.

----

Phagosome-lysosome fusion is a key step in autophagy, the process in which a lysosome - a package of acidic, lytic enzymes - fuses to a phagosome that has enveloped some cargo, targeted for degradation and recycling. The fusion is a highly regulated process, involving membrane anchored SNAREs, the facilitating HOPS complex, positioning by dynein motors that move along the cytoskeleton, and regulation at the protein, and lipid level, and the ionic context.

The system has been [lucidly reviewed in 2018 (Corona & Jackson)](https://www.sciencedirect.com/science/article/pii/S0962892418301223) and about 100 genes have more or less well defined roles in it. These genes will form our example data set.

As we prepare datasets to be integrated for systems annotation, you will define a workflow that is extensible to annotate all human genes, and annotate our example gene set as a specific example. This doocument describes how the gene set was compiled as context for this exercise.


### From GO:0090385 ...

&nbsp;

**[GO:0090385](https://www.ebi.ac.uk/QuickGO/term/GO:0090385)** (phagosome-lysosome fusion) is a term in the Biological Process Ontology. As of 2018-01-20, eleven human proteins are [annotated to this term](https://www.ebi.ac.uk/QuickGO/annotations?goUsage=descendants&goUsageRelationships=is_a,part_of,occurs_in&goId=GO:0090385&taxonId=9606&taxonUsage=descendants):


```R
# Fetch gene symbols for GO:0090385 (phagosome-lysosome fusion) yields 8
#  unique human proteins
#  (http://amigo.geneontology.org/amigo/term/GO:0090385)

GO_0090385set <- c("RAB7A", "RAB7B", "RAB20", "RAB34",
                   "RAB39A", "SPG11", "SYT7", "TMEM175")

# validate: all symbols in HGNC ?
HGNC[GO_0090385set, c("sym", "name")]  # yes, no NA's seen

```

&nbsp;

### From KEGG pathway hsa0410 ... visually

**[hsa04140](https://www.kegg.jp/kegg-bin/show_pathway?hsa04140)** is the KEGG autophagy pathway. Gene symbols are listed on the pathway map, but not all gene symbols are in current HGNC usage. Thus some symbols had to be manually substituted with information found on the HGNC site.

```R
KEGGset <- c("RAB7A", "RAB7B", "LAMP1", "LAMP2", "LAMP3", "LAMP5",
              "ATG14", "SNAP29", "VAMP8")

# validate: all symbols in HGNC ?
HGNC[KEGGset, c("sym", "name")]  # yes

```

&nbsp;

### From expert curation ...

&nbsp;

[Corona & Jackson (2018)](https://www.sciencedirect.com/science/article/pii/S0962892418301223) have published a recent review on the process; reading their paper yields the following list of genes. Here too, a fair number of symbols are not in current HGNC usage and had to be manually annotated.

```R
SNAREset        <- c("STX17", "SNAP29", "VAMP8", "MAP1LC3A", "MAP1LC3B",
                     "LAMP2", "IRGM", "RAB21", "YKT6",
                     "VTI1B", "STX6", "VAMP3", "VAMP7",
                     "SNAP47", "NSF", "NAPA")
ATG8proteins    <- c("MAP1LC3A", "MAP1LC3B", "MAP1LC3C",
                     "GABARAP", "GABARAPL1", "GABARAPL2")
HOPScomplex     <- c("VPS11", "VPS16", "VPS18",  "VPS33A", "VPS39", "VPS41")
BORCcomplex     <- c("BLOC1S1", "BLOC1S2", "SNAPIN", "KXD1",
                    "BORCS5", "BORCS6", "BORCS7", "BORCS8")
LipidsSet       <- c("MYO1C", "OSBPL1A", "PLEKHM1", "VAPA",
                     "INPP5E", "PI4K2A")
CytoskeletonSet <- c("DCTN1", "TARDBP", "TFEB", "RPTOR", "TPPP",
                     "MYO6", "TIFA", "CALCOCO2", "OPTN", "TOM1",
                     "HDAC6")
IonSet          <- c("ATP2A1", "ATP2A2", "ATP2A3", "CACNA1A", "TPCN1", "TPCN2")

# Additional components
CoronaSet       <- c("RAB7A", "RAB29", "UVRAG", "BECN1", "BECN2", "PIK3C3",
                     "AMBRA1", "RUBCN", "RUBCNL", "ATG14", "BIRC6", "EPG5",
                     "PSEN1", "PLEKHM1", "MGRN1", "HSPB8", "TXNIP", "TGM2",
                     "LAMP2", "CTTN")
                     
```

### Combine Sets

Our example set is the unique union of the sets defined above:

```R
exampleGenes <- c(GO_0090385set,
                  KEGGset,
                  SNAREset,
                  ATG8proteins,
                  HOPScomplex,
                  BORCcomplex,
                  LipidsSet,
                  CytoskeletonSet,
                  IonSet,
                  CoronaSet)

exampleGenes <- sort(unique(sampleGeneSet))  # 85 genes

# validate
any(is.na(HGNC[exampleGenes, "sym"]))  # FALSE

```

### Output formats

#### as an R vector ...

```R
dput(exampleGenes)

c("AMBRA1", "ATG14", "ATP2A1", "ATP2A2", "ATP2A3", "BECN1", "BECN2", 
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
```

#### JSON ...

```R
jsonlite::toJSON(exampleGenes)

[
	"AMBRA1", "ATG14", "ATP2A1", "ATP2A2", "ATP2A3", "BECN1", "BECN2", "BIRC6",
	"BLOC1S1", "BLOC1S2", "BORCS5", "BORCS6", "BORCS7", "BORCS8", "CACNA1A",
	"CALCOCO2", "CTTN", "DCTN1", "EPG5", "GABARAP", "GABARAPL1", "GABARAPL2",
	"HDAC6", "HSPB8", "INPP5E", "IRGM", "KXD1", "LAMP1", "LAMP2", "LAMP3",
	"LAMP5", "MAP1LC3A", "MAP1LC3B", "MAP1LC3C", "MGRN1", "MYO1C", "MYO6", "NAPA",
	"NSF", "OPTN", "OSBPL1A", "PI4K2A", "PIK3C3", "PLEKHM1", "PSEN1", "RAB20",
	"RAB21", "RAB29", "RAB34", "RAB39A", "RAB7A", "RAB7B", "RPTOR", "RUBCN",
	"RUBCNL", "SNAP29", "SNAP47", "SNAPIN", "SPG11", "STX17", "STX6", "SYT7",
	"TARDBP", "TFEB", "TGM2", "TIFA", "TMEM175", "TOM1", "TPCN1", "TPCN2", "TPPP",
	"TXNIP", "UVRAG", "VAMP3", "VAMP7", "VAMP8", "VAPA", "VPS11", "VPS16",
	"VPS18", "VPS33A", "VPS39", "VPS41", "VTI1B", "YKT6"
]

# validated at https://jsonlint.com/

```

####  Plain text ...

```text
AMBRA1 ATG14 ATP2A1 ATP2A2 ATP2A3 BECN1 BECN2 BIRC6 BLOC1S1 BLOC1S2 BORCS5 
BORCS6 BORCS7 BORCS8 CACNA1A CALCOCO2 CTTN DCTN1 EPG5 GABARAP GABARAPL1 
GABARAPL2 HDAC6 HSPB8 INPP5E IRGM KXD1 LAMP1 LAMP2 LAMP3 LAMP5 MAP1LC3A 
MAP1LC3B MAP1LC3C MGRN1 MYO1C MYO6 NAPA NSF OPTN OSBPL1A PI4K2A PIK3C3 
PLEKHM1 PSEN1 RAB20 RAB21 RAB29 RAB34 RAB39A RAB7A RAB7B RPTOR RUBCN 
RUBCNL SNAP29 SNAP47 SNAPIN SPG11 STX17 STX6 SYT7 TARDBP TFEB TGM2 TIFA 
TMEM175 TOM1 TPCN1 TPCN2 TPPP TXNIP UVRAG VAMP3 VAMP7 VAMP8 VAPA VPS11 
VPS16 VPS18 VPS33A VPS39 VPS41 VTI1B YKT6

```

#### Or ...

```R
cat(exampleGenes, sep = "\t")   # tab separated ...
cat(exampleGenes, sep = ",")    # comma separated ...
cat(exampleGenes, sep = "\n")   # one per line ...

```

&nbsp;

----

For more context, see also [(Zhi et al. 2018)](https://www.ncbi.nlm.nih.gov/pubmed/28939950) _Anatomy of autophagy: from the beginning to the end_.

&nbsp;

<!-- END -->
