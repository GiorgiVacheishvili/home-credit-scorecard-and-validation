-- 01_data_quality.sql
-- Data quality checks on the application table (database: home_credit).
-- Each section matches a finding in report/notes.md.


-- Finding 1: Loaded data and target

-- Row counts of the three loaded tables
-- Result: 307,511 / 1,716,428 / 1,670,214
SELECT 'application_train' AS table_name, COUNT(*) AS row_amount FROM application_train
UNION ALL
SELECT 'bureau', COUNT(*) FROM bureau
UNION ALL
SELECT 'previous_application', COUNT(*) FROM previous_application;

-- Applicants by target (0 = no payment difficulties, 1 = payment difficulties)
-- Result: 0 = 282,686, 1 = 24,825
SELECT target AS client_w_difficulties,
       COUNT(*) AS client_quantity
FROM application_train
GROUP BY target;

-- Overall default rate
-- Result: 8.07%
SELECT COUNT(*) AS total_count,
       SUM(target) AS client_w_difficulties,
       ROUND(100.0 * SUM(target) / COUNT(*), 2) AS default_rate
FROM application_train;


-- Finding 2: First look at five columns

-- Minimum, maximum and number of missing values, with days_birth converted to years
-- Result: see the table in finding 2
SELECT 'client_income' AS information_type,
       MIN(amt_income_total) AS minimum,
       MAX(amt_income_total) AS maximum,
       COUNT(*) - COUNT(amt_income_total) AS missing
FROM application_train
UNION ALL
SELECT 'credit_amount', MIN(amt_credit), MAX(amt_credit), COUNT(*) - COUNT(amt_credit)
FROM application_train
UNION ALL
SELECT 'years_old',
       ROUND(-MAX(days_birth) / 365.25, 1),
       ROUND(-MIN(days_birth) / 365.25, 1),
       COUNT(*) - COUNT(days_birth)
FROM application_train
UNION ALL
SELECT 'current_job_days', MIN(days_employed), MAX(days_employed), COUNT(*) - COUNT(days_employed)
FROM application_train
UNION ALL
SELECT 'ext_source_1', MIN(ext_source_1), MAX(ext_source_1), COUNT(*) - COUNT(ext_source_1)
FROM application_train;


-- Finding 3: The 365,243 code in days_employed

-- Applicants with the value 365,243
-- Result: 55,374
SELECT COUNT(*) AS clients_with_365243_in_days_employed
FROM application_train
WHERE days_employed = 365243;

-- Default rate: applicants with the code vs the others
-- Result: 5.40% vs 8.66%
SELECT CASE WHEN days_employed = 365243 THEN 'clients_w_365243_days_of_employment'
            ELSE 'other_clients'
       END AS employment_group,
       COUNT(*) AS applicants,
       ROUND(100.0 * SUM(target) / COUNT(*), 2) AS default_rate
FROM application_train
GROUP BY employment_group;

-- Income types of the applicants with the code
-- Result: Pensioner 55,352, Unemployed 22
SELECT name_income_type AS income_type, COUNT(*) AS count
FROM application_train
WHERE days_employed = 365243
GROUP BY income_type;

-- Income types of all applicants, for comparison
-- Result: 55,362 pensioners and 22 unemployed in total
SELECT name_income_type AS income_type, COUNT(*) AS count
FROM application_train
GROUP BY income_type;


-- Finding 4: Extreme incomes

-- Applicants with an income above 1,000,000
-- Result: 250
SELECT COUNT(*) AS count
FROM application_train
WHERE amt_income_total > 1000000;

-- The 10 highest incomes with their credit amounts
-- Result: the top income (117,000,000) is 6.5 times the next one (18,000,090)
SELECT amt_income_total AS income, amt_credit AS credit_amount
FROM application_train
ORDER BY amt_income_total DESC
LIMIT 10;

-- Default rate: income above 1,000,000 vs the rest
-- Result: 5.20% (13 defaults) vs 8.08%
SELECT CASE WHEN amt_income_total > 1000000 THEN 'higher_than_1000000'
            ELSE 'lower_than_1000000'
       END AS income,
       COUNT(*) AS applicants,
       ROUND(100.0 * SUM(target) / COUNT(*), 2) AS default_rate
FROM application_train
GROUP BY income;


-- Finding 5: ext_source missingness

-- Default rate for each combination of missing and present ext_source scores
-- Result: see the combinations in finding 5
SELECT CASE WHEN ext_source_1 IS NULL THEN 'missing' ELSE 'not_missing' END AS ext_source_1_status,
       CASE WHEN ext_source_2 IS NULL THEN 'missing' ELSE 'not_missing' END AS ext_source_2_status,
       CASE WHEN ext_source_3 IS NULL THEN 'missing' ELSE 'not_missing' END AS ext_source_3_status,
       COUNT(*) AS applicants,
       ROUND(100.0 * SUM(target) / COUNT(*), 2) AS default_rate
FROM application_train
GROUP BY ext_source_1_status, ext_source_2_status, ext_source_3_status
ORDER BY ext_source_1_status, ext_source_2_status, ext_source_3_status;

-- Default rate: missing vs present, one score at a time
-- Result: ext_source_1 8.52% vs 7.50%
SELECT CASE WHEN ext_source_1 IS NULL THEN 'missing' ELSE 'not_missing' END AS ext_source_1_status,
       COUNT(*) AS applicants,
       ROUND(100.0 * SUM(target) / COUNT(*), 2) AS default_rate
FROM application_train
GROUP BY ext_source_1_status;

-- Result: ext_source_2 7.88% vs 8.07%
SELECT CASE WHEN ext_source_2 IS NULL THEN 'missing' ELSE 'not_missing' END AS ext_source_2_status,
       COUNT(*) AS applicants,
       ROUND(100.0 * SUM(target) / COUNT(*), 2) AS default_rate
FROM application_train
GROUP BY ext_source_2_status;

-- Result: ext_source_3 9.31% vs 7.77%
SELECT CASE WHEN ext_source_3 IS NULL THEN 'missing' ELSE 'not_missing' END AS ext_source_3_status,
       COUNT(*) AS applicants,
       ROUND(100.0 * SUM(target) / COUNT(*), 2) AS default_rate
FROM application_train
GROUP BY ext_source_3_status;