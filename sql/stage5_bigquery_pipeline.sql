-- ============================================================
-- Stage 5 SQL Pipeline (BigQuery / GoogleSQL)
-- PL Manager Sacking Project
-- ============================================================
--   b) bq CLI, one command per season file, e.g.:
--      bq load --source_format=CSV --skip_leading_rows=1 \
--        your_project:pl_manager.matches_0506 \
--        E0_0506.csv \
--        match_date:DATE,home_team:STRING,away_team:STRING,fthg:INTEGER,ftag:INTEGER,ftr:STRING
--
--   c) Or load all 21 into Cloud Storage first, then use
--      `bq load` pointing at gs://your-bucket/E0_*.csv with a
--      wildcard — faster if you don't want 21 separate commands.
--
-- IMPORTANT: football-data.co.uk's raw CSVs have NO 'season'
-- column. Two options:
--   (i) Load each season into its OWN table (matches_0506,
--       matches_0607, ...) and add the season label when you
--       UNION them together in step 2 below, OR
--   (ii) Add a 'season' column to each CSV yourself before
--       upload (e.g. in Excel/pandas) so you can load them
--       all into one `matches` table directly.
-- Option (ii) is simpler for the rest of this pipeline —
-- the queries below assume a single `matches` table with a
-- `season` column already present.


-- 2. DERIVE SEASON BOUNDARIES ------------------------------------

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.season_boundaries` AS
SELECT
    season,
    MIN(match_date) AS season_start_date,
    MAX(match_date) AS season_end_date
FROM `coursera-501914.pl_manager.matches`
GROUP BY season
ORDER BY season;

-- Sanity check: should return 21 rows, one per season
SELECT * FROM `coursera-501914.pl_manager.season_boundaries`;


-- 3. CLASSIFY TENURES AS MID-SEASON vs END-OF-SEASON --------------

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.tenures_classified` AS
SELECT
    mt.*,
    CASE
        WHEN mt.end_date IS NULL THEN 'incumbent'
        WHEN EXISTS (
            SELECT 1
            FROM `coursera-501914.pl_manager.season_boundaries` sb
            WHERE mt.end_date BETWEEN sb.season_start_date AND sb.season_end_date
        ) THEN 'mid_season'
        ELSE 'end_of_season'
    END AS departure_timing
FROM `coursera-501914.pl_manager.manager_tenures_0526` mt;


-- 4. SPLIT INTO THE TWO WORKING TABLES ----------------------------

-- (a) End-of-season / incumbent: auto-classified, no manual work needed
CREATE OR REPLACE TABLE `coursera-501914.pl_manager.tenures_end_of_season` AS
SELECT *,
       'end_of_season' AS departure_reason_auto,
       0 AS sacked_flag_auto
FROM `coursera-501914.pl_manager.tenures_classified`
WHERE departure_timing = 'end_of_season';

-- (b) Mid-season, non-caretaker: THIS is your manual research list
CREATE OR REPLACE TABLE `coursera-501914.pl_manager.tenures_mid_season_research` AS
SELECT *
FROM `coursera-501914.pl_manager.tenures_classified`
WHERE departure_timing = 'mid_season'
  AND is_caretaker = 0   -- exclude caretakers, they aren't sacking candidates
ORDER BY club, start_date;

-- Check how many rows actually need manual research
SELECT COUNT(*) AS rows_to_research
FROM `coursera-501914.pl_manager.tenures_mid_season_research`;

-- Export for manual research: easiest via BigQuery Console
-- (query results -> "Save Results" -> CSV / Google Sheets),
-- or `bq extract` to a Cloud Storage bucket if scripting it.
