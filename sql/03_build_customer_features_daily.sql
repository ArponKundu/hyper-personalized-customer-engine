CREATE TABLE IF NOT EXISTS hpce.customer_features_daily (
    global_customer_id    TEXT NOT NULL,
    feature_date          DATE NOT NULL,

    total_events          NUMERIC,
    views                 NUMERIC,
    adds_to_cart          NUMERIC,
    purchases             NUMERIC,
    num_orders            NUMERIC,
    total_spent           NUMERIC,
    last_event_time       TIMESTAMPTZ,

    churn_label_30d       BOOLEAN,
    churn_label_60d       BOOLEAN,

    created_at            TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (global_customer_id, feature_date)
);

INSERT INTO hpce.customer_features_daily (
    global_customer_id,
    feature_date,
    total_events,
    views,
    adds_to_cart,
    purchases,
    num_orders,
    total_spent,
    last_event_time
)
SELECT
    COALESCE(b.global_customer_id, s.global_customer_id) AS global_customer_id,
    COALESCE(b.activity_date,      s.activity_date)      AS feature_date,
    COALESCE(b.total_events,   0) AS total_events,
    COALESCE(b.views,          0) AS views,
    COALESCE(b.adds_to_cart,   0) AS adds_to_cart,
    COALESCE(b.purchases,      0) AS purchases,
    COALESCE(s.num_orders,     0) AS num_orders,
    COALESCE(s.total_spent,    0) AS total_spent,
    b.last_event_time
FROM hpce.behavior_daily_tagged b
FULL OUTER JOIN hpce.spend_daily_tagged s
    ON b.global_customer_id = s.global_customer_id
   AND b.activity_date      = s.activity_date
ON CONFLICT (global_customer_id, feature_date) DO NOTHING;
