-- ============================================================
-- Stage 4: Pre-season expectation baseline
-- PL Manager Sacking Project (BigQuery / GoogleSQL)
--
-- Approach: previous season's final league position as the
-- expectation baseline. Newly promoted clubs (no top-flight
-- standing the prior season) are assigned position 17 —
-- treated as the "just survived" pre-season expectation.
-- ============================================================

-- 1. DERIVE FINAL LEAGUE STANDINGS PER SEASON --------------------
-- Standard football points: 3 for a win, 1 for a draw, 0 for a loss.
-- Combine home and away results per team, per season.

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.season_standings` AS
WITH team_results AS (
    -- Home matches
    SELECT season, home_team AS team,
        CASE WHEN ftr = 'H' THEN 3 WHEN ftr = 'D' THEN 1 ELSE 0 END AS points
    FROM `coursera-501914.pl_manager.matches`
    UNION ALL
    -- Away matches
    SELECT season, away_team AS team,
        CASE WHEN ftr = 'A' THEN 3 WHEN ftr = 'D' THEN 1 ELSE 0 END AS points
    FROM `coursera-501914.pl_manager.matches`
),
season_points AS (
    SELECT season, team, SUM(points) AS total_points
    FROM team_results
    GROUP BY season, team
)
SELECT
    season,
    team,
    total_points,
    RANK() OVER (PARTITION BY season ORDER BY total_points DESC) AS final_position
FROM season_points
ORDER BY season, final_position;

-- Sanity check: every season should have 20 teams, positions 1-20
SELECT season, COUNT(*) AS num_teams, MAX(final_position) AS max_position
FROM `coursera-501914.pl_manager.season_standings`
GROUP BY season
ORDER BY season;


-- 2. BUILD A SEASON SEQUENCE TABLE (to find "previous season") ---

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.season_sequence` AS
SELECT
    season,
    LAG(season) OVER (ORDER BY season) AS previous_season
FROM `coursera-501914.pl_manager.season_boundaries`
ORDER BY season;


-- 3. BUILD THE EXPECTATION BASELINE ------------------------------

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.expectation_baseline` AS
SELECT
    curr.season,
    curr.team,
    curr.final_position AS actual_finish_this_season,
    prev.final_position AS prior_season_position,
    CASE
        WHEN ss.previous_season IS NULL THEN NULL                 -- first season in dataset (05/06), no prior data at all
        WHEN prev.final_position IS NULL THEN 17                  -- team not in top flight last season = promoted, assign 17
        ELSE prev.final_position
    END AS expectation_baseline,
    CASE
        WHEN ss.previous_season IS NULL THEN 'no_prior_data'
        WHEN prev.final_position IS NULL THEN 'promoted_assumed'
        ELSE 'prior_finish'
    END AS source
FROM `coursera-501914.pl_manager.season_standings` curr
LEFT JOIN `coursera-501914.pl_manager.season_sequence` ss
    ON curr.season = ss.season
LEFT JOIN `coursera-501914.pl_manager.season_standings` prev
    ON prev.season = ss.previous_season
    AND prev.team = curr.team
ORDER BY curr.season, curr.final_position;

-- Sanity check: see the breakdown of source types
SELECT source, COUNT(*) AS num_rows
FROM `coursera-501914.pl_manager.expectation_baseline`
GROUP BY source;

-- Spot check: look at a season with known promoted teams, e.g. 15/16 (Leicester's title year)
SELECT * FROM `coursera-501914.pl_manager.expectation_baseline`
WHERE season = '1516'
ORDER BY actual_finish_this_season;
