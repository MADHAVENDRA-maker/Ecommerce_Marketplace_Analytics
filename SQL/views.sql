-- The following commands have been used to create the views inside the database
-- 1)vw_order_summary
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    c.customer_zip_code_prefix,

    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    oi.total_items,
    oi.product_value,
    oi.freight_value,

    p.total_payment_value,
    p.max_installments,

    r.average_review_score,
    r.review_count,

    CASE
        WHEN oi.product_value IS NOT NULL
        THEN oi.product_value + COALESCE(oi.freight_value, 0)
        ELSE NULL
    END AS order_value,

    CASE
        WHEN o.order_approved_at IS NOT NULL
             AND o.order_approved_at >= o.order_purchase_timestamp
        THEN TIMESTAMPDIFF(
            HOUR,
            o.order_purchase_timestamp,
            o.order_approved_at
        )
        ELSE NULL
    END AS approval_time_hours,

    CASE
        WHEN o.order_delivered_carrier_date IS NOT NULL
             AND o.order_delivered_carrier_date >= o.order_purchase_timestamp
        THEN TIMESTAMPDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_carrier_date
        )
        ELSE NULL
    END AS carrier_processing_days,

    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
             AND o.order_delivered_customer_date >= o.order_purchase_timestamp
        THEN TIMESTAMPDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        )
        ELSE NULL
    END AS delivery_time_days,

    CASE
        WHEN o.order_estimated_delivery_date IS NOT NULL
             AND o.order_estimated_delivery_date >= o.order_purchase_timestamp
        THEN TIMESTAMPDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_estimated_delivery_date
        )
        ELSE NULL
    END AS estimated_delivery_days,

    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
             AND o.order_estimated_delivery_date IS NOT NULL
        THEN TIMESTAMPDIFF(
            DAY,
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date
        )
        ELSE NULL
    END AS delivery_delay_days

FROM ecommerce_project.orders AS o

LEFT JOIN ecommerce_project.customers AS c
    ON o.customer_id = c.customer_id

LEFT JOIN (
    SELECT
        order_id,
        COUNT(*) AS total_items,
        SUM(price) AS product_value,
        SUM(freight_value) AS freight_value
    FROM ecommerce_project.order_items
    GROUP BY order_id
) AS oi
    ON o.order_id = oi.order_id

LEFT JOIN (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value,
        MAX(payment_installments) AS max_installments
    FROM ecommerce_project.order_payments
    GROUP BY order_id
) AS p
    ON o.order_id = p.order_id

LEFT JOIN (
    SELECT
        order_id,
        AVG(review_score) AS average_review_score,
        COUNT(*) AS review_count
    FROM ecommerce_project.order_reviews
    GROUP BY order_id
) AS r
    ON o.order_id = r.order_id;
-- 2)vw_product_sales
CREATE OR REPLACE VIEW vw_product_sales AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,

    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'unknown'
    ) AS product_category,

    p.product_name_length,
    p.product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,

    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state,

    oi.price,
    oi.freight_value,

    oi.price + oi.freight_value AS item_total_value

FROM ecommerce_project.order_items AS oi

LEFT JOIN ecommerce_project.products AS p
    ON oi.product_id = p.product_id

LEFT JOIN ecommerce_project.category_translation AS ct
    ON p.product_category_name = ct.product_category_name

LEFT JOIN ecommerce_project.sellers AS s
    ON oi.seller_id = s.seller_id;
-- 3)vw_seller_summary
CREATE OR REPLACE VIEW vw_seller_summary AS
SELECT
    ps.seller_id,

    MAX(ps.seller_city) AS seller_city,
    MAX(ps.seller_state) AS seller_state,

    COUNT(DISTINCT ps.order_id) AS total_orders,

    COUNT(*) AS total_items_sold,

    COUNT(DISTINCT ps.product_id) AS unique_products_sold,

    SUM(ps.price) AS total_product_sales,

    SUM(ps.freight_value) AS total_freight,

    SUM(ps.item_total_value) AS total_sales_value,

    AVG(ps.price) AS average_item_price,

    AVG(o.order_value) AS average_order_value,

    AVG(o.average_review_score) AS average_review_score,

    AVG(
        CASE
            WHEN o.order_status = 'delivered'
            THEN o.delivery_time_days
        END
    ) AS average_delivery_days,

    AVG(
        CASE
            WHEN o.order_status = 'delivered'
            THEN o.delivery_delay_days
        END
    ) AS average_delivery_delay_days

FROM ecommerce_project.vw_product_sales AS ps

LEFT JOIN ecommerce_project.vw_order_summary AS o
    ON ps.order_id = o.order_id

GROUP BY
    ps.seller_id;
-- 4)vw_customer_summary
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
    c.customer_unique_id,

    MAX(c.customer_city) AS customer_city,
    MAX(c.customer_state) AS customer_state,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(
        DISTINCT CASE
            WHEN o.order_status = 'delivered'
            THEN o.order_id
        END
    ) AS delivered_orders,

    COUNT(
        DISTINCT CASE
            WHEN o.order_status = 'canceled'
            THEN o.order_id
        END
    ) AS canceled_orders,

    SUM(
        CASE
            WHEN o.order_id IS NOT NULL
            THEN COALESCE(oi.order_value, 0)
            ELSE 0
        END
    ) AS total_spent,

    AVG(oi.order_value) AS average_order_value,

    MIN(o.order_purchase_timestamp) AS first_purchase,
    MAX(o.order_purchase_timestamp) AS last_purchase,

    AVG(r.average_review_score) AS average_review_score,

    AVG(
        CASE
            WHEN o.order_status = 'delivered'
            THEN oi.delivery_time_days
        END
    ) AS average_delivery_days,

    AVG(
        CASE
            WHEN o.order_status = 'delivered'
            THEN oi.delivery_delay_days
        END
    ) AS average_delivery_delay_days

FROM ecommerce_project.customers AS c

LEFT JOIN ecommerce_project.orders AS o
    ON c.customer_id = o.customer_id

LEFT JOIN ecommerce_project.vw_order_summary AS oi
    ON o.order_id = oi.order_id

LEFT JOIN (
    SELECT
        order_id,
        AVG(review_score) AS average_review_score
    FROM ecommerce_project.order_reviews
    GROUP BY order_id
) AS r
    ON o.order_id = r.order_id

GROUP BY
    c.customer_unique_id;
-- 5)vw_category_summary
CREATE OR REPLACE VIEW vw_category_summary AS
SELECT
    ps.product_category,

    COUNT(DISTINCT ps.order_id) AS total_orders,

    COUNT(*) AS total_items_sold,

    COUNT(DISTINCT ps.product_id) AS unique_products,

    COUNT(DISTINCT ps.seller_id) AS unique_sellers,

    SUM(ps.price) AS total_product_sales,

    SUM(ps.freight_value) AS total_freight,

    SUM(ps.item_total_value) AS total_sales_value,

    AVG(ps.price) AS average_item_price,

    AVG(o.average_review_score) AS average_review_score,

    AVG(
        CASE
            WHEN o.order_status = 'delivered'
            THEN o.delivery_time_days
        END
    ) AS average_delivery_days,

    AVG(
        CASE
            WHEN o.order_status = 'delivered'
            THEN o.delivery_delay_days
        END
    ) AS average_delivery_delay_days

FROM ecommerce_project.vw_product_sales AS ps

LEFT JOIN ecommerce_project.vw_order_summary AS o
    ON ps.order_id = o.order_id

GROUP BY
    ps.product_category;