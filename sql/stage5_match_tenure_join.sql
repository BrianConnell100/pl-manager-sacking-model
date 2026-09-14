-- ============================================================
-- Stage 5, Step 1: Join every match to the manager in charge
-- on that date, for both the home and away team.
-- ============================================================

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.matches_with_managers` AS
SELECT
    m.season,
    m.match_date,
    m.home_team,
    m.away_team,
    m.fthg,
    m.ftag,
    m.ftr,

    home_tenure.manager AS home_manager,
    home_tenure.start_date AS home_manager_start_date,
    home_tenure.event_observed AS home_manager_event_observed,

    away_tenure.manager AS away_manager,
    away_tenure.start_date AS away_manager_start_date,
    away_tenure.event_observed AS away_manager_event_observed

FROM `coursera-501914.pl_manager.matches` m

LEFT JOIN `coursera-501914.pl_manager.tenure_events` home_tenure
    ON m.home_team = home_tenure.club
    AND m.match_date >= home_tenure.start_date
    AND (m.match_date <= home_tenure.end_date OR home_tenure.end_date IS NULL)

LEFT JOIN `coursera-501914.pl_manager.tenure_events` away_tenure
    ON m.away_team = away_tenure.club
    AND m.match_date >= away_tenure.start_date
    AND (m.match_date <= away_tenure.end_date OR away_tenure.end_date IS NULL);

-- Sanity check 1: how many matches have NO home manager matched?
-- (some expected - caretaker gaps aren't in tenure_events at all)
SELECT COUNT(*) AS matches_missing_home_manager
FROM `coursera-501914.pl_manager.matches_with_managers`
WHERE home_manager IS NULL;

-- Sanity check 2: how many matches have NO away manager matched?
SELECT COUNT(*) AS matches_missing_away_manager
FROM `coursera-501914.pl_manager.matches_with_managers`
WHERE away_manager IS NULL;

-- Sanity check 3: total row count should roughly match total matches (7,980)
-- but could be HIGHER if any tenure date ranges overlap (a data quality issue to check)
SELECT COUNT(*) AS total_rows FROM `coursera-501914.pl_manager.matches_with_managers`;
