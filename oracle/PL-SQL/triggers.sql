CREATE OR REPLACE TRIGGER checkBeforeNewFinancialRecord
BEFORE INSERT
ON financial_log
FOR EACH ROW
DECLARE
    accountStatusID INTEGER;
BEGIN
    -- Main account status verification -> must be "ACTIVE"
    SELECT status_id INTO accountStatusID FROM account
    WHERE id = :NEW.account_id;
    IF accountStatusID <> 1 THEN
        RAISE_APPLICATION_ERROR(-20100, 'Account status is different from: "active"');
    END IF;

    -- Procede rush
    IF :NEW.rush > 0 THEN
        -- CALL updateAccountBalance(:NEW.id);
    END IF;

    -- Check "positive" amount
    IF :NEW.amount > 0 THEN
        -- Check if the transaction type matches the payment amount
        IF :NEW.transaction_type_id NOT IN (2, 5, 6) THEN -- Refund, Loan, Chargeback
            RAISE_APPLICATION_ERROR(-20101, 'The transaction type does not match the positive amount');
        END IF;
    -- Check "negative" amount
    ELSIF :NEW.amount < 0 THEN
        -- Check if the transaction type matches the payment amount
        IF :NEW.transaction_type_id NOT IN (3, 4) THEN -- Fee, Interest
            RAISE_APPLICATION_ERROR(-20101, 'The transaction type does not match the negative amount');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20102, 'Payment type not available: amount cannot be 0');
    END IF;
END;

