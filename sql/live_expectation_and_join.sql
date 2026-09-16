-- ============================================================
-- Stage 9: Add expectation baseline (from 25/26 final position,
-- or 17 for promoted clubs) and join everything together with
-- the current manager list into one final scoring table.
-- ============================================================

-- 1. Get each current club's expectation baseline for 26/27
-- (their 25/26 final position, or 17 if newly promoted)
CREATE OR REPLACE TABLE `coursera-501914.pl_manager.live_expectation_baseline` AS
SELECT
    cm.club AS team,
    COALESCE(ss.final_position, 17) AS expectation_baseline_2627,
    CASE WHEN ss.final_position IS NULL THEN 'promoted_assumed' ELSE 'prior_finish' END AS source
FROM `coursera-501914.pl_manager.current_managers_2627` cm
LEFT JOIN `coursera-501914.pl_manager.season_standings` ss
    ON cm.club = ss.team AND ss.season = '2526';

-- Sanity check: promoted clubs (Coventry, Hull, Ipswich) should show 17
SELECT * FROM `coursera-501914.pl_manager.live_expectation_baseline` ORDER BY team;


-- 2. FINAL JOIN: bring together manager, form, position, expectation,
-- and tenure length into one scoring-ready table
CREATE OR REPLACE TABLE `coursera-501914.pl_manager.live_scoring_input` AS
SELECT
    cm.club AS team,
    cm.manager,
    cm.start_date AS manager_start_date,
    DATE_DIFF(CURRENT_DATE(), cm.start_date, DAY) AS tenure_days_so_far,
    pos.points_last_5_equivalent AS points_last_5,
    pos.current_league_position AS league_position_before_match,
    eb.expectation_baseline_2627 AS expectation_baseline,
    (eb.expectation_baseline_2627 - pos.current_league_position) AS expectation_gap
FROM `coursera-501914.pl_manager.current_managers_2627` cm
JOIN `coursera-501914.pl_manager.live_team_current_position` pos
    ON cm.club = pos.team
JOIN `coursera-501914.pl_manager.live_expectation_baseline` eb
    ON cm.club = eb.team;

-- Final check: should be 20 rows, one per current PL manager, ready to
-- feed into the trained Cox model
SELECT * FROM `coursera-501914.pl_manager.live_scoring_input` ORDER BY league_position_before_match;
