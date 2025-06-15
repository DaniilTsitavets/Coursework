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
  SELECT 1 FROM album al
  WHERE al.artist_id = a.artist_id AND LOWER(TRIM(al.title)) = LOWER(TRIM(sd.title))
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
WITH ranked AS (
  SELECT
    first_name, last_name, address, city, country, phone, email,
    ROW_NUMBER() OVER (PARTITION BY email, phone ORDER BY invoice_date DESC, ctid DESC) AS rn
  FROM staging_data
)
INSERT INTO customer (
  first_name, last_name, address, city, country, phone, email
)
SELECT
  first_name, last_name, address, city, country, phone, email
FROM ranked
WHERE rn = 1
ON CONFLICT (email, phone) DO UPDATE
SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  address = EXCLUDED.address,
  city = EXCLUDED.city,
  country = EXCLUDED.country;


-- Invoice
WITH deduplicated AS (
  SELECT DISTINCT ON (
    email, phone, invoice_date, billing_address, billing_city, billing_country,
    track_name, media_type_name, unit_price, quantity
  )
    *
  FROM staging_data
  ORDER BY
    email, phone, invoice_date, billing_address, billing_city, billing_country,
    track_name, media_type_name, unit_price, quantity,
    ctid
),
invoices AS (
  SELECT
    c.customer_id,
    d.invoice_date,
    d.billing_address,
    d.billing_city,
    d.billing_country,
    SUM(d.unit_price * d.quantity) AS recalculated_total
  FROM deduplicated d
  JOIN customer c
    ON LOWER(TRIM(c.email)) = LOWER(TRIM(d.email))
    AND TRIM(c.phone) = TRIM(d.phone)
  GROUP BY
    c.customer_id,
    d.invoice_date,
    d.billing_address,
    d.billing_city,
    d.billing_country
)
INSERT INTO invoice (
  customer_id, invoice_date, billing_address, billing_city, billing_country, total
)
SELECT *
FROM invoices
ON CONFLICT (customer_id, invoice_date) DO UPDATE
SET total = EXCLUDED.total;

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
JOIN invoice i ON i.customer_id = c.customer_id AND i.invoice_date = sd.invoice_date
JOIN artist a ON LOWER(TRIM(REPLACE(a.name, '"', ''))) = LOWER(TRIM(REPLACE(sd.artist_name, '"', '')))
JOIN album al ON LOWER(TRIM(REPLACE(al.title, '"', ''))) = LOWER(TRIM(REPLACE(sd.title, '"', ''))) AND al.artist_id = a.artist_id
JOIN track t ON LOWER(TRIM(REPLACE(t.name, '"', ''))) = LOWER(TRIM(REPLACE(sd.track_name, '"', '')))
           AND t.album_id = al.album_id
           AND t.unit_price = sd.unit_price
ON CONFLICT (invoice_id, track_id) DO UPDATE
SET quantity = EXCLUDED.quantity;

TRUNCATE TABLE staging_data;

COMMIT;
