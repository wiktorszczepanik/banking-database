/* Updating Loyalty Rating per account */

CREATE PROCEDURE updateLoyaltyRating
AS BEGIN
    -- Initial loyalty rating for account
    DECLARE @newLoyaltyRating DECIMAL(5, 2) = 0.00;

    -- Values for setting new loyalty rating
    DECLARE @currentFinancialStat DECIMAL(5, 2);
    DECLARE @currentRegistrationDate DATE;
    DECLARE @currentAdditionalConsents SMALLINT;
    DECLARE @currentAvailableFunds NUMERIC(19, 2);

    DECLARE curs1 CURSOR FOR SELECT id FROM account;
    DECLARE @currentAccountId BIGINT, @currentAccountStatus INT;

    OPEN curs1;
    FETCH NEXT FROM curs1 INTO @currentAccountId, @currentAccountStatus;
    WHILE @@Fetch_status = 0 BEGIN
        -- Account status need to be "ACTIVE"
        IF @currentAccountStatus = 1 BEGIN
            -- Financial activity (0.00-30.00)
            SET @currentFinancialStat = ();
            -- Registration date (0.00-20.00)
            -- Additional consents (0.00-20.00)
            -- Available funds on account (0.00-30.00)
        END;
        SET @newLoyaltyRating = 0.00;
        FETCH NEXT FROM curs1 INTO @currentAccountId, @currentAccountStatus;
    END;
END;

