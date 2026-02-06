DROP MATERIALIZED VIEW IF EXISTS hpce.mv_category_cooccur;

CREATE MATERIALIZED VIEW hpce.mv_category_cooccur AS
WITH order_cats AS (
  SELECT DISTINCT
    oi.order_id,
    p.product_category_name AS cat
  FROM hpce.olist_order_items oi
  JOIN hpce.olist_products p
    ON p.product_id = oi.product_id
  WHERE p.product_category_name IS NOT NULL
),
pairs AS (
  SELECT
    a.cat AS cat_a,
    b.cat AS cat_b,
    COUNT(*) AS n_orders_together
  FROM order_cats a
  JOIN order_cats b
    ON a.order_id = b.order_id
   AND a.cat <> b.cat
  GROUP BY 1,2
)
SELECT * FROM pairs;

CREATE INDEX IF NOT EXISTS idx_mv_category_cooccur_a
ON hpce.mv_category_cooccur(cat_a);

CREATE INDEX IF NOT EXISTS idx_mv_category_cooccur_b
ON hpce.mv_category_cooccur(cat_b);

CREATE INDEX IF NOT EXISTS idx_mv_category_cooccur_a_b
ON hpce.mv_category_cooccur(cat_a, cat_b);

