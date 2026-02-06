DROP TABLE IF EXISTS hpce.orders_valid;

CREATE TABLE hpce.orders_valid AS
SELECT
  o.order_id,
  m.customer_unique_id AS customer_uid,
  o.order_purchase_timestamp::date AS purchase_date,
  o.order_purchase_timestamp AS purchase_ts
FROM hpce.olist_orders o
JOIN hpce.customer_map m
  ON m.customer_id = o.customer_id
WHERE o.order_status NOT IN ('canceled','unavailable')
  AND o.order_purchase_timestamp IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_orders_valid_uid_date
ON hpce.orders_valid(customer_uid, purchase_date);
