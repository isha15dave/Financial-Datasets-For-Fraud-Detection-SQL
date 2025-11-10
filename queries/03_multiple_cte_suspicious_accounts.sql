WITH large_transfers AS (
    SELECT 
        nameOrig, 
        step, 
        amount
    FROM 
        transactions
    WHERE 
        type = 'TRANSFER' AND amount > 500000
), 

no_balance_change AS (
    SELECT 
        nameOrig, 
        step, 
        oldbalanceOrg, 
        newbalanceOrig
    FROM 
        transactions
    WHERE 
        oldbalanceOrg = newbalanceOrig
),

flagged_transactions AS (
    SELECT 
        nameOrig, 
        step, 
        isFlaggedFraud
    FROM 
        transactions
    WHERE 
        isFlaggedFraud = 1
)

SELECT 
    lt.nameOrig
FROM 
    large_transfers lt
JOIN 
    no_balance_change nbc ON lt.nameOrig = nbc.nameOrig AND lt.step = nbc.step
JOIN 
    flagged_transactions ft ON lt.nameOrig = ft.nameOrig AND lt.step = ft.step;