/* Financial log trigger (append rush fee) */

ALTER TRIGGER handleRush ON financial_log
INSTEAD OF INSERT
AS BEGIN
	-- Insert
    IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted) BEGIN

        -- Max id in financial log
        DECLARE @maxFinancialLogId BIGINT;
        SELECT @maxFinancialLogId = MAX(id) + 1 FROM financial_log;

        -- Help vars
		DECLARE @rushFeeAmount NUMERIC(19, 2);
		DECLARE @currentBalance NUMERIC(19, 2);
		-- 0 -> (not rush), 1 -> (rush request), 2+ -> (already validated rush)
		DECLARE @newRushState INT;
		SET @newRushState = 0;

		DECLARE @currentAccountId BIGINT,
			@currentAmount NUMERIC(19, 2),
			@currentRushStatus SMALLINT,
			@currentTimestamp DATETIME,
			@currentTransactionType INT,
			@currentDescription VARCHAR(1000),
			@currentCurrencyId INT,
			@currentCurrencyDate DATETIME,
			@currentOtherAccountNumber VARCHAR(30),
			@currentAccountNumberFormatId INT;

		-- Cursor setup
		DECLARE curs1 CURSOR FOR SELECT account_id, amount, rush, [timestamp], transaction_type_id,
            description, currency_id, currency_date, other_account_number, account_number_format_id
            FROM inserted;

		OPEN curs1;
		FETCH NEXT FROM curs1 INTO @currentAccountId, @currentAmount, @currentRushStatus,
		    @currentTimestamp, @currentTransactionType, @currentDescription,
		    @currentCurrencyId, @currentCurrencyDate, @currentOtherAccountNumber,
		    @currentAccountNumberFormatId;

		WHILE @@Fetch_status = 0 BEGIN

			-- Insert rush fee if new log has "rush" status (outcoming)
			IF @currentRushStatus = 1 AND @currentAmount < 0 BEGIN

				-- Calculate fee amount
				SET @rushFeeAmount = 0.01 * ABS(@currentAmount);
				IF @rushFeeAmount < 1.00 BEGIN
					SET @rushFeeAmount = 1.00;
				END;
				ELSE IF @rushFeeAmount > 10000.00 BEGIN
					SET @rushFeeAmount = 10000.00;
				END;

				-- Insert fee amount
				INSERT INTO financial_log (id, account_id, amount, rush, operation_date, [timestamp], transaction_type_id,
					description, currency_id, currency_date, other_account_number, account_number_format_id)
				VALUES (@maxFinancialLogId, @currentAccountId, -ABS(@rushFeeAmount), 0, GETDATE(), SYSDATETIME(),
					3, 'Rush fee', 1, SYSDATETIME(), 10000000000000000000000001, 1);
				SET @maxFinancialLogId = @maxFinancialLogId + 1;
				SET @newRushState = 2;
			END;

			-- Insert financial info
			INSERT INTO financial_log (id, account_id, amount, rush, operation_date, [timestamp], transaction_type_id,
					description, currency_id, currency_date, other_account_number, account_number_format_id)
			VALUES (@maxFinancialLogId, @currentAccountId, @currentAmount, @newRushState, GETDATE(), @currentTimestamp, @currentTransactionType,
					@currentDescription, @currentCurrencyId, @currentCurrencyDate, @currentOtherAccountNumber, @currentAccountNumberFormatId);
			SET @maxFinancialLogId = @maxFinancialLogId + 1;
			SET @newRushState = 0;

			-- Update account balance for incoming financial info
			IF @currentRushStatus > 0 BEGIN
				SELECT @currentBalance = SUM(amount)
					FROM financial_log
					WHERE account_id = @currentAccountId;
				UPDATE account SET available = @currentBalance
				WHERE id = @currentAccountId;
			END;
			FETCH NEXT FROM curs1 INTO @currentAccountId, @currentAmount, @currentRushStatus,
		        @currentTimestamp, @currentTransactionType, @currentDescription,
		        @currentCurrencyId, @currentCurrencyDate, @currentOtherAccountNumber,
		        @currentAccountNumberFormatId;
		END;
		CLOSE curs1;
		DEALLOCATE curs1;

	END;
END;


/* Financial log trigger (append rush fee) */

ALTER TRIGGER handleRush ON financial_log
INSTEAD OF INSERT
AS BEGIN
	-- Insert
	IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted) BEGIN

		-- Max id in financial log
		DECLARE @maxFinancialLogId BIGINT;
		SELECT @maxFinancialLogId = MAX(id) FROM financial_log;

		-- Cursor setup
		DECLARE curs1 CURSOR FOR SELECT account_id, amount, rush FROM inserted;
		DECLARE @currentAccountId BIGINT,
			@currentAmount NUMERIC(19, 2),
			@currentRushStatus SMALLINT,
			@currentTransactionType INT;

		-- Help vars
		DECLARE @rushFeeAmount NUMERIC(19, 2);
		DECLARE @currentBalance NUMERIC(19, 2);

		OPEN curs1;
		FETCH NEXT FROM curs1 INTO @currentAccountId,
		    @currentAmount, @currentRushStatus, @currentTransactionType;
		WHILE @@Fetch_status = 0 BEGIN

			-- Insert rush fee if new log has "rush" status (outcoming)
			IF @currentRushStatus > 0 AND @currentAmount < 0 BEGIN

				-- Calculate fee amount
				SET @rushFeeAmount = 0.01 * ABS(@currentAmount);
				IF @rushFeeAmount < 1.00 BEGIN
					SET @rushFeeAmount = 1.00;
				END;
				ELSE IF @rushFeeAmount > 10000.00 BEGIN
					SET @rushFeeAmount = 10000.00;
				END;

				-- Insert fee amount
				INSERT INTO financial_log (id, account_id, amount, rush, operation_date, [timestamp], transaction_type_id,
					description, currency_id, currency_date, other_account_number, account_number_format_id)
				VALUES (@maxFinancialLogId, @currentAccountId, -ABS(@rushFeeAmount), 0, GETDATE(), SYSDATETIME(),
					3, 'Rush fee', 1, SYSDATETIME(), 10000000000000000000000001, 1);
				SET @maxFinancialLogId = @maxFinancialLogId + 1;
			END;

			-- Update account balance for (incoming) financial info
			IF @currentRushStatus > 0 AND @currentAmount > 0 BEGIN

			    -- Calculate current account balance
				SELECT @currentBalance = SUM(amount)
					FROM financial_log
					WHERE account_id = @currentAccountId;

			    -- Set new balance for account
				UPDATE account SET available = @currentBalance
				WHERE id = @currentAccountId;
			END;
			FETCH NEXT FROM curs1 INTO @currentAccountId, @currentRushStatus;
		END;
		CLOSE curs1;
		DEALLOCATE curs1;

	END;
	-- Update / Delete
	ELSE BEGIN
		RAISERROR ('Cannot update / delete financial logs.', 20, 1);
	END;
END;



/* Maintain primary address */

CREATE TRIGGER maintainPrimaryAddress ON address
AFTER INSERT, UPDATE, DELETE
AS BEGIN
    SET NOCOUNT ON;

    DECLARE @id INT, @client_data_id INT;

	-- Insert 
	IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted) BEGIN

		-- Reset (1 -> 0) others if inserted is primary (1)
		-- Only one primary per client is allowed
		UPDATE address SET [primary] = 0
        FROM address a
        INNER JOIN inserted i ON a.client_data_id = i.client_data_id
        WHERE i.[primary] = 1 
		AND a.id <> i.id 
		AND a.[primary] = 1;
    END;

	-- Update
	ELSE IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted) BEGIN

		-- Reset (1 -> 0) others if updated is primary (1)
		-- Only one primary per client is allowed
		UPDATE address SET [primary] = 0
		FROM address a
		INNER JOIN inserted i ON a.client_data_id = i.client_data_id
		INNER JOIN deleted d ON i.id = d.id
		WHERE i.[primary] = 1 
        AND d.[primary] <> 1
        AND a.id <> i.id
        AND a.[primary] = 1;
    END

	-- Delete
    IF EXISTS(SELECT * FROM deleted) AND NOT EXISTS(SELECT * FROM inserted) BEGIN

		-- Set new primary if deleted (only Business address is alowed)
		-- Find clients with 'primary' deleted
        DECLARE curs1 CURSOR FOR SELECT DISTINCT client_data_id
			FROM deleted
			WHERE [primary] = 1;

        DECLARE @currentClientDataId INT;
		DECLARE @isBusinessExists SMALLINT = 0;

        OPEN curs1;
        FETCH NEXT FROM curs1 INTO @currentClientDataId;
        WHILE @@FETCH_STATUS = 0 BEGIN

			SET @isBusinessExists = (
				SELECT COUNT(*)
				FROM address
				WHERE client_data_id = @currentClientDataId
				AND address_type_id = 1;
			);

			IF @isBusinessExists > 0 BEGIN
				UPDATE address SET [primary] = 1
				WHERE client_data_id = @currentClientDataId
				AND address_type_id = 1;
			END;
			ELSE BEGIN
				RAISERROR ('Cannot delete address due to primary. (Update / Insert address with new primary set to 1 and then delete)', 21, 1);
			END;
			SET @isBusinessExitst = 0;
            FETCH NEXT FROM curs1 INTO @currentClientDataId;
        END

        CLOSE curs1;
        DEALLOCATE curs1;
    END
END;
