WITH last_season_scd AS (
    SELECT * FROM players_scd
    WHERE current_season = 2021
      AND end_season = 2021
),
     historical_scd AS (SELECT *
                        FROM players_scd
                        WHERE current_season = 2021
                          AND end_season < 2021
     ),
     this_season_data AS (
         SELECT * FROM players
         WHERE current_season = 2022
     )

SELECT * FROM last_season_scd;