
INSERT INTO actors
WITH last_year AS (
   SELECT *
   FROM actors
   WHERE film_year = 1969
), 
this_year AS (
   SELECT
    actorid,
    actor,
    year,
    CASE WHEN year IS NULL THEN ARRAY[]::films[]
         ELSE ARRAY_AGG(ROW(film, votes, rating, filmid)::films)
    END AS films
   FROM actor_films
   WHERE year = 1970
   GROUP BY actorid, actor,year
)
-- INSERT INTO actors
SELECT
    COALESCE(ty.actorid, ly.actorid) actorid, 
    COALESCE(ty.actor, ly.actor) actor,
	COALESCE(ty.year,ly.film_year+1) as film_year,
    COALESCE(ly.films, ARRAY[]::films[]) || 
                     CASE WHEN ty.year IS NOT NULL THEN ty.films
                     ELSE ARRAY[]::films[]
            END as films,
FROM last_year ly
FULL OUTER JOIN this_year ty
    ON ly.actorid = ty.actorid;


select * from actor_films limit 25;