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




/* Maintain primary address */

/* INSERT test */
INSERT INTO address (id, client_data_id, [primary], address_type_id, street, building_number, apartment_number, city_id, postal_code)
VALUES (8, 2, 1, 2, 'Staszica', 5, 12, 1, '01001');

/* UPDATE test */
UPDATE address SET [primary] = 1
WHERE id = 2;

/* DELETE test */
DELETE FROM address
WHERE id = 2;
