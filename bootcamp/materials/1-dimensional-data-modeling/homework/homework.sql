-- TYPE films_struct
drop type films_struct;

create type films_struct as (
    film text,
    year integer,
    votes integer,
    rating real,
    filmid text
    );


-- TABLE actors
drop table actors;

create table actors
(
    actor        text,
    actorid      text,
    current_year integer,
    films        films_struct[]
);

-- removing temportal value and aggregating on films and year
with years as (
    select *
    from generate_series(1970, 2021) as year
    ),
    last_year as (
select *
from actors
    inner join years on actors.current_year = years.year
    ),
    current_year_data as (
select a.actorid,
    a.actor,
    a.year,
    array_agg(row(film, a.year, votes, rating, filmid)::films_struct) as films,
    avg(rating) as avg_rating
from actor_films a
    inner join years y on a.year = y.year + 1
group by a.actorid, a.actor, a.year
    )
select
    coalesce(c.actorid, l.actorid) as actorid,
    coalesce(c.actor, l.actor) as actor,
    case
        when l.films is null then c.films
        when c.year is not null then l.films || c.films
        else l.films
        end as films,


    coalesce(c.year, l.year + 1) as current_year
from current_year_data c
         full outer join last_year l
                         on c.actorid = l.actorid
order by c.actor, c.year;