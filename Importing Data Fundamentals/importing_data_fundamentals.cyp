// IMPORTING DATA FUNDAMENTALS
// -----------------------------------------------------------------

// Neo4j Data Importer:
// ~~~~~~~~~~~~~~~~~~~~~~~
// DATA IMPORTER:

// Cypher and LOAD CSV:
LOAD CSV WITH HEADERS FROM 'file:///transactions.csv' AS row
MERGE (t:Transactions {id: row.id})
SET
    t.reference = row.reference,
    t.amount = toInteger(row.amount),
    t.timestamp = datetime(row.timestamp)

// ***************************************************************

// Test data (persons.csv) imported using Neo4j workspace:
MATCH (p:Person) RETURN p LIMIT 25

// ***************************************************************

// ADD MOVIE NODES:

// Test data (movies.csv) imported using Neo4j workspace:
MATCH (m:Movie) RETURN m LIMIT 25

// ***************************************************************

// UNIQUE IDs & CONSTRAINTS:

// View index created using Neo4j workspace:
SHOW INDEXES

// ***************************************************************
