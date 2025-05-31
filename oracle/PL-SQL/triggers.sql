
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
                :NEW.transaction_type_id := 1; -- 1 = "Payment"
                DBMS_OUTPUT.PUT_LINE('The transaction type "' || transactionType || '" does not match the positive amount. ' ||
                    'Transaction type is updated to base value "Payment"');
            END IF;
        -- Check "negative" amount
        ELSIF :NEW.amount < 0 THEN
            -- Check if the transaction type matches the payment amount
            IF :NEW.transaction_type_id NOT IN (3, 4) THEN -- Fee, Interest
                :NEW.transaction_type_id := 1; -- 1 = "Payment"
                DBMS_OUTPUT.PUT_LINE('The transaction type "' || transactionType || '" does not match the negative amount. ' ||
                    'Transaction type is updated to base value "Payment"');
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



/* Check KYC after mandatory consent */

CREATE OR REPLACE TRIGGER checkKYCAfterMandatoryConsents
AFTER INSERT OR DELETE
ON account_consents
FOR EACH ROW
DECLARE
    -- Data for KYC
    clientId INTEGER;
    clientStatus INTEGER;
    clientBusinessAddress INTEGER;
    clientLegalAddress INTEGER;
    accountsPerClient INTEGER;
    notificationPhone INTEGER;
    forPend INTEGER;
BEGIN
    IF INSERTING THEN
        IF :NEW.consents_id = 1 THEN -- Data Porc. Consent\
            forPend := 0;
            SELECT client_data_id INTO clientId FROM account WHERE id = :NEW.client_account_id;

            -- Verify Client status
            SELECT status_id INTO clientStatus FROM client_data WHERE id = clientId;
            IF clientStatus <> 1 THEN
                DBMS_OUTPUT.PUT_LINE('Client must be active');
                forPend := 1;
            END IF;

            -- Client must have Business and Legal address
            SELECT COUNT(*) INTO clientBusinessAddress
            FROM address
            WHERE client_data_id = clientId
            AND address_type_id = 1;
            SELECT COUNT(*) INTO clientLegalAddress
            FROM address
            WHERE client_data_id = clientId
            AND address_type_id = 2;

            IF clientBusinessAddress <> 1 THEN
                DBMS_OUTPUT.PUT_LINE('Missing Business address for client: ' || clientId);
                forPend := 1;
            ELSIF clientLegalAddress <> 1 THEN
                forPend := 1;
                DBMS_OUTPUT.PUT_LINE('Missing Legal address for client: ' || clientId);
            END IF;

            -- Notification phone / code required for more than 1 account per client

            -- Number of accounts per client
            SELECT COUNT(*) INTO accountsPerClient
            FROM account
            WHERE client_data_id = clientId;

            -- client notification phone / code
            SELECT COUNT(*) INTO notificationPhone
            FROM client_data
            WHERE id = clientId
            AND notification_phone_code IS NOT NULL
            AND notification_phone_number IS NOT NULL;

            -- Error if notification phone / code is missing
            IF accountsPerClient > 1 AND notificationPhone = 0 THEN
                forPend := 1;
                DBMS_OUTPUT.PUT_LINE('Notification phone and notification phone code is required' ||
                    ' for client with more then 1 account');
            END IF;

            IF forPend > 0 THEN
                UPDATE account SET status_id = 3
                WHERE id = :NEW.client_account_id;
                DBMS_OUTPUT.PUT_LINE('Account: ' || :NEW.client_account_id || ' is updated to status "PEND"');
            END IF;
        END IF;
    ELSIF DELETING THEN
        IF :OLD.consents_id = 1 OR :OLD.consents_id = 3 THEN
            UPDATE account SET status_id = 3
            WHERE id = :OLD.client_account_id;
            DBMS_OUTPUT.PUT_LINE('Account: ' || :OLD.client_account_id || ' is updated to status "PEND". ' ||
                'Mandatory consents are required for "ACTIVE" account status');
        END IF;
    END IF;
END;

-- CALL updateAccountBalance(:NEW.id);
-- CALL verifyKYC(:NEW.client_account_id);
