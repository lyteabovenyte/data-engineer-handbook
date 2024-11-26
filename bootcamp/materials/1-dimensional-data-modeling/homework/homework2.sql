with years as (
    select *
    from generate_series(1970, 2021) as year
    ),
    last_year as (
select * from actors
    inner join years on actors.current_year = years.year
    ),
    current_year_data as (
select a.actorid,
    a.actor,
    a.year,
    array_agg(row(film, a.year, votes, rating, filmid)::films) as films,
    avg(rating) as avg_rating
from actor_films a
    inner join years y on a.year = y.year + 1
group by a.actorid, a.actor, a.year
    )
select coalesce(c.actorid, l.actorid) as actorid,
       coalesce(c.actor, l.actor) as actor,
       case
           when l.films is null then c.films
           when c.year is not null then l.films || c.films
           else l.films
           end as films,
       case
           when c.year is not null then
               case
                   when c.avg_rating > 8 then 'star'
                   when c.avg_rating > 7 then 'good'
                   when c.avg_rating > 6 then 'average'
                   else 'bad'
                   end::quality_class
           else l.quality_class
           end as quality_class,
       coalesce (c.year, l.current_year+1) as current_year,
       case
           when c.year is not null then true
           else false
           end as is_active
from current_year_data c
         full outer join last_year l on c.actorid = l.actorid
order by c.actor, c.year;