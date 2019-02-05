# `systems data model`

&nbsp;

###### [Boris Steipe](https://orcid.org/0000-0002-1134-6758),
###### Department of Biochemistry and Department of Molecular Genetics,
###### University of Toronto
###### Canada
###### &lt;boris.steipe@utoronto.ca&gt;

----

A data model to support work with systems data.

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

This knowledge is stored in a database, from where we retrieve it for systems modelling and analyis.

The database needs to provide the following features:

1. Store molecular and conceptual entities, taking the complexity of biological relationships into account;
2. Store data and metadata about entities, sets of such entities, and relationships between entities;
3. Store attributes of variable types;
4. Support dictionaries of controlled vocabularies for attributes;
5. Support versioning of entities, attribution, evidence, ...;
6. Support distributed, stateless generation of primary keys,
7. Support hierarchical relationships;
8. Support complex queries;
9. Provide functions to insert (import), update, and delete entities;
10. Provide functions to merge databases;
11. Provide functions for internal consistency checks: detect duplicate entities, warn about duplicate names, ... .
12. Scale to routinely accommodate storage and retrieval of data sets with 1e4 cardinalities;

#### Technical realization

These are complex requirements that require features of a hybrid of relational-, [entity-attribute-value (EAV)-](https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model), graph-, and object- datamodels. However, the database is overall not very large, with a few million records at best, and since it is developed for research purposes, in a single-user model, performance will not be critical. Nevertheless, if the database is implemented in R, use of the `fastmatch` package will allow to keep all key lookups in tables in a hash table in memory and access can be done in `O(1)`.

A proposed solution has at its core a relational datamodel, which is extended through tables that implement the other requirements. Requirement (1) requires a basic atomic entity of "molecules" that are polymorphic: they can be DNA, RNA or amino acid entities, small molecules, or even concepts. These "molecules" can, but don't have to be related to an underlying gene. Requirement (2) can be realized with a feature table that can be _joined_ to particular coordinates of entities where this makes sense. This avoids having to store most attributes in the entity tables themselves, while not being constrained in adding any number of new features. Requirement (3) _variable types_ is the classic requirement of EAV models. This is addressed in two complementary ways. Where the number of types is small, their properties are well abstractable, and two types have compatible attributes, polymorphism of entities can be used. Where the number of types is large, EAV-type tables are used instead. These can be used for any kind of metadata linked to any Primary Key, *if* we can construct Primary Keys that are unique in the entire database, across all copies of the database (req. 6). This requirement can be fulfilled with UUID's as Primary Keys in all tables. Controlled vocabularies (req. 4) are natively implemented in R via factors. Metadata (req. 5) about _any_ entity can be stored consistently in a single EAV table. Hierarchical relationships require that sets of components can themselves be systems (i.e. systems can have subsystems).  This requires two join tables between system and component. One describes the elements of a system, the other handles the situation that a componentcan be composed, not atomic. This implements hierarchical relationships (req. 7).

&nbsp;

### The model

[![system data model 2.1](http://steipe.biochemistry.utoronto.ca/abc/assets/systemDB-data_model.2.1.svg)](https://docs.google.com/presentation/d/1spOv8NoLtySvnUPv1vne7L5hXkeK5l_CVRCCYD8BQ7A/edit?usp=sharing)
(Schema of the systemDB 2.1 system data model. The model is [here](https://docs.google.com/presentation/d/1spOv8NoLtySvnUPv1vne7L5hXkeK5l_CVRCCYD8BQ7A/edit?usp=sharing) and can be copied and adapted.)

&nbsp;

### Details

All `ID`s in the model are realized as [Universally Unique Identifiers (UUID)](https://en.wikipedia.org/wiki/Universally_unique_identifier) and formatted as "QQIDs". A QQID is a UUID in which the first five hexadecimal digits have been mapped to two words from a list of 1,024 four-letter, monosyllabic words. IDs that differ in the two words are necessarily different. IDs that have the same words could be different - one needs to consider the rest of the ID. The advantage of QQIDs is that it is much easier to perform visual consistency checks during manual editing. Code to produce QQIDs is included in the [BCB420-2019-resources repository](https://github.com/hyginn/BCB420-2019-resources). Example:

```text
UUID:                                  QQID:
6c10088e-4a13-a1d2-79ee-ec0567354223   gram.love-88e-4a13-a1d2-79ee-ec0567354223
e2062b08-9f14-9032-0baa-5f796fa2a71b   skip.torn-b08-9f14-9032-0baa-5f796fa2a71b
51513df7-652d-1982-0a5c-2c1a88284ee8   wave.loaf-df7-652d-1982-0a5c-2c1a88284ee8
28c24f9e-d798-3d22-6894-643b13ed8740   time.pike-f9e-d798-3d22-6894-643b13ed8740
965ec6e3-4461-3002-99be-eb263a3a14d2   flee.teak-6e3-4461-3002-99be-eb263a3a14d2

```


&nbsp;

##### Entity Tables

* `system`: a system has an **ID**, a **name**, a short **code** of five capital letters, a short **definition**, and a more explicit **description** of its purpose and context.
* `component`: a component has an **ID**, a **name** and a **type**. Types can be either atomic, or composed. If atomic, the component must be present in the `molecule` table. If composed, the component must be present in the `system` table, linked via the `componentSystem` join table. Such a composed component is a "subsystem".
* `molecule`: a molecule has an **ID**, a **name**, and a **type** which can be RNA / DNA, protein, metabolite, molecule, or just a concept - generically any atomic entity in our domain. In addition it has a **structure** attribute, the semantics of which which depends on the type: nucleotide alphabet string, amino acid alphabet string, SMILES string, or text. In a typical usage a protein molecule, would have cross-references in the `xRef` table to UniProt and ENSP identifiers. 
* `gene`: a gene has an **ID**, a (HGNC) **symbol**, a **name**, and a **type**. Types are protein coding, rRNA, tRNA etc. Further information can be stored as a `note` or database `xRef`. Typically we expect presence of an ENSG cross-reference.
* `feature`: the main table to hold annotation data. Features are linked via join tables to system, component, relation, gene, and molecule - where appropriate, with ranges of annotation over the annotated object. For example a domain annotation would be stored as a feature, with start and end coordinates corresponding to the FASTA sequence in the `structure` attribute of the `moleulae`table 
* `componentRelation`: this looks like a join table, but is in fact a table that holds edges for graphs. However, since components can be atomic (`molecule`), or composed (`system`), this table may describe a [hypergraph](https://en.wikipedia.org/wiki/Hypergraph).

&nbsp;

#### Auxiliary Tables

* `parameter`: Information about the datamodel: schema version, species name, tax ID ...
* `type`: a data dictionary. Other tables store (typeID, value) tuples, The dictionary contains an attribute `validation`. This could be an index into an R list of validation functions, which implement regex, type/mode/class and range limitations, a regex, or other mechanisms.
* `xRef`: database cross-references such as UniProt, RefSeq, ENSP or PDB IDs.
* `note`: metadata such as "see.also" references, curator name, evidence codes, date, version, and history of record.

&nbsp;

##### Join Tables

* `systemComponent`: a component that is part of a system. Identified by the join of `system` and `component`, and the `role` that the component has in that system. One component can have more than one distinct role for a system; as well, one component can have roles in different systems. The role is a term from `SyRO` - the Systems Role Ontology. A description further clarifies the role.
* `componentSystem`: system that is a composed component - itself a (sub-)system. For example a protein complex could be described as a subsystem, and identified in this join table.
* `componentMolecule`: this join table identifies atomic components.
* `geneProduct`: gene associated with a molecule. One gene can be associated with more than one molecule; (rarely) one molecule my be produed by more than one gene.

&nbsp;

The `&lt;entity&gt;Feature` tables could possible be merged. This would simplify the structure, but whether this is efficient will depend on the frequency of use-cases that seek backwards from a feature to list all the entities it is attributed to.

* `systemFeature`: 
* `componentFeature`: 
* `relationFeature`: 
* `moleculeFeature`: 
* `geneFeature`: 

&nbsp;

##### Use case examples

TBC ...

* Add a PTM
* record that the PTM activates a protein
* describe function
* add an MSA
* add a pathway
* record isoforms that can substitute for each other
* record transcriptional variants that can substitute for each other
* record a mutation with a phenotype
* annotate a boundary component
* annotate a complement

&nbsp;


<!-- END -->
