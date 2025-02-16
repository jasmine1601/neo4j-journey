// INTERMEDIATE CYPHER QUERIES
// -----------------------------------------------------------------

// Filtering Queries:
// ~~~~~~~~~~~~~~~~~

// View the data model in the sandbox:
CALL db.schema.visualization()

// View the property types for nodes in the graph:
CALL db.schema.nodeTypeProperties()

// View the property types for relationships in the graph:
CALL db.schema.relTypeProperties()

// View the uniqueness constraint indexes in the graph:
SHOW CONSTRAINTS

// ***************************************************************

//BASIC CYPHER QUERIES:

// Find all people who directed a movie in 2015 where the role property exists on the relationship:
MATCH (p:Person)-[r:DIRECTED]->(m:Movie)
WHERE r.role IS NOT NULL
AND m.year = 2015
RETURN p.name, r.role, m.title

// ***************************************************************

// TESTING EQUALITY:

// Find the directors of horror movies released in the year 2000:
MATCH (d:Director)-[:DIRECTED]->(m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE m.year=2000 AND g.name="Horror"
RETURN d.name

// ***************************************************************

// QUERYING FOR NULL VALUES:

// Find all Movie nodes in the graph that do not have a tmdbId property:
MATCH (m:Movie)
WHERE m.tmdbId IS NULL
RETURN m

// ***************************************************************

// CHECKING FOR VALUES:

// How many movies have a poster?
// Find the titles of all movies that have a poster:
MATCH (m:Movie)
WHERE m.poster IS NOT NULL
RETURN m.title

// ***************************************************************

// RANGE QUERY:

// Find people born in the 1950’s (1950 - 1959) that are both Actors and Directors:
MATCH (p:Person)
WHERE p:Actor AND p:Director
  AND p.born.year >= 1950 AND p.born.year <= 1959
RETURN p.name, labels(p), p.born

// ***************************************************************

// TESTING LIST INCLUSION:

// Find movies from "Jamaica":
MATCH (m:Movie) 
WHERE "Jamaica" IN m.countries
RETURN m.title, m.countries

// ***************************************************************

// TESTING STRINGS:

// Find all actors whose name begins with Robert:
MATCH (p:Person)
WHERE p.name STARTS WITH 'Robert'
RETURN p.name

// ***************************************************************

// CASE INSENSITIVE SEARCH:

// Find all the Movies where the title begins with "Life is":
MATCH (m:Movie)
WHERE toUpper(m.title) STARTS WITH 'LIFE IS'
RETURN m.title

// ***************************************************************

// USING THE 'CONTAINS' PREDICATE:

// Find the roles that contain the word "dog" (case-insensitive):
MATCH (p:Person)-[r:ACTED_IN]->(m:Movie)
WHERE toUpper(r.role) CONTAINS "DOG"
RETURN p.name, r.role, m.title

// ***************************************************************

// QUERY PATTERNS AND PERFORMANCE:

// Return the movies that Clint Eastwood acted in and directed:
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE  p.name = "Clint Eastwood"
AND exists { (p)-[:DIRECTED]→(m) }
RETURN  m.title

// ***************************************************************

// TESTING PATTERNS:

// Find the movies that "Rob Reiner" directed, but did not act in:
MATCH (p:Person)-[:DIRECTED]->(m:Movie)
WHERE p.name = 'Rob Reiner' 
AND NOT EXISTS { (p)-[:ACTED_IN]->(m) }
RETURN DISTINCT m.title

// ***************************************************************

// PROFILING:

// Returns the movies that "Clint Eastwood" acted in but did not direct:
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = 'Clint Eastwood'
AND NOT exists {(p)-[:DIRECTED]->(m)}
RETURN m.title

// Profile the query to see the performance of the query by adding PROFILE to the beginning of the query:
PROFILE MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = 'Clint Eastwood'
AND NOT exists {(p)-[:DIRECTED]->(m)}
RETURN m.title

// ***************************************************************

// MULTIPLE MATCH CLAUSES:

// Return the names of all actors whose name begins with Tom and also the title of the movies they directed
// If they did not direct the movie, then return a null value
MATCH (p:Person)
WHERE p.name STARTS WITH 'Tom'
OPTIONAL MATCH (p)-[:DIRECTED]→(m:Movie)
RETURN p.name, m.title

// Retrieve Movies and Reviewers
// Find all the movies in the Film-Noir genre and the users who rated them:
MATCH (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE g.name = 'Film-Noir'
MATCH (u:User)-[:RATED]->(m)
RETURN m.title, u.name

// Using OPTIONAL MATCH
// Return all the titles movies in the Film-Noir genre and the users who rated them:
MATCH (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE g.name = 'Film-Noir'
MATCH (m)<-[:RATED]-(u:User)
RETURN m.title, u.name

// Modify the query so that it returns all movies in the Film-Noir genre, regardless of whether they have been rated:
MATCH (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE g.name = 'Film-Noir'
OPTIONAL MATCH (m)<-[:RATED]-(u:User)
RETURN m.title, u.name

// ***************************************************************
