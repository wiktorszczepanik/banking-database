/* "checkBeforeNewFinancialRecord" - trigger tests */


/* DELETING test */

-- Simple row delete
DELETE FROM financial_log
WHERE id = 1;
-- OUTPUT:
-- [2025-05-31 16:38:41] [72000][20099]
-- [2025-05-31 16:38:41] 	ORA-20099: Cannot delete any financial log
-- ...


/* INSERTING test */

-- INSERTING to "CLOSED" account
INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id,
    description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (16, 5, -- Account is "CLOSED"
    100, 0, SYSDATE, SYSDATE, 1,
    'Test description', 1, SYSDATE, 61109010140000071219812875, 1);
-- OUTPUT:
-- [2025-05-31 16:39:57] [72000][20100]
-- [2025-05-31 16:39:57] 	ORA-20100: Account status cannot be "CLOSED"
-- ...


-- INSERTING with positive amount
INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id,
    description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (22, 1, 100, -- Positive
    0, SYSDATE, SYSDATE, 3, -- Fee
    'Test description', 1, SYSDATE, 61109010140000071219812875, 1);
-- OUTPUT:
-- [2025-05-31 21:56:39] 1 row affected in 146 ms
-- The transaction type "Fee" does not match the positive amount. Transaction type is updated to base value "Payment"
-- ...


-- INSERTING with negative amount
INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id,
    description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (23, 1, -100, -- Negative
    0, SYSDATE, SYSDATE, 5, -- Loan
    'Test description', 1, SYSDATE, 61109010140000071219812875, 1);
-- OUTPUT:
-- [2025-05-31 21:58:59] 1 row affected in 152 ms
-- The transaction type "Loan" does not match the negative amount. Transaction type is updated to base value "Payment"
-- ...


-- INSERTING with ZERO amount
INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id,
    description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (24, 1, 0, -- Amount is ZERO
    0, SYSDATE, SYSDATE, 1,
    'Test description', 1, SYSDATE, 61109010140000071219812875, 1);
-- OUTPUT:
-- [72000][20102]
-- ORA-20102: Payment type not available: amount cannot be 0
-- ...



/* "checkKYCAfterMandatoryConsents" - trigger tests */

/* INSERTING test */
    
-- Invalid Client status, missing business address, missing legal address
INSERT INTO account_consents (consents_id, client_account_id)
VALUES (1, 4);
-- OUTPUT:
-- Client: 3 -  must be active
-- Missing Business address for client: 3
-- Missing Legal address for client: 3
-- Account: 4 is updated to status "PEND"
-- ...


-- Show missing notification data for more than 1 account
INSERT INTO account_consents (consents_id, client_account_id)
VALUES (1, 2);
-- OUTPUT:
-- Notification phone and notification phone code is required for client with more then 1 account
-- Account: 2 is updated to status "PEND"
-- ...


/* DELETING test */

DELETE FROM account_consents
WHERE client_account_id = 4
AND consents_id = 3;
-- OUTPUT:
-- Account: 4 is updated to status "PEND". Mandatory consents are required for "ACTIVE" account status
-- ...

