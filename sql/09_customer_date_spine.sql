DROP TABLE IF EXISTS hpce.customer_date_spine;

CREATE TABLE hpce.customer_date_spine AS
SELECT
  b.customer_uid,
  gs::date AS feature_date
FROM hpce.customer_bounds b
CROSS JOIN LATERAL generate_series(b.first_date, b.last_date, interval '1 day') gs;

CREATE INDEX IF NOT EXISTS idx_customer_date_spine_uid
ON hpce.customer_date_spine(customer_uid, feature_date);
