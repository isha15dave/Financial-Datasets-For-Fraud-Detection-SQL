WITH rolling_fraud AS (
    SELECT 
        nameOrig, 
        step, 
        SUM(isFraud) OVER (PARTITION BY nameOrig ORDER BY step ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS fraud_rolling_sum
    FROM 
        transactions
)
SELECT 
    nameOrig, 
    step, 
    fraud_rolling_sum
FROM 
    rolling_fraud
WHERE 
    fraud_rolling_sum > 0;