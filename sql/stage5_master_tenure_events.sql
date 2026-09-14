-- ============================================================
-- Stage 5: Build the master tenure events table
-- Combines all three tenure categories into one table with a
-- consistent event_observed flag for survival modeling:
--   event_observed = 1 -> sacked
--   event_observed = 0 -> censored (still in post, or left without
--                          being sacked - end of season/voluntary/
--                          poached/political/health, etc.)
-- ============================================================

-- 1. INCUMBENTS (currently active managers) - previously missing
CREATE OR REPLACE TABLE `coursera-501914.pl_manager.tenures_incumbent` AS
SELECT
    manager, nationality, club, start_date, end_date,
    is_incumbent, is_caretaker, duration_days
FROM `coursera-501914.pl_manager.tenures_classified`
WHERE departure_timing = 'incumbent'
  AND is_caretaker = 0;

SELECT COUNT(*) AS num_incumbents FROM `coursera-501914.pl_manager.tenures_incumbent`;


-- 2. MASTER EVENTS TABLE ------------------------------------------
-- Combines: end-of-season (event=0), classified mid-season
-- (event=sacked_flag, excluding the non-PL-season EXCLUDE rows),
-- and incumbents (event=0, censored as of data cutoff)
--
-- IMPORTANT: tenures_end_of_season and tenures_mid_season_research
-- were built BEFORE the team_name_crosswalk fix, so they still use
-- original Wikipedia-style club names. We apply the crosswalk here
-- so the club names match the `matches` table for the join step.

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.tenure_events` AS

-- End of season / natural contract expiry departures
SELECT
    manager, nationality,
    COALESCE(xwalk.matches_name, t.club) AS club,
    start_date, end_date,
    duration_days,
    0 AS event_observed,
    'end_of_season' AS event_type
FROM `coursera-501914.pl_manager.tenures_end_of_season` t
LEFT JOIN `coursera-501914.pl_manager.team_name_crosswalk` xwalk
    ON t.club = xwalk.wikipedia_name

UNION ALL

-- Classified mid-season departures
-- IMPORTANT: we do NOT drop the 21 rows with a blank sacked_flag
-- (departures that occurred during a Championship season for a
-- yo-yo club). Those tenures still covered REAL Premier League
-- matches earlier in their span (e.g. Ian Holloway managed
-- Blackpool's entire solitary PL season, even though his tenure's
-- END date falls in the Championship afterwards). Dropping the
-- whole row would silently remove manager attribution for those
-- legitimate PL matches. Instead we keep the row for match-join
-- purposes, but flag it as 'non_pl_departure' so it's excluded
-- from sacking-event counts in Stage 7.
SELECT
    manager, nationality,
    COALESCE(xwalk.matches_name, t.club) AS club,
    start_date, end_date,
    CAST(t.duration_days AS INT64) AS duration_days,
    CASE WHEN t.sacked_flag IS NULL THEN 0 ELSE CAST(t.sacked_flag AS INT64) END AS event_observed,
    CASE
        WHEN t.sacked_flag IS NULL THEN 'non_pl_departure'
        WHEN CAST(t.sacked_flag AS INT64) = 1 THEN 'sacked'
        ELSE 'mid_season_not_sacked'
    END AS event_type
FROM `coursera-501914.pl_manager.tenures_mid_season_research_classified` t
LEFT JOIN `coursera-501914.pl_manager.team_name_crosswalk` xwalk
    ON t.club = xwalk.wikipedia_name

UNION ALL

-- Currently active managers - censored at data cutoff
SELECT
    manager, nationality,
    COALESCE(xwalk.matches_name, t.club) AS club,
    start_date, end_date,
    duration_days,
    0 AS event_observed,
    'incumbent' AS event_type
FROM `coursera-501914.pl_manager.tenures_incumbent` t
LEFT JOIN `coursera-501914.pl_manager.team_name_crosswalk` xwalk
    ON t.club = xwalk.wikipedia_name;

-- Sanity checks
SELECT event_type, COUNT(*) AS num_rows
FROM `coursera-501914.pl_manager.tenure_events`
GROUP BY event_type
ORDER BY event_type;

SELECT COUNT(*) AS total_tenure_events FROM `coursera-501914.pl_manager.tenure_events`;
