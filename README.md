# Coursework

## Objective

Design and deploy a cloud-native ETL/ELT pipeline using only free-tier AWS components. This project serves both as a university coursework and a pet-project.

## Task
- Identifying a domain of interest.
- Creating multiple `.csv` datasets related to the chosen domain.
- Ingesting the datasets into an OLTP database using ETL/ELT processes.
- Transfe the data from OLTP into a DWH using ETL/ELT for further querying.
- Performing data analysis and generating visualizations based on the data from DWH.

## Stack

- **Terraform** – Infrastructure as Code (IaC)
- **AWS** – S3, Lambda, RDS (OLTP), Redshift (OLAP), IAM
- **Amazon QuickSight** – Visualization (BI)
- **SQL** – For schema creation and ETL logic
- **GitHub** – Project repository and version control

## Infrastrucutre Diagram
![изображение](https://github.com/user-attachments/assets/44120ea9-de60-42c1-b426-b43dd492dd06)

## Repository Structure

```plaintext
.
├── terraform/
│   ├── main.tf
│   ├── iam.tf
│   ├── quicksight.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf    
│   ├── backend.tf               
│   └── modules/
│       ├── s3/
│       ├── vpc/
│       ├── ec2-basion/
│       ├── rds/
│       ├── redshift/
│       └── lambda/
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
