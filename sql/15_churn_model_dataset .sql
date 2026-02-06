DROP TABLE IF EXISTS hpce.churn_model_dataset;

CREATE TABLE hpce.churn_model_dataset AS
SELECT
  f.*,
  l.churn_30d,
  l.churn_60d,
  l.churn_90d
FROM hpce.customer_features_daily f
JOIN hpce.customer_churn_labels_by_snapshot l
  ON l.customer_id = f.customer_id
 AND l.snapshot_date = f.feature_date;
