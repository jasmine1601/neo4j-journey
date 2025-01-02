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
