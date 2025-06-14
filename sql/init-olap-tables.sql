DROP TABLE IF EXISTS bridge_invoice_track;
DROP TABLE IF EXISTS fact_invoice_summary;
DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_time;
DROP TABLE IF EXISTS dim_track;
DROP TABLE IF EXISTS dim_customer;
CREATE EXTENSION IF NOT EXISTS dblink;

-- Dimension: Customer (SCD Type 2)
CREATE TABLE IF NOT EXISTS dim_customer (
  customer_sk INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id INT,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  city VARCHAR(50),
  country VARCHAR(50),
  email VARCHAR(100),
  start_date DATE,
  end_date DATE,
  is_current BOOLEAN
);

-- Dimension: Track
CREATE TABLE dim_track (
  track_sk INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  track_id INT,
  track_name VARCHAR(200),
  album_title VARCHAR(160),
  artist_name VARCHAR(120),
  genre_name VARCHAR(120),
  media_type VARCHAR(50),
  unit_price NUMERIC(10,2)
);

ALTER TABLE dim_track
ADD CONSTRAINT uq_dim_track_id_name UNIQUE (track_id, track_name);

-- Dimension: Time
CREATE TABLE dim_time (
  time_sk INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  date DATE,
  day INT,
  month INT,
  quarter INT,
  year INT
);

ALTER TABLE dim_time
ADD CONSTRAINT uq_dim_time_date UNIQUE (date);

-- Fact: Sales
CREATE TABLE fact_sales (
  sales_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_sk INT,
  track_sk INT,
  time_sk INT,
  quantity INT,
  total NUMERIC(10,2),
  FOREIGN KEY (customer_sk) REFERENCES dim_customer(customer_sk),
  FOREIGN KEY (track_sk) REFERENCES dim_track(track_sk),
  FOREIGN KEY (time_sk) REFERENCES dim_time(time_sk)
);

-- Fact: Invoice Summary
CREATE TABLE fact_invoice_summary (
  invoice_id INT PRIMARY KEY,
  customer_sk INT,
  time_sk INT,
  total_amount NUMERIC(10,2),
  total_items INT,
  FOREIGN KEY (customer_sk) REFERENCES dim_customer(customer_sk),
  FOREIGN KEY (time_sk) REFERENCES dim_time(time_sk)
);

-- Bridge Table: Invoice - Track
CREATE TABLE bridge_invoice_track (
  invoice_id INT,
  track_sk INT,
  quantity INT,
  PRIMARY KEY (invoice_id, track_sk)
);

ALTER TABLE bridge_invoice_track
ADD CONSTRAINT fk_invoice_id FOREIGN KEY (invoice_id)
REFERENCES fact_invoice_summary(invoice_id);

ALTER TABLE bridge_invoice_track
ADD CONSTRAINT fk_track_sk FOREIGN KEY (track_sk)
REFERENCES dim_track(track_sk);
