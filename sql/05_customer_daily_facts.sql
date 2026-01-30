DROP TABLE IF EXISTS hpce.customer_daily_facts;

CREATE TABLE hpce.customer_daily_facts AS
WITH order_value AS (
  SELECT order_id, SUM(price + freight_value) AS order_total_value
  FROM staging.olist_order_items
  GROUP BY order_id
)
SELECT
  v.customer_uid,
  v.purchase_date AS feature_date,
  COUNT(DISTINCT v.order_id) AS daily_orders,
  COALESCE(SUM(ov.order_total_value),0) AS daily_spend
FROM hpce.orders_valid v
LEFT JOIN order_value ov
  ON ov.order_id = v.order_id
GROUP BY v.customer_uid, v.purchase_date;

CREATE INDEX IF NOT EXISTS idx_customer_daily_facts_uid
ON hpce.customer_daily_facts(customer_uid, feature_date);
