-- select * from player_seasons;
-- create type season_stats as (
--     season integer,
--     gp integer,
--     pts real,
--     reb real,
--     ast real
--                             )
--

-- CREATE TYPE scoring_class AS ENUM('star', 'good', 'average', 'bad');
--
-- create table players (
--     player_name text,
--     height text,
--     college text,
--     country text,
--     draft_year text,
--     draft_round text,
--     draft_number text,
--     season_stats season_stats[],
--     scoring_class scoring_class,
--     years_since_last_season integer,
--     current_season integer,
--     primary key (player_name, current_season)
-- );

-- select min(season) from player_seasons;

-- cumulative design and temporal season_stats type.
-- to keep the ordering for Run-Length-Encoding
insert into players
with yesterday as (
    select * from players
             where current_season = 2000
),
    today as (
        select * from player_seasons
                 where season = 2001
    )
SELECT
    COALESCE(t.player_name, y.player_name) as player_name,
    COALESCE(t.height, y.height) as height,
    COALESCE(t.college, y.college) as college,
    COALESCE(t.country, y.country) as country,
    COALESCE(t.draft_year, y.draft_year) as draft_year,
    COALESCE(t.draft_round, y.draft_round) as draft_round,
    COALESCE(t.draft_number, y.draft_number) as draft_number,
    case when y.season_stats is null
then array[ROW(
    t.season,
    t.gp,
    t.pts,
    t.reb,
    t.ast
            )::season_stats]
when t.season is not null then y.season_stats || array[ROW(
    t.season,
    t.gp,
    t.pts,
    t.reb,
    t.ast
    )::season_stats]
else y.season_stats
end as season_stats,
    case
        when t.season is not null then
            case
                when t.pts > 20 then 'star'
                when t.pts > 15 then 'good'
                when t.pts > 10 then 'average'
                else 'bad'
            end::scoring_class
        else y.scoring_class
    end as scoring_class,

    case
        when t.season is not null then
            0
        else y.years_since_last_season + 1
    end as years_since_last_season,

    coalesce(t.season, y.current_season + 1) as current_season

from today t full outer join yesterday y
on t.player_name = y.player_name;

select player_name,
       (season_stats[cardinality(season_stats)]::season_stats).pts /
       case
           when (season_stats[1]::season_stats).pts = 0 then 1
           else (season_stats[1]::season_stats).pts
        end as improvement_rate
from players
where current_season = 2001
order by 2 desc;

-- with unnested as (
--     select player_name,
--            unnest(season_stats)::season_stats as season_stats
--     from players
--     where player_name = 'Michael Jordan'
--     and current_season = 2001
-- )
--
-- select player_name,
--        (season_stats::season_stats).*
-- from unnested;


