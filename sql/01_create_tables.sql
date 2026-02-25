/*
Project: Multi-Account Financial Reconciliation & Suspense Monitoring System
Module: Database Schema Creation
Database: MySQL 8.0
Description:
Creates core tables required for reconciliation, suspense management,
ageing analysis, and end-of-day reporting.
*/

-- =====================================================
-- 1. Internal Ledger Table
-- Represents bank’s internal transaction records
-- =====================================================

CREATE TABLE internal_ledger (
    txn_id VARCHAR(20),
    account_no VARCHAR(15),
    txn_date DATE,
    amount DECIMAL(18,2),
    currency VARCHAR(3),
    txn_type VARCHAR(20),
    counterparty VARCHAR(50),
    booking_timestamp DATETIME,
    status VARCHAR(20)
);

-- =====================================================
-- 2. Numbers Helper Table
-- Used for synthetic data generation
-- =====================================================

CREATE TABLE numbers (
    n INT PRIMARY KEY
);

-- =====================================================
-- 3. External Statement Table
-- Represents external confirmation / settlement feed
-- =====================================================

CREATE TABLE external_statement (
    statement_id VARCHAR(20),
    account_no VARCHAR(15),
    value_date DATE,
    amount DECIMAL(18,2),
    currency VARCHAR(3),
    description VARCHAR(100),
    source_system VARCHAR(20)
);

-- =====================================================
-- 4. Reconciliation Result Table
-- Stores 1-to-1 matching results and break classification
-- =====================================================

CREATE TABLE reconciliation_result (
    recon_id INT AUTO_INCREMENT PRIMARY KEY,
    ledger_txn_id VARCHAR(20),
    statement_id VARCHAR(20),
    account_no VARCHAR(15),
    ledger_amount DECIMAL(18,2),
    statement_amount DECIMAL(18,2),
    ledger_date DATE,
    statement_date DATE,
    break_type VARCHAR(50)
);

-- =====================================================
-- 5. Suspense Account Table
-- Stores unresolved material breaks
-- =====================================================

CREATE TABLE suspense_account (
    suspense_id INT AUTO_INCREMENT PRIMARY KEY,
    source_recon_id INT,
    ledger_txn_id VARCHAR(20),
    statement_id VARCHAR(20),
    account_no VARCHAR(15),
    suspense_amount DECIMAL(18,2),
    created_date DATE,
    break_type VARCHAR(50),
    status VARCHAR(20) DEFAULT 'OPEN'
);
