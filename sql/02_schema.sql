-- ============================================================
-- 02_schema.sql
-- Full schema for Hyper-Personalized Customer Experience System
-- ============================================================

-- 0. Create logical schemas
CREATE SCHEMA IF NOT EXISTS hpce;         -- main working schema
CREATE SCHEMA IF NOT EXISTS hpce_raw;     -- raw untouched imports (optional but good practice)


-- ============================================================
-- 1. RAW SOURCE TABLES (from CSV, do not modify after load)
--    These let you keep source-of-truth copies.
-- ============================================================

-- Olist raw tables
CREATE TABLE IF NOT EXISTS hpce_raw.olist_orders_raw (
    order_id                         TEXT PRIMARY KEY,
    customer_id                      TEXT,
    order_status                     TEXT,
    order_purchase_timestamp         TIMESTAMPTZ,
    order_approved_at                TIMESTAMPTZ,
    order_delivered_carrier_date     TIMESTAMPTZ,
    order_delivered_customer_date    TIMESTAMPTZ,
    order_estimated_delivery_date    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS hpce_raw.olist_order_items_raw (
    order_id             TEXT,
    order_item_id        INT,
    product_id           TEXT,
    seller_id            TEXT,
    shipping_limit_date  TIMESTAMPTZ,
    price                NUMERIC,
    freight_value        NUMERIC
);

CREATE TABLE IF NOT EXISTS hpce_raw.olist_customers_raw (
    customer_id               TEXT,
    customer_unique_id        TEXT,
    customer_zip_code_prefix  TEXT,
    customer_city             TEXT,
    customer_state            TEXT
);

CREATE TABLE IF NOT EXISTS hpce_raw.olist_order_payments_raw (
    order_id               TEXT,
    payment_sequential     INT,
    payment_type           TEXT,
    payment_installments   INT,
    payment_value          NUMERIC
);

CREATE TABLE IF NOT EXISTS hpce_raw.olist_order_reviews_raw (
    review_id                TEXT,
    order_id                 TEXT,
    review_score             INT,
    review_comment_title     TEXT,
    review_comment_message   TEXT,
    review_creation_date     TIMESTAMPTZ,
    review_answer_timestamp  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS hpce_raw.olist_products_raw (
    product_id                  TEXT,
    product_category_name       TEXT,
    product_name_length         INT,
    product_description_length  INT,
    product_photos_qty          INT,
    product_weight_g            NUMERIC,
    product_length_cm           NUMERIC,
    product_height_cm           NUMERIC,
    product_width_cm            NUMERIC
);

-- REES46 / Retail Rocket raw events BEFORE cleaning (epoch ms etc.)
CREATE TABLE IF NOT EXISTS hpce_raw.rees46_events_raw (
    timestamp_ms     BIGINT,
    visitorid        TEXT,
    event            TEXT,
    itemid           TEXT,
    transactionid    TEXT
);



-- ============================================================
-- 2. CLEANED / STANDARDIZED TABLES
--    These are what you will actually query for analytics.
--    You can populate these from hpce_raw.* using Python or SQL.
-- ============================================================

-- Clean Olist tables
CREATE TABLE IF NOT EXISTS hpce.olist_orders (
    order_id                         TEXT PRIMARY KEY,
    customer_id                      TEXT,
    order_status                     TEXT,
    order_purchase_ts                TIMESTAMPTZ,
    order_approved_ts                TIMESTAMPTZ,
    order_delivered_carrier_ts       TIMESTAMPTZ,
    order_delivered_customer_ts      TIMESTAMPTZ,
    order_estimated_delivery_ts      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS hpce.olist_order_items (
    order_id             TEXT,
    order_item_id        INT,
    product_id           TEXT,
    seller_id            TEXT,
    shipping_limit_date  TIMESTAMPTZ,
    price                NUMERIC,
    freight_value        NUMERIC,
    PRIMARY KEY(order_id, order_item_id)
);

CREATE TABLE IF NOT EXISTS hpce.olist_customers (
    customer_id               TEXT PRIMARY KEY,
    customer_unique_id        TEXT,
    customer_zip_code_prefix  TEXT,
    customer_city             TEXT,
    customer_state            TEXT
);

CREATE TABLE IF NOT EXISTS hpce.olist_order_payments (
    order_id               TEXT,
    payment_sequential     INT,
    payment_type           TEXT,
    payment_installments   INT,
    payment_value          NUMERIC
);

CREATE TABLE IF NOT EXISTS hpce.olist_order_reviews (
    review_id                TEXT PRIMARY KEY,
    order_id                 TEXT,
    review_score             INT,
    review_comment_title     TEXT,
    review_comment_message   TEXT,
    review_creation_date     TIMESTAMPTZ,
    review_answer_timestamp  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS hpce.olist_products (
    product_id                  TEXT PRIMARY KEY,
    product_category_name       TEXT,
    product_name_length         INT,
    product_description_length  INT,
    product_photos_qty          INT,
    product_weight_g            NUMERIC,
    product_length_cm           NUMERIC,
    product_height_cm           NUMERIC,
    product_width_cm            NUMERIC
);

-- Clean REES46 events table (after timestamp ms -> proper timestamptz,
-- columns renamed, duplicates removed)
CREATE TABLE IF NOT EXISTS hpce.rees46_events (
    event_time       TIMESTAMPTZ,
    user_id          TEXT,
    event_type       TEXT,        -- 'view', 'addtocart', 'transaction'
    product_id       TEXT,
    transaction_id   TEXT
);


-- ============================================================
-- 3. DAILY AGGREGATION TABLES
--    We'll build these from the clean tables.
--    These are per-user-per-day summaries, not yet unified.
-- ============================================================

-- 3.1 Behavioral daily activity from REES46 clickstream
--     One row per (user_id, date)
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

-- 3.2 Purchase/spend daily from Olist orders
--     One row per (customer_id, date)
CREATE TABLE IF NOT EXISTS hpce.order_spend_daily (
    customer_id       TEXT,
    activity_date     DATE,
    num_orders        INT,
    total_spent       NUMERIC,
    PRIMARY KEY (customer_id, activity_date)
);

-- 3.3 Tagged behavioral daily with global_customer_id
--     user_id from web becomes 'web_<id>'
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

-- 3.4 Tagged spend daily with global_customer_id
--     customer_id from olist becomes 'olist_<id>'
CREATE TABLE IF NOT EXISTS hpce.spend_daily_tagged (
    global_customer_id    TEXT,
    activity_date         DATE,
    num_orders            INT,
    total_spent           NUMERIC,
    PRIMARY KEY (global_customer_id, activity_date)
);


-- ============================================================
-- 4. MASTER DAILY FEATURE TABLE (this is your feature store)
--    Joins behavior_daily_tagged + spend_daily_tagged.
--    Grain: (global_customer_id, feature_date)
--
--    This is what you'll eventually feed into ML after enrichment.
-- ============================================================

CREATE TABLE IF NOT EXISTS hpce.customer_features_daily (
    global_customer_id    TEXT NOT NULL,
    feature_date          DATE NOT NULL,

    -- raw daily signals (from behavior + spend)
    total_events          NUMERIC,
    views                 NUMERIC,
    adds_to_cart          NUMERIC,
    purchases             NUMERIC,
    num_orders            NUMERIC,
    total_spent           NUMERIC,
    last_event_time       TIMESTAMPTZ,

    -- rolling RFM-like metrics
    r_7                   NUMERIC,
    f_7                   NUMERIC,
    m_7                   NUMERIC,
    r_30                  NUMERIC,
    f_30                  NUMERIC,
    m_30                  NUMERIC,
    r_60                  NUMERIC,
    f_60                  NUMERIC,
    m_60                  NUMERIC,
    r_90                  NUMERIC,
    f_90                  NUMERIC,
    m_90                  NUMERIC,

    -- dynamics / health
    activity_velocity     NUMERIC,  -- change in activity vs previous window
    seasonality_score     NUMERIC,  -- optional/placeholder for periodic patterns

    -- customer experience signals (can be added later by UPDATE)
    avg_review_score_recent  NUMERIC,
    avg_delay_days_recent    NUMERIC,

    -- CLV projection
    clv_pred              NUMERIC,
    clv_ci_low            NUMERIC,
    clv_ci_high           NUMERIC,

    -- churn supervision (label)
    churn_label_30d       BOOLEAN,
    churn_label_60d       BOOLEAN,

    created_at            TIMESTAMPTZ DEFAULT now(),

    PRIMARY KEY (global_customer_id, feature_date)
);

-- make it a hypertable in TimescaleDB
-- (use 'feature_date' as the time column)
SELECT create_hypertable(
    'hpce.customer_features_daily',
    'feature_date',
    if_not_exists => TRUE
);


-- ============================================================
-- 5. INTERVENTION LOGS
--    Phase 3: decision engine writes here ("we tried to save them").
--    We'll use this later for learning which actions actually work.
-- ============================================================

CREATE TABLE IF NOT EXISTS hpce.intervention_logs (
    intervention_id      BIGSERIAL PRIMARY KEY,
    global_customer_id   TEXT NOT NULL,
    ts                   TIMESTAMPTZ NOT NULL,
    channel              TEXT,         -- email / sms / popup / etc
    action               TEXT,         -- "10%_coupon", "free_shipping", etc
    metadata             JSONB,        -- payload about offer/audience
    outcome_label        TEXT,         -- "returned", "ignored", "complained", etc
    outcome_value        NUMERIC,      -- could be spend_after_intervention
    success_flag         BOOLEAN,      -- quick binary marker
    created_at           TIMESTAMPTZ DEFAULT now()
);

SELECT create_hypertable(
    'hpce.intervention_logs',
    'ts',
    if_not_exists => TRUE
);


-- ============================================================
-- 6. SEGMENT TRANSITIONS
--    Phase 2: segmentation + Markov transitions.
-- ============================================================

CREATE TABLE IF NOT EXISTS hpce.segment_transitions (
    global_customer_id   TEXT NOT NULL,
    ts                   TIMESTAMPTZ NOT NULL,
    from_segment         TEXT,
    to_segment           TEXT,
    horizon_days         INT,        -- optional: forecast horizon
    driver_features      JSONB,      -- "why did we think they'd move"
    created_at           TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (global_customer_id, ts)
);

SELECT create_hypertable(
    'hpce.segment_transitions',
    'ts',
    if_not_exists => TRUE
);