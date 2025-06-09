-- DROP FOREIGN KEYS

IF OBJECT_ID('dbo.account_consents', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.account_consents DROP CONSTRAINT FK_account_consents_account;
    ALTER TABLE dbo.account_consents DROP CONSTRAINT FK_account_consents_consents;
END;

IF OBJECT_ID('dbo.account', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.account DROP CONSTRAINT FK_account_account_number_format;
    ALTER TABLE dbo.account DROP CONSTRAINT FK_account_client_data;
    ALTER TABLE dbo.account DROP CONSTRAINT FK_account_currency;
    ALTER TABLE dbo.account DROP CONSTRAINT FK_account_status;
END;

IF OBJECT_ID('dbo.activity_log', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.activity_log DROP CONSTRAINT FK_activity_action_type;
    ALTER TABLE dbo.activity_log DROP CONSTRAINT FK_activity_session_history;
END;

IF OBJECT_ID('dbo.address', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.address DROP CONSTRAINT FK_address_address_type;
    ALTER TABLE dbo.address DROP CONSTRAINT FK_address_city;
    ALTER TABLE dbo.address DROP CONSTRAINT FK_address_client_data;
END;

IF OBJECT_ID('dbo.city', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.city DROP CONSTRAINT FK_city_country;
END;

IF OBJECT_ID('dbo.client_data', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.client_data DROP CONSTRAINT FK_client_data_preferred_contact;
    ALTER TABLE dbo.client_data DROP CONSTRAINT FK_client_data_status;
END;

IF OBJECT_ID('dbo.financial_log', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.financial_log DROP CONSTRAINT FK_financial_log_account;
    ALTER TABLE dbo.financial_log DROP CONSTRAINT FK_financial_log_account_number_format;
    ALTER TABLE dbo.financial_log DROP CONSTRAINT FK_financial_log_currency;
    ALTER TABLE dbo.financial_log DROP CONSTRAINT FK_financial_log_transaction_type;
END;

IF OBJECT_ID('dbo.session_history', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.session_history DROP CONSTRAINT FK_session_history_account;
END;


-- DROP TABLES

IF OBJECT_ID('dbo.account_consents', 'U') IS NOT NULL DROP TABLE dbo.account_consents;
IF OBJECT_ID('dbo.activity_log', 'U') IS NOT NULL DROP TABLE dbo.activity_log;
IF OBJECT_ID('dbo.address', 'U') IS NOT NULL DROP TABLE dbo.address;
IF OBJECT_ID('dbo.city', 'U') IS NOT NULL DROP TABLE dbo.city;
IF OBJECT_ID('dbo.client_data', 'U') IS NOT NULL DROP TABLE dbo.client_data;
IF OBJECT_ID('dbo.financial_log', 'U') IS NOT NULL DROP TABLE dbo.financial_log;
IF OBJECT_ID('dbo.session_history', 'U') IS NOT NULL DROP TABLE dbo.session_history;
IF OBJECT_ID('dbo.account', 'U') IS NOT NULL DROP TABLE dbo.account;
IF OBJECT_ID('dbo.account_number_format', 'U') IS NOT NULL DROP TABLE dbo.account_number_format;
IF OBJECT_ID('dbo.action_type', 'U') IS NOT NULL DROP TABLE dbo.action_type;
IF OBJECT_ID('dbo.address_type', 'U') IS NOT NULL DROP TABLE dbo.address_type;
IF OBJECT_ID('dbo.consents', 'U') IS NOT NULL DROP TABLE dbo.consents;
IF OBJECT_ID('dbo.country', 'U') IS NOT NULL DROP TABLE dbo.country;
IF OBJECT_ID('dbo.currency', 'U') IS NOT NULL DROP TABLE dbo.currency;
IF OBJECT_ID('dbo.preferred_contact', 'U') IS NOT NULL DROP TABLE dbo.preferred_contact;
IF OBJECT_ID('dbo.status', 'U') IS NOT NULL DROP TABLE dbo.status;
IF OBJECT_ID('dbo.transaction_type', 'U') IS NOT NULL DROP TABLE dbo.transaction_type;

