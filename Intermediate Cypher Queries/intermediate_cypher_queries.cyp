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

// What Cypher keyword can you use to determine if an index will be used for a query?
// EXPLAIN

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

// What Cypher keyword helps you to understand the performance of a query when it runs?
// PROFILE

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

// What value does OPTIONAL MATCH return if there is no value for a string property being returned in a row?
// null

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

// Controlling Results Returned:
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// ORDERING RETURNED RESULTS:

// Return the ratings that Sandy Jones gave movies and return the rating from highest to lowest:
MATCH (u:User)-[r:RATED]->(m:Movie)
WHERE u.name = 'Sandy Jones'
RETURN m.title AS movie, r.rating AS rating 
ORDER BY r.rating DESC

// What is the maximum number of properties can you order in your results?
// Unlimited

// ***************************************************************

// ORDERING RESULTS:

// Find and return movie titles ordered by the the imdbRating value.
// 1. Return only movies that have a value for the imdbRating property.
// 2. Order the results by the imdbRating value (highest to lowest).
MATCH (m:Movie)
WHERE m.imdbRating IS NOT NULL
RETURN m.title
ORDER BY m.imdbRating DESC

// ***************************************************************

// VIEWING THE ORDERED RESSULTS:

// Returns the movie titles with the highest imdbRating values first:
MATCH (m:Movie)
WHERE m.imdbRating IS NOT NULL
RETURN m.title, m.imdbRating
ORDER BY m.imdbRating DESC

// Return the movie titles with the lowest imdbRating values first:
MATCH (m:Movie)
WHERE m.imdbRating IS NOT NULL
RETURN m.title, m.imdbRating
ORDER BY m.imdbRating

// ***************************************************************

// ORDERING MULTIPLE VALUES:

// Find the highest rates movies:
MATCH (m:Movie)
WHERE m.imdbRating IS NOT NULL
RETURN m.title, m.imdbRating
ORDER BY m.imdbRating DESC

// Find the youngest actor in the highest rated movie:
// 1. Match Movie to Person nodes using the ACTED_IN relationship
// 2. Add the Person node’s name and born property to the RETURN clause
// 3. Order the results by the Person node’s born property
MATCH (m:Movie)<-[ACTED_IN]-(p:Person)
WHERE m.imdbRating IS NOT NULL
RETURN m.title, m.imdbRating, p.name, p.born
ORDER BY m.imdbRating DESC, p.born DESC

// ***************************************************************

// LIMITING OR COUNTING RESULTS RETURNED:

// Return the movies that have been reviewed:
MATCH (m:Movie)<-[:RATED]-()
RETURN DISTINCT m.title

// Why would you want to use LIMIT in a RETURN clause?
// To reduce the amount of data returned to the client.

// Limiting results by movie rating:
// Return just the lowest rated movie based on the imdbRating property:
MATCH (m:Movie)
WHERE m.imdbRating IS NOT NULL
RETURN m.title, m.imdbRating
ORDER BY m.imdbRating LIMIT 1

// ***************************************************************

// ELIMINATING DUPLICATES:

// This query returns the names people who acted or directed the movie Toy Story 
// and then retrieves all people who acted in the same movie.
MATCH (p:Person)-[:ACTED_IN | DIRECTED]->(m)
WHERE m.title = 'Toy Story'
MATCH (p)-[:ACTED_IN]->()<-[:ACTED_IN]-(p2:Person)
RETURN p.name, p2.name

// Modify query to eliminate duplicates:
MATCH (p:Person)-[:ACTED_IN | DIRECTED]->(m)
WHERE m.title = 'Toy Story'
MATCH (p)-[:ACTED_IN]->()<-[:ACTED_IN]-(p2:Person)
RETURN DISTINCT p.name, p2.name

// ***************************************************************

// MAP PROJECTIONS TO RETURN DATA:

// Return the title and release date as Movie objects for all Woody Allen movies:
MATCH (m:Movie)<-[:DIRECTED]-(d:Director)
WHERE d.name = 'Woody Allen'
RETURN m {.title, .released} AS movie
ORDER BY m.released

// What is returned in every row?
MATCH (p:Person)
WHERE p.name CONTAINS "Thomas"
RETURN p AS person ORDER BY p.name
// - labels
// - identity
// - elementId
// - properties

// ***************************************************************

//  CHANGING RESULTS RETURNED:

// We want to return information about actors who acted in the Toy Story movies.
// We want to return the age that an actor will turn this year or that the actor died.
MATCH (m:Movie)<-[:ACTED_IN]-(p:Person)
WHERE m.title CONTAINS 'Toy Story'
RETURN m.title AS movie,
p.name AS actor,
p.born AS dob,
CASE WHEN p.died IS NULL THEN date().year - p.born.year
WHEN p.died IS NOT NULL THEN 'Died'
END AS ageThisYear

// What keywords can you use in a RETURN clause to conditionally return a value?
CASE
WHEN
ELSE
END

// ***************************************************************

// CONDITIONALLY RETURNING DATA:

// Return the movies that Charlie Chaplin has acted in and the runtime for the movie:
MATCH (m:Movie)<-[:ACTED_IN]-(p:Person)
WHERE p.name = 'Charlie Chaplin'
RETURN m.title AS movie,
m.runtime AS runTime

// Modify this query to return "Short" for runTime if the movie’s runtime is < 120 (minutes) 
// and "Long" for runTime if the movie’s runtime is >= 120.
MATCH (m:Movie)<-[:ACTED_IN]-(p:Person)
WHERE p.name = 'Charlie Chaplin'
RETURN m.title AS movie,
CASE 
    WHEN m.runtime < 120 THEN 'Short' 
    ELSE 'Long' 
END AS runTime

// ***************************************************************

// Working with Cypher Data:
// ~~~~~~~~~~~~~~~~~~~~~~~~

// Return the list of names of actors in the movie Toy Story as a single row. What code do you use?
MATCH (movie:Movie {title:'Toy Story'})<-[:ACTED_IN]-(actor:Person)
RETURN collect(actor.name) AS actors

// What Cypher function can you use to return the number of elements in a list of Movie nodes, movies?
// size(movies)

// ***************************************************************

// COUNTING RESULTS:

// Most active director?
// Find the highest number of movies directed by a single director:
MATCH (p:Person)-[:DIRECTED]->(m:Movie)
RETURN p.name, count(m.title)
ORDER BY count(m.title) DESC

// ***************************************************************

// CREATING LISTS:

// Actors by movie title
// Return a list actors who have appeared in movies with the same title.
// 1. Return the actors as a list.
// 2. Order the results by the size of the actors list.
MATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
RETURN 
    m.title AS movie,
    COLLECT(a.name) AS actors
ORDER BY SIZE(actors) DESC
LIMIT 100

// How Many Actors?
// Update the above query to return the number of actors in movies with the same title:
MATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
RETURN m.title AS movie,
collect(a.name) AS cast,
size(collect(a.name)) AS num
ORDER BY num DESC LIMIT 1

// ***************************************************************

// WORKING WITH DATES AND TIMES:

// How old Charlie Chaplin was when he died:
MATCH (p:Person)
WHERE p.name = 'Charlie Chaplin'
RETURN duration.between(p.born, p.died).years

// Duration
// The Test node has been updated using this Cypher statement:
MERGE (x:Test {id: 1})
SET
x.date = date(),
x.datetime = datetime(),
x.timestamp = timestamp(),
x.date1 = date('2022-04-08'),
x.date2 = date('2022-09-20'),
x.datetime1 = datetime('2022-02-02T15:25:33'),
x.datetime2 = datetime('2022-02-02T22:06:12')
RETURN x

// Calculate days between two dates
// Update above query to calculate the number of days between the date1 and date2 properties of the Test node.
// The difference between the two dates is the duration in days.
MATCH (x:Test)
RETURN duration.inDays(x.date1, x.date2).days

// Calculate minutes between two datetime values
// Update above query to calculate the number of minutes between the datetime and datetime2 properties of the Test node.
// The difference between the two dates is the number of minutes.
MATCH (x:Test)
RETURN duration.between(x.datetime1, x.datetime2).minutes

// ***************************************************************

// Graph Traversal:
// ~~~~~~~~~~~~~~~

// Return a list of names of reviewers who rated the movie, Toy Story. What query will perform best?

MATCH (movie:Movie)←[:RATED]-(reviewer)
WHERE movie.title = 'Toy Story'
RETURN reviewer.name

// What term best describes the traversal behavior during a query?
// depth-first

// ***************************************************************

// TRAVERSING THE GRAPH:

// Co-actors of Robert Blake:
MATCH (p:Person {name: 'Robert Blake'})-[:ACTED_IN]->(m:Movie), (coActors:Person)-[:ACTED_IN]->(m)
RETURN m.title, collect(coActors.name)

// How many relationships are traversed to return the result?
// 16

// Finding more co-actors:
MATCH (p:Person {name: 'Robert Blake'})-[:ACTED_IN]->(m:Movie)
MATCH (allActors:Person)-[:ACTED_IN]->(m)
RETURN m.title, collect(allActors.name)

// How many relationships are traversed to return the result?
// This query traverses a total of 20 ACTED_IN relationships.
// It first traverses all ACTED_IN relationships from Robert Blake (4 traversals)
// For each movie found, it traverses all ACTED_IN relationships to tbe movie. (16 traversals, including the traversal from Robert Blake)
// You can see the nodes and relationships involved:
MATCH (p:Person {name: 'Robert Blake'})-[:ACTED_IN]->(m:Movie)
MATCH (allActors:Person)-[:ACTED_IN]->(m)
RETURN p,m,allActors

// ***************************************************************

// VARYING LENGTH TRAVERSAL:

// What actors are up to 6 hops away?
// Return a list of actors that are up to 6 hops away from Tom Hanks:
MATCH (p:Person)-[:ACTED_IN*1..6]-(others:Person)
WHERE p.name = 'Tom Hanks'
RETURN  others.name

// Finding the shortest path between 2 nodes
// shortestPath()

// Return the names of actors that are 2 hops away from Robert Blake using the ACTED_IN relationship:
MATCH (p:Person {name: 'Robert Blake'})-[:ACTED_IN*2]-(others:Person)
RETURN others.name

// Return the 'unique' names of actors that are 4 hops away from Robert Blake using the ACTED_IN relationship:
MATCH (p:Person {name: 'Robert Blake'})-[:ACTED_IN*4]-(others:Person)
RETURN DISTINCT others.name

// Return the unique names of actors that are 'up to 4' hops away from Robert Blake using the ACTED_IN relationship:
MATCH (p:Person {name: 'Robert Blake'})-[:ACTED_IN*1..4]-(others:Person)
RETURN DISTINCT others.name

// ***************************************************************
