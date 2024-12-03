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