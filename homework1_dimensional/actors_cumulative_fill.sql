INSERT INTO actors
WITH years AS (
	SELECT * FROM generate_series(1970, 2021) AS year
), actor AS (
	SELECT
		actor,
		actorid,
		MIN(year) AS first_year
	FROM actor_films
	GROUP BY actor, actorid
), actors_and_years AS (
	SELECT *
	FROM actor
	JOIN years y 
		ON actor.first_year <= y.year
), windowed AS (
	SELECT 
		aay.actor,
		aay.actorid,
		aay.year AS current_year,
		ARRAY_REMOVE(
			ARRAY_AGG(
				CASE
					WHEN af.year IS NOT NULL
						THEN ROW(
							af.year,
							af.film,
							af.votes,
							af.rating,
							af.filmid
					)::films
				END)
			OVER(PARTITION BY
					aay.actorid
					ORDER BY aay.year
				-- COALESCE(aay.year, af.year)),
				), NULL
		) AS films
	FROM actors_and_years aay
	LEFT JOIN actor_films af
		ON aay.actorid = af.actorid
		AND aay.year = af.year
	ORDER BY aay.actorid, aay.year
), static AS (
	SELECT 
		MAX(actor) AS actor,
		actorid
		-- MAX(year) AS year
	FROM actor_films
	GROUP BY actorid
)
SELECT DISTINCT ON (w.actorid, w.current_year)
	w.actor,
	w.actorid,
	w.films,
	CASE 
		WHEN (films[CARDINALITY(films)]::films).rating > 8 THEN 'star'
		WHEN (films[CARDINALITY(films)]::films).rating > 7 THEN 'good'
		WHEN (films[CARDINALITY(films)]::films).rating > 6 THEN 'average'
		ELSE 'bad'
	END::quality_class AS quality_class,
	w.current_year,
	(films[CARDINALITY(films)]::films).year = current_year AS is_active
FROM windowed w 
JOIN static s 
	ON w.actorid = s.actorid;