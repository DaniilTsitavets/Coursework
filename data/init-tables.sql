CREATE TABLE IF NOT EXISTS staging_data (
    title VARCHAR(160),
    artist_name VARCHAR(120),
    first_name VARCHAR(40),
    last_name VARCHAR(20),
    address VARCHAR(70),
    city VARCHAR(40),
    country VARCHAR(40),
    phone VARCHAR(24),
    email VARCHAR(60),
    genre_name VARCHAR(120),
    invoice_date TIMESTAMP,
    billing_address VARCHAR(70),
    billing_city VARCHAR(40),
    billing_country VARCHAR(40),
    total NUMERIC(10,2),
    track_name VARCHAR(200),
    media_type_name VARCHAR(120),
    unit_price NUMERIC(10,2),
    quantity INT
);

CREATE TABLE IF NOT EXISTS artist (
    artist_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(120)
);

CREATE TABLE IF NOT EXISTS album (
    album_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(160) NOT NULL,
    artist_id INT NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);

CREATE TABLE IF NOT EXISTS customer (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    address VARCHAR(70),
    city VARCHAR(40),
    country VARCHAR(40),
    phone VARCHAR(24),
    email VARCHAR(60) NOT NULL
);

CREATE TABLE IF NOT EXISTS genre (
    genre_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(120)
);

CREATE TABLE IF NOT EXISTS media_type (
    media_type_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(120)
);

CREATE TABLE IF NOT EXISTS track (
    track_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    album_id INT,
    media_type_id INT NOT NULL,
    genre_id INT,
    unit_price NUMERIC(10,2) NOT NULL,
    FOREIGN KEY (album_id) REFERENCES album(album_id),
    FOREIGN KEY (media_type_id) REFERENCES media_type(media_type_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

CREATE TABLE IF NOT EXISTS invoice (
    invoice_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL,
    invoice_date TIMESTAMP NOT NULL,
    billing_address VARCHAR(70),
    billing_city VARCHAR(40),
    billing_country VARCHAR(40),
    total NUMERIC(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE IF NOT EXISTS invoice_line (
    invoice_line_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id INT NOT NULL,
    track_id INT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id),
    FOREIGN KEY (track_id) REFERENCES track(track_id)
);
