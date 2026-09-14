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

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.tenure_events` AS

-- End of season / natural contract expiry departures
SELECT
    manager, nationality, club, start_date, end_date,
    duration_days,
    0 AS event_observed,
    'end_of_season' AS event_type
FROM `coursera-501914.pl_manager.tenures_end_of_season`

UNION ALL

-- Classified mid-season departures (excluding non-PL-season rows)
SELECT
    manager, nationality, club, start_date, end_date,
    CAST(duration_days AS INT64) AS duration_days,
    CAST(sacked_flag AS INT64) AS event_observed,
    CASE WHEN CAST(sacked_flag AS INT64) = 1 THEN 'sacked' ELSE 'mid_season_not_sacked' END AS event_type
FROM `coursera-501914.pl_manager.tenures_mid_season_research_classified`
WHERE sacked_flag IS NOT NULL  -- drops the 21 EXCLUDE rows automatically (blank/NULL sacked_flag)

UNION ALL

-- Currently active managers - censored at data cutoff
SELECT
    manager, nationality, club, start_date, end_date,
    duration_days,
    0 AS event_observed,
    'incumbent' AS event_type
FROM `coursera-501914.pl_manager.tenures_incumbent`;

-- Sanity checks
SELECT event_type, COUNT(*) AS num_rows
FROM `coursera-501914.pl_manager.tenure_events`
GROUP BY event_type
ORDER BY event_type;

SELECT COUNT(*) AS total_tenure_events FROM `coursera-501914.pl_manager.tenure_events`;
