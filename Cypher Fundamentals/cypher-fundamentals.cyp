// CYPHER FUNDAMENTALS
// -----------------------------------------------------------------

// Reading Data From Neo4j:
// ~~~~~~~~~~~~~~~~~~~~~~~
// RETRIEVING NODES:

// Find the year that Kevin Bacon was born
MATCH (p:Person {name: "Kevin Bacon"})
RETURN p.born

// ***************************************************************

// FINDING RELATIONSHIPS:

// Names of people who directed movies:
MATCH (m:Movie)<-[:DIRECTED]-(p:Person) RETURN p.name
//or
MATCH (m:Movie)<-[:DIRECTED]-(p) RETURN p.name

// ***************************************************************

// TRAVERSING RELATIONSHIPS:

// Find who directed the movie Cloud Atlas:
MATCH (m:Movie {title: "Cloud Atlas"} )<-[:DIRECTED]-(p:Person)
RETURN p.name

// Which movie has Emil Eifrem acted in?
MATCH (p:Person {name: "Emil Eifrem"})-[:ACTED_IN]->(m:Movie)
RETURN m.title

// ***************************************************************

// FILTERING QUERIES:

// Retrieve all movies that have a released property value that is 2000, 2002, 2004, 2006, or 2008
MATCH (m:Movie)
WHERE m.released IN [2000, 2002, 2004, 2006, 2008]
RETURN m.title

// Retrieve all Person nodes for people born in the years 1970 to 1979
MATCH (a:Person)
WHERE a.born >= 1970 AND a.born < 1980
RETURN a.name, a.born

// or
MATCH (a:Person)
WHERE 1970 <= a.born < 1980
RETURN a.name, a.born

// or
MATCH (a:Person)
WHERE a.born IN [1970,1971,1972,1973,1974,1975,1976,1977,1978,1979]
RETURN a.name, a.born

// Find actors in the movie As Good as It Gets were born after 1960:
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE m.title = 'As Good as It Gets' AND p.born > 1960
RETURN p.name

// ***************************************************************

// Writing Data To Neo4j:
// ~~~~~~~~~~~~~~~~~~~~~~~
// CREATING NODES:

// Create a new Person node for Daniel Kaluuya:
MERGE (p:Person {name: 'Daniel Kaluuya'})

// Validate node creation:
MATCH (p:Person {name: 'Daniel Kaluuya'})
RETURN p

// ***************************************************************

// CREATING RELATIONSHIPS:

// Suppose our graph has a Person node for Lucille Ball and a Movie node for Mame. How do we create the ACTED_IN relationship between these two nodes?
MERGE (p:Person {name: 'Lucille Ball'})-[:ACTED_IN]->(m:Movie {title: 'Mame'})
RETURN p, m

// Find the Person node for Daniel Kaluuya.
// Create a Movie node, with a title property of Get Out.
// Add an ACTED_IN relationship between Daniel Kaluuya and the movie, Get Out.
MATCH (p:Person {name: 'Daniel Kaluuya'})
MERGE (m:Movie {title: 'Get Out'})
MERGE (p)-[:ACTED_IN]->(m)

// Validate creation:
MATCH (p:Person {name: 'Daniel Kaluuya'})
MATCH (m:Movie {title: 'Get Out'})
MATCH (p)-[:ACTED_IN]->(m)
RETURN p, m

// ***************************************************************

// UPDATING PROPERTIES:

// Remove all tagline properties from all Movie nodes in the graph:
MATCH (m:Movie)
REMOVE m.tagline
RETURN  m

// Adding Properties to a Movie

// Run this Cypher, you will see that the tagline and released properties are null:
MATCH (m:Movie {title: 'Get Out'})
RETURN m.title, m.tagline, m.released

// Modify this Cypher to use the SET clause to add the following properties to the Movie node:
// tagline: Gripping, scary, witty and timely!
// released: 2017
MATCH (m:Movie {title: 'Get Out'})
SET m.tagline = 'Gripping, scary, witty and timely!', m.released = 2017
RETURN m.title, m.tagline, m.released

// ***************************************************************

// MERGE PROCESSING:

// Our graph has a Person node for Lucille Ball. Suppose we want to add the year that Lucille Ball was born to this node. 
// The Person node for Lucille Ball has only the name property set to Lucille Ball.
// How can we update this code to include her birth year of 1911?
MERGE (p:Person {name: 'Lucille Ball'})
ON MATCH
SET p.born = 1911
RETURN p

// Adding or Updating a Movie

// create a Cypher script which will add createdAt and updatedAt to Movie nodes:
// 1. The createdAt property should be set to the current date and time when the node is created
// 2. If the node already exists, the updatedAt property should be set
MERGE (m:Movie {title: 'Rocketman'})
ON CREATE SET m.createdAt = datetime()
ON MATCH SET m.updatedAt = datetime()
SET m.tagline = "The Only Way to Tell His Story is to live His Fantasy.", m.released = 2019
RETURN m

// ***************************************************************

// DELETING DATA:

// Remove the actor River Phoenix, who may have relationships to movies in our database:
MATCH (p:Person {name: 'River Phoenix'})
DETACH DELETE p

// Remove actor Emil Eifrem
MATCH (p:Person {name: "Emil Eifrem"})
DETACH DELETE p

// ***************************************************************


