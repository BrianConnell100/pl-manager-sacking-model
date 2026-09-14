-- ============================================================
-- Diagnostic: look at the shape of matches missing a manager
-- ============================================================

-- 1. Are missing matches spread across many clubs (expected/fine)
--    or concentrated in a few (would suggest a remaining bug)?
SELECT home_team, COUNT(*) AS missing_count
FROM `coursera-501914.pl_manager.matches_with_managers`
WHERE home_manager IS NULL
GROUP BY home_team
ORDER BY missing_count DESC
LIMIT 20;

-- 2. Look at actual dates for one club with missing matches, to see
--    if gaps are short (caretaker-shaped) or long (a real bug).
--    Replace 'Chelsea' below with a club name from query 1's results.
SELECT match_date, home_team, away_team
FROM `coursera-501914.pl_manager.matches_with_managers`
WHERE home_manager IS NULL
ORDER BY home_team, match_date
LIMIT 50;
