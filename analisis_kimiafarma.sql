[-- Membuat tabel bernama tabel_analisa
CREATE OR REPLACE TABLE 
  kinerja-bisnis-kimia-farma.dataset.tabel_analisa AS

-- Mengambil data dari tabel kf_product
WITH
  price_with_margin AS (
SELECT
  product_id,
  product_name,
  price AS actual_price,
CASE
  WHEN price <= 50000 THEN 0.10
  WHEN price > 50000 AND price <= 100000 THEN 0.15
  WHEN price > 100000 AND price <= 300000 THEN 0.20
  WHEN price > 300000 AND price <= 500000 THEN 0.25
  ELSE 0.30
  END AS persentase_gross_laba
FROM kinerja-bisnis-kimia-farma.dataset.kf_product
),

-- Menggabungkan data transaksi (kf_final_transaction) dengan produk
transaksi_dengan_produk AS (
SELECT
  t.transaction_id,
  t.date,
  t.branch_id,
  t.customer_name,
  t.product_id,
  p.product_name,
  p.actual_price,
  t.discount_percentage,
  p.persentase_gross_laba,
ROUND
  (t.price * (1 - t.discount_percentage / 100), 2) 
AS nett_sales,
ROUND
  ((t.price * (1 - t.discount_percentage / 100)) * p.persentase_gross_laba, 2) 
AS nett_profit,t.rating 
AS rating_transaksi
FROM
  kinerja-bisnis-kimia-farma.dataset.kf_final_transaction t
JOIN 
  price_with_margin p
ON
  t.product_id = p.product_id
),

-- Menggabungkan data transaksi dengan informasi cabang (kf_kantor_cabang).
transaksi_dengan_cabang AS (
SELECT
  tp.transaction_id,
  tp.date,
  tp.branch_id,
  kc.branch_name,
  kc.kota,
  kc.provinsi,
  kc.rating AS rating_cabang,
  tp.customer_name,
  tp.product_id,
  tp.product_name,
  tp.actual_price,
  tp.discount_percentage,
  tp.persentase_gross_laba,
  tp.nett_sales,
  tp.nett_profit,
  tp.rating_transaksi
FROM transaksi_dengan_produk tp
JOIN kinerja-bisnis-kimia-farma.dataset.kf_kantor_cabang kc
ON tp.branch_id = kc.branch_id
)

-- Menampilkan semua kolom dari CTE terakhir
SELECT * FROM transaksi_dengan_cabang;
