-- ============================================================
-- Stage 5, Feature building - Step 2: rolling form
-- For each team-match row, calculate points from the last 5
-- and last 10 matches (NOT including the current match itself),
-- partitioned by manager tenure so form resets for a new manager.
-- ============================================================

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.team_match_rolling_form` AS
SELECT
    *,
    SUM(points) OVER (
        PARTITION BY team, manager, manager_start_date
        ORDER BY match_date
        ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING
    ) AS points_last_5,

    SUM(points) OVER (
        PARTITION BY team, manager, manager_start_date
        ORDER BY match_date
        ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING
    ) AS points_last_10,

    -- Also count how many prior matches actually exist in this tenure
    -- so we know whether points_last_5/10 are based on a full window
    -- or a partial one early in a manager's tenure
    ROW_NUMBER() OVER (
        PARTITION BY team, manager, manager_start_date
        ORDER BY match_date
    ) - 1 AS matches_into_tenure_so_far

FROM `coursera-501914.pl_manager.team_match_points`
WHERE manager IS NOT NULL;  -- drop the ~130 caretaker-gap rows with no manager attributed

-- Sanity check: same Arsenal spot-check as before, now with rolling form attached
SELECT match_date, team, manager, points, points_last_5, points_last_10, matches_into_tenure_so_far
FROM `coursera-501914.pl_manager.team_match_rolling_form`
WHERE team = 'Arsenal' AND season = '2324'
ORDER BY match_date
LIMIT 10;
