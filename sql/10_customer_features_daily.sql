DROP TABLE IF EXISTS hpce.customer_features_daily;

CREATE TABLE hpce.customer_features_daily AS
WITH base AS (
  SELECT
    s.customer_uid,
    s.feature_date::date AS feature_date,
    COALESCE(f.daily_orders,0) AS daily_orders,
    COALESCE(f.daily_spend,0)  AS daily_spend
  FROM hpce.customer_date_spine s
  LEFT JOIN hpce.customer_daily_facts f
    ON f.customer_uid = s.customer_uid
   AND f.feature_date = s.feature_date
),
roll AS (
  SELECT
    b.*,
    -- 30-day windows
    SUM(daily_orders) OVER (
      PARTITION BY customer_uid ORDER BY feature_date
      ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS f_30,
    SUM(daily_spend) OVER (
      PARTITION BY customer_uid ORDER BY feature_date
      ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS m_30,
    SUM(daily_orders) OVER (
      PARTITION BY customer_uid ORDER BY feature_date
      ROWS BETWEEN 59 PRECEDING AND 30 PRECEDING
    ) AS f_30_prev30,
    SUM(daily_spend) OVER (
      PARTITION BY customer_uid ORDER BY feature_date
      ROWS BETWEEN 59 PRECEDING AND 30 PRECEDING
    ) AS m_30_prev30,

    -- 60-day windows
    SUM(daily_orders) OVER (
      PARTITION BY customer_uid ORDER BY feature_date
      ROWS BETWEEN 59 PRECEDING AND CURRENT ROW
    ) AS f_60,
    SUM(daily_spend) OVER (
      PARTITION BY customer_uid ORDER BY feature_date
      ROWS BETWEEN 59 PRECEDING AND CURRENT ROW
    ) AS m_60,
    SUM(daily_orders) OVER (
      PARTITION BY customer_uid ORDER BY feature_date
      ROWS BETWEEN 119 PRECEDING AND 60 PRECEDING
    ) AS f_60_prev60,
    SUM(daily_spend) OVER (
      PARTITION BY customer_uid ORDER BY feature_date
      ROWS BETWEEN 119 PRECEDING AND 60 PRECEDING
    ) AS m_60_prev60,

    -- 90-day windows
    SUM(daily_orders) OVER (
      PARTITION BY customer_uid ORDER BY feature_date
      ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
    ) AS f_90,
    SUM(daily_spend) OVER (
      PARTITION BY customer_uid ORDER BY feature_date
      ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
    ) AS m_90,
    SUM(daily_orders) OVER (
      PARTITION BY customer_uid ORDER BY feature_date
      ROWS BETWEEN 179 PRECEDING AND 90 PRECEDING
    ) AS f_90_prev90,
    SUM(daily_spend) OVER (
      PARTITION BY customer_uid ORDER BY feature_date
      ROWS BETWEEN 179 PRECEDING AND 90 PRECEDING
    ) AS m_90_prev90,

    MAX(CASE WHEN daily_orders > 0 THEN feature_date END) OVER
      (PARTITION BY customer_uid ORDER BY feature_date) AS last_purchase_date

  FROM base b
)
SELECT
  customer_uid AS customer_id,
  feature_date,
  daily_orders,
  daily_spend,

  -- 30
  f_30,
  m_30,
  COALESCE(f_30_prev30,0) AS f_30_prev30,
  (f_30 - COALESCE(f_30_prev30,0)) AS f_trend_30,
  COALESCE(m_30_prev30,0) AS m_30_prev30,
  (m_30 - COALESCE(m_30_prev30,0)) AS m_trend_30,

  -- 60
  f_60,
  m_60,
  COALESCE(f_60_prev60,0) AS f_60_prev60,
  (f_60 - COALESCE(f_60_prev60,0)) AS f_trend_60,
  COALESCE(m_60_prev60,0) AS m_60_prev60,
  (m_60 - COALESCE(m_60_prev60,0)) AS m_trend_60,

  -- 90
  f_90,
  m_90,
  COALESCE(f_90_prev90,0) AS f_90_prev90,
  (f_90 - COALESCE(f_90_prev90,0)) AS f_trend_90,
  COALESCE(m_90_prev90,0) AS m_90_prev90,
  (m_90 - COALESCE(m_90_prev90,0)) AS m_trend_90,

  -- recency
  COALESCE((feature_date - last_purchase_date), 999) AS recency_days

FROM roll;

CREATE INDEX IF NOT EXISTS idx_customer_features_daily_key
ON hpce.customer_features_daily(customer_id, feature_date);
