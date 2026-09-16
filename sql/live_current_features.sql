-- ============================================================
-- Stage 9: Calculate CURRENT features for the live dashboard
-- using the 2026/27 season's matches so far.
-- ============================================================

-- 1. Points per team per match (long format), reusing the same
-- logic as your historical team_match_points table
CREATE OR REPLACE TABLE `coursera-501914.pl_manager.live_team_match_points` AS
SELECT Date AS match_date, HomeTeam AS team,
    CASE WHEN FTR = 'H' THEN 3 WHEN FTR = 'D' THEN 1 ELSE 0 END AS points,
    (FTHG - FTAG) AS goal_diff
FROM `coursera-501914.pl_manager.matches_2627_live`
UNION ALL
SELECT Date, AwayTeam AS team,
    CASE WHEN FTR = 'A' THEN 3 WHEN FTR = 'D' THEN 1 ELSE 0 END AS points,
    (FTAG - FTHG) AS goal_diff
FROM `coursera-501914.pl_manager.matches_2627_live`;

-- 2. Aggregate to season-to-date totals per team (all 4 games played so far)
CREATE OR REPLACE TABLE `coursera-501914.pl_manager.live_team_current_form` AS
SELECT
    team,
    SUM(points) AS points_this_season,
    SUM(goal_diff) AS gd_this_season,
    COUNT(*) AS matches_played,
    -- "points_last_5" equivalent: since only 4 games played, this is
    -- just all points so far (a partial window, same concept as your
    -- matches_into_tenure_so_far handling for early tenures)
    SUM(points) AS points_last_5_equivalent
FROM `coursera-501914.pl_manager.live_team_match_points`
GROUP BY team;

-- 3. Add current league position (ranked by points then goal difference)
CREATE OR REPLACE TABLE `coursera-501914.pl_manager.live_team_current_position` AS
SELECT
    *,
    RANK() OVER (ORDER BY points_this_season DESC, gd_this_season DESC) AS current_league_position
FROM `coursera-501914.pl_manager.live_team_current_form`;

-- Check it looks right
SELECT * FROM `coursera-501914.pl_manager.live_team_current_position`
ORDER BY current_league_position;
