DROP MATERIALIZED VIEW IF EXISTS hpce.mv_product_popularity;

CREATE MATERIALIZED VIEW hpce.mv_product_popularity AS
SELECT
  oi.product_id,
  p.product_category_name,
  COUNT(*) AS n_items,
  AVG(oi.price) AS avg_price
FROM hpce.olist_order_items oi
JOIN hpce.olist_products p
  ON p.product_id = oi.product_id
GROUP BY 1,2;

CREATE INDEX IF NOT EXISTS idx_mv_product_popularity_pid
ON hpce.mv_product_popularity(product_id);

CREATE INDEX IF NOT EXISTS idx_mv_product_popularity_cat
ON hpce.mv_product_popularity(product_category_name);
