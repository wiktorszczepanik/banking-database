/* Updating account balance based on financial_log */

CREATE OR UPDATE PROCEDURE updateAccountBalance
(accountForBalanceUpdate INTEGER)
AS
    updatedAccountId INTEGER;
    updatedAccountAmount NUMBER(19, 2);
    CURSOR cur1 IS SELECT account_id, SUM(amount)
    FROM financial_log
    GROUP BY account_id;
    
BEGIN
    -- Update for one account
    IF accountForBalanceUpdate >= 0 THEN
        SELECT SUM(amount) INTO updatedAccountAmount
        FROM financial_log
        WHERE account_id = accountForBalanceUpdate;
        
        UPDATE account SET available = updatedAccountAmount
        WHERE id = accountForBalanceUpdate;
    -- If values under ZERO then update ALL accounts
    ELSE
        OPEN cur1;
        LOOP
            FETCH cur1 INTO updatedAccountId, updatedAccountAmount;
            EXIT WHEN cur1%NOTFOUND;
            UPDATE account SET available = updatedAccountAmount
            WHERE id = updatedAccountId;
        END LOOP;
    END IF;
END;
