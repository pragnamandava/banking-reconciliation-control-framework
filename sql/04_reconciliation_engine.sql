/*
Project: Multi-Account Financial Reconciliation & Suspense Monitoring System
Module: Reconciliation Engine
Database: MySQL 8.0
Description:
Implements deterministic 1-to-1 transaction matching with layered
break classification and duplicate allocation prevention.
*/

-- =====================================================
-- 1. EXACT MATCH STAGE
-- Matches account, currency, amount, and T+2 date tolerance
-- =====================================================

INSERT INTO reconciliation_result (
    ledger_txn_id,
    statement_id,
    account_no,
    ledger_amount,
    statement_amount,
    ledger_date,
    statement_date,
    break_type
)
SELECT
    l.txn_id,
    s.statement_id,
    l.account_no,
    l.amount,
    s.amount,
    l.txn_date,
    s.value_date,
    'MATCHED'
FROM internal_ledger l
JOIN external_statement s
    ON l.account_no = s.account_no
    AND l.currency = s.currency
    AND l.amount = s.amount
    AND ABS(DATEDIFF(l.txn_date, s.value_date)) <= 2
WHERE NOT EXISTS (
    SELECT 1
    FROM reconciliation_result r
    WHERE r.ledger_txn_id = l.txn_id
       OR r.statement_id = s.statement_id
);

-- =====================================================
-- 2. AMOUNT MISMATCH STAGE
-- Same account and date tolerance, different amount
-- =====================================================

INSERT INTO reconciliation_result (
    ledger_txn_id,
    statement_id,
    account_no,
    ledger_amount,
    statement_amount,
    ledger_date,
    statement_date,
    break_type
)
SELECT
    l.txn_id,
    s.statement_id,
    l.account_no,
    l.amount,
    s.amount,
    l.txn_date,
    s.value_date,
    'AMOUNT_MISMATCH'
FROM internal_ledger l
JOIN external_statement s
    ON l.account_no = s.account_no
    AND l.currency = s.currency
    AND ABS(DATEDIFF(l.txn_date, s.value_date)) <= 2
    AND l.amount <> s.amount
WHERE NOT EXISTS (
    SELECT 1
    FROM reconciliation_result r
    WHERE r.ledger_txn_id = l.txn_id
       OR r.statement_id = s.statement_id
);

-- =====================================================
-- 3. MISSING IN STATEMENT
-- Internal record without external confirmation
-- =====================================================

INSERT INTO reconciliation_result (
    ledger_txn_id,
    account_no,
    ledger_amount,
    ledger_date,
    break_type
)
SELECT
    l.txn_id,
    l.account_no,
    l.amount,
    l.txn_date,
    'MISSING_IN_STATEMENT'
FROM internal_ledger l
WHERE NOT EXISTS (
    SELECT 1
    FROM reconciliation_result r
    WHERE r.ledger_txn_id = l.txn_id
);

-- =====================================================
-- 4. MISSING IN LEDGER
-- External transaction not recorded internally
-- =====================================================

INSERT INTO reconciliation_result (
    statement_id,
    account_no,
    statement_amount,
    statement_date,
    break_type
)
SELECT
    s.statement_id,
    s.account_no,
    s.amount,
    s.value_date,
    'MISSING_IN_LEDGER'
FROM external_statement s
WHERE NOT EXISTS (
    SELECT 1
    FROM reconciliation_result r
    WHERE r.statement_id = s.statement_id
);

-- =====================================================
-- 5. Optional Validation Query
-- =====================================================

-- SELECT break_type, COUNT(*)
-- FROM reconciliation_result
-- GROUP BY break_type;
