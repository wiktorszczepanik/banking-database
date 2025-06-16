/* Updating Loyalty Rating per account */

CREATE PROCEDURE updateLoyaltyRating
AS BEGIN
    -- Initial loyalty rating for account
    DECLARE @newLoyaltyRating DECIMAL(5, 2) = 0.00;

    -- Values for setting new loyalty rating
    DECLARE @currentAvailableFunds NUMERIC(19, 2);
    DECLARE @currentYearSeniority DATE;

    DECLARE @currentBalanceStat SMALLINT;
    DECLARE @currentFinancialStat DECIMAL(5, 2);
    DECLARE @currentRegistrationDateStat DECIMAL(5, 2);
    DECLARE @currentAdditionalConsentsStat SMALLINT;

    DECLARE curs1 CURSOR FOR SELECT id FROM account;
    DECLARE @currentAccountId BIGINT, @currentAccountStatus INT;

    OPEN curs1;
    FETCH NEXT FROM curs1 INTO @currentAccountId, @currentAccountStatus;
    WHILE @@Fetch_status = 0 BEGIN
        -- Account status need to be "ACTIVE"
        IF @currentAccountStatus = 1 BEGIN

            -- Available funds on account (0.00-30.00)
            SET @currentAvailableFunds = (
                SELECT available FROM account
                WHERE id = @currentAccountId
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
                WHEN @currentYearSeniority < 15 THEN (@currentYearSeniority / 15) * 30
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
        END;
        SET @newLoyaltyRating = 0.00;
        FETCH NEXT FROM curs1 INTO @currentAccountId, @currentAccountStatus;
    END;
END;

/* Payment incident detector */


