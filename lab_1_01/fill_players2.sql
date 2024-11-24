-- truncate table players2;
INSERT INTO players2
WITH yesterday AS (
	SELECT * FROM players2
	WHERE current_season = 2000
),
	today AS (
		SELECT * FROM player_seasons
		WHERE season = 2001
	)
SELECT 
	COALESCE(t.player_name, y.player_name) AS player_name,
	COALESCE(t.height, y.height) AS height,
	COALESCE(t.college, y.college) AS college,
	COALESCE(t.country, y.country) AS country,
	COALESCE(t.draft_year, y.draft_year) AS draft_year,
	COALESCE(t.draft_round, y.draft_round) AS draft_round,
	COALESCE(t.draft_number, y.draft_number) AS draft_number,
	CASE WHEN y.season_stats IS NULL
		THEN ARRAY[ROW(
			t.season,
			t.gp,
			t.pts,
			t.reb,
			t.ast
		)::season_stats_struct]
	WHEN t.season IS NOT NULL 
	THEN y.season_stats || ARRAY[ROW(
			t.season,
			t.gp,
			t.pts,
			t.reb,
			t.ast
		)::season_stats_struct]
	ELSE y.season_stats
	END AS season_stats,
	CASE WHEN t.season IS NOT NULL THEN
		CASE WHEN t.pts > 20 THEN 'star'
			WHEN t.pts > 15 THEN 'good'
			WHEN t.pts > 10 THEN 'average'
			ELSE 'bad'
	END::scoring_class_struct 
	ELSE y.scoring_class
	END AS scoring_class,
	CASE WHEN t.season IS NOT NULL THEN 0
		ELSE y.years_since_last_season + 1
	END AS years_since_last_season,
	COALESCE(t.season, y.current_season+1) AS current_season
FROM today t
FULL OUTER JOIN yesterday y 
	ON t.player_name = y.player_name;

-- select player_name,
-- 	(UNNEST(season_stats)::season_stats_struct).*
-- 	from players2;

SELECT 
	player_name,
(season_stats[CARDINALITY(season_stats)]::season_stats_struct).pts /
	CASE WHEN (season_stats[1]::season_stats_struct).pts=0 THEN 1
	ELSE (season_stats[1]::season_stats_struct).pts END
	AS latest_season
FROM players2
WHERE current_season = 2001
	AND scoring_class = 'star'
	ORDER BY 2 DESC;
-- AND player_name = 'Michael Jordan'