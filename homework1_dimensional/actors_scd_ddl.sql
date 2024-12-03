CREATE TYPE scd_type AS (
    quality_class quality_class,
	is_active BOOLEAN,
	start_year INTEGER, 
	end_year INTEGER
);

CREATE TABLE actors_scd (
	actor TEXT,
	actorid TEXT,
	quality_class quality_class,
	is_active BOOLEAN,
	start_year INTEGER,
	end_year INTEGER,
	current_year INTEGER,
	PRIMARY KEY(actorid, start_year)
);