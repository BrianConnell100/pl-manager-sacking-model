-- ============================================================
-- Combine 21 season tables into one `matches` table
-- ============================================================

-- NOTE: We select only the core columns explicitly (rather than
-- SELECT *) because older seasons have far fewer betting-odds
-- columns than newer ones. UNION ALL requires every branch to
-- have the same number of columns, so SELECT * would fail here.
-- These 6 columns are the ones present and consistently named
-- across all 21 seasons.

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.matches` AS
SELECT '0506' AS season, Date AS match_date, HomeTeam AS home_team, AwayTeam AS away_team, FTHG AS fthg, FTAG AS ftag, FTR AS ftr FROM `coursera-501914.pl_manager.matches_0506`
UNION ALL
SELECT '0607', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_0607`
UNION ALL
SELECT '0708', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_0708`
UNION ALL
SELECT '0809', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_0809`
UNION ALL
SELECT '0910', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_0910`
UNION ALL
SELECT '1011', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_1011`
UNION ALL
SELECT '1112', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_1112`
UNION ALL
SELECT '1213', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_1213`
UNION ALL
SELECT '1314', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_1314`
UNION ALL
SELECT '1415', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_1415`
UNION ALL
SELECT '1516', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_1516`
UNION ALL
SELECT '1617', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_1617`
UNION ALL
SELECT '1718', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_1718`
UNION ALL
SELECT '1819', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_1819`
UNION ALL
SELECT '1920', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_1920`
UNION ALL
SELECT '2021', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_2021`
UNION ALL
SELECT '2122', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_2122`
UNION ALL
SELECT '2223', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_2223`
UNION ALL
SELECT '2324', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_2324`
UNION ALL
SELECT '2425', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_2425`
UNION ALL
SELECT '2526', Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR FROM `coursera-501914.pl_manager.matches_2526`;

-- Sanity check: should be ~21 * ~380 = ~7,980 rows (21 seasons x 380 matches/season)
SELECT COUNT(*) AS total_matches FROM `coursera-501914.pl_manager.matches`;

-- Check row count per season to spot any obvious upload errors
SELECT season, COUNT(*) AS matches_in_season
FROM `coursera-501914.pl_manager.matches`
GROUP BY season
ORDER BY season;
