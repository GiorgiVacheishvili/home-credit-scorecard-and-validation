# Home Credit Scorecard and Validation

Independent project building and validating a bank-style credit scorecard on multi-table
consumer-credit data (Kaggle "Home Credit Default Risk"), with data work in PostgreSQL and
modelling in Python.

**Status: in progress**

This is my second credit risk project. The first one,
[credit-risk-validation](https://github.com/GiorgiVacheishvili/credit-risk-validation),
used a single-table dataset. This project adds:
- SQL joins and aggregations across several linked tables (applications, credit bureau
  history and previous applications);
- a scorecard built the way banks often build them: binned features with weight of evidence
  (WoE) and information value (IV), converted into points;
- calibration checks (do the predicted default probabilities match the actual default rates?);
- cross-validation.

## Data
- application_train: 307,511 loan applications, one row per applicant. The target marks
  applicants with payment difficulties (8.07% of applicants).
- bureau: 1,716,428 rows, the applicants' previous credits reported by the credit bureau.
- previous_application: 1,670,214 rows, the applicants' previous applications at Home Credit.

## Project structure
| Folder | Contents |
|---|---|
| notebooks/ | 00_load.ipynb loads the CSV files into PostgreSQL; the modelling notebooks will follow |
| sql/ | 01_data_quality.sql: data quality checks on the application table |
| report/ | notes.md: detailed working notes for every finding and decision |

## Progress
- [x] Load the data into PostgreSQL
- [ ] Data quality checks on the application table (in progress)
- [ ] Features from the bureau and previous application tables (joins)
- [ ] WoE/IV scorecard and points
- [ ] Validation: cross-validation, calibration and a LightGBM challenger
- [ ] Validation report

## Tools
PostgreSQL (pgAdmin), Python (pandas, SQLAlchemy), Jupyter.

## Reproducing the project
The data files are not included in this repository, as Kaggle competition data can't be
redistributed. To reproduce the project:
1. Download the data from the Kaggle competition "Home Credit Default Risk" (you need to
   accept the competition rules).
2. Create a PostgreSQL database called home_credit.
3. Run notebooks/00_load.ipynb, which loads application_train, bureau and
   previous_application and lowercases the column names. The database password is entered
   with getpass and is not stored in the files.
4. Run the SQL files in order.
