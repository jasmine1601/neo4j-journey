// GRAPH DATA MODELING FUNDAMENTALS
// -----------------------------------------------------------------

// Modeling Nodes:
// ~~~~~~~~~~~~~~~~~~~~~~~
// CREATING NODES:

// Add the Person and Movie nodes to the graph which is the initial instance model:
MATCH (n) DETACH DELETE n;

MERGE (:Movie {title: 'Apollo 13', tmdbId: 568, released: '1995-06-30', imdbRating: 7.6, genres: ['Drama', 'Adventure', 'IMAX']})
MERGE (:Person {name: 'Tom Hanks', tmdbId: 31, born: '1956-07-09'})
MERGE (:Person {name: 'Meg Ryan', tmdbId: 5344, born: '1961-11-19'})
MERGE (:Person {name: 'Danny DeVito', tmdbId: 518, born: '1944-11-17'})
MERGE (:Person {name: 'Jack Nicholson', tmdbId: 514, born: '1937-04-22'})
MERGE (:Movie {title: 'Sleepless in Seattle', tmdbId: 858, released: '1993-06-25', imdbRating: 6.8, genres: ['Comedy', 'Drama', 'Romance']})
MERGE (:Movie {title: 'Hoffa', tmdbId: 10410, released: '1992-12-25', imdbRating: 6.6, genres: ['Crime', 'Drama']})

// Validate creation:
MATCH (n) RETURN n

// ***************************************************************

// CREATING MORE NODES:

// Add 2 more users
MERGE (u:User {userId: 534})
SET u.name = "Sandy Jones"

MERGE (u:User {userId: 105})
SET u.name = "Clinton Spencer"

// ***************************************************************

// Modeling Relationships:
// ~~~~~~~~~~~~~~~~~~~~~~~
// CREATING INITIAL RELATIONSHIPS:

// Add the ACTED_IN and DIRECTED relationships to the graph:
MATCH (apollo:Movie {title: 'Apollo 13'})
MATCH (tom:Person {name: 'Tom Hanks'})
MATCH (meg:Person {name: 'Meg Ryan'})
MATCH (danny:Person {name: 'Danny DeVito'})
MATCH (sleep:Movie {title: 'Sleepless in Seattle'})
MATCH (hoffa:Movie {title: 'Hoffa'})
MATCH (jack:Person {name: 'Jack Nicholson'})

// Create the relationships between nodes
MERGE (tom)-[:ACTED_IN {role: 'Jim Lovell'}]->(apollo)
MERGE (tom)-[:ACTED_IN {role: 'Sam Baldwin'}]->(sleep)
MERGE (meg)-[:ACTED_IN {role: 'Annie Reed'}]->(sleep)
MERGE (danny)-[:ACTED_IN {role: 'Bobby Ciaro'}]->(hoffa)
MERGE (danny)-[:DIRECTED]->(hoffa)
MERGE (jack)-[:ACTED_IN {role: 'Jimmy Hoffa'}]->(hoffa)

// Validate creation:
MATCH (n) RETURN n

// ***************************************************************

// CREATING MORE RELATIONSHIPS:

// Create RATED relationships that include the rating property
MATCH (sandy:User {name: 'Sandy Jones'})
MATCH (clinton:User {name: 'Clinton Spencer'})
MATCH (apollo:Movie {title: 'Apollo 13'})
MATCH (sleep:Movie {title: 'Sleepless in Seattle'})
MATCH (hoffa:Movie {title: 'Hoffa'})
MERGE (sandy)-[:RATED {rating:5}]->(apollo)
MERGE (sandy)-[:RATED {rating:4}]->(sleep)
MERGE (clinton)-[:RATED {rating:3}]->(apollo)
MERGE (clinton)-[:RATED {rating:3}]->(sleep)
MERGE (clinton)-[:RATED {rating:3}]->(hoffa)

// ***************************************************************

// Testing the model:
// ~~~~~~~~~~~~~~~~~
// TESTING WITH INSTANCE MODEL:

// Use case #1: What people acted in a movie?
MATCH (p:Person)-[:ACTED_IN]-(m:Movie)
WHERE m.title = 'Sleepless in Seattle'
RETURN p.name AS Actor

// Use case #2: What person directed a movie?
MATCH (p:Person)-[:DIRECTED]-(m:Movie)
WHERE m.title = 'Hoffa'
RETURN  p.name AS Director

// Use case #3: What movies did a person act in?
MATCH (p:Person)-[:ACTED_IN]-(m:Movie)
WHERE p.name = 'Tom Hanks'
RETURN m.title AS Movie

// Use case #4: How many users rated a movie?
MATCH (u:User)-[:RATED]-(m:Movie)
WHERE m.title = 'Apollo 13'
RETURN count(*) AS `Number of reviewers`

// Use case #5: Who was the youngest person to act in a movie?
MATCH (p:Person)-[:ACTED_IN]-(m:Movie)
WHERE m.title = 'Hoffa'
RETURN  p.name AS Actor, p.born as `Year Born` ORDER BY p.born DESC LIMIT 1

// Use case #6: What role did a person play in a movie?
MATCH (p:Person)-[r:ACTED_IN]-(m:Movie)
WHERE m.title = 'Sleepless in Seattle' AND
p.name = 'Meg Ryan'
RETURN  r.role AS Role

// Add another 1995 released movie
MERGE (casino:Movie {title: 'Casino', tmdbId: 524, released: '1995-11-22', imdbRating: 8.2, genres: ['Drama','Crime']})
MERGE (martin:Person {name: 'Martin Scorsese', tmdbId: 1032})
MERGE (martin)-[:DIRECTED]->(casino)

// Use case #7: What is the highest rated movie in a particular year according to imDB?
MATCH (m:Movie)
WHERE m.released STARTS WITH '1995'
RETURN  m.title as Movie, m.imdbRating as Rating ORDER BY m.imdbRating DESC LIMIT 1

// Use case #8: What drama movies did an actor act in?
MATCH (p:Person)-[:ACTED_IN]-(m:Movie)
WHERE p.name = 'Tom Hanks' AND
'Drama' IN m.genres
RETURN m.title AS Movie

// Use case #9: What users gave a movie a rating of 5?
MATCH (u:User)-[r:RATED]-(m:Movie)
WHERE m.title = 'Apollo 13' AND
r.rating = 5
RETURN u.name as Reviewer

// ***************************************************************

// Refactoring the Graph:
// ~~~~~~~~~~~~~~~~~~~~~
// ADDING THE ACTOR LABEL:

// Profile the query:
PROFILE MATCH (p:Person)-[:ACTED_IN]-()
WHERE p.born < '1950'
RETURN p.name

// Refactor the graph:
// Add the Actor label:
MATCH (p:Person)
WHERE exists ((p)-[:ACTED_IN]-())
SET p:Actor

// Profile again after refactoring:
PROFILE MATCH (p:Actor)-[:ACTED_IN]-()
WHERE p.born < '1950'
RETURN p.name

// Retesting with Actor Label:
// Use case #1: What people acted in a movie?
MATCH (p:Actor)-[:ACTED_IN]-(m:Movie)
WHERE m.title = 'Sleepless in Seattle'
RETURN p.name AS Actor

// Use case #3: What movies did a person act in?
MATCH (p:Actor)-[:ACTED_IN]-(m:Movie)
WHERE p.name = 'Tom Hanks'
RETURN m.title AS Movie

// Use case #5: Who was the youngest person to act in a movie?
MATCH (p:Actor)-[:ACTED_IN]-(m:Movie)
WHERE m.title = 'Hoffa'
RETURN  p.name AS Actor, p.born as `Year Born` ORDER BY p.born DESC LIMIT 1

// Use case #6: What role did a person play in a movie?
MATCH (p:Actor)-[r:ACTED_IN]-(m:Movie)
WHERE m.title = 'Sleepless in Seattle' AND
p.name = 'Meg Ryan'
RETURN  r.role AS Role

// Use case #8: What drama movies did an actor act in?
MATCH (p:Actor)-[:ACTED_IN]-(m:Movie)
WHERE p.name = 'Tom Hanks' AND
'Drama' IN m.genres
RETURN m.title AS Movie

// Use case #10: What actors were born before 1950?
MATCH (p:Actor)
WHERE p.born < '1950'
RETURN p.name

// ***************************************************************

// ADDING THE DIRECTOR LABEL:

// Refactor the graph:
MATCH (p:Person) WHERE exists ((p)-[:DIRECTED]-()) SET p:Director

// Use case #2: What person directed a movie?
MATCH (p:Director)-[:DIRECTED]-(m:Movie)
WHERE m.title = 'Hoffa'
RETURN  p.name AS Director

// ***************************************************************

// Eliminating Duplicate Data:
// ~~~~~~~~~~~~~~~~~~~~~~~~~~
// ADDING LANGUAGE DATA:

// To illustrate duplication of data, add a languages property to each Movie node in the instance model:
MATCH (apollo:Movie {title: 'Apollo 13', tmdbId: 568, released: '1995-06-30', imdbRating: 7.6, genres: ['Drama', 'Adventure', 'IMAX']})
MATCH (sleep:Movie {title: 'Sleepless in Seattle', tmdbId: 858, released: '1993-06-25', imdbRating: 6.8, genres: ['Comedy', 'Drama', 'Romance']})
MATCH (hoffa:Movie {title: 'Hoffa', tmdbId: 10410, released: '1992-12-25', imdbRating: 6.6, genres: ['Crime', 'Drama']})
MATCH (casino:Movie {title: 'Casino', tmdbId: 524, released: '1995-11-22', imdbRating: 8.2, genres: ['Drama','Crime']})
SET apollo.languages = ['English']
SET sleep.languages =  ['English']
SET hoffa.languages =  ['English', 'Italian', 'Latin']
SET casino.languages =  ['English']

// Use case #11: What movies are available in a particular language?
MATCH (m:Movie)
WHERE 'Italian' IN m.languages
RETURN m.title

// ***************************************************************

// ADDING LANGUAGE NODES:

// Refactor graph to turn the languages property values into Language nodes:
MATCH (m:Movie)
UNWIND m.languages AS language
WITH  language, collect(m) AS movies
MERGE (l:Language {name:language})
WITH l, movies
UNWIND movies AS m
WITH l,m
MERGE (m)-[:IN_LANGUAGE]->(l);
MATCH (m:Movie)
SET m.languages = null

// Use case #11: What movies are available in a particular language?
// Query using new Language node:
MATCH (m:Movie)-[:IN_LANGUAGE]-(l:Language)
WHERE  l.name = 'Italian'
RETURN m.title

// ***************************************************************

// ADDING GENRE NODES:

// Use the data in the genres property for the Movie nodes
// Create Genre nodes using the IN_GENRE relationship to connect Movie nodes to Genre nodes
// Delete the genres property from the Movie nodes
MATCH (m:Movie)
UNWIND m.genres AS genre
WITH genre, collect(m) AS movies
MERGE (g:Genre {name:genre})
WITH g, movies
UNWIND movies AS m
WITH g,m
MERGE (m)-[:IN_GENRE]->(g);
MATCH (m:Movie)
SET m.genres = null

// Use case #8: What drama movies did an actor act in?
MATCH (p:Actor)-[:ACTED_IN]-(m:Movie)
MATCH (m:Movie)-[:IN_GENRE]-(g:Genre)
WHERE p.name = 'Tom Hanks' AND g.name = 'Drama'
RETURN m.title AS Movie

// ***************************************************************

// SPECIALIZING ACTED_IN & DIRECTED RELATIONSHIPS:

// 1. Refactor all ACTED_IN relationships:
// Create a new set of relationships based on the year of the released property for each Node:
MATCH (n:Actor)-[:ACTED_IN]->(m:Movie)
CALL apoc.merge.relationship(n,
  'ACTED_IN_' + left(m.released,4),
  {},
  {},
  m ,
  {}
) YIELD rel
RETURN count(*) AS `Number of relationships merged`;

// Use case #12: What movies did an actor act in for a particular year?
MATCH (p:Actor)-[:ACTED_IN_1995]->(m:Movie)
WHERE p.name = 'Tom Hanks'
RETURN m.title AS Movie

// 2. Refactor all DIRECTED relationships:
// Create DIRECTED_{year} relationships between the Director and the Movie:
MATCH (n:Director)-[:DIRECTED]->(m:Movie)
CALL apoc.merge.relationship(n,
  'DIRECTED_' + left(m.released,4),
  {},
  {},
  m ,
  {}
) YIELD rel
RETURN count(*) AS `Number of relationships merged`;

// Use case #12: What movies did an actor act in for a particular year?
MATCH (p:Person)-[:ACTED_IN_1995|DIRECTED_1995]->()
RETURN p.name as `Actor or Director`

// ***************************************************************

// SPECIALIZING RATED RELATIONSHIPS:

// Refactoring:
MATCH (u:User)-[r:RATED]->(m:Movie)
CALL apoc.merge.relationship(u,
  'RATED_'+ r.rating,
  {},
  {},
  m ,
  {}
) YIELD rel
RETURN count(*) AS `Number of relationships merged`

// ***************************************************************

// Adding Intermediate Nodes:
// ~~~~~~~~~~~~~~~~~~~~~~~~~
// ADDING A ROLE NODE:

// 1. Match the Actor, ACTED_IN relationship, and Movie
// 2. Create a Role node and set its name to the role property of ACTED_IN
// 2. Create a PLAYED relationship between the Actor and the Role node
// 4. Create an IN_MOVIE relationship between the Role and the Movie node
MATCH (a:Actor)-[r:ACTED_IN]->(m:Movie)
MERGE (role:Role {name: r.role})
MERGE (a)-[:PLAYED]->(role)
MERGE (role)-[:IN_MOVIE]->(m)
RETURN a, role, m

// ***************************************************************
