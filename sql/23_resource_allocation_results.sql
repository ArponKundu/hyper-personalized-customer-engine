DROP TABLE IF EXISTS hpce.resource_allocation_results;

CREATE TABLE hpce.resource_allocation_results AS
WITH budget AS (
  SELECT COALESCE(
           (SELECT max_coupons FROM hpce.resource_budget_config WHERE budget_date = CURRENT_DATE),
           5000
         ) AS max_coupons
),
ranked AS (
  SELECT
    l.*,
    CASE WHEN LOWER(l.recommended_action) LIKE '%coupon%' THEN 1 ELSE 0 END AS is_coupon,
    ROW_NUMBER() OVER (
      PARTITION BY (CASE WHEN LOWER(l.recommended_action) LIKE '%coupon%' THEN 1 ELSE 0 END)
      ORDER BY l.churn_probability DESC
    ) AS rnk_within_type
  FROM hpce.intervention_logs l
)
SELECT
  intervention_id,
  customer_id,
  segment_label,
  churn_probability,
  recommended_action,
  CASE
    WHEN is_coupon = 1 AND rnk_within_type <= (SELECT max_coupons FROM budget)
      THEN recommended_action
    WHEN is_coupon = 1 AND rnk_within_type > (SELECT max_coupons FROM budget)
      THEN 'send_reminder_email'
    ELSE recommended_action
  END AS final_action,
  is_coupon,
  rnk_within_type AS priority_rank
FROM ranked;
