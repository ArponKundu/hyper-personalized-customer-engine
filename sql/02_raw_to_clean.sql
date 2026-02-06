-- Clean table definitions (if not already created)
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

CREATE TABLE IF NOT EXISTS hpce.rees46_events (
    event_time       TIMESTAMPTZ,
    user_id          TEXT,
    event_type       TEXT,
    product_id       TEXT,
    transaction_id   TEXT
);


-- Load from raw -> clean
INSERT INTO hpce.olist_orders
SELECT
    order_id,
    customer_id,
    lower(order_status) AS order_status,
    order_purchase_timestamp       AS order_purchase_ts,
    order_approved_at              AS order_approved_ts,
    order_delivered_carrier_date   AS order_delivered_carrier_ts,
    order_delivered_customer_date  AS order_delivered_customer_ts,
    order_estimated_delivery_date  AS order_estimated_delivery_ts
FROM hpce_raw.olist_orders_raw
ON CONFLICT (order_id) DO NOTHING;

INSERT INTO hpce.olist_order_items
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM hpce_raw.olist_order_items_raw
ON CONFLICT (order_id, order_item_id) DO NOTHING;

INSERT INTO hpce.olist_customers
SELECT DISTINCT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM hpce_raw.olist_customers_raw
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO hpce.olist_order_payments
SELECT
    order_id,
    payment_sequential,
    lower(payment_type),
    payment_installments,
    payment_value
FROM hpce_raw.olist_order_payments_raw
ON CONFLICT DO NOTHING;

INSERT INTO hpce.olist_order_reviews
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM hpce_raw.olist_order_reviews_raw
ON CONFLICT (review_id) DO NOTHING;

INSERT INTO hpce.olist_products
SELECT DISTINCT
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM hpce_raw.olist_products_raw
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO hpce.rees46_events
SELECT
    to_timestamp(timestamp_ms / 1000.0) AS event_time,
    visitorid                           AS user_id,
    lower(event)                        AS event_type,
    itemid                              AS product_id,
    transactionid                       AS transaction_id
FROM hpce_raw.rees46_events_raw
ON CONFLICT DO NOTHING;
