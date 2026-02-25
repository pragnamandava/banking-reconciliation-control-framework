/*
Project: Multi-Account Financial Reconciliation & Suspense Monitoring System
Module: External Statement Data Generation
Database: MySQL 8.0
Description:
Generates external statement data with controlled reconciliation scenarios:
- Perfect matches
- Timing differences (T+1 / T+2)
- Amount mismatches
- Duplicate entries
*/

-- =====================================================
-- 1. Perfect Matches (~75%)
-- Simulates normal settlement confirmation
-- =====================================================

INSERT INTO external_statement
SELECT
    CONCAT('STM', SUBSTRING(txn_id, 4)) AS statement_id,
    account_no,
    txn_date AS value_date,
    amount,
    currency,
    txn_type,
    'SWIFT' AS source_system
FROM internal_ledger
WHERE RAND() < 0.75;

-- =====================================================
-- 2. Timing Differences (~10%)
-- Simulates T+1 / T+2 settlement cycle delays
-- =====================================================

INSERT INTO external_statement
SELECT
    CONCAT('STM_T', SUBSTRING(txn_id, 4)) AS statement_id,
    account_no,
    DATE_ADD(txn_date, INTERVAL FLOOR(RAND() * 2 + 1) DAY) AS value_date,
    amount,
    currency,
    txn_type,
    'RTGS' AS source_system
FROM internal_ledger
WHERE RAND() BETWEEN 0.75 AND 0.85;

-- =====================================================
-- 3. Amount Mismatches (~5%)
-- Simulates FX variance / operational discrepancies
-- =====================================================

INSERT INTO external_statement
SELECT
    CONCAT('STM_M', SUBSTRING(txn_id, 4)) AS statement_id,
    account_no,
    txn_date AS value_date,
    CAST(
        ROUND(amount + (RAND() * 50 - 25), 2)
        AS DECIMAL(18,2)
    ) AS amount,
    currency,
    txn_type,
    'ACH' AS source_system
FROM internal_ledger
WHERE RAND() BETWEEN 0.85 AND 0.90;

-- =====================================================
-- 4. Duplicate Entries (~3%)
-- Simulates system duplication / reprocessing error
-- =====================================================

INSERT INTO external_statement
SELECT
    CONCAT('STM_D', SUBSTRING(txn_id, 4)) AS statement_id,
    account_no,
    txn_date AS value_date,
    amount,
    currency,
    txn_type,
    'SWIFT' AS source_system
FROM internal_ledger
WHERE RAND() BETWEEN 0.90 AND 0.93;

-- =====================================================
-- 5. Optional Validation Queries
-- (Can be commented out in production execution)
-- =====================================================

-- Validate record counts
-- SELECT COUNT(*) FROM internal_ledger;
-- SELECT COUNT(*) FROM external_statement;

-- Validate currency distribution
-- SELECT currency, COUNT(*) FROM external_statement GROUP BY currency;

-- Validate date range
-- SELECT MIN(value_date), MAX(value_date) FROM external_statement;
