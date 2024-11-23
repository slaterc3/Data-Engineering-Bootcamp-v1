SELECT * FROM player_seasons limit 25;

CREATE TYPE season_stats_struct AS (
	season INTEGER,
	gp INTEGER,
	pts REAL,
	reb REAL,
	ast REAL
)

drop table players2;

CREATE TABLE players2 (
	player_name TEXT,
	height TEXT,
	college TEXT,
	country TEXT,
	draft_year TEXT,
	draft_round TEXT,
	draft_number TEXT,
	season_stats season_stats_struct[],
	current_season INTEGER,
	PRIMARY KEY(player_name, current_season)
);
