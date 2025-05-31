/* "checkBeforeNewFinancialRecord" - trigger tests */

SELECT * FROM financial_log;
SELECT * FROM account;
SELECT * FROM status;
SELECT * FROM transaction;


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

-- INSERTING with rush flag
INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id,
    description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (17, 1, 100, 1, -- Rush is TRUE
    SYSDATE, SYSDATE, 1,
    'Test description', 1, SYSDATE, 61109010140000071219812875, 1);
-- OUTPUT:
-- [2025-05-31 16:51:33] 1 row affected in 153 ms
-- Account balance updated for id: 000
-- ...

-- INSERTING with positive amount
INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id,
    description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (17, 1, 100, -- Positive
    0, SYSDATE, SYSDATE, 3, -- Fee
    'Test description', 1, SYSDATE, 61109010140000071219812875, 1);
-- OUTPUT:
-- [72000][20101]
-- ORA-20101: The transaction type "Fee" does not match the positive amount
-- ...

-- INSERTING with negative amount
INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id,
    description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (17, 1, -100, -- Negative
    0, SYSDATE, SYSDATE, 5, -- Loan
    'Test description', 1, SYSDATE, 61109010140000071219812875, 1);
-- OUTPUT:
-- [72000][20101]
-- ORA-20101: The transaction type "Loan" does not match the negative amount
-- ...

-- INSERTING with ZERO amount
INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id,
    description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (17, 1, 0, -- Amount is ZERO
    0, SYSDATE, SYSDATE, 1,
    'Test description', 1, SYSDATE, 61109010140000071219812875, 1);
-- OUTPUT:
-- [72000][20102]
-- ORA-20102: Payment type not available: amount cannot be 0
-- ...


/* UPDATING test */
-- Only "rush" UPDATING
UPDATE financial_log SET amount = 3
WHERE id = 1;
--OUTPUT:
-- [72000][20103]
-- ORA-20103: Cannot update attribute other then "rush"
-- ...

