-- DML

-- INFO --

-- Table: status

INSERT INTO status (id, name) VALUES (1, 'ACTIVE');
INSERT INTO status (id, name) VALUES (2, 'CLOSED');
INSERT INTO status (id, name) VALUES (3, 'PEND');


-- Table: prefered_contact

INSERT INTO preferred_contact (id, type) VALUES (1, 'EMAIL');
INSERT INTO preferred_contact (id, type) VALUES (2, 'MAIL');
INSERT INTO preferred_contact (id, type) VALUES (3, 'PHONE');


-- Table: address_type

INSERT INTO address_type (id, name) VALUES (1, 'BUSINESS');
INSERT INTO address_type (id, name) VALUES (2, 'LEGAL');
INSERT INTO address_type (id, name) VALUES (3, 'SHIPPING');
INSERT INTO address_type (id, name) VALUES (4, 'MAIL');


-- Table: country

INSERT INTO country (id, nazwa, alpha2_code, alpha3_code) VALUES (1, 'Polska', 'PL', 'POL');
INSERT INTO country (id, nazwa, alpha2_code, alpha3_code) VALUES (2, 'Germany', 'DE', 'DEU');
INSERT INTO country (id, nazwa, alpha2_code, alpha3_code) VALUES (3, 'USA', 'US', 'USA');


-- Table: city

INSERT INTO city (id, nazwa, country_id) VALUES (1, 'Warszawa', 1);
INSERT INTO city (id, nazwa, country_id) VALUES (2, 'Kraków', 1);
INSERT INTO city (id, nazwa, country_id) VALUES (3, 'Gdańsk', 1);
INSERT INTO city (id, nazwa, country_id) VALUES (4, 'Poznań', 1);
INSERT INTO city (id, nazwa, country_id) VALUES (5, 'Białystok', 1);
INSERT INTO city (id, nazwa, country_id) VALUES (6, 'Katowice', 1);
INSERT INTO city (id, nazwa, country_id) VALUES (7, 'Berlin', 2);
INSERT INTO city (id, nazwa, country_id) VALUES (8, 'New York', 3);


-- Table: client_data

INSERT INTO client_data (id, first_name, middle_name, last_name, pesel, phone_code, phone_number, notification_phone_code, notification_phone_number, email, preferred_contact_id, status_id)
VALUES (1, 'Jan', 'Krzysztof', 'Kowalski', '12345678901', '48', '600123456', '48', '600654321', 'jan.kowalski@email.com', 1, 2);

INSERT INTO client_data (id, first_name, middle_name, last_name, pesel, phone_code, phone_number, notification_phone_code, notification_phone_number, email, preferred_contact_id, status_id)
VALUES (2, 'Anna', NULL, 'Nowak', '98765432109', '48', '601234567', '48', '601234567', 'anna.nowak@email.com', 2, 1);

INSERT INTO client_data (id, first_name, middle_name, last_name, pesel, phone_code, phone_number, notification_phone_code, notification_phone_number, email, preferred_contact_id, status_id)
VALUES (3, 'Krzysztof', NULL, 'Siennicki', '11122334455', '48', '602345678', '48', '602345678', 'krzysztof.siennicki@email.com', 3, 3);


-- Table: address

INSERT INTO address (id, client_data_id, primary, address_type_id, street, building_number, apartment_number, city_id, postal_code)
VALUES (1, 1, 1, 2, 'Warszawska', 5, 12, 1, '01001');

INSERT INTO address (id, client_data_id, primary, address_type_id, street, building_number, apartment_number, city_id, postal_code)
VALUES (2, 2, 1, 2, 'Krakowska', 15, NULL, 2, '31001');

INSERT INTO address (id, client_data_id, primary, address_type_id, street, building_number, apartment_number, city_id, postal_code)
VALUES (3, 3, 1, 2, 'Gdańska', 21, 8, 3, '80001');

INSERT INTO address (id, client_data_id, primary, address_type_id, street, building_number, apartment_number, city_id, postal_code)
VALUES (4, 2, 0, 4, 'Poznańska', 15, NULL, 4, '60001');

INSERT INTO address (id, client_data_id, primary, address_type_id, street, building_number, apartment_number, city_id, postal_code)
VALUES (5, 3, 1, 3, 'Białostocka', 23, 9, 5, '15001');

INSERT INTO address (id, client_data_id, primary, address_type_id, street, building_number, apartment_number, city_id, postal_code)
VALUES (6, 1, 1, 1, 'Katowicka', 42, 18, 6, '40001');


-- FOUNDS --

-- Table: currency

INSERT INTO currency (id, currency_2, currency_3, full_format)
VALUES (1, 'PL', 'PLN', 'Polish Zloty');

INSERT INTO currency (id, currency_2, currency_3, full_format)
VALUES (2, 'US', 'USD', 'United States Dollar');

INSERT INTO currency (id, currency_2, currency_3, full_format)
VALUES (3, 'EU', 'EUR', 'Euro');


-- Table: transaction

INSERT INTO transaction (id, type)
VALUES (1, 'Payment');

INSERT INTO transaction (id, type)
VALUES (2, 'Refund');

INSERT INTO transaction (id, type)
VALUES (3, 'Fee');

INSERT INTO transaction (id, type)
VALUES (4, 'Interest');

INSERT INTO transaction (id, type)
VALUES (5, 'Loan');

INSERT INTO transaction (id, type)
VALUES (6, 'Chargeback');

INSERT INTO transaction (id, type)
VALUES (7, 'Adjustment');


-- Table: account_number_format

INSERT INTO account_number_format (id, abbreviation, type)
VALUES (1, 'IBAN', 'International Bank Account Number');

INSERT INTO account_number_format (id, abbreviation, type)
VALUES (2, 'CC', 'Credit Card Number');

INSERT INTO account_number_format (id, abbreviation, type)
VALUES (3, 'ACH', 'Automated Clearing House (USA)');

INSERT INTO account_number_format (id, abbreviation, type)
VALUES (4, 'BLZ', 'Bankleitzahl (Germany Bank Code)');

INSERT INTO account_number_format (id, abbreviation, type)
VALUES (5, 'NRB', 'Numer Rachunku Bankowego (Poland)');


-- Table: account

INSERT INTO account (id, account_number, account_number_format_id, status_id, registration_date, loyalty_rating, client_data_id, available, pend, currency_id)
VALUES (1, 61109010140000071219812874, 1, 1, TO_DATE('2010-02-11 10:15:00', 'YYYY-MM-DD HH24:MI:SS'), 0.99, 2, 1000.00, 200.00, 1);

INSERT INTO account (id, account_number, account_number_format_id, status_id, registration_date, loyalty_rating, client_data_id, available, pend, currency_id)
VALUES (2, 89370400440532013000, 2, 1, TO_DATE('2016-03-07 13:45:00', 'YYYY-MM-DD HH24:MI:SS'), 0.50, 2, 5000.00, 1000.00, 1);

INSERT INTO account (id, account_number, account_number_format_id, status_id, registration_date, loyalty_rating, client_data_id, available, pend, currency_id)
VALUES (3, 12345678901234567890123456, 3, 3, TO_DATE('2012-01-02 11:30:00', 'YYYY-MM-DD HH24:MI:SS'), 0.75, 3, 1500.00, 0.00, 2);

INSERT INTO account (id, account_number, account_number_format_id, status_id, registration_date, loyalty_rating, client_data_id, available, pend, currency_id)
VALUES (4, 61109010140000071219812875, 1, 1, TO_DATE('2015-01-01 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 0.32, 3, 3500.00, 500.00, 2);

INSERT INTO account (id, account_number, account_number_format_id, status_id, registration_date, loyalty_rating, client_data_id, available, pend, currency_id)
VALUES (5, 89370400440532013001, 2, 2, TO_DATE('2014-02-02 16:05:00', 'YYYY-MM-DD HH24:MI:SS'), 0.15, 1, 200.00, 50.00, 3);


-- CONSENTS --

-- Table: consents

INSERT INTO consents (id, title, document)
VALUES (1, 'Data Proc. Consent', 'I agree to process my data for account management and legal compliance.');

INSERT INTO consents (id, title, document)
VALUES (2, 'Marketing Consent', 'I agree to receive promos and updates via email and SMS.');

INSERT INTO consents (id, title, document)
VALUES (3, '3rd-Party Data Share', 'I agree to share data with third parties for financial services.');


-- SESSIONS --

-- Table: action_type

INSERT INTO action_type (id, name) VALUES (1, 'Login');
INSERT INTO action_type (id, name) VALUES (2, 'Logout');
INSERT INTO action_type (id, name) VALUES (3, 'View balance');
INSERT INTO action_type (id, name) VALUES (4, 'Transfer funds');
INSERT INTO action_type (id, name) VALUES (5, 'Update profile');


-- ROOT --

-- Table: account_consents

INSERT INTO account_consents (consents_id, client_account_id)
VALUES (1, 1);
INSERT INTO account_consents (consents_id, client_account_id)
VALUES (2, 1);
INSERT INTO account_consents (consents_id, client_account_id)
VALUES (3, 1);

INSERT INTO account_consents (consents_id, client_account_id)
VALUES (1, 2);
INSERT INTO account_consents (consents_id, client_account_id)
VALUES (3, 2);

INSERT INTO account_consents (consents_id, client_account_id)
VALUES (1, 3);

INSERT INTO account_consents (consents_id, client_account_id)
VALUES (1, 4);
INSERT INTO account_consents (consents_id, client_account_id)
VALUES (2, 4);
INSERT INTO account_consents (consents_id, client_account_id)
VALUES (3, 4);

INSERT INTO account_consents (consents_id, client_account_id)
VALUES (1, 5);


-- Table: session_history

INSERT INTO session_history (id, client_account_id, time_start, ttl, time_end)
VALUES (1, 1, TO_TIMESTAMP('2025-01-04 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3600, TO_TIMESTAMP('2025-01-04 10:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO session_history (id, client_account_id, time_start, ttl, time_end)
VALUES (2, 2, TO_TIMESTAMP('2025-01-04 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1800, TO_TIMESTAMP('2025-01-04 11:30:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO session_history (id, client_account_id, time_start, ttl, time_end)
VALUES (3, 3, TO_TIMESTAMP('2025-01-04 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), 7200, TO_TIMESTAMP('2025-01-04 15:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO session_history (id, client_account_id, time_start, ttl, time_end)
VALUES (4, 4, TO_TIMESTAMP('2025-01-04 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), 5400, TO_TIMESTAMP('2025-01-04 17:30:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO session_history (id, client_account_id, time_start, ttl, time_end)
VALUES (5, 5, TO_TIMESTAMP('2025-01-04 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3600, TO_TIMESTAMP('2025-01-04 19:00:00', 'YYYY-MM-DD HH24:MI:SS'));


-- Table: activity_log

INSERT INTO activity_log (id, session_history_id, action_type_id, time_stamp)
VALUES (1, 1, 1, TO_TIMESTAMP('2025-01-04 09:05:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO activity_log (id, session_history_id, action_type_id, time_stamp)
VALUES (2, 1, 3, TO_TIMESTAMP('2025-01-04 09:15:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO activity_log (id, session_history_id, action_type_id, time_stamp)
VALUES (3, 1, 4, TO_TIMESTAMP('2025-01-04 09:30:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO activity_log (id, session_history_id, action_type_id, time_stamp)
VALUES (4, 2, 1, TO_TIMESTAMP('2025-01-04 11:05:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO activity_log (id, session_history_id, action_type_id, time_stamp)
VALUES (5, 2, 5, TO_TIMESTAMP('2025-01-04 11:15:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO activity_log (id, session_history_id, action_type_id, time_stamp)
VALUES (6, 3, 3, TO_TIMESTAMP('2025-01-04 13:10:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO activity_log (id, session_history_id, action_type_id, time_stamp)
VALUES (7, 3, 4, TO_TIMESTAMP('2025-01-04 13:45:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO activity_log (id, session_history_id, action_type_id, time_stamp)
VALUES (8, 4, 1, TO_TIMESTAMP('2025-01-04 16:05:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO activity_log (id, session_history_id, action_type_id, time_stamp)
VALUES (9, 4, 3, TO_TIMESTAMP('2025-01-04 16:25:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO activity_log (id, session_history_id, action_type_id, time_stamp)
VALUES (10, 5, 2, TO_TIMESTAMP('2025-01-04 18:15:00', 'YYYY-MM-DD HH24:MI:SS'));


-- Table: financial_log

INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id, description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (1, 1, 500.00, 0, TO_DATE('2024-01-03 14:15:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-01-02 13:30:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 'Deposit from salary', 1, TO_DATE('2025-01-04', 'YYYY-MM-DD'), 61109010140000071219812875, 1);

INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id, description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (2, 1, -200.00, 1, TO_DATE('2023-02-03 12:45:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-02-03 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 'Payment for utility bill', 1, TO_DATE('2025-01-04', 'YYYY-MM-DD'), 61109010140000071219812876, 1);

INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id, description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (3, 2, 1000.00, 0, TO_DATE('2022-03-02 15:10:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-03-01 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 'Refund from merchant', 1, TO_DATE('2025-01-04', 'YYYY-MM-DD'), 61109010140000071219812877, 1);

INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id, description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (4, 2, -150.00, 0, TO_DATE('2021-04-08 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2021-04-06 13:25:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 'Payment for groceries', 1, TO_DATE('2025-01-04', 'YYYY-MM-DD'), 61109010140000071219812878, 1);

INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id, description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (5, 3, 250.00, 1, TO_DATE('2022-05-08 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-05-08 12:45:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 'Transfer from friend', 2, TO_DATE('2025-01-04', 'YYYY-MM-DD'), 61109010140000071219812879, 2);

INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id, description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (6, 3, -50.00, 0, TO_DATE('2023-04-02 11:20:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-04-01 14:35:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 'Payment for coffee shop', 2, TO_DATE('2025-01-04', 'YYYY-MM-DD'), 61109010140000071219812880, 2);

INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id, description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (7, 4, 800.00, 0, TO_DATE('2024-03-09 13:40:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-03-07 10:55:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 'Salary deposit', 2, TO_DATE('2025-01-04', 'YYYY-MM-DD'), 61109010140000071219812881, 2);

INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id, description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (8, 4, -700.00, 0, TO_DATE('2025-02-10 15:30:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2025-02-09 12:10:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 'Payment for rent', 2, TO_DATE('2025-01-04', 'YYYY-MM-DD'), 61109010140000071219812882, 2);

INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id, description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (9, 4, 50.00, 0, TO_DATE('2021-01-03 14:45:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2021-01-02 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 'Bonus payment', 3, TO_DATE('2025-01-04', 'YYYY-MM-DD'), 12345678901234567890123456, 3);

INSERT INTO financial_log (id, account_id, amount, rush, operation_date, timestamp, transaction_type_id, description, currency_id, currency_date, other_account_number, account_number_format_id)
VALUES (10, 4, -120.00, 1, TO_DATE('2023-03-06 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-03-06 11:25:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 'Payment for subscription service', 3, TO_DATE('2025-01-04', 'YYYY-MM-DD'), 61109010140000071219812884, 3);

