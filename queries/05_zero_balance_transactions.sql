SELECT 
    nameOrig, 
    nameDest, 
    oldbalanceDest, 
    newbalanceDest, 
    amount
FROM 
    transactions
WHERE 
    oldbalanceDest = 0 OR newbalanceDest = 0;