DROP TABLE IF EXISTS hpce.synthetic_events_daily;

CREATE TABLE hpce.synthetic_events_daily AS
SELECT
  customer_id,
  event_time::date AS feature_date,
  SUM(CASE WHEN event_type='view_product' THEN 1 ELSE 0 END) AS views,
  SUM(CASE WHEN event_type='search' THEN 1 ELSE 0 END) AS searches,
  SUM(CASE WHEN event_type='add_to_cart' THEN 1 ELSE 0 END) AS carts,
  COUNT(*) AS events_total,
  MAX(event_time) AS last_event_time
FROM hpce.synthetic_events_raw
GROUP BY 1,2;

CREATE INDEX IF NOT EXISTS idx_sed_key
ON hpce.synthetic_events_daily(customer_id, feature_date);
