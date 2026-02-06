INSERT INTO hpce.intervention_outcomes_daily
(
  customer_id, feature_date, action, segment_name, churn_prob, risk_band,
  responded_14d, orders_14d, revenue_14d, time_to_next_order_days,
  churn_30d
)
WITH base AS (
  SELECT
    a.customer_id,
    a.feature_date,
    a.action,
    COALESCE(a.segment_name, 'Unknown') AS segment_name,
    a.churn_prob,
    a.risk_band,
    m.customer_id AS olist_customer_id
  FROM hpce.action_pack_daily a
  JOIN hpce.customer_map m
    ON m.customer_unique_id = a.customer_id
),
post_orders AS (
  SELECT
    b.customer_id,
    b.feature_date,
    MIN(o.order_purchase_ts::date) AS next_order_date,
    COUNT(DISTINCT o.order_id) FILTER (
      WHERE o.order_purchase_ts::date >= b.feature_date
        AND o.order_purchase_ts::date < b.feature_date + INTERVAL '14 day'
    ) AS orders_14d
  FROM base b
  LEFT JOIN hpce.olist_orders o
    ON o.customer_id = b.olist_customer_id
   AND o.order_status NOT IN ('canceled','unavailable')
   AND o.order_purchase_ts IS NOT NULL
   AND o.order_purchase_ts::date >= b.feature_date
   AND o.order_purchase_ts::date < b.feature_date + INTERVAL '90 day'
  GROUP BY 1,2
),
revenue AS (
  SELECT
    b.customer_id,
    b.feature_date,
    COALESCE(SUM(oi.price + oi.freight_value),0.0) AS revenue_14d
  FROM base b
  LEFT JOIN hpce.olist_orders o
    ON o.customer_id = b.olist_customer_id
   AND o.order_status NOT IN ('canceled','unavailable')
   AND o.order_purchase_ts IS NOT NULL
   AND o.order_purchase_ts::date >= b.feature_date
   AND o.order_purchase_ts::date < b.feature_date + INTERVAL '14 day'
  LEFT JOIN hpce.olist_order_items oi
    ON oi.order_id = o.order_id
  GROUP BY 1,2
),
labels AS (
  SELECT
    customer_id,
    snapshot_date AS feature_date,
    churn_30d
  FROM hpce.customer_churn_labels_by_snapshot
)
SELECT
  a.customer_id,
  a.feature_date,
  a.action,
  COALESCE(a.segment_name, 'Unknown') AS segment_name,
  a.churn_prob,
  a.risk_band,

  CASE WHEN p.orders_14d > 0 THEN 1 ELSE 0 END AS responded_14d,
  p.orders_14d,
  r.revenue_14d,
  CASE
    WHEN p.next_order_date IS NULL THEN NULL
    ELSE (p.next_order_date - a.feature_date)
  END::int AS time_to_next_order_days,

  l.churn_30d
FROM hpce.action_pack_daily a
LEFT JOIN post_orders p
  ON p.customer_id = a.customer_id AND p.feature_date = a.feature_date
LEFT JOIN revenue r
  ON r.customer_id = a.customer_id AND r.feature_date = a.feature_date
LEFT JOIN labels l
  ON l.customer_id = a.customer_id AND l.feature_date = a.feature_date
ON CONFLICT (customer_id, feature_date) DO NOTHING;
