-- DDL

-- tables
-- Table: account
CREATE TABLE account (
    id integer  NOT NULL,
    account_number integer  NOT NULL,
    account_number_format_id integer  NOT NULL,
    status_id integer  NOT NULL,
    registration_date timestamp  NOT NULL,
    loyalty_rating float(100)  NOT NULL,
    client_data_id integer  NOT NULL,
    available number(19,2)  NOT NULL,
    pend number(19,2)  NOT NULL,
    currency_id integer  NOT NULL,
    CONSTRAINT account_pk PRIMARY KEY (id)
) ;

-- Table: account_consents
CREATE TABLE account_consents (
    consents_id integer  NOT NULL,
    client_account_id integer  NOT NULL,
    CONSTRAINT account_consents_pk PRIMARY KEY (consents_id,client_account_id)
) ;

-- Table: account_number_format
CREATE TABLE account_number_format (
    id integer  NOT NULL,
    abbreviation varchar2(5)  NOT NULL,
    type varchar2(60)  NOT NULL,
    CONSTRAINT account_number_format_pk PRIMARY KEY (id)
) ;

-- Table: action_type
CREATE TABLE action_type (
    id integer  NOT NULL,
    name varchar2(15)  NOT NULL,
    CONSTRAINT action_type_pk PRIMARY KEY (id)
) ;

-- Table: activity_log
CREATE TABLE activity_log (
    id integer  NOT NULL,
    session_history_id integer  NOT NULL,
    action_type_id integer  NOT NULL,
    time_stamp timestamp  NOT NULL,
    CONSTRAINT activity_log_pk PRIMARY KEY (id)
) ;

-- Table: address
CREATE TABLE address (
    id integer  NOT NULL,
    client_data_id integer  NOT NULL,
    primary smallint  NOT NULL,
    address_type_id integer  NOT NULL,
    street varchar2(35)  NOT NULL,
    building_number integer  NOT NULL,
    apartment_number integer  NULL,
    city_id integer  NOT NULL,
    postal_code char(5)  NOT NULL,
    CONSTRAINT address_pk PRIMARY KEY (id)
) ;

-- Table: address_type
CREATE TABLE address_type (
    id integer  NOT NULL,
    name varchar2(15)  NOT NULL,
    CONSTRAINT address_type_pk PRIMARY KEY (id)
) ;

-- Table: city
CREATE TABLE city (
    id integer  NOT NULL,
    nazwa varchar2(30)  NOT NULL,
    country_id integer  NOT NULL,
    CONSTRAINT city_pk PRIMARY KEY (id)
) ;

-- Table: client_data
CREATE TABLE client_data (
    id integer  NOT NULL,
    first_name varchar2(20)  NOT NULL,
    middle_name varchar2(20)  NULL,
    last_name varchar2(25)  NOT NULL,
    pesel varchar2(11)  NULL,
    phone_code varchar2(3)  NOT NULL,
    phone_number varchar2(9)  NOT NULL,
    notification_phone_code varchar2(3)  NULL,
    notification_phone_number varchar2(9)  NULL,
    email varchar2(50)  NOT NULL,
    preferred_contact_id integer  NOT NULL,
    status_id integer  NOT NULL,
    CONSTRAINT client_data_pk PRIMARY KEY (id)
) ;

-- Table: consents
CREATE TABLE consents (
    id integer  NOT NULL,
    mandatory smallint  NOT NULL,
    title varchar2(25)  NOT NULL,
    document clob  NOT NULL,
    CONSTRAINT consents_pk PRIMARY KEY (id)
) ;

-- Table: country
CREATE TABLE country (
    id integer  NOT NULL,
    nazwa varchar2(25)  NOT NULL,
    alpha2_code char(2)  NOT NULL,
    alpha3_code char(3)  NOT NULL,
    CONSTRAINT country_pk PRIMARY KEY (id)
) ;

-- Table: currency
CREATE TABLE currency (
    id integer  NOT NULL,
    currency_2 char(2)  NOT NULL,
    currency_3 char(3)  NOT NULL,
    full_format varchar2(30)  NOT NULL,
    CONSTRAINT currency_pk PRIMARY KEY (id)
) ;

-- Table: financial_log
CREATE TABLE financial_log (
    id integer  NOT NULL,
    account_id integer  NOT NULL,
    amount number(19,2)  NOT NULL,
    rush smallint  NOT NULL,
    operation_date date  NOT NULL,
    timestamp timestamp  NOT NULL,
    transaction_type_id integer  NOT NULL,
    description varchar2(1000)  NOT NULL,
    currency_id integer  NOT NULL,
    currency_date date  NOT NULL,
    other_account_number integer  NOT NULL,
    account_number_format_id integer  NOT NULL,
    CONSTRAINT financial_log_pk PRIMARY KEY (id)
) ;

-- Table: preferred_contact
CREATE TABLE preferred_contact (
    id integer  NOT NULL,
    type varchar2(15)  NOT NULL,
    CONSTRAINT preferred_contact_pk PRIMARY KEY (id)
) ;

-- Table: session_history
CREATE TABLE session_history (
    id integer  NOT NULL,
    client_account_id integer  NOT NULL,
    time_start timestamp  NOT NULL,
    ttl integer  NOT NULL,
    time_end timestamp  NULL,
    CONSTRAINT session_history_pk PRIMARY KEY (id)
) ;

-- Table: status
CREATE TABLE status (
    id integer  NOT NULL,
    name varchar2(6)  NOT NULL,
    CONSTRAINT status_pk PRIMARY KEY (id)
) ;

-- Table: transaction
CREATE TABLE transaction (
    id integer  NOT NULL,
    type varchar2(15)  NOT NULL,
    CONSTRAINT transaction_pk PRIMARY KEY (id)
) ;

-- foreign keys
-- Reference: account_account_number_format (table: account)
ALTER TABLE account ADD CONSTRAINT account_account_number_format
    FOREIGN KEY (account_number_format_id)
    REFERENCES account_number_format (id);

-- Reference: account_client_data (table: account)
ALTER TABLE account ADD CONSTRAINT account_client_data
    FOREIGN KEY (client_data_id)
    REFERENCES client_data (id);

-- Reference: account_currency (table: account)
ALTER TABLE account ADD CONSTRAINT account_currency
    FOREIGN KEY (currency_id)
    REFERENCES currency (id);

-- Reference: account_info_prefered_contact (table: client_data)
ALTER TABLE client_data ADD CONSTRAINT account_info_prefered_contact
    FOREIGN KEY (preferred_contact_id)
    REFERENCES preferred_contact (id);

-- Reference: account_status (table: account)
ALTER TABLE account ADD CONSTRAINT account_status
    FOREIGN KEY (status_id)
    REFERENCES status (id);

-- Reference: activity_action_type (table: activity_log)
ALTER TABLE activity_log ADD CONSTRAINT activity_action_type
    FOREIGN KEY (action_type_id)
    REFERENCES action_type (id);

-- Reference: activity_session_history (table: activity_log)
ALTER TABLE activity_log ADD CONSTRAINT activity_session_history
    FOREIGN KEY (session_history_id)
    REFERENCES session_history (id)
    ON DELETE CASCADE;

-- Reference: address_address_type (table: address)
ALTER TABLE address ADD CONSTRAINT address_address_type
    FOREIGN KEY (address_type_id)
    REFERENCES address_type (id);

-- Reference: address_city (table: address)
ALTER TABLE address ADD CONSTRAINT address_city
    FOREIGN KEY (city_id)
    REFERENCES city (id);

-- Reference: address_client_data (table: address)
ALTER TABLE address ADD CONSTRAINT address_client_data
    FOREIGN KEY (client_data_id)
    REFERENCES client_data (id);

-- Reference: city_country (table: city)
ALTER TABLE city ADD CONSTRAINT city_country
    FOREIGN KEY (country_id)
    REFERENCES country (id);

-- Reference: client_consents_client_account (table: account_consents)
ALTER TABLE account_consents ADD CONSTRAINT client_consents_client_account
    FOREIGN KEY (client_account_id)
    REFERENCES account (id)
    ON DELETE CASCADE;

-- Reference: client_consents_consents (table: account_consents)
ALTER TABLE account_consents ADD CONSTRAINT client_consents_consents
    FOREIGN KEY (consents_id)
    REFERENCES consents (id);

-- Reference: client_data_status (table: client_data)
ALTER TABLE client_data ADD CONSTRAINT client_data_status
    FOREIGN KEY (status_id)
    REFERENCES status (id);

-- Reference: financial_log_account (table: financial_log)
ALTER TABLE financial_log ADD CONSTRAINT financial_log_account
    FOREIGN KEY (account_id)
    REFERENCES account (id)
    ON DELETE CASCADE;

-- Reference: financial_log_an_format (table: financial_log)
ALTER TABLE financial_log ADD CONSTRAINT financial_log_an_format
    FOREIGN KEY (account_number_format_id)
    REFERENCES account_number_format (id);

-- Reference: financial_log_currency (table: financial_log)
ALTER TABLE financial_log ADD CONSTRAINT financial_log_currency
    FOREIGN KEY (currency_id)
    REFERENCES currency (id);

-- Reference: financial_log_transaction_type (table: financial_log)
ALTER TABLE financial_log ADD CONSTRAINT financial_log_transaction_type
    FOREIGN KEY (transaction_type_id)
    REFERENCES transaction (id);

-- Reference: session_history_client_account (table: session_history)
ALTER TABLE session_history ADD CONSTRAINT session_history_client_account
    FOREIGN KEY (client_account_id)
    REFERENCES account (id)
    ON DELETE CASCADE;

-- End of file.

