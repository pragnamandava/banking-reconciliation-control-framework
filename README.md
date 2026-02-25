# 📘 Multi-Account Financial Reconciliation & Suspense Monitoring System

## 1. Project Overview

This project simulates a bank-grade **transaction reconciliation control framework** used in financial institutions to compare internal ledger records with external confirmation statements.

The system performs:

- Deterministic 1-to-1 transaction matching  
- Break classification  
- Automated suspense routing  
- Ageing analysis  
- Financial exposure calculation  
- End-of-Day (EOD) control reporting  

The objective is to replicate how banking operations teams manage reconciliation, monitor risk, and control financial exposure.

---

## 2. Business Context

In banking operations, reconciliation ensures that:

- Internal ledger records (bank’s books)
- External statements (custodian / clearing system confirmation)

are aligned.

Breaks (unmatched transactions) indicate:

- Settlement delays  
- Operational errors  
- Booking failures  
- FX discrepancies  
- System duplication  

Unresolved breaks create **financial exposure** and operational risk.

This system simulates that real-world control process.

---

## 3. System Architecture

### Data Sources

#### Internal Ledger (`internal_ledger`)
- 1200 synthetic transactions
- Multi-account structure (10 accounts)
- Multi-currency (INR, USD, EUR)
- Debit & credit flows
- 30-day transaction cycle

Represents: Core banking ledger / sub-ledger.

#### External Statement (`external_statement`)
- 1174 transactions
- Engineered settlement variations
- Duplicate records
- Timing differences
- Amount mismatches

Represents: SWIFT / RTGS / Custodian confirmation feed.

---

## 4. Reconciliation Engine Design

### 4.1 Matching Logic

The system implements **deterministic 1-to-1 allocation logic**.

Matching conditions:
- Same account number
- Same currency
- Exact amount match
- Date tolerance within T+2 (settlement cycle allowance)

To prevent duplicate allocation:

```sql
WHERE NOT EXISTS (...)
```

This enforces:

> One ledger transaction can match only one statement transaction.

This mimics production-grade reconciliation systems.

---

### 4.2 Break Classification

Transactions are classified into:

| Break Type           | Meaning |
|----------------------|----------|
| MATCHED              | Fully reconciled |
| AMOUNT_MISMATCH      | Value discrepancy |
| MISSING_IN_STATEMENT | Internal record without external confirmation |
| MISSING_IN_LEDGER    | External transaction not recorded internally |

This layered logic ensures accurate categorization and controlled processing.

---

## 5. Suspense Account Framework

Unresolved material breaks are routed into:

**`suspense_account` table**

A suspense account is a temporary holding ledger for unresolved transactions.

Break types routed:
- AMOUNT_MISMATCH
- MISSING_IN_LEDGER

Suspense tracks:
- Transaction reference
- Monetary value
- Creation date
- Status (OPEN / CLEARED)

This simulates financial containment controls used in real banking environments.

---

## 6. Ageing Analysis

Ageing measures how long breaks remain unresolved.

Age buckets implemented:

- 0–2 Days (Within SLA)
- 3–7 Days (Moderate Risk)
- 8–30 Days (High Risk)
- 30+ Days (Audit Concern)

Ageing analysis helps identify operational backlog and escalation triggers.

---

## 7. Financial Exposure Monitoring

Financial exposure is calculated as:

```sql
SUM(suspense_amount)
```

This represents:

> Total monetary risk from unresolved reconciliation breaks.

Exposure is analyzed by:
- Break type
- Ageing bucket
- Total net suspense position

---

## 8. End-of-Day (EOD) Control Summary

Daily dashboard metrics include:

- Total internal transactions
- Total external transactions
- Matched transaction count
- Match rate percentage
- Total breaks
- Suspense open items
- Total suspense exposure
- Items aged >7 days

Example Output:

- Match Rate: 88.08%
- Suspense Open Items: 262
- Total Exposure: 23,994.28
- Items >7 Days: 193

This simulates operational reporting sent to:
- Operations Head
- Risk Management
- Finance Control

---

## 9. Key Control Principles Implemented

- 1-to-1 allocation integrity
- Settlement tolerance (T+2 logic)
- Break prioritization order
- Controlled suspense routing
- Age-based risk escalation framework
- Monetary exposure tracking

---

## 10. Tools Used

- MySQL 8.0
- Advanced SQL (joins, subqueries, aggregations)
- Synthetic data engineering

---

## 11. What This Project Demonstrates

- Understanding of reconciliation workflows
- Knowledge of suspense accounting principles
- Financial risk monitoring capability
- Data integrity controls
- Structured operational reporting
- Practical SQL implementation of banking processes

---

## 12. Future Enhancements

Planned improvements:

- SLA breach flagging
- Materiality thresholds
- Root cause tagging
- Automated break resolution simulation
- Power BI dashboard integration
- Multi-currency exposure breakdown
- Workflow status tracking (Investigation / Escalated / Resolved)

---

## Project Summary

This project simulates a banking-grade reconciliation control environment, implementing deterministic 1-to-1 transaction matching, break classification, suspense management, ageing monitoring, and financial exposure analytics using MySQL.
