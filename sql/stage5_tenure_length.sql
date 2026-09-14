-- ============================================================
-- Stage 5, Feature building - Step 5: tenure length so far
-- Days and matches into the tenure, as of each match date.
-- ============================================================

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.team_match_tenure_length` AS
SELECT
    season,
    match_date,
    team,
    manager,
    manager_start_date,
    DATE_DIFF(match_date, manager_start_date, DAY) AS tenure_days_so_far,
    matches_into_tenure_so_far
FROM `coursera-501914.pl_manager.team_match_rolling_form`;

-- Sanity check: Arsenal, 2023/24 - tenure days should climb steadily
-- and matches_into_tenure_so_far should climb by 1 each row
SELECT match_date, team, manager, manager_start_date, tenure_days_so_far, matches_into_tenure_so_far
FROM `coursera-501914.pl_manager.team_match_tenure_length`
WHERE team = 'Arsenal' AND season = '2324'
ORDER BY match_date
LIMIT 10;
