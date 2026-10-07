# Boston Hospital Database System

This repository contains the complete database design, implementation scripts, and technical report for the **Boston Hospital Case Study**.

## Repository Structure

* **[`Boston_Hospital_Case_Study.md`](./Boston_Hospital_Case_Study.md)**: Comprehensive academic technical report containing:
  * **Part A:** Database Description & Architectural Rationale
  * **Part B:** Entity Relationship Diagram (ERD) with Mermaid Crow's Foot Notation
  * **Part C:** Relational Schema, Functional Dependencies, and Normalization Proofs (3NF & BCNF)
  * **Part D:** Database and Table DDL Scripts & Sample Population Data
  * **Part E:** Views, Stored Procedures supporting Transactions (a) through (n), and Validation Test Queries
* **[`SETUP_AND_RUN_GUIDE.md`](./SETUP_AND_RUN_GUIDE.md)**: Beginner-friendly, step-by-step setup and execution manual with visual architecture and troubleshooting flowcharts.
* **[`boston_hospital_database.sql`](./boston_hospital_database.sql)**: Pure SQL script ready to run directly in MySQL Workbench or MySQL CLI.

## How to Run

1. Open MySQL Workbench or connect to MySQL CLI:
   ```bash
   mysql -u root -p
   ```
2. Execute the script:
   ```sql
   source /path/to/boston_hospital_database.sql;
   ```
3. All tables, sample records, views, and stored procedures will be created and verified automatically under the `BostonHospital` database.
