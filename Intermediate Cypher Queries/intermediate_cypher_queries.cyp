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

// Pipelining Queries:
// ~~~~~~~~~~~~~~~~~~

// SCOPING VARIABLES:

// Return the name of the actor (Clint Eastwood) and all the movies that he acted in that contain the string 'high':
WITH  'Clint Eastwood' AS a, 'high' AS t
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WITH p, m, toLower(m.title) AS movieTitle
WHERE p.name = a
AND movieTitle CONTAINS t
RETURN p.name AS actor, m.title AS movie

// Using WITH to scope variables
// create a variable for the actor’s name:
WITH 'Tom Hanks' AS theActor
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = theActor
RETURN m.title AS title

// Highest Revenue Movies:
WITH  'Tom Hanks' AS theActor
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = theActor
AND m.revenue IS NOT NULL
WITH m ORDER BY m.revenue DESC LIMIT 1
RETURN m.revenue AS revenue, m.title AS title

// Top Movies
// Using WITH for map projection
// Return a map projection of the top 10 movies by IMDb rating:
MATCH (n:Movie)
WHERE n.imdbRating IS NOT NULL
WITH n {
  .title,
  .imdbRating
}
ORDER BY n.imdbRating DESC
LIMIT 10
RETURN collect(n)

// add the following properties to the map projection:
// plot, released, countries
MATCH (n:Movie)
WHERE n.imdbRating IS NOT NULL
WITH n {
  .title,
  .imdbRating,
  .plot,
  .released,
  .countries
}
ORDER BY n.imdbRating DESC
LIMIT 10
RETURN collect(n)

// Adding Genres
// Add relationships to a map projection
// Return the actors in the top 10 movies by IMDb rating:
MATCH (n:Movie)
WHERE n.imdbRating IS NOT NULL
WITH n {
  .title,
  .imdbRating,
  actors: [ (n)<-[:ACTED_IN]-(p) | p { .imdbId, .name } ]
}
ORDER BY n.imdbRating DESC
LIMIT 10
RETURN collect(n)

// Modify this query to add the genres to the map projection.
// You will need to use the IN_GENRE relationship and return the name property for each genre.
MATCH (n:Movie)
WHERE n.imdbRating IS NOT NULL
WITH n {
  .title,
  .imdbRating,
  actors: [ (n)<-[:ACTED_IN]-(p) | p { .imdbId, .name } ],
  genres: [ (n)-[:IN_GENRE]->(g) | g {.name} ]
}
ORDER BY n.imdbRating DESC
LIMIT 10
RETURN collect(n)

// ***************************************************************

// PIPELINING QUERIES:

// Limiting results
// Return the names of Directors who directed movies that Keanu Reeves acted in, limit the number of rows returned to 3:
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name = 'Keanu Reeves'
WITH m LIMIT 3
MATCH (d:Person)-[:DIRECTED]->(m)
RETURN collect(d.name) AS directors,
m.title AS movies

// Highest Rated Tom Hanks Movie
// Using WITH to pass on intermediate results
// Determine the highest average rating for a Tom Hanks movie:
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)<-[r:RATED]-(:User)
WHERE p.name = 'Tom Hanks'
WITH m, avg(r.rating) AS avgRating
WHERE avgRating > 4
RETURN m.title AS Movie, avgRating AS `AverageRating`
ORDER BY avgRating DESC

// ***************************************************************

// UNWINDING LISTS:

// Return the title of a movie and language pair for any Tom Hanks movie that has exactly two languages associated with it. 
// Each movie will have two rows, the title is repeated and then each language for that title. 
// Create a lang value that is an element of the languages list:
MATCH (m:Movie)-[:ACTED_IN]-(a:Actor)
WHERE a.name = 'Tom Hanks'
AND size(m.languages) = 2
UNWIND m.languages as lang
RETURN m.title AS movie,lang AS languages

// What type of data can UNWIND be used for?
// - List of strings
// - List of numerics

// UK Movies
// Using UNWIND pass on intermediate results
// Find the number of movies containing each language:
MATCH (m:Movie)
UNWIND m.languages AS lang
WITH m, trim(lang) AS language
WITH language, collect(m.title) AS movies
RETURN language, size(movies)

// How many movies released in the UK are in the graph?
// here trimmedCountry is distinct because it's a grouping key
MATCH (m:Movie)
UNWIND m.countries AS country
WITH m, trim(country) AS trimmedCountry
WITH trimmedCountry, collect(m.title) AS movies
RETURN trimmedCountry, size(movies)

// Switzerland Movies
// Using UNWIND pass on intermediate results
// Filter the movies produced in Switzerland:
MATCH (m:Movie)
UNWIND m.countries AS country
WITH m, trim(country) AS trimmedCountry
WHERE trimmedCountry = 'Switzerland'
WITH trimmedCountry, collect(m.title) AS movies
RETURN trimmedCountry, size(movies)

// ***************************************************************

// REDUCING MEMORY:

// Using a subquery
// Here is a query that has a subquery. The enclosing query finds all User nodes. 
// The subquery finds all movies that this user rated with 5 and return them.
MATCH (u:User)
CALL {
  with u
  MATCH (m:Movie)<-[r:RATED]-(u)
     WHERE r.rating = 5
    RETURN m
}
RETURN m.title, count(m) AS numReviews
ORDER BY numReviews DESC

// Using Subqueries
// Add a subquery
// Top Genres
// Find the number of movies in each genre that have a imdbRating greater than 9:
MATCH (g:Genre)
CALL { 
    WITH g
    MATCH (g)<-[:IN_GENRE]-(m) WHERE m.imdbRating > 9
    RETURN count(m) AS numMovies
}
RETURN g.name AS Genre, numMovies 
ORDER BY numMovies DESC

// Combining Results
// Combining actors and directors data
// Actors and Directors from 2015
MATCH (m:Movie)<-[:ACTED_IN]-(p:Person)
WHERE m.year = 2015
RETURN "Actor" AS type,
p.name AS workedAs,
collect(m.title) AS movies
UNION ALL
MATCH (m:Movie)<-[:DIRECTED]-(p:Person)
WHERE m.year = 2015
RETURN "Director" AS type,
p.name AS workedAs,
collect(m.title) AS movies

// ***************************************************************

// USING PARAMETERS:

// Set the following parameters:
:params {actorName: 'Tom Cruise', movieName: 'Top Gun', l:2}

// Return the names of the actors in a particular movie that is parameterized. 
// The number of results returned is also parameterized.
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE m.title = $movieName
RETURN p.name
LIMIT $l

// What command in Neo4j Browser returns all parameters set for the session?
// : params

// Setting Integers:
// Which command would you use to ensure that the value of the myNumber parameter is cast as an integer?
:param myNumber ⇒ 10

// Given the following query which finds all users with a name beginning with the string value supplied in the $name parameter.
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name STARTS WITH $name
RETURN p.name AS actor,
m.title AS title

// What commands would you run in Neo4j Browser to set the $name parameter to Tom?
:param name: 'Tom'
:params {name: 'Tom'}

// Using Parameters
// 1. Set Parameters:
:param name => 'Tom';
:param country => 'UK';

// 2. Run the query:
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name STARTS WITH $name
AND $country IN m.countries
RETURN p.name AS actor,
m.title AS title

// ***************************************************************

// APPLICATION EXAMPLES USING PARAMETERS:

// Example: Java
// In this example, the parameters are passed to the second argument of the tx.run method 
// using the static parameters function provided by the org.neo4j.driver.Values class.
try (var session = driver.session()) {
  Result res = session.readTransaction(tx -> tx.run("""
    MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
    WHERE m.title = $title
    RETURN p
    LIMIT 10
  """, Values.parameters("title", "Toy Story")));
}

// Example: JavaScript
// In this example, the parameters are passed to the second argument of the tx.run method as a JavaScript object.
const session = driver.session()
const res = await session.readTransaction(tx =>
  tx.run(`
    MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
    WHERE m.title = $title
    RETURN p
    LIMIT 10
  `,
  { title: 'Toy Story'})
)

// Example: Python
// In Python, Cypher parameters are passed as named parameters to the tx.run method. 
// In this example, title has been passed as a named parameter.
def get_actors(tx, movieTitle): # (1)
  result = tx.run("""
    MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
    WHERE m.title = $title
    RETURN p
  """, title=movieTitle)

  # Access the `p` value from each record
  return [ record["p"] for record in result ]

with driver.session() as session:
    result = session.read_transaction(get_actors, movieTitle="Toy Story")

// ***************************************************************
