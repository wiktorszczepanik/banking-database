/* Updating Loyalty Rating per account */

EXEC updateLoyaltyRating;
-- OUTPUT:
-- Account ID: 1 | (0.99 -> 73.00)
-- Account ID: 2 | (0.50 -> 23.00)


/* Financial statistics for account */

EXEC getFinancialStats @inputAccountId = 4, @startDate = '2021-01-02 14:45:00.000', @endDate = '2025-05-10 15:30:00.000';
-- OUTPUT:
-- --- Financial Statistics ---
-- <2021-01-02 ; 2025-05-10>
-- Account ID: 4
-- Current balance: 30.00 USD
-- Number of transactions: 4
-- Expenses: 820.00 USD
-- ----> Loan: 820.00 USD
-- Profits: 850.00 USD
-- ----> Payment: 850.00 USD
-- [2025-06-19 23:27:06] completed in 237 ms
