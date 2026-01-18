DROP TABLE IF EXISTS hpce.product_recommendations_top5;

CREATE TABLE hpce.product_recommendations_top5 AS
SELECT *
FROM (
  SELECT
    product_a,
    product_b,
    n,
    ROW_NUMBER() OVER (PARTITION BY product_a ORDER BY n DESC) AS rank
  FROM hpce.copurchase_pairs
) t
WHERE rank <= 5;
