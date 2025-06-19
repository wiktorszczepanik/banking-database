/* Updating Loyalty Rating per account */

EXEC updateLoyaltyRating;



/* Financial statistics for account */

EXEC getFinancialStats @inputAccountId = 4, @startDate = '2021-01-02 14:45:00.000', @endDate = '2025-05-10 15:30:00.000';

