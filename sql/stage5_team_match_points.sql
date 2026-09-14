-- ============================================================
-- Stage 5, Feature building - Step 1: team_match_points
-- One row per team per match, with points earned that match.
-- This is the foundation for rolling form calculations.
-- ============================================================

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.team_match_points` AS

-- Home team perspective
SELECT
    season,
    match_date,
    home_team AS team,
    CASE WHEN ftr = 'H' THEN 3 WHEN ftr = 'D' THEN 1 ELSE 0 END AS points,
    home_manager AS manager,
    home_manager_start_date AS manager_start_date
FROM `coursera-501914.pl_manager.matches_with_managers`

UNION ALL

-- Away team perspective
SELECT
    season,
    match_date,
    away_team AS team,
    CASE WHEN ftr = 'A' THEN 3 WHEN ftr = 'D' THEN 1 ELSE 0 END AS points,
    away_manager AS manager,
    away_manager_start_date AS manager_start_date
FROM `coursera-501914.pl_manager.matches_with_managers`;

-- Sanity check 1: should be exactly double the matches table (each match = 2 team-rows)
SELECT COUNT(*) AS total_rows FROM `coursera-501914.pl_manager.team_match_points`;

-- Sanity check 2: spot-check one team/season, ordered by date, to eyeball it looks right
SELECT * FROM `coursera-501914.pl_manager.team_match_points`
WHERE team = 'Arsenal' AND season = '2324'
ORDER BY match_date
LIMIT 10;
