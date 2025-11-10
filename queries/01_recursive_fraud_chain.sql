WITH RECURSIVE fraud_chain AS (
    SELECT 
        nameOrig AS initial_account, 
        nameDest AS next_account, 
        step, 
        amount
    FROM 
        transactions
    WHERE 
        isFraud = 1 AND type = 'TRANSFER'
    
    UNION ALL
    
    SELECT 
        fc.initial_account, 
        t.nameDest, 
        t.step, 
        t.amount
    FROM 
        fraud_chain fc
    JOIN 
        transactions t 
    ON 
        fc.next_account = t.nameOrig AND fc.step < t.step
    WHERE 
        t.isFraud = 1 AND t.type = 'TRANSFER'
)
SELECT * FROM fraud_chain;