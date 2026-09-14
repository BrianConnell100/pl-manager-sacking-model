-- ============================================================
-- Stage 5, Feature building - Step 3: current league position
-- For each match, calculate where a team stood in the table
-- BEFORE that match was played (points then goal difference
-- as tiebreaker - standard PL rules).
-- ============================================================

-- First, extend the team-per-match view with goal difference,
-- since team_match_points only has points, not goals.
CREATE OR REPLACE TABLE `coursera-501914.pl_manager.team_match_goals` AS
SELECT season, match_date, home_team AS team, (fthg - ftag) AS goal_diff
FROM `coursera-501914.pl_manager.matches`
UNION ALL
SELECT season, match_date, away_team AS team, (ftag - fthg) AS goal_diff
FROM `coursera-501914.pl_manager.matches`;

-- Now build cumulative points and goal difference BEFORE each match,
-- using a window function (much simpler and correct vs a self-join)
CREATE OR REPLACE TABLE `coursera-501914.pl_manager.team_match_position` AS
WITH team_stats AS (
    SELECT
        p.season,
        p.match_date,
        p.team,
        p.points,
        g.goal_diff,
        SUM(p.points) OVER (
            PARTITION BY p.team, p.season
            ORDER BY p.match_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS points_to_date,
        SUM(g.goal_diff) OVER (
            PARTITION BY p.team, p.season
            ORDER BY p.match_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS gd_to_date
    FROM `coursera-501914.pl_manager.team_match_points` p
    JOIN `coursera-501914.pl_manager.team_match_goals` g
        ON p.team = g.team AND p.season = g.season AND p.match_date = g.match_date
)
SELECT
    season, match_date, team,
    COALESCE(points_to_date, 0) AS points_to_date,
    COALESCE(gd_to_date, 0) AS gd_to_date,
    RANK() OVER (
        PARTITION BY season, match_date
        ORDER BY COALESCE(points_to_date, 0) DESC, COALESCE(gd_to_date, 0) DESC
    ) AS league_position_before_match
FROM team_stats;

-- Sanity check: Arsenal's position before each match, 2023/24
SELECT match_date, team, points_to_date, gd_to_date, league_position_before_match
FROM `coursera-501914.pl_manager.team_match_position`
WHERE team = 'Arsenal' AND season = '2324'
ORDER BY match_date
LIMIT 10;
