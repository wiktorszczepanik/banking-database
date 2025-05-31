-- plik .SQL z zapytaniami SELECT i UPDATE/DELETE

/*
1. Zapytanie z LEFT/INNER JOIN + GROUP BY
Klienci co mają powyżej dwóch aktywnych kont w aplikacji bankowej.

output:
+-----+------------+------------+--------------------------------+
|ID   |FIRST_NAME  |LAST_NAME   |NUMBER_OF_ACCOUNTS_PER_CLIENT   |
+-----+------------+------------+--------------------------------+
|    2|Anna        |Nowak       |                               2|
+-----+------------+------------+--------------------------------+
*/
SELECT cd.id, cd.first_name, cd.last_name,
COUNT(a.id) AS number_of_accounts_per_client
FROM client_data cd
LEFT JOIN account a ON cd.id = a.client_data_id
INNER JOIN status s ON a.status_id = s.ID
WHERE a.status_id = 1
GROUP BY cd.id, cd.first_name, cd.last_name
HAVING COUNT(a.account_number) > 1;

/*
2. Zapytanie z RIGHR JOIN
Konta, które nie posiadają żadnych tranzakcji.

output:
+---------------+---------------+-----------------------+
|CLIENT_ID	|ACCOUNT_ID	|TRANSACTION_STATE	|
+---------------+---------------+-----------------------+
|              1|	       5|no transactions	|
+---------------+---------------+-----------------------+
*/
SELECT cd.id AS client_id, a.id AS account_id,
'no transactions' AS transaction_state
FROM financial_log fl
RIGHT JOIN account a ON fl.account_id = a.id
RIGHT JOIN client_data cd ON a.client_data_id = cd.id
WHERE fl.id IS NULL
ORDER BY 1, 2;

/*
3.Zapytanie z podzapytaniem
Adresy, które mają address_type 'MAIL' oraz których klienci mają 'MAIL' jako preferowaną formę kontaktu.

output:
+-------+-------+---------------+-----------------------+-----------------------+---------------+
|ID	|CITY	|STREET		|BUILDING_NUMBER	|APARTMENT_NUMBER	|POSTAL_CODE	|
+-------+-------+---------------+-----------------------+-----------------------+---------------+
|      4|Poznań	|Poznańska	|                     15|                 <null>|60001		|
+-------+-------+---------------+-----------------------+-----------------------+---------------+
*/
SELECT a.id, c.nazwa AS city, a.street, a.building_number, a.apartment_number, a.postal_code
FROM address a
INNER JOIN client_data cd ON a.client_data_id = cd.id
INNER JOIN city c ON a.city_id = c.ID
WHERE a.address_type_id = (
    SELECT at.id
    FROM address_type at
    WHERE at.name = 'MAIL'
) AND cd.preferred_contact_id = (
    SELECT pc.id
    FROM preferred_contact pc
    WHERE pc.type = 'MAIL'
);

/*
4. Podzapytanie skorelowane
Klienci których konta mają największe saldo (available) w danej walucie.

output:
+---------------+---------------+---------------+---------------+
|FIRST NAME	|LAST_NAME	|AVAILABLE	|CURRENCY_2	|
+---------------+---------------+---------------+---------------+
|Anna		|Nowak		|        5000.00|PL		|
+---------------+---------------+---------------+---------------+
|Krzysztof	|Siennicki	|        3500.00|US		|
+---------------+---------------+---------------+---------------+
|Jan		|Kowalski	|         200.00|EU		|
+---------------+---------------+---------------+---------------+
*/
SELECT cd.first_name, cd.last_name, a1.available, c.currency_2
FROM client_data cd
JOIN account a1 ON cd.id = a1.client_data_id
JOIN currency c ON a1.currency_id = c.id
WHERE a1.available = (
    SELECT MAX(a2.available)
    FROM account a2
    WHERE a2.currency_id = a1.currency_id
)
ORDER BY 3 DESC;

/*
5. UPDATE + podzapytanie
Dodanie 0.05 do ratingu dla klientów którzy od 2024-01-01 00:00:00 do 2025-03-01 23:59:59 dokonali więcej niż 1 tranzakcję.

output: Dla konta (account) o id równym 4, ocena lojalności (loyalty_rating) podniesie się z 0.32 do 0.37) możemy to zaobserwować poprzez zapytanie:

SELECT id, loyalty_rating
FROM account
WHERE id = 4;

Przed:
+-------+---------------+
|ID	|LOYALTY_RATING	|
+-------+---------------+
|      4|0.32		|
+-------+---------------+

Po:
+-------+---------------+
|ID	|LOYALTY_RATING	|
+-------+---------------+
|      4|0.37		|
+-------+---------------+
*/
UPDATE account a1 SET a1.loyalty_rating = a1.loyalty_rating + 0.05
WHERE a1.id IN (
    SELECT a2.id
    FROM account a2
    INNER JOIN financial_log fl ON a2.id = fl.account_id
    WHERE fl.timestamp BETWEEN TO_DATE('2024-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
        AND TO_DATE('2025-03-01 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
    GROUP BY a2.id
    HAVING COUNT(fl.id) > 1
);

/*
6. DELETE + podzapytanie
Usunięcie kont które posiadają status "Closed" oraz takich, które w 2024 i 2025 nie miały żadnej aktywności finansowej (tranzakcji)
output: Konta (account) o numerach 

SELECT id, account_number
FROM account;

Przed:
+-------+-------------------------------+
|ID	|ACCOUNT_NUMBER			|
+-------+-------------------------------+
|      1|     61109010140000071219812874|
+-------+-------------------------------+
|      2|           89370400440532013000|
+-------+-------------------------------+
|      3|     12345678901234567890123456|
+-------+-------------------------------+
|      4|     61109010140000071219812875|
+-------+-------------------------------+
|      5|           89370400440532013001|
+-------+-------------------------------+

Po:
+-------+-------------------------------+
|ID	|ACCOUNT_NUMBER			|
+-------+-------------------------------+
|      1|     61109010140000071219812874|
+-------+-------------------------------+
|      2|           89370400440532013000|
+-------+-------------------------------+
|      3|     12345678901234567890123456|
+-------+-------------------------------+
|      4|     61109010140000071219812875|
+-------+-------------------------------+
*/

DELETE FROM account a
WHERE a.status_id = 2
OR a.id IN (
    SELECT fl.account_id
    FROM financial_log fl
    WHERE TO_CHAR(fl.timestamp, 'YYYY') IN ('2024', '2025')
    GROUP BY fl.account_id
    HAVING COUNT(fl.id) = 0
);

