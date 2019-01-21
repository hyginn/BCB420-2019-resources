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

These are complex requirements that require features of a hybrid of relational-, [entity-attribute-value (EAV)-](https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model), graph-, and object- datamodels. However, the database is overall not very large, with a few million records at best, and since it is developed for research purposes, in a single-user model, performance will not be critical. However if the database is implemented in R, use of the `fastmatch` package will allow to keep all key lookups in tables in a hash table in memory and access can be done in `O(1)`.

A proposed solution has at its core a relational datamodel, which is extended through tables that capture the other requirements. Requirement (1) requires a basic atomic entity of "molecules" that are polymorphic: they can be DNA, RNA or amino acid entities, small molecules, or even concepts. These "molecules" can, but don't have to be related to an underlying gene. Requirement (2) can be realized with a feature table that can be _joined_ to particular coordinates of entities where this makes sense. This avoids having to store most attributes in the entity tables themselves, while not being constrained in adding any number of new features. Requirement (3) _variable types_ is the classic requirement of EAV models. This is addressed in two complementary ways. Where the number of types is small and the properties are well abstractable, polymorphism of entities can be used. Where the number of types is large, EAV-type tables are used instead. These can be used for any kind of metadat linked to any Primary Key, *if* we can construct Primary Keys that are unique in the entire database, across all copies of the database (req. 6). This requirement can be fulfilled with UUID's as Primary Keys in all tables. Controlled vocabularies (req. 4) are natively implemented in R via factors. Metadata (req. 5) about _any_ entity can be stored consistently in a single EAV table. Hierarchical relationships require that sets of components can themselves be systems (i.e. systems can have subsystems).  This requires two join tables between system and component. One describes the elements of a system, the other handles the situation that a componentcan be composed, not atomic. This implements hierarchical relationships (req. 7).

&nbsp;

### The model

[![system data model 2.0](http://steipe.biochemistry.utoronto.ca/abc/assets/systemDB-data_model.2.0.svg)](https://docs.google.com/presentation/d/1FOAPMn28WOKWQOGdkGUxuMTea3IMCfARop1RWOX_mqw/edit?usp=sharing)
(Schema of the systemDB 2.0 system data model. The model is [here](https://docs.google.com/presentation/d/1FOAPMn28WOKWQOGdkGUxuMTea3IMCfARop1RWOX_mqw/edit?usp=sharing) and can be copied and adapted.)

&nbsp;

### Details

All `ID`s in the model are realized as [Universally Unique Identifiers (UUID)](https://en.wikipedia.org/wiki/Universally_unique_identifier)

&nbsp;

##### Entity Tables

* `system`: a system has a name. Beyond that, it may have features, and it has components.
* `component`: types can be either atomic, or composed. If atomic, the component must be present in the `molecule` table. If composed, the component must be present in the `system` table, it is a "subsystem". The component role is taken from the systems role ontology.
* `feature`: the main table to hold annotation data. Linked via join tables to system, component, relation, gene, and molecule - where appropriate, with ranges of validity.
* `gene`: identified by its HGNC symbol, name and type. Further information can be stored as a `note` or database `xRef`.
* `molecule`: can be RNA / DNA, protein, metabolite, molecule, or just a concept - generically any atomic entity in our domain. The structure attribute is linked to the type: nucleotide alphabet string, amino acid alphabet string, SMILES string, or text.
* `componentRelation`: this looks like a join table, but is in fact a table that holds edges for graphs. However, since components can be atomic (`molecule`), or composed (`system`), this table may describe a [hypergraph](https://en.wikipedia.org/wiki/Hypergraph).
* `parameter`: Information about the datamodel: schema version, species name, tax ID ...
* `type`: a data dictionary. Other tables store (typeID, value) tuples, The dictionary contains an attribute `validation`. This could be an index into an R list of validation functions, which implement regex, type/mode/class and range limitations, a regex, or other mechanisms.
* `xRef`: database cross-references
* `note`: metadata such as see.also, curator name, evidence codes, date, version, and history of record.

&nbsp;

##### Join Tables

* `systemComponent`: a component that is part of a system
* `componentSystem`: system that is a composed component - itself a (sub-)system 
* `componentMolecule`: molecule that is an atomic component
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

&nbsp;


<!-- END -->
