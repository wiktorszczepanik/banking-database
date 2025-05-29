/* Basic check of account before inserting financial record to financial_log */

CREATE OR REPLACE TRIGGER checkBeforeNewFinancialRecord
BEFORE INSERT
ON financial_log
FOR EACH ROW
DECLARE
    accountStatusID INTEGER;
    transactionType INTEGER;
BEGIN
    -- Main account status verification -> must be "ACTIVE"
    SELECT status_id INTO accountStatusID FROM account
    WHERE account.id = :NEW.account_id;
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
    ELSE
        RAISE_APPLICATION_ERROR(-20102, 'Payment type not available: amount cannot be 0');
    END IF;
END;

/* Verify is client also active */
-- Cannot insert account if client is deactivated
-- Only possible update with deactivated client is deactivating account

CREATE OR REPLACE TRIGGER verifyIsClientActive
BEFORE INSERT OR UPDATE
ON account
FOR EACH ROW
DECLARE
    clientStatus INTEGER;
BEGIN
    -- Check is client active
    SELECT COUNT(*) INTO clientStatus FROM status
    WHERE status.id = :NEW.client_data_id AND status.name = 'ACTIVE';

    IF INSERTING AND clientStatus <> 1 THEN
        RAISE_APPLICATION_ERROR(-20103, 'Client is not "ACTIVE" in banking system. ' ||
            'We cannot insert new account under this client');
    -- Cannot change values other than account status if client is "CLOSED"
    ELSIF UPDATING AND clientStatus <> 1 THEN
        IF :NEW.account_number <> :OLD.account_number OR
           :NEW.account_number_format_id <> :OLD.account_number_format_id OR
           :NEW.registration_date <> :OLD.registration_date OR
           :NEW.loyalty_rating <> :OLD.loyalty_rating OR
           :NEW.client_data_id <> :OLD.client_data_id OR
           :NEW.available <> :OLD.available OR
           :NEW.pend <> :OLD.pend OR
           :NEW.currency_id <> :OLD.currency_id THEN
            RAISE_APPLICATION_ERROR(-20104, 'Cannot update values other then status to "CLOSED" or "PEND"');
        ELSIF :NEW.status_id = 1 THEN
            RAISE_APPLICATION_ERROR(-20105, 'Cannot change account status to "ACTIVE" due to current client status');
        END IF;
    END IF;
END;

