/* Updating account balance based on financial_log */

CREATE OR REPLACE PROCEDURE updateAccountBalance
(accountForBalanceUpdate INTEGER)
AS
    updatedAccountId INTEGER;
    updatedAccountAmount NUMBER(19, 2);
    currentAccountAmount NUMBER(19, 2);
    CURSOR cur1 IS SELECT account_id, SUM(amount)
    FROM financial_log
    GROUP BY account_id;
BEGIN
    -- Update for one account
    IF accountForBalanceUpdate >= 0 THEN
        SELECT SUM(amount) INTO updatedAccountAmount
        FROM financial_log
        WHERE account_id = accountForBalanceUpdate;

        SELECT available INTO currentAccountAmount
        FROM account WHERE id = accountForBalanceUpdate;

        UPDATE account SET available = updatedAccountAmount
        WHERE id = accountForBalanceUpdate;

        DBMS_OUTPUT.PUT_LINE('Balance for account: ' || accountForBalanceUpdate ||
            ' [ Before: ' || currentAccountAmount || ' -> After: ' || updatedAccountAmount || ' ]');
    -- If values under ZERO then update ALL accounts
    ELSE
        OPEN cur1;
        LOOP
            FETCH cur1 INTO updatedAccountId, updatedAccountAmount;
            EXIT WHEN cur1%NOTFOUND;

            SELECT available INTO currentAccountAmount
            FROM account WHERE id = updatedAccountId;

            UPDATE account SET available = updatedAccountAmount
            WHERE id = updatedAccountId;

            -- Display only for new values
            IF currentAccountAmount <> updatedAccountAmount THEN
                DBMS_OUTPUT.PUT_LINE('Balance for account: ' || updatedAccountId ||
                    ' [ Before: ' || currentAccountAmount || ' -> After: ' || updatedAccountAmount || ' ]');
            END IF;
        END LOOP;
        CLOSE cur1;
    END IF;
END;



/* Inserting fee for accounts without any payments in last month */

CREATE OR REPLACE PROCEDURE accountFeeInsertion
(inputMaxAmount INTEGER, inputAmountToPay INTEGER)
AS
    currentAccountId INTEGER;
    currentAccountAmount NUMBER(19, 2);
    currentAccountStatus INTEGER;
    newInputToPay INTEGER;
    newIndex INTEGER;
    CURSOR cur1 IS SELECT account_id, SUM(amount)
    FROM financial_log
    WHERE amount > 0
    AND operation_date >= TRUNC(ADD_MONTHS(SYSDATE, -1), 'MM')
    AND operation_date < TRUNC(SYSDATE, 'MM')
    GROUP BY account_id;
BEGIN
    -- Reversed ABS() for particular accounts to pay
    IF inputAmountToPay > 0 THEN
        newInputToPay := -inputAmountToPay;
    ELSE
        newInputToPay := inputAmountToPay;
    END IF;
    -- New index for financial logs
    SELECT MAX(id) + 1 INTO newIndex FROM financial_log;
    OPEN cur1;
    LOOP
        FETCH cur1 INTO currentAccountId, currentAccountAmount;
        EXIT WHEN cur1%NOTFOUND;

        -- Get account status
        SELECT status_id INTO currentAccountStatus FROM account WHERE id = currentAccountId;

        -- Condition to insert fee for account
        IF currentAccountStatus = 1 AND currentAccountAmount < inputMaxAmount THEN
            INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id,
            description, currency_id, currency_date, other_account_number, account_number_format_id)
            VALUES (newIndex, currentAccountId, newInputToPay, 0, SYSDATE, SYSDATE, 3,
            'Fee for not using account enough', 1, SYSDATE, 10000000000000000000000001, 1);

            DBMS_OUTPUT.PUT_LINE('Account affected by fee: ' || currentAccountId || ' [ Fee: ' || newInputToPay || ' ]');
            newIndex := newIndex + 1;
        END IF;
    END LOOP;
    CLOSE cur1;
END;

