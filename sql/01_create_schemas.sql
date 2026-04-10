
-- Create logical schemas
CREATE SCHEMA IF NOT EXISTS hpce;
CREATE SCHEMA IF NOT EXISTS hpce_raw;

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