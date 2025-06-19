/* Updating Loyalty Rating per account */

CREATE PROCEDURE updateLoyaltyRating
AS BEGIN
    -- Initial loyalty rating for account
    DECLARE @previousLoyaltyRating DECIMAL(5, 2) = 0.00;
    DECLARE @newLoyaltyRating DECIMAL(5, 2) = 0.00;

    -- Values for setting new loyalty rating
    DECLARE @currentAvailableFunds NUMERIC(19, 2);
    DECLARE @currentYearSeniority INT;

    DECLARE @currentBalanceStat SMALLINT;
    DECLARE @currentFinancialStat DECIMAL(5, 2);
    DECLARE @currentRegistrationDateStat DECIMAL(5, 2);
    DECLARE @currentAdditionalConsentsStat SMALLINT;

    DECLARE curs1 CURSOR FOR SELECT id, status_id FROM account;
    DECLARE @currentAccountId BIGINT, @currentAccountStatus INT;

    OPEN curs1;
    FETCH NEXT FROM curs1 INTO @currentAccountId, @currentAccountStatus;
    WHILE @@Fetch_status = 0 BEGIN
        -- Account status need to be "ACTIVE"
        IF @currentAccountStatus = 1 BEGIN

            -- Get loyalty rating before update
            SET @previousLoyaltyRating = (
                SELECT loyalty_rating FROM account
                WHERE id = @currentAccountId
            );

            -- Available funds on account (0.00-30.00)
            SET @currentAvailableFunds = (
                SELECT SUM(amount) FROM financial_log
                WHERE account_id = @currentAccountId
            );

            SET @currentBalanceStat = CASE -- category points
                WHEN @currentAvailableFunds >= 0 AND @currentAvailableFunds < 10000 THEN 5
                WHEN @currentAvailableFunds >= 10000 AND @currentAvailableFunds < 100000 THEN 10
                WHEN @currentAvailableFunds >= 10000 AND @currentAvailableFunds < 1000000 THEN 20
                WHEN @currentAvailableFunds >= 1000000 THEN 30
                ELSE 0
            END;
            SET @newLoyaltyRating = @currentBalanceStat;

            -- Financial activity (0.00-30.00)
            SET @currentFinancialStat = (
                SELECT CASE  -- Avoid division by 0
                    WHEN SUM(amount) > 0 AND @currentAvailableFunds > 0
                        THEN (@currentAvailableFunds / SUM(amount)) * 30
                    ELSE 0 END
                FROM financial_log
                WHERE amount > 0 AND id = @currentAccountId
            );
            SET @newLoyaltyRating = @newLoyaltyRating + @currentFinancialStat;

            -- Registration date (0.00-20.00)
            SET @currentYearSeniority = (
                SELECT DATEDIFF(YEAR, registration_date, GETDATE())
                FROM account
                WHERE id = @currentAccountId
            );

            SET @currentRegistrationDateStat = CASE
                WHEN @currentYearSeniority < 15 THEN (@currentYearSeniority / 15.00) * 30
                ELSE 30
            END;
            SET @newLoyaltyRating = @newLoyaltyRating + @currentRegistrationDateStat;

            -- Additional consents (0.00-20.00)
            SET @currentAdditionalConsentsStat = (
                SELECT CASE
                    WHEN COUNT(*) > 0 THEN 20
                    ELSE 0 END
                FROM account_consents ac
                INNER JOIN consents c ON ac.consents_id = c.id
                WHERE ac.client_account_id = @currentAccountId
                AND c.mandatory = 0
            );
            SET @newLoyaltyRating = @newLoyaltyRating + @currentAdditionalConsentsStat;

            -- UPDATE loyalty rating
            UPDATE account SET loyalty_rating = @newLoyaltyRating
            WHERE id = @currentAccountId;

            -- Change to DBMS
            PRINT 'Account ID: ' + CONVERT(VARCHAR, @currentAccountId)
                + ' | (' + CONVERT(VARCHAR, @previousLoyaltyRating)
                + ' -> ' + CONVERT(VARCHAR, @newLoyaltyRating) + ')'
        END;
        SET @previousLoyaltyRating = 0.00;
        SET @newLoyaltyRating = 0.00;
        FETCH NEXT FROM curs1 INTO @currentAccountId, @currentAccountStatus;
    END;
    CLOSE curs1;
    DEALLOCATE curs1;
END;



/* Financial statistics for account */

CREATE PROCEDURE getFinancialStats
    @inputAccountId BIGINT,
    @startDate DATE,
    @endDate DATE
AS BEGIN

    DECLARE @transactionBalance NUMERIC(19, 2);
    DECLARE @accountCurrency CHAR(3);
    DECLARE @transactionCount INT;
    DECLARE @profits NUMERIC(19, 2);
    DECLARE @expenses NUMERIC(19, 2);

    -- Init account stats
    PRINT '--- Financial Statistics --- ';
    PRINT '<' + CONVERT(VARCHAR, @startDate) + ' ; ' + CONVERT(VARCHAR, @endDate) + '>'
    PRINT 'Account ID: ' + CONVERT(VARCHAR, @inputAccountId);

    SET @accountCurrency = (
        SELECT c.currency_3
        FROM account a
        INNER JOIN currency c ON a.currency_id = c.id
        WHERE a.id = @inputAccountId
    );
    SET @transactionBalance = (
        SELECT SUM(amount) FROM financial_log
        WHERE account_id = @inputAccountId
        AND timestamp >= @startDate AND timestamp <= @endDate
    );
    PRINT 'Current balance: ' + CONVERT(VARCHAR, @transactionBalance) + ' ' + @accountCurrency;

    SET @transactionCount = (
        SELECT COUNT(amount) FROM financial_log
        WHERE account_id = @inputAccountId
        AND timestamp >= @startDate AND timestamp <= @endDate
    );
    PRINT 'Number of transactions: ' + CONVERT(VARCHAR, @transactionCount);

    -- Expenses section
    SET @expenses = (
        SELECT SUM(amount) FROM financial_log
        WHERE account_id = @inputAccountId AND amount < 0
        AND timestamp >= @startDate AND timestamp <= @endDate
    );
    PRINT 'Expenses: ' + CONVERT(VARCHAR, ABS(@expenses)) + ' ' + @accountCurrency;
    DECLARE curs1 CURSOR FOR SELECT t.type, SUM(amount)
        FROM financial_log fl
        INNER JOIN [transaction] t ON fl.transaction_type_id = t.id
        WHERE fl.account_id = @inputAccountId AND amount < 0
        AND timestamp >= @startDate AND timestamp <= @endDate
        GROUP BY t.type
        ORDER BY 2 DESC;
    DECLARE @curs1Type VARCHAR(15), @curs1Sum NUMERIC(19, 2);
    OPEN curs1;
    FETCH NEXT FROM curs1 INTO @curs1Type, @curs1Sum;
    WHILE @@FETCH_STATUS = 0 BEGIN
        PRINT '----> ' + @curs1Type + ': ' + CONVERT(VARCHAR, ABS(@curs1Sum)) + ' ' + CONVERT(VARCHAR, @accountCurrency);
        FETCH NEXT FROM curs1 INTO @curs1Type, @curs1Sum;
    END;
    CLOSE curs1;
    DEALLOCATE curs1;

    -- Profits section
    SET @profits = (
        SELECT SUM(amount) FROM financial_log
        WHERE account_id = @inputAccountId AND amount > 0
        AND timestamp >= @startDate AND timestamp <= @endDate
    );
    PRINT 'Profits: ' + CONVERT(VARCHAR, @profits) + ' ' + @accountCurrency;
    DECLARE curs2 CURSOR FOR SELECT t.type, SUM(amount)
        FROM financial_log fl
        INNER JOIN [transaction] t ON fl.transaction_type_id = t.id
        WHERE fl.account_id = @inputAccountId AND amount > 0
        AND timestamp >= @startDate AND timestamp <= @endDate
        GROUP BY t.type
        ORDER BY 2 DESC;
    DECLARE @curs2Type VARCHAR(15), @curs2Sum NUMERIC(19, 2);
    OPEN curs2;
    FETCH NEXT FROM curs2 INTO @curs2Type, @curs2Sum;
    WHILE @@FETCH_STATUS = 0 BEGIN
        PRINT '----> ' + @curs2Type + ': ' + CONVERT(VARCHAR, @curs2Sum) + ' ' + CONVERT(VARCHAR, @accountCurrency);
        FETCH NEXT FROM curs2 INTO @curs2Type, @curs2Sum;
    END;
    CLOSE curs2;
    DEALLOCATE curs2;

END;


