--1 bulan apa yang memiliki transaksi terbesar pada tahun 2021
SELECT 
	EXTRACT (MONTH FROM order_date) AS bulan, 
	SUM(after_discount) AS total_transaksi
FROM 
	order_detail
WHERE
	EXTRACT (YEAR FROM order_date) = 2021 
    AND is_valid = 1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3

--2. transaksi tahun 2022 kategori apa yg menghasilkan nilai transaksi paling besar?
SELECT
sd.category AS kategori,
round(SUM(after_discount)) AS total_transaksi
FROM
	order_detail as od
LEFT JOIN
	sku_detail as sd 
    ON od.sku_id = sd.id
WHERE
	EXTRACT(YEAR FROM order_date) = 2022
AND is_valid = 1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3

-- 3. Sebutkan kategori apa saja yang mengalami peningkatan dan kategori 
-- apa yang mengalami penurunan nilai transaksi dari tahun 2021 ke 2022.
WITH kategori_pertahun AS (
SELECT
  sd.category AS kategori,
  SUM(CASE WHEN EXTRACT(YEAR FROM od.order_date) = 2021 THEN after_discount END) AS transaksi_2021,
  SUM(CASE WHEN EXTRACT(YEAR FROM od.order_date) = 2022 THEN after_discount END) AS transaksi_2022
FROM order_detail AS od
LEFT JOIN sku_detail AS sd
ON od.sku_id = sd.id
WHERE is_valid = 1
AND EXTRACT (YEAR FROM od.order_date) IN (2021,2022)
GROUP BY 1
)
SELECT
kategori,
transaksi_2021,
transaksi_2022,
CASE WHEN transaksi_2022 - transaksi_2021 < 0 THEN 'Penurunan'
ELSE 'Kenaikan'
END AS Status
FROM kategori_pertahun
ORDER BY 4 DESC

--4. Tampilkan top 5 metode pembayaran yang paling populer digunakan selama 2022
SELECT
pd.payment_method,
COUNT(DISTINCT od.id) AS total_transaksi
FROM order_detail AS od
LEFT JOIN payment_detail AS pd
ON od.payment_id = pd.id
WHERE 
is_valid = 1 AND
EXTRACT (YEAR FROM od.order_date) = 2022
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--5. Urutkan dari ke-5 produk ini :
-- 1)samsung 2)apple 3)sony 4)huawei 5)lenovo
with brand AS (
SELECT
CASE
	WHEN LOWER(sd.sku_name) LIKE '%samsung' THEN 'Samsung'
  	WHEN LOWER(sd.sku_name) LIKE '%apple%' OR LOWER(sd.sku_name) LIKE '%iphone%'
  	OR LOWER(sd.sku_name) LIKE '%ipads%' OR LOWER(sd.sku_name) LIKE '%macbook%' THEN 'Apple'
  	WHEN LOWER(sd.sku_name) LIKE '%sony%' THEN 'Sony' 
  	WHEN LOWER(sd.sku_name) LIKE '%huawei%' THEN 'Huawei'
  	WHEN LOWER(sd.sku_name) LIKE '%lenovo%' THEN 'Lenovo'
  END AS product_name,
  SUM(od.after_discount) total_sales
FROM
	order_detail od
LEFT JOIN
  sku_detail sd
ON od.sku_id = sd.id
WHERE
is_valid = 1
GROUP BY 1
ORDER BY 2 DESC
)
SELECT * FROM brand
where product_name IS NOT NULL
ORDER BY total_sales DESC