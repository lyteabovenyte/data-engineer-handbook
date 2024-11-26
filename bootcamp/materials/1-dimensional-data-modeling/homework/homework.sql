
-- drop type films_struct;

-- CREATE TYPE quality_class AS ENUM('star', 'good', 'average', 'bad');
drop table actors;

CREATE TABLE actors (
                        actor text,
                        actorid text,
                        current_year integer,
                        films films_struct[],
                        primary key (actorid, current_year)
);

drop type films_struct;


CREATE TYPE films_struct as (
    film TEXT,
    votes INTEGER,
    rating REAL,
    filmid TEXT
    );


WITH last_year AS (
    SELECT *
    FROM actors
    WHERE current_year = 1969
),
     this_year AS (
         SELECT
             actorid,
             actor,
    year,
    CASE WHEN year IS NULL THEN ARRAY[]::films_struct[]
    ELSE ARRAY_AGG(ROW(film, votes, rating, filmid)::films_struct)
END AS films
         FROM actor_films
         WHERE year = 1970
         GROUP BY actorid, actor,year
     )
INSERT INTO actors
SELECT
    COALESCE(ty.actor, ly.actor) actor,
    COALESCE(ty.actorid, ly.actorid) actorid,
    COALESCE(ly.films, ARRAY[]::films_struct[]) ||
    CASE WHEN ty.year IS NOT NULL THEN ty.films
         ELSE ARRAY[]::films_struct[]
        END as films,
    COALESCE(ty.year,ly.current_year+1) as current_year
FROM last_year ly
         FULL OUTER JOIN this_year ty
                         ON ly.actorid = ty.actorid;
