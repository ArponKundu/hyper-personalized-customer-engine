DROP MATERIALIZED VIEW IF EXISTS hpce.mv_top_products_by_category;

CREATE MATERIALIZED VIEW hpce.mv_top_products_by_category AS
SELECT
  product_category_name,
  product_id,
  n_items,
  avg_price,
  ROW_NUMBER() OVER (
    PARTITION BY product_category_name
    ORDER BY n_items DESC
  ) AS rn
FROM hpce.mv_product_popularity
WHERE product_category_name IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_topprod_cat_rn
ON hpce.mv_top_products_by_category(product_category_name, rn);

CREATE INDEX IF NOT EXISTS idx_topprod_pid
ON hpce.mv_top_products_by_category(product_id);

REFRESH MATERIALIZED VIEW hpce.mv_product_popularity;
REFRESH MATERIALIZED VIEW hpce.mv_category_cooccur;
REFRESH MATERIALIZED VIEW hpce.mv_top_products_by_category;
