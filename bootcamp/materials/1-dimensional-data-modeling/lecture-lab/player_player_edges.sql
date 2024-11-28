WITH deduped AS (
    SELECT *, row_number() over (PARTITION BY player_id, game_id) AS row_num
    FROM game_details
),
     filtered AS (
         SELECT * FROM deduped
         WHERE row_num = 1
     ),
     aggregated AS (
          SELECT
           f1.player_id as subject_identifier,

           f2.player_id as object_identifier,

            CASE WHEN f1.team_abbreviation = f2.team_abbreviation
                THEN 'shares_team'::edge_type
            ELSE 'plays_against'::edge_type
            END as edge_type,
            f1.player_name as subject_player_name,
            f2.player_name as object_player_name,
            COUNT(1) AS num_games,
            SUM(f1.pts) AS left_points,
            SUM(f2.pts) as right_points
        FROM filtered f1
        JOIN filtered f2
        ON f1.game_id = f2.game_id
        AND f1.player_name <> f2.player_name
        WHERE f1.player_id > f2.player_id -- one sided edge
        GROUP BY
            f1.player_id,
            f2.player_id,
           CASE WHEN f1.team_abbreviation = f2.team_abbreviation
                THEN  'shares_team'::edge_type
            ELSE 'plays_against'::edge_type
            END as edge_type
     )