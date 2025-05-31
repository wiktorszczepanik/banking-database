/* Basic check of account before inserting financial record to financial_log */

CREATE OR REPLACE TRIGGER checkBeforeNewFinancialRecord
BEFORE DELETE OR INSERT OR UPDATE
ON financial_log
FOR EACH ROW
DECLARE
    accountStatusID INTEGER;
    transactionType VARCHAR2(15);
BEGIN
    IF DELETING THEN
        RAISE_APPLICATION_ERROR(-20099, 'Cannot delete any financial log');
    ELSIF INSERTING THEN
        -- Main account status verification -> must be "ACTIVE" or "PEND" for INSERTING and UPDATING
        SELECT status_id INTO accountStatusID FROM account
        WHERE account.id = :NEW.account_id;
        IF accountStatusID = 2 OR accountStatusID = 3 THEN -- 2 = "CLOSED", 3 = "PEND"
            RAISE_APPLICATION_ERROR(-20100, 'Account status cannot be "CLOSED"');
        END IF;

        -- Procede rush
        IF :NEW.rush <> 0 AND accountStatusID = 1 THEN -- 1 = "ACTIVE"
            -- CALL updateAccountBalance(:NEW.id);
            DBMS_OUTPUT.PUT_LINE('Account balance updated for id: ' || :NEW.id);
        END IF;

        -- Get transaction type used in INSERT
        SELECT type INTO transactionType FROM transaction WHERE id = :NEW.transaction_type_id;
        -- Check "positive" amount
        IF :NEW.amount > 0 THEN
            -- Check if the transaction type matches the payment amount
            IF :NEW.transaction_type_id NOT IN (2, 5, 6) THEN -- Refund, Loan, Chargeback
                RAISE_APPLICATION_ERROR(-20101, 'The transaction type "' || transactionType || '" does not match the positive amount');
            END IF;
        -- Check "negative" amount
        ELSIF :NEW.amount < 0 THEN
            -- Check if the transaction type matches the payment amount
            IF :NEW.transaction_type_id NOT IN (3, 4) THEN -- Fee, Interest
                RAISE_APPLICATION_ERROR(-20101, 'The transaction type "' || transactionType || '" does not match the negative amount');
            END IF;
        ELSE -- IF zero
            RAISE_APPLICATION_ERROR(-20102, 'Payment type not available: amount cannot be 0');
        END IF;
    -- Available to change is only "rush"
    ELSIF UPDATING AND (:OLD.id <> :NEW.id OR
            :OLD.account_id <> :NEW.account_id OR
            :OLD.amount <> :NEW.amount OR
            :OLD.operation_date <> :NEW.operation_date OR
            :OLD.timestamp <> :NEW.timestamp OR
            :OLD.transaction_type_id <> :NEW.transaction_type_id OR
            :OLD.description <> :NEW.description OR
            :OLD.currency_id <> :NEW.currency_id OR
            :OLD.currency_date <> :NEW.currency_date OR
            :OLD.other_account_number <> :NEW.other_account_number OR
            :OLD.account_number_format_id <> :NEW.account_number_format_id) THEN
            RAISE_APPLICATION_ERROR(-20103, 'Cannot update attribute other then "rush"');
    END IF;
END;


/* Fill account information after mandatory consents */

CREATE OR REPLACE TRIGGER fillAccountInfoAfterConsents
AFTER INSERT OR DELETE OR UPDATE
ON account_consents
FOR EACH ROW
DECLARE
    -- Consents info
    requiredAccountConsents INTEGER;
    accountConsents INTEGER;
    isMandatory INTEGER;

    -- Funds info
    newId INTEGER;
    newAccountId INTEGER;
    newAmount NUMBER(19, 2); -- When setting up account -> "1000$" for start etc.
    newRush SMALLINT := 1;
    newOperationDate DATE;
    newTimestamp TIMESTAMP;
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
            SELECT MAX(id) + 1 INTO newId FROM financial_log;
            newAccountId := :NEW.client_account_id;
            SELECT available INTO newAmount FROM account WHERE id = :NEW.client_account_id;
            newRush := 0;
            newOperationDate := SYSDATE;
            newTimestamp := SYSDATE;
            newTransactionTypeId := 1;
            newDescription := 'Initial funds for opening new account';
            SELECT currency_id INTO newCurrencyId FROM account WHERE id = :NEW.client_account_id;
            newCurrencyDate := SYSDATE;
            newOtherAccountNumber := 10020100100000000000000000;
            newAccountNumberFormatId := 3;

            -- Inserting into financial log
            INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id,
                description, currency_id, currency_date, other_account_number, account_number_format_id)
            VALUES (newId, newAccountId, newAmount, newRush,
                newOperationDate, newTimestamp, newTransactionTypeId,
                newDescription, newCurrencyId, newCurrencyDate, newOtherAccountNumber,
                newAccountNumberFormatId);
            DBMS_OUTPUT.PUT_LINE('Initial fund for opening account are added to financial log');
        END IF;
    ELSIF DELETING THEN
        SELECT COUNT(*) INTO isMandatory
        FROM account_consents ac
        INNER JOIN consents c ON ac.consents_id = c.id
        WHERE ac.client_account_id = :OLD.client_account_id
        AND c.mandatory = 1;
        IF isMandatory > 0 THEN
            RAISE_APPLICATION_ERROR(-20200, 'Cannot delete mandatory consent');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Marketing consent was deleted from: ' || :OLD.client_account_id);
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20200, 'Cannot update account_consent. Available are only inserting and deleting.');
    END IF;
END;


SELECT * FROM account_consents;

/* INSERTING test */













-- CALL updateAccountBalance(:NEW.id);
-- CALL verifyKYC(:NEW.client_account_id);
