INSERT INTO hpce.mvp_recommendations_daily
(customer_id, feature_date, strategy, product_id, product_category_name, score, reason)
SELECT
  DISTINCT d.customer_id AS customer_id,
  d.feature_date,
  'RETENTION_LAST_CATEGORY' AS strategy,
  tp.product_id,
  tp.product_category_name,
  tp.n_items::double precision AS score,
  'Top products in customer last purchased category (as-of snapshot)' AS reason
FROM hpce.decision_engine_output_daily d
JOIN hpce.customer_last_category_asof_daily lc
  ON lc.customer_unique_id = d.customer_id
 AND lc.feature_date = d.feature_date
JOIN hpce.mv_top_products_by_category tp
  ON tp.product_category_name = lc.last_category
 AND tp.rn <= 10
WHERE lower(d.action) LIKE '%retention%';



WITH co_top AS (
  SELECT
    cat_a,
    cat_b,
    n_orders_together,
    ROW_NUMBER() OVER (PARTITION BY cat_a ORDER BY n_orders_together DESC) AS rn
  FROM hpce.mv_category_cooccur
),
recs AS (
  SELECT
    d.customer_id,
    d.feature_date,
    'CROSS_SELL' AS strategy,
    tp.product_id,
    tp.product_category_name,
    (co.n_orders_together::double precision * 0.7 +
     tp.n_items::double precision * 0.3) AS score,
    'Cross-sell from categories frequently bought with last category' AS reason
  FROM hpce.decision_engine_output_daily d
  JOIN hpce.customer_segments_snapshot s
    ON s.customer_id = d.customer_id
   AND s.feature_date = d.feature_date
  JOIN hpce.customer_last_category_asof_daily lc
    ON lc.customer_unique_id = d.customer_id
   AND lc.feature_date = d.feature_date
  JOIN co_top co
    ON co.cat_a = lc.last_category
   AND co.rn <= 3
  JOIN hpce.mv_top_products_by_category tp
    ON tp.product_category_name = co.cat_b
   AND tp.rn <= 5
  WHERE s.segment_name IN ('Loyal Champions','Growth Potential')
),
ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id, feature_date
      ORDER BY score DESC
    ) AS rn
  FROM recs
)

INSERT INTO hpce.mvp_recommendations_daily
(customer_id, feature_date, strategy, product_id,
 product_category_name, score, reason)

SELECT
  customer_id,
  feature_date,
  strategy,
  product_id,
  product_category_name,
  score,
  reason
FROM ranked
WHERE rn <= 10

ON CONFLICT (customer_id, feature_date, strategy, product_id)
DO NOTHING;


WITH global_top AS (
  SELECT
    product_id,
    product_category_name,
    n_items,
    ROW_NUMBER() OVER (ORDER BY n_items DESC) AS rn
  FROM hpce.mv_product_popularity
),
recs AS (
  SELECT
    d.customer_id,
    d.feature_date,
    'POPULAR_OVERALL' AS strategy,
    gt.product_id,
    gt.product_category_name,
    gt.n_items::double precision AS score,
    'Fallback: overall most popular products' AS reason
  FROM hpce.decision_engine_output_daily d
  JOIN global_top gt
    ON gt.rn <= 50
),
ranked AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY customer_id, feature_date ORDER BY score DESC) AS rn2
  FROM recs
)
INSERT INTO hpce.mvp_recommendations_daily
(customer_id, feature_date, strategy, product_id, product_category_name, score, reason)
SELECT customer_id, feature_date, strategy, product_id, product_category_name, score, reason
FROM ranked
WHERE rn2 <= 10;

INSERT INTO hpce.mvp_recommendations_daily
(customer_id, feature_date, strategy, product_id, product_category_name, score, reason)
SELECT
  DISTINCT d.customer_id,
  d.feature_date,
  'ENGAGEMENT_LAST_CATEGORY' AS strategy,
  tp.product_id,
  tp.product_category_name,
  tp.n_items::double precision AS score,
  'Engagement: top products in customer last category (as-of snapshot)' AS reason
FROM hpce.decision_engine_output_daily d
JOIN hpce.customer_last_category_asof_daily lc
  ON lc.customer_unique_id = d.customer_id
 AND lc.feature_date = d.feature_date
JOIN hpce.mv_top_products_by_category tp
  ON tp.product_category_name = lc.last_category
 AND tp.rn <= 10
WHERE lower(d.action) LIKE '%engagement%';


WITH cheap_pop AS (
  SELECT
    product_id,
    product_category_name,
    n_items,
    avg_price,
    ROW_NUMBER() OVER (ORDER BY avg_price ASC, n_items DESC) AS rn
  FROM hpce.mv_product_popularity
  WHERE avg_price IS NOT NULL
)
INSERT INTO hpce.mvp_recommendations_daily
(customer_id, feature_date, strategy, product_id, product_category_name, score, reason)
SELECT
  d.customer_id,
  d.feature_date,
  'WINBACK_LOW_PRICE' AS strategy,
  c.product_id,
  c.product_category_name,
  (c.n_items::double precision * 0.2 + (1.0 / NULLIF(c.avg_price,0)) * 0.8) AS score,
  'Win-back: cheaper popular items to reduce friction' AS reason
FROM hpce.decision_engine_output_daily d
JOIN hpce.customer_segments_snapshot s
  ON s.customer_id = d.customer_id
 AND s.feature_date = d.feature_date
JOIN cheap_pop c
  ON c.rn <= 10
WHERE s.segment_name IN ('Dormant / Low-Value');
