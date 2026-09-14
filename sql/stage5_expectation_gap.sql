-- ============================================================
-- Stage 5, Feature building - Step 4: expectation_gap
-- Compares a team's CURRENT league position to their pre-season
-- expected finish (expectation_baseline from Stage 4).
--
-- Convention: expectation_gap = expectation_baseline - actual_position
--   Positive value = doing BETTER than expected (actual position
--                     number is lower than expected, e.g. expected
--                     10th, currently 3rd -> gap = +7)
--   Negative value = doing WORSE than expected (underperforming)
-- ============================================================

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.team_match_expectation_gap` AS
SELECT
    p.season,
    p.match_date,
    p.team,
    p.points_to_date,
    p.gd_to_date,
    p.league_position_before_match,
    e.expectation_baseline,
    e.source AS expectation_source,
    e.expectation_baseline - p.league_position_before_match AS expectation_gap
FROM `coursera-501914.pl_manager.team_match_position` p
LEFT JOIN `coursera-501914.pl_manager.expectation_baseline` e
    ON p.team = e.team AND p.season = e.season;

-- Sanity check 1: any rows where the join failed to find an expectation?
SELECT COUNT(*) AS rows_missing_expectation
FROM `coursera-501914.pl_manager.team_match_expectation_gap`
WHERE expectation_baseline IS NULL;

-- Sanity check 2: Arsenal spot-check again, now with the full feature set
SELECT match_date, team, league_position_before_match, expectation_baseline, expectation_gap
FROM `coursera-501914.pl_manager.team_match_expectation_gap`
WHERE team = 'Arsenal' AND season = '2324'
ORDER BY match_date
LIMIT 10;

-- Confirm the 760 missing rows are all from season 05/06 (expected,
-- no prior-season data exists for the first season in our window)
SELECT season, COUNT(*) AS missing_count
FROM `coursera-501914.pl_manager.team_match_expectation_gap`
WHERE expectation_baseline IS NULL
GROUP BY season;
