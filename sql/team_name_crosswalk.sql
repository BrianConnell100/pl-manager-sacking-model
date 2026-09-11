-- ============================================================
-- Team name crosswalk: Wikipedia (manager_tenures) -> football-data.co.uk (matches)
-- Standardizing ON the football-data.co.uk short names, since
-- that's what your match data already uses.
-- ============================================================

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.team_name_crosswalk` AS
SELECT * FROM UNNEST([
    STRUCT('Birmingham City' AS wikipedia_name, 'Birmingham' AS matches_name),
    ('Blackburn Rovers', 'Blackburn'),
    ('Bolton Wanderers', 'Bolton'),
    ('Brighton & Hove Albion', 'Brighton'),
    ('Cardiff City', 'Cardiff'),
    ('Charlton Athletic', 'Charlton'),
    ('Coventry City', 'Coventry'),
    ('Derby County', 'Derby'),
    ('Huddersfield Town', 'Huddersfield'),
    ('Hull City', 'Hull'),
    ('Ipswich Town', 'Ipswich'),
    ('Leeds United', 'Leeds'),
    ('Leicester City', 'Leicester'),
    ('Luton Town', 'Luton'),
    ('Manchester City', 'Man City'),
    ('Manchester United', 'Man United'),
    ('Newcastle United', 'Newcastle'),
    ('Norwich City', 'Norwich'),
    ('Nottingham Forest', "Nott'm Forest"),
    ('Queens Park Rangers', 'QPR'),
    ('Stoke City', 'Stoke'),
    ('Swansea City', 'Swansea'),
    ('Tottenham Hotspur', 'Tottenham'),
    ('West Bromwich Albion', 'West Brom'),
    ('West Ham United', 'West Ham'),
    ('Wigan Athletic', 'Wigan'),
    ('Wolverhampton Wanderers', 'Wolves')
]);

-- Sanity check: should be exactly 27 rows
SELECT COUNT(*) AS crosswalk_rows FROM `coursera-501914.pl_manager.team_name_crosswalk`;


-- Apply the crosswalk: create a CLEANED version of manager_tenures
-- with club names standardized to match the `matches` table.
-- Uses the crosswalk where a mapping exists, otherwise keeps the
-- original name unchanged (covers the clubs that already matched).

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.manager_tenures_clean` AS
SELECT
    mt.* EXCEPT(club),
    COALESCE(xwalk.matches_name, mt.club) AS club
FROM `coursera-501914.pl_manager.manager_tenures_0526` mt
LEFT JOIN `coursera-501914.pl_manager.team_name_crosswalk` xwalk
    ON mt.club = xwalk.wikipedia_name;

-- Verify: this should now return ZERO rows (no more mismatches)
SELECT DISTINCT club AS still_unmatched
FROM `coursera-501914.pl_manager.manager_tenures_clean`
WHERE club NOT IN (
    SELECT DISTINCT team FROM `coursera-501914.pl_manager.season_standings`
)
ORDER BY still_unmatched;
