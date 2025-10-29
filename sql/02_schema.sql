-- 02_schema.sql
-- Creates schemas and tables for:
-- - time-series features (customer_features_daily)
-- - intervention logs
-- - segment transitions
-- - raw/staging data from Olist and REES46

CREATE SCHEMA IF NOT EXISTS hpce;

-- =========================
-- customer_features_daily
-- =========================
CREATE TABLE IF NOT EXISTS hpce.customer_features_daily (
    customer_id          TEXT NOT NULL,
    feature_date         DATE NOT NULL,

    -- Rolling Recency / Frequency / Monetary features
    r_7                  NUMERIC,
    f_7                  NUMERIC,
    m_7                  NUMERIC,
    r_30                 NUMERIC,
    f_30                 NUMERIC,
    m_30                 NUMERIC,
    r_60                 NUMERIC,
    f_60                 NUMERIC,
    m_60                 NUMERIC,
    r_90                 NUMERIC,
    f_90                 NUMERIC,
    m_90                 NUMERIC,

    -- Behavioral dynamics
    activity_velocity    NUMERIC,
    seasonality_score    NUMERIC,

    -- Simple CLV projection
    clv_pred             NUMERIC,
    clv_ci_low           NUMERIC,
    clv_ci_high          NUMERIC,

    created_at           TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (customer_id, feature_date)
);

SELECT create_hypertable(
    'hpce.customer_features_daily',
    by_range('feature_date'),
    if_not_exists => TRUE
);

-- =========================
-- intervention_logs
-- =========================
CREATE TABLE IF NOT EXISTS hpce.intervention_logs (
    intervention_id      BIGSERIAL,
    customer_id          TEXT NOT NULL,
    ts                   TIMESTAMPTZ NOT NULL,
    channel              TEXT,
    action               TEXT,
    metadata             JSONB,
    outcome_label        TEXT,
    outcome_value        NUMERIC,
    created_at           TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (intervention_id, ts)
);

SELECT create_hypertable(
    'hpce.intervention_logs',
    by_range('ts'),
    if_not_exists => TRUE
);

-- =========================
-- segment_transitions
-- =========================
CREATE TABLE IF NOT EXISTS hpce.segment_transitions (
    customer_id          TEXT NOT NULL,
    ts                   TIMESTAMPTZ NOT NULL,
    from_segment         TEXT,
    to_segment           TEXT,
    driver_features      JSONB,
    created_at           TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY(customer_id, ts)
);

SELECT create_hypertable(
    'hpce.segment_transitions',
    by_range('ts'),
    if_not_exists => TRUE
);

-- =========================
-- Olist staging tables
-- =========================
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
    customer_id          TEXT PRIMARY KEY,
    customer_unique_id   TEXT,
    customer_zip_code_prefix TEXT,
    customer_city        TEXT,
    customer_state       TEXT
);

-- =========================
-- REES46 / clickstream / behavioral events
-- =========================
CREATE TABLE IF NOT EXISTS hpce.rees46_events (
     event_time TIMESTAMP,
    user_id TEXT,
    event_type TEXT,
    product_id TEXT,
    transaction_id TEXT
);
