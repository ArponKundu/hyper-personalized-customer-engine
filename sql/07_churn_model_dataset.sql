CREATE TABLE IF NOT EXISTS hpce.customer_rfm_snapshot AS
WITH obs AS (
    SELECT LEAST(
        (SELECT MAX(feature_date) FROM hpce.customer_features_daily),
        (SELECT MAX(event_time::date) FROM hpce.rees46_events)
    ) AS obs_end
),
last_orders AS (
    SELECT
        c.customer_id,
        MAX(c.feature_date) FILTER (WHERE c.daily_orders > 0) AS last_order_date
    FROM hpce.customer_features_daily c
    GROUP BY c.customer_id
),
recent_30 AS (
    SELECT
        c.customer_id,
        SUM(CASE 
                WHEN c.feature_date > o.obs_end - INTERVAL '30 days' 
                THEN c.daily_orders 
                ELSE 0 
            END) AS f_30,
        SUM(CASE 
                WHEN c.feature_date > o.obs_end - INTERVAL '30 days' 
                THEN c.daily_gmv 
                ELSE 0 
            END) AS m_30,
        SUM(CASE 
                WHEN c.feature_date > o.obs_end - INTERVAL '30 days' 
                THEN c.daily_views 
                ELSE 0 
            END) AS views_30,
        SUM(CASE 
                WHEN c.feature_date > o.obs_end - INTERVAL '30 days' 
                THEN c.daily_events_total 
                ELSE 0 
            END) AS events_30
    FROM hpce.customer_features_daily c
    CROSS JOIN obs o
    GROUP BY c.customer_id
),
rfm_base AS (
    SELECT
        r.customer_id,
        COALESCE(
            DATE_PART('day', o.obs_end - l.last_order_date),
            999
        ) AS recency_days,
        r.f_30,
        r.m_30,
        r.views_30,
        r.events_30
    FROM recent_30 r
    CROSS JOIN obs o
    LEFT JOIN last_orders l
        ON r.customer_id = l.customer_id
)
SELECT * FROM rfm_base;
