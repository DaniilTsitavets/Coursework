 SELECT
  dc.customer_id,
  dc.first_name,
  dc.last_name,
  SUM(fis.total_amount) AS total_spent,
  COUNT(fis.invoice_id) AS invoice_count
FROM fact_invoice_summary fis
JOIN dim_customer dc ON fis.customer_sk = dc.customer_sk
WHERE dc.is_current = true
GROUP BY dc.customer_id, dc.first_name, dc.last_name
ORDER BY total_spent DESC
LIMIT 10;


SELECT
  dt.genre_name,
  SUM(fs.total) AS total_sales,
  SUM(fs.quantity) AS total_quantity
FROM fact_sales fs
JOIN dim_track dt ON fs.track_sk = dt.track_sk
JOIN dim_time dtime ON fs.time_sk = dtime.time_sk
WHERE dtime.year = EXTRACT(YEAR FROM CURRENT_DATE) - 2
GROUP BY dt.genre_name
ORDER BY total_sales DESC;


SELECT
  dtime.year,
  dtime.quarter,
  dc.country,
  SUM(fs.total) AS total_sales
FROM fact_sales fs
JOIN dim_customer dc ON fs.customer_sk = dc.customer_sk
JOIN dim_time dtime ON fs.time_sk = dtime.time_sk
WHERE dc.is_current = true
GROUP BY dtime.year, dtime.quarter, dc.country
ORDER BY dtime.year, dtime.quarter, total_sales DESC;
