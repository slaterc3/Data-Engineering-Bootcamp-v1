-- select * from players2 limit 25;
-- INSERT INTO actors
WITH years AS (
	SELECT generate_series(1970, 2021) AS year
), actor_first_year AS (
	SELECT 
		actor,
		actorid,
		MIN(year) AS first_year
	FROM actor_films
	GROUP BY actor, actorid
), actors_and_years AS (
	SELECT 
		afy.actor,
		afy.actorid,
		y.year AS current_year
	FROM actor_first_year afy
	JOIN years y 
		ON afy.first_year <= y.year
), agg_data AS (
	SELECT 
		ay.actor,
		ay.actorid,
		ay.current_year,
		ARRAY_REMOVE(
			ARRAY_AGG(
				CASE 
					WHEN af.year IS NOT NULL THEN
						ROW(
							af.year,
							af.film,
							af.votes,
							af.rating,	
							af.filmid
						)::films
				END
			) OVER (
				PARTITION BY ay.actorid ORDER BY af.year
			), NULL
		) AS agg_films,
		AVG(af.rating) FILTER (WHERE af.year=ay.current_year) AS avg_rating
		FROM actors_and_years ay
		LEFT JOIN actor_films af
			ON ay.actorid = af.actorid
			AND ay.current_year = af.year
	-- GROUP BY ay.actor, ay.actorid, ay.current_year
), quality_active AS (
	SELECT
		ad.actor,
		ad.actorid,
		ad.agg_films AS films, 
		CASE 
			WHEN ad.avg_rating > 8 THEN 'star'
			WHEN ad.avg_rating > 7 THEN 'good'
			WHEN ad.avg_rating > 6 THEN 'average'
			ELSE 'bad'
		END AS quality_class,
		ad.current_year,
		ad.avg_rating IS NOT NULL AS is_active
	FROM agg_data ad
)
SELECT *
	-- qa.actor,
	-- qa.actorid,
	-- qa.films,
	-- qa.quality_class,
	-- qa.current_year,
	-- qa.is_active
FROM quality_active qa
ORDER BY qa.actorid, qa.current_year;
	
	-- LIMIT 25;

WITH years AS (
    -- Generate a range of years dynamically
    SELECT generate_series(1970, 2022) AS year
), actors_with_first_year AS (
    -- Identify the first year each actor appeared in a film
    SELECT 
        actor,
        actorid,
        MIN(year) AS first_year
    FROM actor_films
    GROUP BY actor, actorid
), actors_and_years AS (
    -- Create a record for every year from the actor's first appearance onward
    SELECT 
        afy.actor,
        afy.actorid,
        y.year AS current_year
    FROM actors_with_first_year afy
    JOIN years y
        ON afy.first_year <= y.year
), cumulative_films AS (
    -- Use DISTINCT ON to avoid GROUP BY and aggregate cumulative films
    SELECT DISTINCT ON (aay.actorid, aay.current_year)
        aay.actor,
        aay.actorid,
        aay.current_year,
        ARRAY_REMOVE(
            ARRAY_AGG(
                CASE 
                    WHEN af.year <= aay.current_year THEN
                        ROW(
                            af.year,
                            af.film,
                            af.votes,
                            af.rating,
                            af.filmid
                        )::films
                END
            ) OVER (
                PARTITION BY aay.actorid
                ORDER BY aay.current_year
            ), NULL
        ) AS cumulative_films,
        AVG(af.rating) FILTER (WHERE af.year = aay.current_year) AS avg_rating
    FROM actors_and_years aay
    LEFT JOIN actor_films af
        ON aay.actorid = af.actorid
        AND af.year = aay.current_year
), quality_active AS (
    -- Determine quality_class and is_active status
    SELECT
        cf.actor,
        cf.actorid,
        cf.current_year,
        cf.cumulative_films AS films,
        CASE
            WHEN cf.avg_rating > 8 THEN 'star'
            WHEN cf.avg_rating > 7 THEN 'good'
            WHEN cf.avg_rating > 6 THEN 'average'
            ELSE 'bad'
        END AS quality_class,
        cf.avg_rating IS NOT NULL AS is_active
    FROM cumulative_films cf
)
SELECT * 
FROM quality_active
ORDER BY actorid, current_year;
