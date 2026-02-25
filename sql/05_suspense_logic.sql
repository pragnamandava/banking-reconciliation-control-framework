/*
Project: Multi-Account Financial Reconciliation & Suspense Monitoring System
Module: Suspense Routing Logic
Database: MySQL 8.0
Description:
Routes material reconciliation breaks into suspense account
for exposure monitoring and risk containment.
*/

-- =====================================================
-- 1. Route Material Breaks to Suspense
-- (Amount mismatch and missing in ledger only)
-- =====================================================

INSERT INTO suspense_account (
    source_recon_id,
    ledger_txn_id,
    statement_id,
    account_no,
    suspense_amount,
    created_date,
    break_type
)
SELECT
    recon_id,
    ledger_txn_id,
    statement_id,
    account_no,
    COALESCE(statement_amount, ledger_amount) AS suspense_amount,
    CURDATE() AS created_date,
    break_type
FROM reconciliation_result
WHERE break_type IN ('AMOUNT_MISMATCH', 'MISSING_IN_LEDGER');

-- =====================================================
-- 2. Optional Validation Query
-- =====================================================

-- SELECT break_type, COUNT(*), SUM(suspense_amount)
-- FROM suspense_account
-- GROUP BY break_type;
