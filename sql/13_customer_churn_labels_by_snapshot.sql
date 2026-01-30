DROP TABLE IF EXISTS hpce.customer_churn_labels_by_snapshot;

CREATE TABLE hpce.customer_churn_labels_by_snapshot AS
SELECT
  f.customer_id,
  f.feature_date AS snapshot_date,

  -- churn_30d: no purchase in (snapshot_date+1 .. snapshot_date+30)
  CASE WHEN EXISTS (
    SELECT 1
    FROM hpce.customer_purchases p
    WHERE p.customer_id = f.customer_id
      AND p.purchase_date > f.feature_date
      AND p.purchase_date <= f.feature_date + 30
  ) THEN 0 ELSE 1 END AS churn_30d,

  CASE WHEN EXISTS (
    SELECT 1
    FROM hpce.customer_purchases p
    WHERE p.customer_id = f.customer_id
      AND p.purchase_date > f.feature_date
      AND p.purchase_date <= f.feature_date + 60
  ) THEN 0 ELSE 1 END AS churn_60d,

  CASE WHEN EXISTS (
    SELECT 1
    FROM hpce.customer_purchases p
    WHERE p.customer_id = f.customer_id
      AND p.purchase_date > f.feature_date
      AND p.purchase_date <= f.feature_date + 90
  ) THEN 0 ELSE 1 END AS churn_90d

FROM hpce.customer_features_daily f;

CREATE INDEX IF NOT EXISTS idx_labels_snapshot
ON hpce.customer_churn_labels_by_snapshot(snapshot_date);

CREATE INDEX IF NOT EXISTS idx_labels_customer_snapshot
ON hpce.customer_churn_labels_by_snapshot(customer_id, snapshot_date);
