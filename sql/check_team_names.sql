-- ============================================================
-- Step 1: Check for team/club name mismatches between tables
-- Run this FIRST, before building the crosswalk
-- ============================================================

-- All distinct team names as they appear in your match data
-- (football-data.co.uk naming convention)
SELECT DISTINCT team AS name_in_matches
FROM `coursera-501914.pl_manager.season_standings`
ORDER BY name_in_matches;

-- All distinct club names as they appear in your manager tenures data
-- (Wikipedia naming convention)
SELECT DISTINCT club AS name_in_tenures
FROM `coursera-501914.pl_manager.manager_tenures_0526`
ORDER BY name_in_tenures;

-- Names that exist in tenures but have NO exact match in matches
-- (these are your actual mismatches to fix)
SELECT DISTINCT club AS unmatched_club_name
FROM `coursera-501914.pl_manager.manager_tenures_0526`
WHERE club NOT IN (
    SELECT DISTINCT team FROM `coursera-501914.pl_manager.season_standings`
)
ORDER BY unmatched_club_name;
