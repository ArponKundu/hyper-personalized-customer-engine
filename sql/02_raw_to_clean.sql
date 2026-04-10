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
