--This file is just for comfortable review of coursework
--This file isn't used by terraform or anything else

SELECT dblink_connect('oltp', format(
  'host=%s port=%s dbname=%s user=%s password=%s',
  '${host}', '5432', '${db_name}', '${user}', '${password}'
));

WITH oltp_customers AS (
  SELECT *
  FROM dblink('oltp', 'SELECT customer_id, first_name, last_name, city, country, email FROM customer')
  AS t(customer_id INT, first_name VARCHAR, last_name VARCHAR, city VARCHAR, country VARCHAR, email VARCHAR)
),
joined AS (
  SELECT c.*, d.customer_sk, d.first_name AS old_first_name, d.last_name AS old_last_name,
         d.city AS old_city, d.country AS old_country, d.email AS old_email
  FROM oltp_customers c
  LEFT JOIN dim_customer d
    ON c.customer_id = d.customer_id AND d.is_current = true
),
changed_customers AS (
  SELECT *
  FROM joined
  WHERE customer_sk IS NOT NULL
    AND (
      old_first_name IS DISTINCT FROM first_name
      OR old_last_name IS DISTINCT FROM last_name
      OR old_city IS DISTINCT FROM city
      OR old_country IS DISTINCT FROM country
      OR old_email IS DISTINCT FROM email
    )
)
UPDATE dim_customer
SET end_date = current_date - 1,
    is_current = false
FROM changed_customers cc
WHERE dim_customer.customer_id = cc.customer_id
  AND dim_customer.is_current = true;

WITH oltp_customers AS (
  SELECT *
  FROM dblink('oltp', 'SELECT customer_id, first_name, last_name, city, country, email FROM customer')
  AS t(customer_id INT, first_name VARCHAR, last_name VARCHAR, city VARCHAR, country VARCHAR, email VARCHAR)
),
joined AS (
  SELECT c.*, d.customer_sk, d.first_name AS old_first_name, d.last_name AS old_last_name,
         d.city AS old_city, d.country AS old_country, d.email AS old_email
  FROM oltp_customers c
  LEFT JOIN dim_customer d
    ON c.customer_id = d.customer_id AND d.is_current = true
),
changed_customers AS (
  SELECT *
  FROM joined
  WHERE customer_sk IS NULL
     OR (
        old_first_name IS DISTINCT FROM first_name
        OR old_last_name IS DISTINCT FROM last_name
        OR old_city IS DISTINCT FROM city
        OR old_country IS DISTINCT FROM country
        OR old_email IS DISTINCT FROM email
     )
)
INSERT INTO dim_customer (
  customer_id, first_name, last_name, city, country, email, start_date, end_date, is_current
)
SELECT customer_id, first_name, last_name, city, country, email,
       current_date, NULL, true
FROM changed_customers;

WITH oltp_tracks AS (
  SELECT *
  FROM dblink('oltp', $$
    SELECT t.track_id, t.name as track_name, a.title AS album_title,
           ar.name AS artist_name, g.name AS genre_name, mt.name AS media_type, t.unit_price
    FROM track t
    JOIN album a ON t.album_id = a.album_id
    JOIN artist ar ON a.artist_id = ar.artist_id
    LEFT JOIN genre g ON t.genre_id = g.genre_id
    JOIN media_type mt ON t.media_type_id = mt.media_type_id
  $$) AS t(track_id INT, track_name VARCHAR, album_title VARCHAR,
           artist_name VARCHAR, genre_name VARCHAR, media_type VARCHAR, unit_price NUMERIC)
)
INSERT INTO dim_track (track_id, track_name, album_title, artist_name, genre_name, media_type, unit_price)
SELECT track_id, track_name, album_title, artist_name, genre_name, media_type, unit_price
FROM oltp_tracks
ON CONFLICT (track_id, track_name) DO NOTHING;

-- Загрузка dim_time
WITH invoice_dates AS (
  SELECT DISTINCT invoice_date::date AS date
  FROM dblink('oltp', 'SELECT DISTINCT invoice_date FROM invoice')
  AS t(invoice_date TIMESTAMP)
),
normalized_time AS (
  SELECT date,
         EXTRACT(DAY FROM date)::INT AS day,
         EXTRACT(MONTH FROM date)::INT AS month,
         EXTRACT(QUARTER FROM date)::INT AS quarter,
         EXTRACT(YEAR FROM date)::INT AS year
  FROM invoice_dates
)
INSERT INTO dim_time (date, day, month, quarter, year)
SELECT date, day, month, quarter, year
FROM normalized_time
ON CONFLICT (date) DO NOTHING;

WITH invoice_lines AS (
  SELECT *
  FROM dblink('oltp', $$
    SELECT il.invoice_id, il.track_id, il.unit_price, il.quantity, i.customer_id, i.invoice_date
    FROM invoice_line il
    JOIN invoice i ON il.invoice_id = i.invoice_id
  $$) AS t(invoice_id INT, track_id INT, unit_price NUMERIC, quantity INT,
           customer_id INT, invoice_date TIMESTAMP)
),
enriched AS (
  SELECT
    dc.customer_sk,
    dt.track_sk,
    dtime.time_sk,
    il.quantity,
    il.unit_price * il.quantity AS total
  FROM invoice_lines il
  JOIN dim_customer dc ON il.customer_id = dc.customer_id AND dc.is_current = true
  JOIN dim_track dt ON il.track_id = dt.track_id
  JOIN dim_time dtime ON dtime.date = il.invoice_date::date
)
INSERT INTO fact_sales (customer_sk, track_sk, time_sk, quantity, total)
SELECT customer_sk, track_sk, time_sk, quantity, total
FROM enriched
WHERE NOT EXISTS (
  SELECT 1 FROM fact_sales fs
  WHERE fs.customer_sk = enriched.customer_sk
    AND fs.track_sk = enriched.track_sk
    AND fs.time_sk = enriched.time_sk
    AND fs.quantity = enriched.quantity
    AND fs.total = enriched.total
);

WITH invoices AS (
  SELECT *
  FROM dblink('oltp', $$
    SELECT i.invoice_id, i.customer_id, i.invoice_date, i.total,
           (SELECT COUNT(*) FROM invoice_line il WHERE il.invoice_id = i.invoice_id) AS total_items
    FROM invoice i
  $$) AS t(invoice_id INT, customer_id INT, invoice_date TIMESTAMP, total NUMERIC, total_items INT)
),
mapped AS (
  SELECT
    i.invoice_id,
    dc.customer_sk,
    dt.time_sk,
    i.total AS total_amount,
    i.total_items
  FROM invoices i
  JOIN dim_customer dc ON i.customer_id = dc.customer_id AND dc.is_current = true
  JOIN dim_time dt ON dt.date = i.invoice_date::date
)
INSERT INTO fact_invoice_summary (invoice_id, customer_sk, time_sk, total_amount, total_items)
SELECT invoice_id, customer_sk, time_sk, total_amount, total_items
FROM mapped
ON CONFLICT (invoice_id) DO UPDATE
SET customer_sk = EXCLUDED.customer_sk,
    time_sk = EXCLUDED.time_sk,
    total_amount = EXCLUDED.total_amount,
    total_items = EXCLUDED.total_items;

WITH invoice_lines AS (
  SELECT *
  FROM dblink('oltp', 'SELECT invoice_id, track_id, quantity FROM invoice_line')
  AS t(invoice_id INT, track_id INT, quantity INT)
),
joined AS (
  SELECT il.invoice_id, dt.track_sk, il.quantity
  FROM invoice_lines il
  JOIN dim_track dt ON il.track_id = dt.track_id
)
INSERT INTO bridge_invoice_track (invoice_id, track_sk, quantity)
SELECT invoice_id, track_sk, quantity
FROM joined
ON CONFLICT (invoice_id, track_sk) DO UPDATE
SET quantity = EXCLUDED.quantity;

SELECT dblink_disconnect('oltp');
