DROP TABLE IF EXISTS hpce.customer_map;

CREATE TABLE hpce.customer_map AS
SELECT DISTINCT
  customer_id,
  customer_unique_id
FROM hpce.olist_customers;

CREATE INDEX IF NOT EXISTS idx_customer_map_customer_id
ON hpce.customer_map(customer_id);

CREATE INDEX IF NOT EXISTS idx_customer_map_unique_id
ON hpce.customer_map(customer_unique_id);
