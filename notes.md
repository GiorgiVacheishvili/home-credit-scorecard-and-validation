## 1. Loaded data and target
I loaded 3 tables into PostgreSQL with pandas to_sql and lowercased the column names.
The tables are in a new database called home_credit, and the tables I loaded are
application_train, bureau and previous_application. application_train contains 307,511
clients, bureau 1,716,428 rows and previous_application 1,670,214 rows.
282,686 applicants in application_train have no payment difficulties, indicated by 0 in the
target column, and 24,825 have difficulties, indicated by 1. The default rate for the
clients in application_train is 8.07%.

## 2. First look at five columns
These are the columns I looked at, with their minimum, maximum and number of missing values:

| Column | Min | Max | Missing |
|---|---|---|---|
| amt_income_total | 25,650 | 117,000,000 | 0 |
| amt_credit | 45,000 | 4,050,000 | 0 |
| days_birth (in years) | 20.5 | 69.1 | 0 |
| days_employed | -17,912 | 365,243 | 0 |
| ext_source_1 | 0.0146 | 0.9627 | 173,378 |

days_birth is recorded as the number of days before the application, so I converted it to
years (-days_birth / 365.25). The age range of 20.5 to 69.1 years is realistic.
days_employed is also counted in days before the application: a negative value means the job
started that many days ago.

## 3. The 365,243 code in days_employed
The value 365,243 in days_employed doesn't make sense. Firstly, it translates to roughly 1,000
years, and secondly, its positive sign would mean the job starts in the future.
55,374 applicants have exactly this value, and their default rate is 5.40%, compared with
8.66% for the others, suggesting there is information in this value. Of these clients,
55,352 are pensioners (out of 55,362 pensioners in total), and all 22 unemployed clients have
the code.
Treatment: set days_employed to NULL for these applicants. I originally assumed a flag would be
needed, but since it would only mark most of the pensioners and all of the unemployed, it would
be redundant: these clients are already identified by name_income_type.

## 4. Extreme incomes
250 applicants have an income of more than 1,000,000, and their default rate is 5.20%
compared with 8.08% for the others, suggesting that a high income carries information about
the probability of default.
Note: the 5.20% is based on only 13 defaults, a small sample.
The top earner's income is 117,000,000, 6.5 times the next highest income (18,000,090), with
credit amounts of 562,491 and 675,000 respectively. This suggests that the top applicant
either has an error in the reported income or is an extreme outlier.
Treatment: keep these applicants. Decide whether to cap income in the scorecard stage, where
income will be split into bands.

## 5. ext_source missingness
These are normalised scores from external data sources (the column description doesn't say
what they measure).

Missing vs not missing:
- ext_source_1: 173,378 missing (56%), default rate 8.52% vs 7.50%
- ext_source_2: 660 missing (0.2%), 7.88% vs 8.07% (almost no difference, small group)
- ext_source_3: 60,965 missing (20%), 9.31% vs 7.77% (the biggest difference, in a large group)

Combinations:
- all three present: 109,589 applicants at 7.30%, the lowest of the big groups;
- all three missing: only 172 applicants at 8.14%, about average;
- ext_source_1 and ext_source_3 missing (ext_source_2 present): 36,402 applicants at 9.96%,
  the highest of the big groups.

ext_source_3 missingness carries the most information, while ext_source_1 missingness
carries some.