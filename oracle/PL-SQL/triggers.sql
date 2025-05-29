/* Basic check of account before inserting financial record to financial_log */

CREATE OR REPLACE TRIGGER checkBeforeNewFinancialRecord
BEFORE INSERT
ON financial_log
FOR EACH ROW
DECLARE
    accountStatusID INTEGER;
    transactionType INTEGER;
BEGIN
    -- Main account status verification -> must be "ACTIVE" or "PEND"
    SELECT status_id INTO accountStatusID FROM account
    WHERE account.id = :NEW.account_id;
    IF accountStatusID = 2 THEN -- 2 = "CLOSED"
        RAISE_APPLICATION_ERROR(-20100, 'Account status cannot be "CLOSED"');
    END IF;

    -- Procede rush
    IF :NEW.rush <> 0 AND accountStatusID = 1 THEN -- 1 = "ACTIVE"
        -- CALL updateAccountBalance(:NEW.id);
    END IF;

    -- Check "positive" amount
    IF :NEW.amount > 0 THEN
        -- Check if the transaction type matches the payment amount
        SELECT id BULK COLLECT INTO transactionType FROM transaction WHERE for_amount = '+';
        IF :NEW.transaction_type_id NOT IN transactionType THEN -- Refund, Loan, Chargeback
            RAISE_APPLICATION_ERROR(-20101, 'The transaction type does not match the positive amount');
        END IF;
    -- Check "negative" amount
    ELSIF :NEW.amount < 0 THEN
        -- Check if the transaction type matches the payment amount
        SELECT id BULK COLLECT INTO transactionType FROM transaction WHERE for_amount = '-';
        IF :NEW.transaction_type_id NOT IN transactionType THEN -- Fee, Interest
            RAISE_APPLICATION_ERROR(-20101, 'The transaction type does not match the negative amount');
        END IF;
    ELSE -- IF zero
        RAISE_APPLICATION_ERROR(-20102, 'Payment type not available: amount cannot be 0');
    END IF;
END;

SELECT * FROM status;

/* Fill account information after mandatory consents */

SELECT * FROM CONSENTS;

CREATE OR REPLACE TRIGGER fillAccountInfoAfterConsents
AFTER INSERT OR UPDATE
ON account_consents
FOR EACH ROW
DECLARE
    -- Consents info
    requiredAccountConsents INTEGER;
    accountConsents INTEGER;

    -- Funds info
    availableAccountFunds INTEGER; -- When setting up account -> "1000$" for start etc.
    newID INTEGER;
    newAccountId INTEGER;
    newAmount NUMBER(19, 2);
    newRush SMALLINT := 1;
    newOperationDate DATE := SYSDATE;
    newTimestamp TIMESTAMP := SYSDATE;
    newTransactionTypeId INTEGER;
    newDescription VARCHAR2(1000);
    newCurrencyId INTEGER;
    newCurrencyDate DATE;
    newOtherAccountNumber INTEGER;
    newAccountNumberFormatId INTEGER;


BEGIN
    IF INSERTING THEN
        -- Get number of mandatory consents
        SELECT COUNT(*) INTO requiredAccountConsents
        FROM consents WHERE mandatory = 1;

        -- Account consents
        SELECT COUNT(*) INTO accountConsents
        FROM account_consents ac
        INNER JOIN consents c ON ac.consents_id = c.id
        WHERE ac.client_account_id = :NEW.client_account_id
        AND c.mandatory = 1;

        IF requiredAccountConsents = accountConsents THEN
            -- CALL verifyKYC(:NEW.client_account_id);
            -- Fill financial_log by available funds after setting up account

        END IF;
    END IF;
END;

SELECT * FROM FINANCIAL_LOG;


