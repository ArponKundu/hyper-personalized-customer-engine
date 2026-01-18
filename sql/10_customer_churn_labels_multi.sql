CREATE TABLE hpce.customer_churn_labels_multi AS
WITH obs AS (
  SELECT LEAST(
    (SELECT MAX(feature_date)::date FROM hpce.customer_features_daily),
    (SELECT MAX(event_time)::date FROM hpce.rees46_events)
  ) AS obs_end
),
last_order AS (
  SELECT
    customer_id,
    MAX(feature_date)::date FILTER (WHERE daily_orders > 0) AS last_order_date
  FROM hpce.customer_features_daily
  GROUP BY customer_id
),
base AS (
  SELECT
    l.customer_id,
    o.obs_end,
    l.last_order_date,
    CASE
      WHEN l.last_order_date IS NULL THEN 999
      ELSE (o.obs_end::date - l.last_order_date::date)
    END AS days_since_last_order
  FROM last_order l
  CROSS JOIN obs o
)
SELECT
  customer_id,
  obs_end,
  last_order_date,
  days_since_last_order,
  CASE WHEN days_since_last_order = 999 OR days_since_last_order > 30 THEN 1 ELSE 0 END AS churn_30d,
  CASE WHEN days_since_last_order = 999 OR days_since_last_order > 60 THEN 1 ELSE 0 END AS churn_60d,
  CASE WHEN days_since_last_order = 999 OR days_since_last_order > 90 THEN 1 ELSE 0 END AS churn_90d
FROM base;
