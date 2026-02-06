DROP TABLE IF EXISTS hpce.synthetic_event_features_daily;

CREATE TABLE hpce.synthetic_event_features_daily AS
WITH spine AS (
  SELECT customer_id, feature_date
  FROM hpce.customer_features_daily
  WHERE feature_date BETWEEN '2018-06-01' AND '2018-08-04'
),
e AS (
  SELECT
    s.customer_id,
    s.feature_date,
    COALESCE(d.views,0) AS views,
    COALESCE(d.searches,0) AS searches,
    COALESCE(d.carts,0) AS carts,
    COALESCE(d.events_total,0) AS events_total,
    d.last_event_time
  FROM spine s
  LEFT JOIN hpce.synthetic_events_daily d
    ON d.customer_id = s.customer_id
   AND d.feature_date = s.feature_date
),
r AS (
  SELECT
    *,
    SUM(views) OVER (PARTITION BY customer_id ORDER BY feature_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)  AS views_7,
    SUM(views) OVER (PARTITION BY customer_id ORDER BY feature_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS views_30,
    SUM(searches) OVER (PARTITION BY customer_id ORDER BY feature_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS searches_30,
    SUM(carts) OVER (PARTITION BY customer_id ORDER BY feature_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS carts_30,
    SUM(events_total) OVER (PARTITION BY customer_id ORDER BY feature_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS events_30,

    MAX(CASE WHEN events_total > 0 THEN feature_date END) OVER
      (PARTITION BY customer_id ORDER BY feature_date) AS last_event_date
  FROM e
)
SELECT
  customer_id,
  feature_date,
  views_7,
  views_30,
  searches_30,
  carts_30,
  events_30,
  carts_30::float / NULLIF(views_30,0) AS cart_to_view_rate_30,
  COALESCE((feature_date - last_event_date), 999) AS event_recency_days
FROM r;

CREATE INDEX IF NOT EXISTS idx_sefd_key
ON hpce.synthetic_event_features_daily(customer_id, feature_date);
