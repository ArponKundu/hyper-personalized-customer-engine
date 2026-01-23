CREATE OR REPLACE VIEW hpce.customer_latest_churn_score AS
SELECT DISTINCT ON (customer_id)
  customer_id,
  feature_date,
  churn_probability_90d
FROM hpce.churn_scores_daily
ORDER BY customer_id, feature_date DESC;