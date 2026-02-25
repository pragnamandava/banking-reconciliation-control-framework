/*
Project: Multi-Account Financial Reconciliation & Suspense Monitoring System
Module: Internal Ledger Data Generation
Database: MySQL 8.0
Description:
1. Creates a helper numbers table using recursive CTE.
2. Generates 1200 synthetic internal ledger transactions.
*/

-- =====================================================
-- 1. Increase recursion depth (MySQL safety setting)
-- =====================================================

SET SESSION cte_max_recursion_depth = 2000;

-- =====================================================
-- 2. Populate Numbers Helper Table (1 to 1500)
-- =====================================================

INSERT INTO numbers (n)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 1500
)
SELECT n FROM seq;

-- =====================================================
-- 3. Generate Synthetic Internal Ledger Transactions
-- =====================================================

INSERT INTO internal_ledger
SELECT
    CONCAT('TXN', LPAD(n, 6, '0')) AS txn_id,

    CONCAT('ACC', FLOOR(RAND() * 10 + 1)) AS account_no,

    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 30) DAY) AS txn_date,

    ROUND(
        (
            CASE
                WHEN RAND() < 0.5 THEN -1
                ELSE 1
            END
        ) * (RAND() * 100000 + 100),
        2
    ) AS amount,

    CASE
        WHEN RAND() < 0.6 THEN 'INR'
        WHEN RAND() < 0.85 THEN 'USD'
        ELSE 'EUR'
    END AS currency,

    CASE
        WHEN RAND() < 0.4 THEN 'PAYMENT'
        WHEN RAND() < 0.6 THEN 'FX'
        WHEN RAND() < 0.75 THEN 'FEE'
        WHEN RAND() < 0.9 THEN 'INTEREST'
        ELSE 'CHARGEBACK'
    END AS txn_type,

    CONCAT('CP_', FLOOR(RAND() * 50 + 1)) AS counterparty,

    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 30) DAY) AS booking_timestamp,

    'POSTED' AS status

FROM numbers
LIMIT 1200;
