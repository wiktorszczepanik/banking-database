-- DDL

-- tables
-- Table: account
CREATE TABLE dbo.account (
    id INT NOT NULL,
    account_number INT NOT NULL,
    account_number_format_id INT NOT NULL,
    status_id INT NOT NULL,
    registration_date DATETIME2 NOT NULL,
    loyalty_rating FLOAT NOT NULL,
    client_data_id INT NOT NULL,
    available DECIMAL(19,2) NOT NULL,
    pend DECIMAL(19,2) NOT NULL,
    currency_id INT NOT NULL,
    CONSTRAINT account_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: account_consents
CREATE TABLE dbo.account_consents (
    consents_id INT NOT NULL,
    client_account_id INT NOT NULL,
    CONSTRAINT account_consents_pk PRIMARY KEY CLUSTERED (consents_id,client_account_id)
);
GO

-- Table: account_number_format
CREATE TABLE dbo.account_number_format (
    id INT NOT NULL,
    abbreviation VARCHAR(5) NOT NULL,
    type VARCHAR(60) NOT NULL,
    CONSTRAINT account_number_format_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: action_type
CREATE TABLE dbo.action_type (
    id INT NOT NULL,
    name VARCHAR(15) NOT NULL,
    CONSTRAINT action_type_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: activity_log
CREATE TABLE dbo.activity_log (
    id INT NOT NULL,
    session_history_id INT NOT NULL,
    action_type_id INT NOT NULL,
    time_stamp DATETIME2 NOT NULL,
    CONSTRAINT activity_log_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: address
CREATE TABLE dbo.address (
    id INT NOT NULL,
    client_data_id INT NOT NULL,
    primary_flag SMALLINT NOT NULL,
    address_type_id INT NOT NULL,
    street VARCHAR(35) NOT NULL,
    building_number INT NOT NULL,
    apartment_number INT NULL,
    city_id INT NOT NULL,
    postal_code CHAR(5) NOT NULL,
    CONSTRAINT address_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: address_type
CREATE TABLE dbo.address_type (
    id INT NOT NULL,
    name VARCHAR(15) NOT NULL,
    CONSTRAINT address_type_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: city
CREATE TABLE dbo.city (
    id INT NOT NULL,
    nazwa VARCHAR(30) NOT NULL,
    country_id INT NOT NULL,
    CONSTRAINT city_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: client_data
CREATE TABLE dbo.client_data (
    id INT NOT NULL,
    first_name VARCHAR(20) NOT NULL,
    middle_name VARCHAR(20) NULL,
    last_name VARCHAR(25) NOT NULL,
    pesel VARCHAR(11) NULL,
    phone_code VARCHAR(3) NOT NULL,
    phone_number VARCHAR(9) NOT NULL,
    notification_phone_code VARCHAR(3) NULL,
    notification_phone_number VARCHAR(9) NULL,
    email VARCHAR(50) NOT NULL,
    preferred_contact_id INT NOT NULL,
    status_id INT NOT NULL,
    CONSTRAINT client_data_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: consents
CREATE TABLE dbo.consents (
    id INT NOT NULL,
    mandatory SMALLINT NOT NULL,
    title VARCHAR(25) NOT NULL,
    document TEXT NOT NULL,
    CONSTRAINT consents_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: country
CREATE TABLE dbo.country (
    id INT NOT NULL,
    nazwa VARCHAR(25) NOT NULL,
    alpha2_code CHAR(2) NOT NULL,
    alpha3_code CHAR(3) NOT NULL,
    CONSTRAINT country_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: currency
CREATE TABLE dbo.currency (
    id INT NOT NULL,
    currency_2 CHAR(2) NOT NULL,
    currency_3 CHAR(3) NOT NULL,
    full_format VARCHAR(30) NOT NULL,
    CONSTRAINT currency_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: financial_log
CREATE TABLE dbo.financial_log (
    id INT NOT NULL,
    account_id INT NOT NULL,
    amount DECIMAL(19,2) NOT NULL,
    rush SMALLINT NOT NULL,
    operation_date DATE NOT NULL,
    timestamp DATETIME2 NOT NULL,
    transaction_type_id INT NOT NULL,
    description VARCHAR(1000) NOT NULL,
    currency_id INT NOT NULL,
    currency_date DATE NOT NULL,
    other_account_number INT NOT NULL,
    account_number_format_id INT NOT NULL,
    CONSTRAINT financial_log_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: preferred_contact
CREATE TABLE dbo.preferred_contact (
    id INT NOT NULL,
    type VARCHAR(15) NOT NULL,
    CONSTRAINT preferred_contact_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: session_history
CREATE TABLE dbo.session_history (
    id INT NOT NULL,
    client_account_id INT NOT NULL,
    time_start DATETIME2 NOT NULL,
    ttl INT NOT NULL,
    time_end DATETIME2 NULL,
    CONSTRAINT session_history_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: status
CREATE TABLE dbo.status (
    id INT NOT NULL,
    name VARCHAR(6) NOT NULL,
    CONSTRAINT status_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- Table: transaction_type
CREATE TABLE dbo.transaction_type (
    id INT NOT NULL,
    type VARCHAR(15) NOT NULL,
    CONSTRAINT transaction_pk PRIMARY KEY CLUSTERED (id)
);
GO

-- foreign keys
ALTER TABLE dbo.account
  ADD CONSTRAINT FK_account_account_number_format FOREIGN KEY(account_number_format_id) REFERENCES dbo.account_number_format(id);
GO

ALTER TABLE dbo.account
  ADD CONSTRAINT FK_account_client_data FOREIGN KEY(client_data_id) REFERENCES dbo.client_data(id);
GO

ALTER TABLE dbo.account
  ADD CONSTRAINT FK_account_currency FOREIGN KEY(currency_id) REFERENCES dbo.currency(id);
GO

ALTER TABLE dbo.client_data
  ADD CONSTRAINT FK_client_data_preferred_contact FOREIGN KEY(preferred_contact_id) REFERENCES dbo.preferred_contact(id);
GO

ALTER TABLE dbo.account
  ADD CONSTRAINT FK_account_status FOREIGN KEY(status_id) REFERENCES dbo.status(id);
GO

ALTER TABLE dbo.activity_log
  ADD CONSTRAINT FK_activity_action_type FOREIGN KEY(action_type_id) REFERENCES dbo.action_type(id);
GO

ALTER TABLE dbo.activity_log
  ADD CONSTRAINT FK_activity_session_history FOREIGN KEY(session_history_id) REFERENCES dbo.session_history(id) ON DELETE CASCADE;
GO

ALTER TABLE dbo.address
  ADD CONSTRAINT FK_address_address_type FOREIGN KEY(address_type_id) REFERENCES dbo.address_type(id);
GO

ALTER TABLE dbo.address
  ADD CONSTRAINT FK_address_city FOREIGN KEY(city_id) REFERENCES dbo.city(id);
GO

ALTER TABLE dbo.address
  ADD CONSTRAINT FK_address_client_data FOREIGN KEY(client_data_id) REFERENCES dbo.client_data(id);
GO

ALTER TABLE dbo.city
  ADD CONSTRAINT FK_city_country FOREIGN KEY(country_id) REFERENCES dbo.country(id);
GO

ALTER TABLE dbo.account_consents
  ADD CONSTRAINT FK_account_consents_account FOREIGN KEY(client_account_id) REFERENCES dbo.account(id) ON DELETE CASCADE;
GO

ALTER TABLE dbo.account_consents
  ADD CONSTRAINT FK_account_consents_consents FOREIGN KEY(consents_id) REFERENCES dbo.consents(id);
GO

ALTER TABLE dbo.client_data
  ADD CONSTRAINT FK_client_data_status FOREIGN KEY(status_id) REFERENCES dbo.status(id);
GO

ALTER TABLE dbo.financial_log
  ADD CONSTRAINT FK_financial_log_account FOREIGN KEY(account_id) REFERENCES dbo.account(id) ON DELETE CASCADE;
GO

ALTER TABLE dbo.financial_log
  ADD CONSTRAINT FK_financial_log_account_number_format FOREIGN KEY(account_number_format_id) REFERENCES dbo.account_number_format(id);
GO

ALTER TABLE dbo.financial_log
  ADD CONSTRAINT FK_financial_log_currency FOREIGN KEY(currency_id) REFERENCES dbo.currency(id);
GO

ALTER TABLE dbo.financial_log
  ADD CONSTRAINT FK_financial_log_transaction_type FOREIGN KEY(transaction_type_id) REFERENCES dbo.transaction_type(id);
GO

ALTER TABLE dbo.session_history
  ADD CONSTRAINT FK_session_history_account FOREIGN KEY(client_account_id) REFERENCES dbo.account(id) ON DELETE CASCADE;
GO

-- End of file.

