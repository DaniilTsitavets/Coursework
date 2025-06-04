# Coursework

## Objective

Design and deploy a cloud-native ETL/ELT pipeline using only free-tier AWS components. This project serves both as a university coursework and a pet-project.

## Task
- Identifying a domain of interest.
- Creating`.csv` dataset related to the chosen domain.
- Ingesting the datasets into an OLTP database using ETL/ELT processes.
- Transfer the data from OLTP into a DWH using ETL/ELT for further querying.
- Performing data analysis and generating visualizations based on the data from DWH.

## Stack

- **Terraform** – Infrastructure as Code (IaC)
- **AWS** – S3, Lambda, RDS (OLTP and OLAP), IAM, Amazon QuickSight
- **SQL** – For schema creation and ETL logic
- **GitHub** – Project repository and version control

## Infrastrucutre Diagram
![изображение](https://github.com/user-attachments/assets/b3567f85-28cb-4296-9ef9-89c0633d319a)



## Repository Structure

```plaintext
.
├── terraform/
│   ├── main.tf
│   ├── quicksight.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf               
│   └── modules/
│       ├── s3/
│       ├── vpc/
│       ├── ec2-basion/
│       ├── rds_oltp/
│       ├── rds_olap/
│       └── lambda/
├── sql/                   
│   ├── rds_schema.sql
│   ├── redshift_schema.sql
│   ├── elt_csv_to_oltp.sql
│   └── etl_oltp_to_olap.sql
├── lambda/                 
│   ├── lambda-to-oltp/
│   │   └── lambda_function.py
│   └── lambda-to-oltp/
│       └── lambda_function.py
├── data/                   
│   └── *.csv
├── diagrams/               
│   └── architecture.png
└── README.md              
