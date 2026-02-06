DROP TABLE IF EXISTS hpce.final_recommendations_daily;

CREATE TABLE hpce.final_recommendations_daily (
  customer_id TEXT NOT NULL,
  feature_date DATE NOT NULL,
  product_id TEXT NOT NULL,
  product_category_name TEXT,
  strategy TEXT NOT NULL,
  score DOUBLE PRECISION,
  reason TEXT,
  rank INT NOT NULL,
  PRIMARY KEY (customer_id, feature_date, rank)
);

CREATE INDEX IF NOT EXISTS idx_final_recs_customer_date
ON hpce.final_recommendations_daily(customer_id, feature_date);


INSERT INTO hpce.final_recommendations_daily
(customer_id, feature_date, product_id, product_category_name, strategy, score, reason, rank)
WITH base AS (
  SELECT
    r.*,
    CASE
      WHEN r.strategy = 'RETENTION_LAST_CATEGORY' THEN 1
      WHEN r.strategy = 'CROSS_SELL' THEN 2
      WHEN r.strategy = 'ENGAGEMENT_LAST_CATEGORY' THEN 3
      WHEN r.strategy = 'WINBACK_LOW_PRICE' THEN 4
      WHEN r.strategy IN ('POPULAR_OVERALL','POPULAR_OVERALL_FALLBACK','FALLBACK_GLOBAL_POPULAR') THEN 5
      ELSE 99
    END AS strategy_priority
  FROM hpce.mvp_recommendations_daily r
),
dedup AS (
  -- If same product appears in multiple strategies for same customer/date,
  -- keep the best (lowest priority number, then highest score).
  SELECT *
  FROM (
    SELECT
      b.*,
      ROW_NUMBER() OVER (
        PARTITION BY customer_id, feature_date, product_id
        ORDER BY strategy_priority ASC, score DESC NULLS LAST
      ) AS keep_one
    FROM base b
  ) x
  WHERE keep_one = 1
),
ranked AS (
  SELECT
    d.customer_id,
    d.feature_date,
    d.product_id,
    d.product_category_name,
    d.strategy,
    d.score,
    d.reason,
    ROW_NUMBER() OVER (
      PARTITION BY d.customer_id, d.feature_date
      ORDER BY d.strategy_priority ASC, d.score DESC NULLS LAST, d.product_id
    ) AS rn
  FROM dedup d
)
SELECT
  customer_id, feature_date, product_id, product_category_name,
  strategy, score, reason,
  rn AS rank
FROM ranked
WHERE rn <= 10;

