-- 1. Roll up REES46 user behavior per day
CREATE TABLE IF NOT EXISTS hpce.behavior_daily (
    user_id           TEXT,
    activity_date     DATE,
    total_events      INT,
    views             INT,
    adds_to_cart      INT,
    purchases         INT,
    last_event_time   TIMESTAMPTZ,
    PRIMARY KEY (user_id, activity_date)
);

INSERT INTO hpce.behavior_daily
SELECT
    user_id,
    DATE(event_time) AS activity_date,
    COUNT(*) AS total_events,
    SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS views,
    SUM(CASE WHEN event_type IN ('addtocart','add_to_cart') THEN 1 ELSE 0 END) AS adds_to_cart,
    SUM(CASE WHEN event_type IN ('transaction','purchase') THEN 1 ELSE 0 END) AS purchases,
    MAX(event_time) AS last_event_time
FROM hpce.rees46_events
GROUP BY user_id, DATE(event_time)
ON CONFLICT (user_id, activity_date) DO NOTHING;


-- 2. Roll up Olist spend per day
CREATE TABLE IF NOT EXISTS hpce.order_spend_daily (
    customer_id       TEXT,
    activity_date     DATE,
    num_orders        INT,
    total_spent       NUMERIC,
    PRIMARY KEY (customer_id, activity_date)
);

WITH order_values AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_purchase_ts::date AS activity_date,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM hpce.olist_orders o
    JOIN hpce.olist_order_items oi
      ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id, o.order_purchase_ts::date
)
INSERT INTO hpce.order_spend_daily
SELECT
    customer_id,
    activity_date,
    COUNT(*) AS num_orders,
    SUM(order_value) AS total_spent
FROM order_values
GROUP BY customer_id, activity_date
ON CONFLICT (customer_id, activity_date) DO NOTHING;


-- 3. Apply global_customer_id prefixes
CREATE TABLE IF NOT EXISTS hpce.behavior_daily_tagged (
    global_customer_id    TEXT,
    activity_date         DATE,
    total_events          INT,
    views                 INT,
    adds_to_cart          INT,
    purchases             INT,
    last_event_time       TIMESTAMPTZ,
    PRIMARY KEY (global_customer_id, activity_date)
);

INSERT INTO hpce.behavior_daily_tagged
SELECT
    'web_' || user_id AS global_customer_id,
    activity_date,
    total_events,
    views,
    adds_to_cart,
    purchases,
    last_event_time
FROM hpce.behavior_daily
ON CONFLICT (global_customer_id, activity_date) DO NOTHING;


CREATE TABLE IF NOT EXISTS hpce.spend_daily_tagged (
    global_customer_id    TEXT,
    activity_date         DATE,
    num_orders            INT,
    total_spent           NUMERIC,
    PRIMARY KEY (global_customer_id, activity_date)
);

INSERT INTO hpce.spend_daily_tagged
SELECT
    'olist_' || customer_id AS global_customer_id,
    activity_date,
    num_orders,
    total_spent
FROM hpce.order_spend_daily
ON CONFLICT (global_customer_id, activity_date) DO NOTHING;
