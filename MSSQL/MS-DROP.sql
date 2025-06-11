-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2025-06-11 22:05:32.922

-- foreign keys
ALTER TABLE account DROP CONSTRAINT account_account_number_format;

ALTER TABLE account DROP CONSTRAINT account_client_data;

ALTER TABLE account DROP CONSTRAINT account_currency;

ALTER TABLE client_data DROP CONSTRAINT account_info_prefered_contact;

ALTER TABLE account DROP CONSTRAINT account_status;

ALTER TABLE activity_log DROP CONSTRAINT activity_action_type;

ALTER TABLE activity_log DROP CONSTRAINT activity_session_history;

ALTER TABLE address DROP CONSTRAINT address_address_type;

ALTER TABLE address DROP CONSTRAINT address_city;

ALTER TABLE address DROP CONSTRAINT address_client_data;

ALTER TABLE city DROP CONSTRAINT city_country;

ALTER TABLE account_consents DROP CONSTRAINT client_consents_client_account;

ALTER TABLE account_consents DROP CONSTRAINT client_consents_consents;

ALTER TABLE client_data DROP CONSTRAINT client_data_status;

ALTER TABLE financial_log DROP CONSTRAINT financial_log_account;

ALTER TABLE financial_log DROP CONSTRAINT financial_log_an_format;

ALTER TABLE financial_log DROP CONSTRAINT financial_log_currency;

ALTER TABLE financial_log DROP CONSTRAINT financial_log_transaction_type;

ALTER TABLE session_history DROP CONSTRAINT session_history_client_account;

-- tables
DROP TABLE account;

DROP TABLE account_consents;

DROP TABLE account_number_format;

DROP TABLE action_type;

DROP TABLE activity_log;

DROP TABLE address;

DROP TABLE address_type;

DROP TABLE city;

DROP TABLE client_data;

DROP TABLE consents;

DROP TABLE country;

DROP TABLE currency;

DROP TABLE financial_log;

DROP TABLE preferred_contact;

DROP TABLE session_history;

DROP TABLE status;

DROP TABLE "transaction";

-- End of file.

