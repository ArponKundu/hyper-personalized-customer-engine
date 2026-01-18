DROP TABLE IF EXISTS hpce.copurchase_pairs;

CREATE TABLE hpce.copurchase_pairs AS
WITH pairs AS (
  SELECT
    a.product_id AS product_a,
    b.product_id AS product_b,
    COUNT(*) AS n
  FROM hpce.olist_order_items a
  JOIN hpce.olist_order_items b
    ON a.order_id = b.order_id
   AND a.product_id <> b.product_id
  GROUP BY a.product_id, b.product_id
)
SELECT *
FROM pairs;
