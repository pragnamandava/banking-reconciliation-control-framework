/*
Project: Multi-Account Financial Reconciliation & Suspense Monitoring System
Module: Ageing Analysis & End-of-Day Reporting
Database: MySQL 8.0
Description:
Implements ageing simulation and consolidated operational dashboard metrics.
*/

-- =====================================================
-- 1. Simulate Ageing Distribution (0–30 Days)
-- =====================================================

UPDATE suspense_account
SET created_date = DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 30) DAY);

-- =====================================================
-- 2. Ageing Bucket Analysis
-- =====================================================

SELECT
    CASE
        WHEN DATEDIFF(CURDATE(), created_date) <= 2 THEN '0-2 Days'
        WHEN DATEDIFF(CURDATE(), created_date) <= 7 THEN '3-7 Days'
        WHEN DATEDIFF(CURDATE(), created_date) <= 30 THEN '8-30 Days'
        ELSE '30+ Days'
    END AS ageing_bucket,
    COUNT(*) AS item_count,
    SUM(suspense_amount) AS exposure
FROM suspense_account
WHERE status = 'OPEN'
GROUP BY ageing_bucket;

-- =====================================================
-- 3. End-of-Day (EOD) Control Summary
-- =====================================================

SELECT
    (SELECT COUNT(*) FROM internal_ledger) AS total_internal_txns,
    (SELECT COUNT(*) FROM external_statement) AS total_external_txns,
    (SELECT COUNT(*) FROM reconciliation_result WHERE break_type = 'MATCHED') AS matched_txns,
    (SELECT COUNT(*) FROM reconciliation_result WHERE break_type <> 'MATCHED') AS total_breaks,
    ROUND(
        (
            SELECT COUNT(*)
            FROM reconciliation_result
            WHERE break_type = 'MATCHED'
        ) /
        (
            SELECT COUNT(*)
            FROM internal_ledger
        ) * 100,
        2
    ) AS match_rate_percentage,
    (SELECT COUNT(*) FROM suspense_account WHERE status = 'OPEN') AS suspense_open_items,
    (SELECT SUM(suspense_amount) FROM suspense_account WHERE status = 'OPEN') AS total_suspense_exposure,
    (SELECT COUNT(*)
        FROM suspense_account
        WHERE DATEDIFF(CURDATE(), created_date) > 7
    ) AS items_over_7_days;
