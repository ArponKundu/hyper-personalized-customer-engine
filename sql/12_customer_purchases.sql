DROP TABLE IF EXISTS hpce.customer_purchases;

CREATE TABLE hpce.customer_purchases AS
SELECT DISTINCT
  customer_id,
  feature_date AS purchase_date
FROM hpce.customer_features_daily
WHERE daily_orders > 0;

CREATE INDEX IF NOT EXISTS idx_customer_purchases
ON hpce.customer_purchases(customer_id, purchase_date);
