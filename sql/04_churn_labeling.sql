CREATE TABLE IF NOT EXISTS hpce.customer_churn_labels AS
WITH last_orders AS (
    SELECT
        customer_id,
        MAX(feature_date) FILTER (WHERE daily_orders > 0) AS last_order_date
    FROM hpce.customer_features_daily
    GROUP BY customer_id
),
obs AS (
    SELECT MAX(feature_date) AS obs_end
    FROM hpce.customer_features_daily
),
-- Churn logic: 90 days of inactivity
labels AS (
    SELECT
        l.customer_id,
        l.last_order_date,
        o.obs_end,
        DATE_PART('day', o.obs_end - l.last_order_date) AS days_since_last_order,
        CASE 
            WHEN l.last_order_date IS NULL THEN 1
            WHEN DATE_PART('day', o.obs_end - l.last_order_date) > 90 THEN 1
            ELSE 0
        END AS churn_90d
    FROM last_orders l
    CROSS JOIN obs o
)
SELECT * FROM labels;
