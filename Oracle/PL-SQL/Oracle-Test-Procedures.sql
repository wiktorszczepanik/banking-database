/* "updateAccountBalance" - procedure test */

/* INSERT - test */
CALL updateAccountBalance(-1);

INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id, description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (25, 1, 1000, 1, SYSDATE, SYSDATE, 1,'Test description', 1, SYSDATE, 61109010140000071219812875, 1);

CALL updateAccountBalance(-1);
-- OUTPUT (example):
-- Balance for account: 1 [ Before: 4412 -> After: 6412 ]
-- ...


/* "feeInsertionForAccountPaymentActivity" - procedure test */

CALL feeInsertionForAccountPaymentActivity(1500, 1000);
-- OUTPUT (example):
-- [2025-06-02 01:14:09] completed in 85 ms
-- Account affected by fee: 1 [ Fee: -1000 ]
-- Account affected by fee: 2 [ Fee: -1000 ]
-- ...

