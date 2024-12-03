

INSERT INTO actors_scd
WITH last_year_scd AS (
	SELECT * FROM actors_scd
	WHERE current_year = (SELECT MAX(current_year) FROM actors)
	AND end_year = (SELECT MAX(current_year) FROM actors)
),
	historical_scd AS (
	SELECT 
		actor,
		actorid,
		quality_class,
		is_active,
		start_year,
		end_year
	FROM actors_scd
	WHERE current_year = (SELECT MAX(current_year) FROM actors)
	AND end_year < (SELECT MAX(current_year) FROM actors)
	),
	this_year_data AS (
		SELECT * FROM actors
		WHERE current_year = (SELECT MAX(current_year) FROM actors)
	), unchanged_records AS (
		SELECT 
	ty.actor,
	ty.actorid,
	ty.quality_class,
	ty.is_active,
	ly.start_year, 
	ty.current_year AS end_year
FROM this_year_data ty
JOIN last_year_scd ly
	ON ly.actorid = ty.actorid
WHERE ty.quality_class = ly.quality_class
AND ty.is_active = ly.is_active
	), changed_records AS (
	SELECT 
	ty.actor,
	ty.actorid,
	ty.quality_class,
	UNNEST(ARRAY[
		ROW(
			ly.quality_class,
			ly.is_active,
			ly.start_year,
			ly.end_year
		)::scd_type,
		ROW(
			ty.quality_class,
			ty.is_active,
			ty.current_year,
			ty.current_year
		)::scd_type
	]) AS records
FROM this_year_data ty
LEFT JOIN last_year_scd ly
	ON ly.actorid = ty.actorid
WHERE (ty.quality_class <> ly.quality_class
OR ty.is_active = ly.is_active)
	-- OR ly.actorid IS NULL
	), unnested_changed_records AS (
	SELECT 
		actor,
		actorid,
		(records::scd_type).*
	FROM changed_records
	), new_records AS (
	SELECT 
		ty.actor,
		ty.actorid,
		ty.quality_class,
		ty.is_active,
		ty.current_year AS start_year,
		ty.current_year AS end_year
	FROM this_year_data ty
	LEFT JOIN last_year_scd ly
		ON ty.actorid = ly.actorid
	WHERE ly.actorid IS NULL
	)
SELECT * FROM historical_scd
UNION ALL
SELECT * FROM unchanged_records
UNION ALL
SELECT * FROM unnested_changed_records
UNION ALL
SELECT * FROM new_records;