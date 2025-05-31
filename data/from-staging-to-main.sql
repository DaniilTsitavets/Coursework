BEGIN;

-- Artist
INSERT INTO artist (name)
SELECT DISTINCT REPLACE(TRIM(sd.artist_name), '"', '')
FROM staging_data sd
WHERE NOT EXISTS (
  SELECT 1 FROM artist a
  WHERE LOWER(TRIM(a.name)) = LOWER(TRIM(sd.artist_name))
);

-- Album
INSERT INTO album (title, artist_id)
SELECT DISTINCT REPLACE(TRIM(sd.title), '"', ''),
       a.artist_id
FROM staging_data sd
JOIN artist a ON LOWER(TRIM(REPLACE(a.name, '"', ''))) = LOWER(TRIM(REPLACE(sd.artist_name, '"', '')))
WHERE NOT EXISTS (
  SELECT 1 FROM genre g
  WHERE LOWER(TRIM(g.name)) = LOWER(TRIM(sd.genre_name))
);

-- Genre
INSERT INTO genre (name)
SELECT DISTINCT REPLACE(TRIM(sd.genre_name), '"', '')
FROM staging_data sd
WHERE NOT EXISTS (
  SELECT 1 FROM genre g
  WHERE LOWER(TRIM(g.name)) = LOWER(TRIM(sd.genre_name))
);

-- Media Type
INSERT INTO media_type (name)
SELECT DISTINCT REPLACE(TRIM(sd.media_type_name), '"', '')
FROM staging_data sd
WHERE NOT EXISTS (
  SELECT 1 FROM media_type m
  WHERE LOWER(TRIM(m.name)) = LOWER(TRIM(sd.media_type_name))
);

-- Customer
INSERT INTO customer (first_name, last_name, address, city, country, phone, email)
SELECT DISTINCT sd.first_name, sd.last_name, sd.address, sd.city, sd.country, sd.phone, sd.email
FROM staging_data sd
WHERE NOT EXISTS (
  SELECT 1 FROM customer c
  WHERE LOWER(TRIM(c.email)) = LOWER(TRIM(sd.email))
);

-- Invoice
INSERT INTO invoice (customer_id, invoice_date, billing_address, billing_city, billing_country, total)
SELECT DISTINCT
  c.customer_id,
  sd.invoice_date,
  sd.billing_address,
  sd.billing_city,
  sd.billing_country,
  sd.total
FROM staging_data sd
JOIN customer c ON LOWER(TRIM(REPLACE(c.email, '"', ''))) = LOWER(TRIM(REPLACE(sd.email, '"', '')))
WHERE NOT EXISTS (
  SELECT 1 FROM invoice i
  WHERE i.customer_id = c.customer_id
    AND i.invoice_date = sd.invoice_date
    AND i.total = sd.total
);

-- Track
INSERT INTO track (name, album_id, media_type_id, genre_id, unit_price)
SELECT DISTINCT
  REPLACE(TRIM(sd.track_name), '"', ''),
  al.album_id,
  mt.media_type_id,
  g.genre_id,
  sd.unit_price
FROM staging_data sd
JOIN artist a ON LOWER(TRIM(REPLACE(a.name, '"', ''))) = LOWER(TRIM(REPLACE(sd.artist_name, '"', '')))
JOIN album al ON LOWER(TRIM(REPLACE(al.title, '"', ''))) = LOWER(TRIM(REPLACE(sd.title, '"', ''))) AND al.artist_id = a.artist_id
JOIN media_type mt ON LOWER(TRIM(REPLACE(mt.name, '"', ''))) = LOWER(TRIM(REPLACE(sd.media_type_name, '"', '')))
LEFT JOIN genre g ON LOWER(TRIM(REPLACE(g.name, '"', ''))) = LOWER(TRIM(REPLACE(sd.genre_name, '"', '')))
WHERE NOT EXISTS (
  SELECT 1 FROM track t
  WHERE LOWER(TRIM(t.name)) = LOWER(TRIM(sd.track_name))
    AND t.album_id = al.album_id
    AND t.media_type_id = mt.media_type_id
    AND t.unit_price = sd.unit_price
);

-- Invoice Line
INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
SELECT DISTINCT
  i.invoice_id,
  t.track_id,
  sd.unit_price,
  sd.quantity
FROM staging_data sd
JOIN customer c ON LOWER(TRIM(REPLACE(c.email, '"', ''))) = LOWER(TRIM(REPLACE(sd.email, '"', '')))
JOIN invoice i ON i.customer_id = c.customer_id
             AND i.invoice_date = sd.invoice_date
             AND i.total = sd.total
JOIN artist a ON LOWER(TRIM(REPLACE(a.name, '"', ''))) = LOWER(TRIM(REPLACE(sd.artist_name, '"', '')))
JOIN album al ON LOWER(TRIM(REPLACE(al.title, '"', ''))) = LOWER(TRIM(REPLACE(sd.title, '"', ''))) AND al.artist_id = a.artist_id
JOIN track t ON LOWER(TRIM(REPLACE(t.name, '"', ''))) = LOWER(TRIM(REPLACE(sd.track_name, '"', '')))
           AND t.album_id = al.album_id
           AND t.unit_price = sd.unit_price
WHERE NOT EXISTS (
  SELECT 1 FROM invoice_line il
  WHERE il.invoice_id = i.invoice_id
    AND il.track_id = t.track_id
    AND il.unit_price = sd.unit_price
    AND il.quantity = sd.quantity
);

TRUNCATE TABLE staging_data;

COMMIT;
