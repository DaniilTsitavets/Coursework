--Какие жанры чаще всего покупаются?
SELECT
  g.name AS genre,
  COUNT(*) AS purchase_count
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY g.name
ORDER BY purchase_count DESC;

--Средний чек по городам
SELECT
  billing_city,
  AVG(total) AS average_invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY average_invoice_total DESC;

--Какие клиенты оформили больше всего заказов?
SELECT
  c.first_name,
  c.last_name,
  COUNT(i.invoice_id) AS invoice_count
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY invoice_count DESC;
