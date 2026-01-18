DROP TABLE IF EXISTS hpce.product_recommendations_topn;

CREATE TABLE hpce.product_recommendations_topn AS
SELECT
  product_a,
  product_b,
  n,
  ROW_NUMBER() OVER (PARTITION BY product_a ORDER BY n DESC) AS rank
FROM hpce.copurchase_pairs;

-- keep top 5
DELETE FROM hpce.product_recommendations_topn WHERE rank > 5;
