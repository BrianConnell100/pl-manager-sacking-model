-- ============================================================
-- Stage 9: Current (2026/27) manager list for live dashboard
-- Rebuilt as an explicit, fully deterministic list of all 20
-- current PL clubs, rather than filtering the old incumbents
-- table (too error-prone given the huge managerial + relegation
-- churn this summer).
--
-- Relegated end of 25/26: West Ham, Burnley, Wolves
-- Promoted for 26/27: Coventry, Hull, Ipswich
-- ============================================================

CREATE OR REPLACE TABLE `coursera-501914.pl_manager.current_managers_2627` AS
SELECT * FROM UNNEST([
    -- 9 managers UNCHANGED from last season
    STRUCT('Mikel Arteta' AS manager, 'Arsenal' AS club, DATE('2019-12-22') AS start_date),
    ('Unai Emery', 'Aston Villa', DATE('2022-11-01')),
    ('Keith Andrews', 'Brentford', DATE('2025-06-27')),
    ('Fabian Hurzeler', 'Brighton', DATE('2024-07-02')),
    ('David Moyes', 'Everton', DATE('2025-01-11')),
    ('Daniel Farke', 'Leeds', DATE('2023-07-04')),
    ('Michael Carrick', 'Man United', DATE('2026-01-13')),
    ('Regis Le Bris', 'Sunderland', DATE('2024-07-01')),
    ('Roberto De Zerbi', 'Tottenham', DATE('2026-03-31')),

    -- 9 NEW appointments this summer (confirmed real dates)
    ('Marco Rose', 'Bournemouth', DATE('2026-06-01')),
    ('Andoni Iraola', 'Liverpool', DATE('2026-06-04')),
    ('Pierre Sage', 'Crystal Palace', DATE('2026-06-15')),
    ('Gary O\'Neil', 'Ipswich', DATE('2026-06-23')),
    ('Enzo Maresca', 'Man City', DATE('2026-06-29')),
    ('Xabi Alonso', 'Chelsea', DATE('2026-07-01')),
    ('Oliver Glasner', 'Nott\'m Forest', DATE('2026-07-06')),
    ('Alvaro Arbeloa', 'Fulham', DATE('2026-07-08')),
    ('Matthias Jaissle', 'Newcastle', DATE('2026-08-05')),

    -- 2 promoted clubs, kept their promotion-winning managers
    ('Frank Lampard', 'Coventry', DATE('2024-11-28')),
    ('Sergej Jakirovic', 'Hull', DATE('2025-06-11'))
]);

-- Sanity check: should be exactly 20 rows, no duplicates
SELECT COUNT(*) AS total_current_managers FROM `coursera-501914.pl_manager.current_managers_2627`;
SELECT * FROM `coursera-501914.pl_manager.current_managers_2627` ORDER BY club;
