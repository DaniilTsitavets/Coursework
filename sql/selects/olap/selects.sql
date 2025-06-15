--Какие исполнители были самыми прибыльными в прошлом году (по общей выручке)?
SELECT
  dt.year,
  dtrk.artist_name,
  SUM(fs.total) AS total_revenue
FROM fact_sales fs
JOIN dim_time dt ON fs.time_sk = dt.time_sk
JOIN dim_track dtrk ON fs.track_sk = dtrk.track_sk
WHERE dt.year = EXTRACT(YEAR FROM CURRENT_DATE) - 1
GROUP BY dt.year, dtrk.artist_name
ORDER BY total_revenue DESC
LIMIT 10;

--инвойсов 2 года назад
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

--Топ-5 самых покупаемых треков всех времён (по количеству проданных единиц)
SELECT
  dtrk.track_name,
  dtrk.artist_name,
  SUM(fs.quantity) AS total_quantity
FROM fact_sales fs
JOIN dim_track dtrk ON fs.track_sk = dtrk.track_sk
GROUP BY dtrk.track_name, dtrk.artist_name
ORDER BY total_quantity DESC
LIMIT 5;

