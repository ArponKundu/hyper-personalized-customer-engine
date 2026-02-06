DROP TABLE IF EXISTS hpce.order_value_by_order;

CREATE TABLE hpce.order_value_by_order AS
SELECT
  oi.order_id,
  SUM(oi.price) AS order_items_value,
  SUM(oi.freight_value) AS order_freight_value,
  SUM(oi.price + oi.freight_value) AS order_total_value
FROM hpce.olist_order_items oi
GROUP BY oi.order_id;

CREATE INDEX IF NOT EXISTS idx_order_value_by_order_order
ON hpce.order_value_by_order (order_id);