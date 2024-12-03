-- Insert into actors table

-- INSERT INTO actors
-- WITH min_max_years AS (
--     SELECT MIN(year) AS min_year, MAX(year) AS max_year FROM actor_films
-- ),
WITH years AS (
    SELECT * FROM generate_series(1970, 2021) AS year
),
actors AS (
    SELECT DISTINCT actorid, actor FROM actor_films
),
actors_first_year AS (
    SELECT
        actorid,
        MIN(year) AS first_year
    FROM actor_films
    GROUP BY actorid
),
actors_and_years AS (
    SELECT
        a.actorid,
        a.actor,
        y.year AS current_year
    FROM actors a
    JOIN actors_first_year afy ON a.actorid = afy.actorid
    JOIN years y ON afy.first_year <= y.year
),
windowed AS (
    SELECT
        aay.actorid,
        aay.actor,
        aay.current_year,
        (
            SELECT ARRAY_AGG(
                ROW(af.year, af.film, af.votes, af.rating, af.filmid)::films
                ORDER BY af.year
            )
            FROM actor_films af
            WHERE af.actorid = aay.actorid
              AND af.year <= aay.current_year
        ) AS films,
        (
            SELECT MAX(af.year)
            FROM actor_films af
            WHERE af.actorid = aay.actorid
              AND af.year <= aay.current_year
        ) AS last_film_year,
        (
            SELECT AVG(af.rating)
            FROM actor_films af
            WHERE af.actorid = aay.actorid
              AND af.year = (
                  SELECT MAX(af2.year)
                  FROM actor_films af2
                  WHERE af2.actorid = aay.actorid
                    AND af2.year <= aay.current_year
              )
        ) AS avg_rating,
        EXISTS(
            SELECT 1
            FROM actor_films af
            WHERE af.actorid = aay.actorid
              AND af.year = aay.current_year
        ) AS is_active
    FROM actors_and_years aay
)
SELECT
    w.actor,
    w.actorid,
    w.films,
    CASE
        WHEN w.avg_rating IS NULL THEN NULL
        WHEN w.avg_rating > 8 THEN 'star'
        WHEN w.avg_rating > 7 THEN 'good'
        WHEN w.avg_rating > 6 THEN 'average'
        ELSE 'bad'
    END::quality_class AS quality_class,
    w.current_year,
    w.is_active
FROM windowed w
ORDER BY w.actorid, w.current_year;


