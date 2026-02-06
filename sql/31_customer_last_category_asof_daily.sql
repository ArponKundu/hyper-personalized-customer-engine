DROP TABLE IF EXISTS hpce.customer_last_category_asof_daily;

CREATE TABLE hpce.customer_last_category_asof_daily AS
SELECT
  d.customer_id::text AS customer_unique_id,
  d.feature_date::date AS feature_date,
  COALESCE(lc.last_category, 'COLD_START') AS last_category
FROM hpce.decision_engine_output_daily d
JOIN hpce.customer_map m
  ON m.customer_unique_id::text = d.customer_id::text
LEFT JOIN LATERAL (
  SELECT p.product_category_name AS last_category
  FROM hpce.olist_orders o
  JOIN hpce.olist_order_items oi ON oi.order_id = o.order_id
  JOIN hpce.olist_products p ON p.product_id = oi.product_id
  WHERE o.customer_id = m.customer_id
    AND o.order_status NOT IN ('canceled','unavailable')
    AND o.order_purchase_ts IS NOT NULL
    AND o.order_purchase_ts::date < d.feature_date::date
    AND p.product_category_name IS NOT NULL
  ORDER BY o.order_purchase_ts DESC
  LIMIT 1
) lc ON TRUE;

CREATE INDEX IF NOT EXISTS idx_lastcat_unique_date
ON hpce.customer_last_category_asof_daily(customer_unique_id, feature_date);

CREATE INDEX IF NOT EXISTS idx_lastcat_category
ON hpce.customer_last_category_asof_daily(last_category);
