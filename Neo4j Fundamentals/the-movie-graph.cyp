// NEO4J FUNDAMENTALS
// -----------------------------------------------------------------

// NODES:

// The graph contains nodes labeled Movie and Person
// Cypher query to return the first 50 Movie nodes in the graph:
MATCH (m:Movie) RETURN m LIMIT 50

// Return all the Person nodes in the graph:
MATCH (p:Person) RETURN p

// Filter Movie nodes by the title property:
MATCH (m:Movie {title: 'Toy Story'}) RETURN m

// ***************************************************************

// RELATIONSHIPS:

// Person nodes have ACTED_IN and DIRECTED relationships with Movie nodes
// Return the Movie node 'Hoffa' and Person nodes with an ACTED_IN relationship to the movie:
MATCH (m:Movie {title: 'Hoffa'})<-[r:ACTED_IN]-(p:Person)
RETURN m, r, p

// ***************************************************************

// PROPERTIES:

// Person nodes have properties like name and born
// Movie nodes have properties like title and released
// Return the movie title and person’s name who acted in the movie "Top Gun":
MATCH (m:Movie {title: 'Top Gun'})<-[r:ACTED_IN]-(p:Person)
RETURN m.title, p.name

// Modify the query to return the role property of the ACTED_IN relationship:
MATCH (m:Movie {title: "Top Gun"})<-[r:ACTED_IN]-(p:Person)
RETURN m.title, p.name, r.role

// ***************************************************************
