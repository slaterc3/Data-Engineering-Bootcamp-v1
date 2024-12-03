-- - `quality_class`: This field represents an actor's performance quality, determined by the average rating of movies of their most recent year. It's categorized as follows:

-- --     - `is_active`: A BOOLEAN field that indicates whether an actor is currently active in the film industry (i.e., making films this year).
-- - `films`: An array of `struct` with the following fields:
-- 		- film: The name of the film.
-- 		- votes: The number of votes the film received.
-- 		- rating: The rating of the film.
-- 		- filmid: A unique identifier for each film.

-- -- select * from actor_films limit 10;

-- drop table actors;

CREATE TYPE films AS (
	year INTEGER,
	film TEXT,
	votes INTEGER,
	rating REAL,
	filmid TEXT
);

CREATE TYPE quality_class AS 
	ENUM ('bad', 'average', 'good', 'star');

CREATE TABLE actors (
	actor TEXT,
	actorid TEXT,
	films films[],
	quality_class quality_class,
	current_year INTEGER,
	is_active BOOLEAN,
	PRIMARY KEY(actorid, current_year)
);

-- drop table actors;

select * from actor_films;

-- select actorid, year, count(film) 
-- from actor_films
-- group by actorid, year;

-- select * FROM actor_films;

-- DO $$
-- DECLARE
--     year_start INT := 1970; -- Starting year
--     year_end INT := 2021;   -- Ending year
--     asofyear INT;       -- Loop variable for previous year
-- BEGIN
--     -- Loop from the starting year to the ending year
--     FOR asofyear IN year_start..year_end LOOP
--         <put your yearly code filling here>       
--     END LOOP;
-- END $$;

-- select * from actor_films;
-- INSERT INTO actors
-- WITH yesteryear AS (
-- 	SELECT * FROM actors
-- 	WHERE film_year = 1969
-- ),
-- 	curr_year AS (
-- 		SELECT * FROM actor_films
-- 		WHERE year = 1970
-- 	)
-- SELECT 
-- 	COALESCE(c.actorid, y.actorid) AS actorid,
-- 	COALESCE(c.actor, y.actor) AS actor,
-- 	-- COALESCE(c.year, y.film_year) AS film_year,
-- 	COALESCE(c.year, y.film_year + 1) AS film_year,
-- 	CASE WHEN y.films IS NULL 
-- 		THEN ARRAY[ROW(
-- 			c.film,
-- 			c.votes,
-- 			c.rating,
-- 			c.filmid
-- 		)::films]
-- 	WHEN c.year IS NOT NULL THEN y.films || ARRAY[ROW(
-- 			c.film,
-- 			c.votes,
-- 			c.rating,
-- 			c.filmid
-- 		)::films]
-- 	ELSE y.films
-- 	END AS films,
-- 	-- 		- `star`: Average rating > 8.
-- -- 		- `good`: Average rating > 7 and ≤ 8.
-- -- 		- `average`: Average rating > 6 and ≤ 7.
-- -- 		- `bad`: Average rating ≤ 6.
-- 	CASE WHEN c.year IS NOT NULL THEN
-- 	CASE WHEN c.rating > 8 THEN 'star'
-- 		WHEN c.rating > 7 THEN 'good'
-- 		WHEN c.rating > 6 THEN 'average'
-- 		ELSE 'bad'
-- 		END::quality_class
-- 	ELSE y.quality_class
-- 	END AS quality_class,
-- 	CASE WHEN c.year = y.film_year THEN True
-- 		ELSE False END AS is_active
-- FROM curr_year c 
-- FULL OUTER JOIN yesteryear y
-- 	ON c.actor = y.actor;
-- -- LIMIT 20;

-- -- drop type films;
