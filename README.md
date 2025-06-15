# Coursework

> ⚠️ **Disclaimer:**  
> This repository is not recommended for use in academic or production environments.  
> It contains several bad practices used solely to meet coursework constraints and work within the AWS Free Tier limits.  

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
│   ├── etl2.sql.tpl
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── s3/
│       ├── vpc/
│       ├── ec2-basion/
│       ├── rds_oltp/
│       ├── rds_olap/
│       └── lambda/
├── sql/                   
│   ├── init-olap-tables.sql
│   ├── init-oltp-tables.sql
│   ├── etl1.sql
│   ├── to_show_etl2.sql
│   └── selects
│       ├── olap/
│       │   └── selects.sql
│       └── oltp/
│           └── selects.sql
├── lambda/                 
│   ├── lambda-to-oltp/
│   │   └── lambda_function.py
│   └── lambda-to-oltp/
│       └── lambda_function.py
├── data/                   
│   └── *.csv
└── README.md              
```

## 🗃️ Database Design

### OLTP Schema (Normalized)

The OLTP database is based on a simplified version of the **Chinook** schema, fully normalized (3NF), and designed for efficient transactional operations.

**Included Tables:**

- `Artist` — stores artist metadata
- `Album` — each album belongs to one artist
- `Track` — each track belongs to an album and contains pricing/media info
- `Genre` — genre classification for tracks
- `MediaType` — file format metadata
- `Customer` — customer info (location, contact, etc.)
- `Invoice` — purchases made by customers
- `InvoiceLine` — line items per invoice (track purchases)
![изображение](https://github.com/user-attachments/assets/3f2b6d9d-3997-4365-a5ce-95a3e13bc380)

**Notes:**

- Some unused tables and attributes were removed to reduce complexity  
- The schema preserves referential integrity with foreign keys  
- Suitable for ingestion via CSV and Lambda

---

### OLAP Schema (Dimensional)

For analytical workloads, data is transformed into a **star schema** within the OLAP database. It supports efficient aggregation and filtering for BI tools.

**Fact Tables:**

- `fact_sales` — transactional grain, representing each track sale
- `fact_invoice_summary` — invoice-level aggregates

**Dimension Tables:**

- `dim_customer` — slowly changing dimension (Type 2)
- `dim_track` — track details including artist, album, genre
- `dim_time` — calendar dimension (day, month, quarter, year)

**Bridge Table:**

- `bridge_invoice_track` — resolves many-to-many between `invoice` and `track`

![изображение](https://github.com/user-attachments/assets/db6c9f94-8f4c-484c-994e-562a6ea0b897)

This OLAP schema powers Amazon QuickSight dashboards through custom SQL queries.


## Amazon QuickSight Visualizations

This section showcases final visualizations built using **Amazon QuickSight** connected to the **OLAP** database.

> All dashboards use **custom SQL datasets**, include **interactive filters**.

### 1. Most Profitable Artists (2 Years Ago)

![изображение](https://github.com/user-attachments/assets/433739bc-26c6-43f5-8317-017119eb1924)

### 2. Genre-wise Sales (2 Years Ago)

![изображение](https://github.com/user-attachments/assets/404daca7-c2b9-4cb2-8e4e-96bf6c9bf2e0)

### 3. Top 5 Tracks of All Time by Quantity Sold

![изображение](https://github.com/user-attachments/assets/3bcec799-649b-4644-9eea-8cbf6175d69c)

