DROP TABLE IF EXISTS hpce.customer_bounds;

CREATE TABLE hpce.customer_bounds AS
SELECT
  customer_uid,
  MIN(purchase_date) AS first_date,
  MAX(purchase_date) AS last_date
FROM hpce.orders_valid
GROUP BY customer_uid;

CREATE INDEX IF NOT EXISTS idx_customer_bounds_uid
ON hpce.customer_bounds(customer_uid);
