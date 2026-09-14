-- ============================================================
-- Stage 5, FINAL ASSEMBLY: model_input
-- One row per team-match, with every feature joined together,
-- ready to export to Python for Stage 6/7.
-- ============================================================

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.model_input` AS
SELECT
    rf.season,
    rf.match_date,
    rf.team,
    rf.manager,
    rf.manager_start_date,

    -- Form features
    rf.points,
    rf.points_last_5,
    rf.points_last_10,
    rf.matches_into_tenure_so_far,

    -- Tenure length
    tl.tenure_days_so_far,

    -- League position
    pos.league_position_before_match,
    pos.points_to_date,
    pos.gd_to_date,

    -- Expectation
    eg.expectation_baseline,
    eg.expectation_source,
    eg.expectation_gap,

    -- Sacking outcome for this tenure (joined from tenure_events)
    te.event_observed,
    te.event_type,
    te.duration_days AS tenure_total_duration_days,
    te.end_date AS tenure_end_date

FROM `coursera-501914.pl_manager.team_match_rolling_form` rf

JOIN `coursera-501914.pl_manager.team_match_tenure_length` tl
    ON rf.team = tl.team AND rf.season = tl.season AND rf.match_date = tl.match_date

JOIN `coursera-501914.pl_manager.team_match_position` pos
    ON rf.team = pos.team AND rf.season = pos.season AND rf.match_date = pos.match_date

LEFT JOIN `coursera-501914.pl_manager.team_match_expectation_gap` eg
    ON rf.team = eg.team AND rf.season = eg.season AND rf.match_date = eg.match_date

LEFT JOIN `coursera-501914.pl_manager.tenure_events` te
    ON rf.team = te.club AND rf.manager = te.manager AND rf.manager_start_date = te.start_date;

-- Sanity check 1: total row count - should match team_match_rolling_form
-- (roughly 15,966 minus the ~130 caretaker-gap rows already dropped there)
SELECT COUNT(*) AS total_rows FROM `coursera-501914.pl_manager.model_input`;

-- Sanity check 2: how many rows failed to find a tenure_events match?
-- (should be 0 or very close - every row's manager/team/start_date
-- combination should exist in tenure_events)
SELECT COUNT(*) AS rows_missing_event
FROM `coursera-501914.pl_manager.model_input`
WHERE event_observed IS NULL;

-- Sanity check 3: full Arsenal spot-check with everything joined
SELECT match_date, team, manager, points_last_5, league_position_before_match,
       expectation_gap, tenure_days_so_far, event_observed, event_type
FROM `coursera-501914.pl_manager.model_input`
WHERE team = 'Arsenal' AND season = '2324'
ORDER BY match_date
LIMIT 10;
