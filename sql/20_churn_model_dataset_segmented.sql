DROP TABLE IF EXISTS hpce.churn_model_dataset_segmented;

CREATE TABLE hpce.churn_model_dataset_segmented AS
SELECT
  d.*,
  COALESCE(s.segment_label, 'Unknown') AS segment_label,
  CASE
    WHEN COALESCE(s.segment_label,'Unknown') IN ('Champion','Loyal') THEN 'A_high_value'
    WHEN COALESCE(s.segment_label,'Unknown') = 'Recent' THEN 'B_recent'
    WHEN COALESCE(s.segment_label,'Unknown') IN ('Low Value','At Risk') THEN 'C_low_or_risky'
    WHEN COALESCE(s.segment_label,'Unknown') = 'Never Purchased' THEN 'D_never'
    ELSE 'E_other'
  END AS segment_group
FROM hpce.churn_model_dataset_multi d
LEFT JOIN hpce.customer_segments s
  ON d.customer_id = s.customer_id;
