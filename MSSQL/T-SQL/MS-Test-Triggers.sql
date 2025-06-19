/* Financial log trigger (append rush fee) */

/* INSERT - test */

-- Regular payment (profit)
INSERT INTO financial_log (id, account_id, amount, rush, operation_date, [timestamp], transaction_type_id,
	description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (11, 4, 37, -- incoming payment / profit
    0, -- No rush
    GETDATE(), SYSDATETIME(),
	1, 'Regular payment', 1, SYSDATETIME(), '12345678901234567890123456', 3);

-- Regular (expense)
INSERT INTO financial_log (id, account_id, amount, rush, operation_date, [timestamp], transaction_type_id,
	description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (12, 4, -37, -- outcoming payment / expense
    0, -- No rush
    GETDATE(), SYSDATETIME(),
	1, 'Regular payment', 1, SYSDATETIME(), '12345678901234567890123456', 3);

-- Rush payment (profit)
INSERT INTO financial_log (id, account_id, amount, rush, operation_date, [timestamp], transaction_type_id,
	description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (12, 4, 100, -- outcoming payment / expense
    1, -- Rush
    GETDATE(), SYSDATETIME(),
	1, 'Regular payment', 1, SYSDATETIME(), '12345678901234567890123456', 3);


-- Rush payment (expense)
INSERT INTO financial_log (id, account_id, amount, rush, operation_date, [timestamp], transaction_type_id,
	description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (12, 4, -1000, -- outcoming payment / expense
    1, -- No rush
    GETDATE(), SYSDATETIME(),
	1, 'Regular payment', 1, SYSDATETIME(), '12345678901234567890123456', 3);

