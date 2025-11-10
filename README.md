# SQL Data Analyst Project
*By Isha Dave*  
Date: November 2025

## Project Overview
This project showcases advanced SQL techniques to detect and analyse fraudulent transactions using recursive and non‑recursive common table expressions (CTEs). It is aimed at demonstrating how a data analyst can use SQL to uncover complex fraud patterns, rolling metrics, and suspicious behaviour in a transactional dataset.

## Objective
- Detect potential money‐laundering chains by tracking funds transferred across multiple accounts.  
- Analyse fraudulent activity over time using rolling windows.  
- Combine multiple criteria (large transfers, zero balance changes, flagged transactions) to identify high‐risk accounts.  
- Validate transactional integrity by comparing computed expected balances vs actual destination balances.  
- Identify transactions where destination balance is zero before or after the transfer.

## Dataset
- The dataset includes a table (e.g., `transactions`) with columns such as:  
  - `nameOrig` – origin account  
  - `nameDest` – destination account  
  - `step` – time step (transaction number or sequence)  
  - `amount` – amount transferred  
  - `type` – transaction type (e.g., ‘TRANSFER’)  
  - `oldbalanceOrg`, `newbalanceOrig` – balances of the origin account  
  - `oldbalanceDest`, `newbalanceDest` – balances of the destination account  
  - `isFraud` – flag indicating fraudulent transaction  
  - `isFlaggedFraud` – possibly flagged fraud indicator  

## Project Structure
```
/sql‑data‑analyst‑project
│
├── README.md
├── queries/
│    ├── 01_recursive_fraud_chain.sql
│    ├── 02_rolling_fraud_sum.sql
│    ├── 03_multiple_cte_suspicious_accounts.sql
│    ├── 04_balance_validation.sql
│    └── 05_zero_balance_transactions.sql
├── data/
│    └── transactions.csv
├── results/
│    └── output‑files‑or‑screenshots
└── documentation/
     └── analysis_report.md
```

## Queries & Techniques
### 1. Detecting Recursive Fraudulent Transactions
```sql
WITH RECURSIVE fraud_chain AS (
  SELECT
    nameOrig AS initial_account,
    nameDest AS next_account,
    step,
    amount
  FROM transactions
  WHERE isFraud = 1 AND type = 'TRANSFER'

  UNION ALL

  SELECT
    fc.initial_account,
    t.nameDest,
    t.step,
    t.amount
  FROM fraud_chain fc
  JOIN transactions t
    ON fc.next_account = t.nameOrig
    AND fc.step < t.step
  WHERE t.isFraud = 1 AND t.type = 'TRANSFER'
)
SELECT * FROM fraud_chain;
```

### 2. Analysing Fraudulent Activity Over Time
```sql
WITH rolling_fraud AS (
  SELECT
    nameOrig,
    step,
    SUM(isFraud) OVER (
      PARTITION BY nameOrig
      ORDER BY step
      ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ) AS fraud_rolling_sum
  FROM transactions
)
SELECT nameOrig, step, fraud_rolling_sum
FROM rolling_fraud
WHERE fraud_rolling_sum > 0;
```

### 3. Complex Fraud Detection Using Multiple CTEs
```sql
WITH large_transfers AS (
  SELECT nameOrig, step, amount
  FROM transactions
  WHERE type = 'TRANSFER' AND amount > 500000
),
no_balance_change AS (
  SELECT nameOrig, step, oldbalanceOrg, newbalanceOrig
  FROM transactions
  WHERE oldbalanceOrg = newbalanceOrig
),
flagged_transactions AS (
  SELECT nameOrig, step, isFlaggedFraud
  FROM transactions
  WHERE isFlaggedFraud = 1
)
SELECT lt.nameOrig
FROM large_transfers lt
JOIN no_balance_change nbc
  ON lt.nameOrig = nbc.nameOrig
  AND lt.step = nbc.step
JOIN flagged_transactions ft
  ON lt.nameOrig = ft.nameOrig
  AND lt.step = ft.step;
```

### 4. Balance Validation: Computed vs Actual
```sql
WITH cte AS (
  SELECT
    amount,
    nameOrig,
    oldbalanceDest,
    newbalanceDest,
    (amount + oldbalanceDest) AS new_updated_Balance
  FROM transactions
)
SELECT *
FROM cte
WHERE new_updated_Balance = newbalanceDest;
```

### 5. Detecting Transactions with Zero Destination Balance
```sql
SELECT
  nameOrig,
  nameDest,
  oldbalanceDest,
  newbalanceDest,
  amount
FROM transactions
WHERE oldbalanceDest = 0 OR newbalanceDest = 0;
```

## Insights & Learnings
- Recursive CTEs are powerful for tracing multi‑hop transaction flows.  
- Window functions allow time‑based analysis (rolling sums) without manual self‑joins.  
- Breaking down complex detection rules into multiple CTEs leads to cleaner SQL.  
- Validating balances helps detect hidden manipulations.  
- Zero‑balance patterns before/after transfers can uncover suspicious funneling of money.

## How to Run
1. Load the dataset into your SQL environment (PostgreSQL, MySQL, etc).  
2. Run the queries in the `queries/` folder in sequence or individually.  
3. View output in `results/` folder.  
4. Modify thresholds as needed.

## Skills Demonstrated
- Advanced SQL: Recursive CTEs, window functions, multi‑CTE structures  
- Fraud detection logic  
- Data validation and quality checks  
- Reproducible project design  

## Licence
MIT License

---
**Thanks for checking out this project!**
