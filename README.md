# Coursework

## Objective

Design and deploy a cloud-native ETL/ELT pipeline using only free-tier AWS components and open standards such as SQL and Terraform. This project serves both as a university coursework and a production-ready portfolio project.

## Stack

- **Terraform** – Infrastructure as Code (IaC)
- **AWS** – S3, Lambda, RDS (OLTP), Redshift (OLAP), IAM
- **Amazon QuickSight** – Visualization (BI)
- **SQL** – For schema creation and ETL logic
- **GitHub** – Project repository and version control

## Infrastrucutre Diagram
![изображение](https://github.com/user-attachments/assets/0023e4b6-8a1e-400c-b3dc-9840f8f9129b)

## Repository Structure

```plaintext
.
├── terraform/              
│   └── modules/
│       ├── s3/
│       ├── rds/
│       ├── redshift/
│       ├── lambda/
│       └── iam/
├── sql/                   
│   ├── rds_schema.sql
│   ├── redshift_schema.sql
│   ├── etl_rds_staging.sql
│   ├── etl_rds_to_oltp.sql
│   └── etl_oltp_to_redshift.sql
├── lambda/                 
│   ├── etl_rds_handler.py    
│   ├── etl_redshift_handler.py
│   └── requirements.txt
├── data/                   
│   └── *.csv
├── diagrams/               
│   └── architecture.png
└── README.md              
