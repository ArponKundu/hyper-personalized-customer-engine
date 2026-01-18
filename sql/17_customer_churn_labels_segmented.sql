DROP TABLE IF EXISTS hpce.customer_churn_labels_segmented;

CREATE TABLE hpce.customer_churn_labels_segmented AS
WITH base AS (
  SELECT
    c.customer_id,
    c.obs_end,
    c.last_order_date,
    c.days_since_last_order,
    s.segment_label
  FROM hpce.customer_churn_labels_multi c
  LEFT JOIN hpce.customer_segments s
    ON c.customer_id = s.customer_id
)
SELECT
  customer_id,
  obs_end,
  last_order_date,
  days_since_last_order,
  COALESCE(segment_label, 'Unknown') AS segment_label,
  CASE
    WHEN days_since_last_order = 999 THEN 1
    WHEN COALESCE(segment_label,'Unknown') IN ('Champion','Loyal') AND days_since_last_order > 60 THEN 1
    WHEN COALESCE(segment_label,'Unknown') = 'Recent' AND days_since_last_order > 45 THEN 1
    WHEN COALESCE(segment_label,'Unknown') IN ('Low Value','At Risk') AND days_since_last_order > 90 THEN 1
    ELSE 0
  END AS churn_segmented
FROM base;
