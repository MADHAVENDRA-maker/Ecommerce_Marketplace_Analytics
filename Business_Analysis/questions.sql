-- Q1: How has marketplace sales performance evolved over time?
-- Monthly sales performance
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(product_value) AS total_product_sales,

    SUM(freight_value) AS total_freight,

    SUM(order_value) AS total_order_value,

    AVG(product_value) AS average_product_value

FROM vw_order_summary

WHERE order_status = 'delivered'

GROUP BY
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m')

ORDER BY
    order_month;
-- Month-over-month sales growth
WITH monthly_sales AS (

    SELECT
        DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,

        COUNT(DISTINCT order_id) AS total_orders,

        SUM(product_value) AS total_product_sales,

        AVG(product_value) AS average_product_value

    FROM vw_order_summary

    WHERE order_status = 'delivered'

    GROUP BY
        DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
)

SELECT
    order_month,

    total_orders,

    total_product_sales,

    average_product_value,

    LAG(total_product_sales) OVER (
        ORDER BY order_month
    ) AS previous_month_sales,

    ROUND(
        (
            total_product_sales
            - LAG(total_product_sales) OVER (
                ORDER BY order_month
            )
        )
        /
        NULLIF(
            LAG(total_product_sales) OVER (
                ORDER BY order_month
            ),
            0
        ) * 100,
        2
    ) AS sales_growth_pct

FROM monthly_sales

ORDER BY
    order_month;
-- 2017 full-year baseline
SELECT
    COUNT(DISTINCT order_id) AS total_orders,

    SUM(product_value) AS total_product_sales,

    SUM(freight_value) AS total_freight,

    SUM(order_value) AS total_order_value,

    AVG(product_value) AS average_product_value

FROM vw_order_summary

WHERE order_status = 'delivered'
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp < '2018-01-01';
-- Comparable Jan–Aug 2017 vs Jan–Aug 2018
SELECT
    YEAR(order_purchase_timestamp) AS order_year,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(product_value) AS total_product_sales,

    SUM(freight_value) AS total_freight,

    SUM(order_value) AS total_order_value,

    AVG(product_value) AS average_product_value

FROM vw_order_summary

WHERE order_status = 'delivered'
  AND MONTH(order_purchase_timestamp) BETWEEN 1 AND 8
  AND YEAR(order_purchase_timestamp) IN (2017, 2018)

GROUP BY
    YEAR(order_purchase_timestamp)

ORDER BY
    order_year;
-- Q2: Which product categories are driving marketplace sales?
SELECT
    product_category,
    total_orders,
    total_items_sold,
    unique_products,
    unique_sellers,
    total_product_sales,
    total_freight,
    total_sales_value,
    average_item_price,
    average_review_score,
    average_delivery_days,
    average_delivery_delay_days
FROM vw_category_summary
ORDER BY total_product_sales DESC
LIMIT 15;
-- Q3: Which sellers are driving marketplace sales, and how concentrated are sales among the top sellers?
-- Top sellers
SELECT
    seller_id,
    seller_city,
    seller_state,

    total_orders,
    total_items_sold,
    unique_products_sold,

    total_product_sales,
    total_freight,
    total_sales_value,

    average_item_price,
    average_order_value,
    average_review_score,
    average_delivery_days,
    average_delivery_delay_days

FROM vw_seller_summary

ORDER BY total_product_sales DESC

LIMIT 20;
-- Top 10 seller concentration
WITH seller_ranked AS (

    SELECT
        seller_id,
        total_product_sales,

        ROW_NUMBER() OVER (
            ORDER BY total_product_sales DESC
        ) AS seller_rank

    FROM vw_seller_summary
)

SELECT
    SUM(
        CASE
            WHEN seller_rank <= 10
            THEN total_product_sales
            ELSE 0
        END
    ) AS top_10_sales,

    SUM(total_product_sales) AS total_marketplace_sales,

    ROUND(
        SUM(
            CASE
                WHEN seller_rank <= 10
                THEN total_product_sales
                ELSE 0
            END
        )
        / SUM(total_product_sales) * 100,
        2
    ) AS top_10_sales_share_pct

FROM seller_ranked;
-- Q4: How valuable are Olist's customers, and how strong is customer retention?
SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN total_orders > 1 THEN 1
            ELSE 0
        END
    ) AS repeat_customers,

    SUM(
        CASE
            WHEN total_orders = 1 THEN 1
            ELSE 0
        END
    ) AS one_time_customers,

    ROUND(AVG(total_orders), 2) AS average_orders_per_customer,

    ROUND(AVG(total_spent), 2) AS average_customer_spend,

    ROUND(MAX(total_spent), 2) AS highest_customer_spend

FROM vw_customer_summary;
-- Q5: What factors are associated with repeat purchasing?
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time customer'
        WHEN total_orders > 1 THEN 'Repeat customer'
    END AS customer_type,

    COUNT(*) AS customer_count,

    ROUND(AVG(total_spent), 2) AS average_total_spent,

    ROUND(AVG(total_orders), 2) AS average_orders,

    ROUND(AVG(average_review_score), 2) AS average_review_score,

    ROUND(AVG(average_delivery_days), 2) AS average_delivery_days,

    ROUND(AVG(average_delivery_delay_days), 2) AS average_delivery_delay_days

FROM vw_customer_summary

GROUP BY
    CASE
        WHEN total_orders = 1 THEN 'One-time customer'
        WHEN total_orders > 1 THEN 'Repeat customer'
    END;
-- Q6: How well is Olist performing on delivery?
SELECT
    COUNT(*) AS delivered_orders,

    ROUND(AVG(delivery_time_days), 2)
        AS average_delivery_days,

    ROUND(AVG(estimated_delivery_days), 2)
        AS average_estimated_delivery_days,

    ROUND(AVG(delivery_delay_days), 2)
        AS average_delivery_delay_days,

    SUM(
        CASE
            WHEN delivery_delay_days > 0 THEN 1
            ELSE 0
        END
    ) AS late_orders,

    SUM(
        CASE
            WHEN delivery_delay_days <= 0 THEN 1
            ELSE 0
        END
    ) AS on_time_or_early_orders

FROM vw_order_summary

WHERE order_status = 'delivered'
  AND delivery_time_days IS NOT NULL
  AND delivery_delay_days IS NOT NULL;
-- Q7: Which regions have the best and worst delivery performance?
SELECT
    customer_state,

    COUNT(*) AS delivered_orders,

    ROUND(AVG(delivery_time_days), 2)
        AS average_delivery_days,

    ROUND(AVG(delivery_delay_days), 2)
        AS average_delivery_delay_days,

    SUM(
        CASE
            WHEN delivery_delay_days > 0 THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        SUM(
            CASE
                WHEN delivery_delay_days > 0 THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS late_delivery_rate_pct

FROM vw_order_summary

WHERE order_status = 'delivered'
  AND delivery_time_days IS NOT NULL
  AND delivery_delay_days IS NOT NULL

GROUP BY customer_state

HAVING COUNT(*) >= 100

ORDER BY late_delivery_rate_pct DESC;
-- Q8: Which product categories have the best and worst customer experience?
SELECT
    product_category,

    total_orders,

    ROUND(average_review_score, 2)
        AS average_review_score,

    ROUND(average_delivery_days, 2)
        AS average_delivery_days,

    ROUND(average_delivery_delay_days, 2)
        AS average_delivery_delay_days

FROM vw_category_summary

WHERE total_orders >= 500

ORDER BY average_review_score ASC;
-- Q9: Which products generate the most sales, and are high-selling products also receiving good customer reviews?
SELECT
    ps.product_id,
    ps.product_category,

    COUNT(DISTINCT ps.order_id) AS total_orders,
    COUNT(*) AS total_items_sold,

    SUM(ps.price) AS total_product_sales,
    SUM(ps.freight_value) AS total_freight,
    SUM(ps.item_total_value) AS total_sales_value,

    ROUND(AVG(ps.price), 2) AS average_item_price,

    ROUND(AVG(o.average_review_score), 2) AS average_review_score

FROM vw_product_sales ps

LEFT JOIN vw_order_summary o
    ON ps.order_id = o.order_id

GROUP BY
    ps.product_id,
    ps.product_category

HAVING COUNT(DISTINCT ps.order_id) >= 20

ORDER BY
    total_product_sales DESC

LIMIT 20;
-- Q10: Which payment methods are most commonly used, and how does payment behavior vary across them?
SELECT
    payment_type,

    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(SUM(payment_value), 2) AS total_payment_value,

    ROUND(AVG(payment_value), 2) AS average_payment_value,

    ROUND(
        SUM(payment_value) /
        (
            SELECT SUM(payment_value)
            FROM order_payments
        ) * 100,
        2
    ) AS payment_value_share_pct

FROM order_payments

GROUP BY
    payment_type

ORDER BY
    total_payment_value DESC;
-- Q11: Which sellers generate the most revenue, and how does their customer experience compare with other sellers?
SELECT
    seller_id,
    seller_city,
    seller_state,

    total_orders,
    total_items_sold,

    ROUND(total_product_sales, 2)
        AS total_product_sales,

    ROUND(total_sales_value, 2)
        AS total_sales_value,

    ROUND(average_order_value, 2)
        AS average_order_value,

    ROUND(average_review_score, 2)
        AS average_review_score,

    ROUND(average_delivery_days, 2)
        AS average_delivery_days,

    ROUND(average_delivery_delay_days, 2)
        AS average_delivery_delay_days

FROM vw_seller_summary

WHERE total_orders >= 20

ORDER BY total_product_sales DESC

LIMIT 20;
-- Q12: How many customers are one-time buyers versus repeat buyers, and how much revenue does each group generate?
SELECT
    CASE
        WHEN total_orders = 1
            THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,

    COUNT(*) AS total_customers,

    ROUND(SUM(total_spent), 2) AS total_revenue,

    ROUND(AVG(total_spent), 2) AS average_customer_spend,

    ROUND(AVG(total_orders), 2) AS average_orders,

    ROUND(
        SUM(total_spent) /
        (
            SELECT SUM(total_spent)
            FROM vw_customer_summary
        ) * 100,
        2
    ) AS revenue_share_pct

FROM vw_customer_summary

GROUP BY
    CASE
        WHEN total_orders = 1
            THEN 'One-time customer'
        ELSE 'Repeat customer'
    END

ORDER BY
    total_revenue DESC;
-- Q13: What characteristics distinguish repeat customers from one-time customers?
SELECT
    CASE
        WHEN total_orders = 1
            THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,

    COUNT(*) AS total_customers,

    ROUND(AVG(total_spent), 2) AS average_customer_spend,

    ROUND(AVG(total_orders), 2) AS average_orders,

    ROUND(AVG(average_review_score), 2) AS average_review_score,

    ROUND(AVG(average_delivery_days), 2) AS average_delivery_days,

    ROUND(AVG(average_delivery_delay_days), 2) AS average_delivery_delay_days

FROM vw_customer_summary

GROUP BY
    CASE
        WHEN total_orders = 1
            THEN 'One-time customer'
        ELSE 'Repeat customer'
    END;
-- Q14: What proportion of orders are delivered, canceled, unavailable, or otherwise unsuccessful, and what is the financial impact of these orders?
-- Part 1: Order-status distribution
SELECT
    order_status,

    COUNT(*) AS total_orders,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders),
        2
    ) AS order_share_pct

FROM orders

GROUP BY
    order_status

ORDER BY
    total_orders DESC;
-- Part 2: Financial impact
SELECT
    o.order_status,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(SUM(oi.product_value), 2) AS product_value,

    ROUND(SUM(oi.freight_value), 2) AS freight_value,

    ROUND(
        SUM(oi.product_value + COALESCE(oi.freight_value, 0)),
        2
    ) AS total_order_value

FROM orders o

LEFT JOIN (
    SELECT
        order_id,
        SUM(price) AS product_value,
        SUM(freight_value) AS freight_value
    FROM order_items
    GROUP BY order_id
) oi
    ON o.order_id = oi.order_id

GROUP BY
    o.order_status

ORDER BY
    total_order_value DESC;
-- Q15: How does delivery performance vary across customer states, and which states experience the longest delivery times or delays?
SELECT
    customer_state,

    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(delivery_time_days),
        2
    ) AS average_delivery_days,

    ROUND(
        AVG(delivery_delay_days),
        2
    ) AS average_delivery_delay_days,

    ROUND(
        AVG(
            CASE
                WHEN delivery_delay_days > 0 THEN 1
                ELSE 0
            END
        ) * 100,
        2
    ) AS late_delivery_rate_pct

FROM vw_order_summary

WHERE order_status = 'delivered'

GROUP BY
    customer_state

HAVING
    COUNT(*) >= 100

ORDER BY
    average_delivery_days DESC;
-- Q16: Does delivery performance affect customer satisfaction?
SELECT
    CASE
        WHEN delivery_delay_days < 0 THEN 'Early'
        WHEN delivery_delay_days = 0 THEN 'On Time'
        WHEN delivery_delay_days > 0 THEN 'Late'
    END AS delivery_status,

    COUNT(*) AS delivered_orders,

    ROUND(AVG(average_review_score), 2) AS average_review_score,

    ROUND(AVG(delivery_time_days), 2) AS average_delivery_days,

    ROUND(AVG(delivery_delay_days), 2) AS average_delay_days

FROM vw_order_summary

WHERE
    order_status = 'delivered'
    AND delivery_delay_days IS NOT NULL
    AND average_review_score IS NOT NULL

GROUP BY
    CASE
        WHEN delivery_delay_days < 0 THEN 'Early'
        WHEN delivery_delay_days = 0 THEN 'On Time'
        WHEN delivery_delay_days > 0 THEN 'Late'
    END

ORDER BY
    CASE
        WHEN delivery_status = 'Early' THEN 1
        WHEN delivery_status = 'On Time' THEN 2
        WHEN delivery_status = 'Late' THEN 3
    END;
-- Q17: How concentrated is marketplace revenue among sellers?
-- Query 1 — Establish Seller Revenue Baseline
SELECT
    COUNT(*) AS total_sellers,
    SUM(total_sales_value) AS total_marketplace_sales,
    AVG(total_sales_value) AS average_seller_sales
FROM vw_seller_summary;
-- Query 2 — Calculate Revenue Concentration
WITH ranked_sellers AS (
    SELECT
        seller_id,
        total_sales_value,

        ROW_NUMBER() OVER (
            ORDER BY total_sales_value DESC
        ) AS seller_rank,

        SUM(total_sales_value) OVER () AS total_marketplace_sales,

        SUM(total_sales_value) OVER (
            ORDER BY total_sales_value DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_sales

    FROM vw_seller_summary
)

SELECT
    seller_rank,
    total_marketplace_sales,
    cumulative_sales,

    ROUND(
        100.0 * cumulative_sales / total_marketplace_sales,
        2
    ) AS cumulative_revenue_percentage

FROM ranked_sellers

WHERE seller_rank IN (
    1,
    10,
    31,
    155,
    310,
    619,
    929,
    1548,
    3095
)

ORDER BY seller_rank;
-- Q18: Which categories and sellers have the strongest overall combination of sales, delivery performance, and customer satisfaction?
-- Category Analysis
SELECT
    product_category,
    total_orders,
    total_sales_value,
    average_review_score,
    average_delivery_days,
    average_delivery_delay_days
FROM vw_category_summary
WHERE total_orders >= 500
ORDER BY
    total_sales_value DESC;
-- Seller Analysis
SELECT
    seller_id,
    seller_city,
    seller_state,
    total_orders,
    total_sales_value,
    average_order_value,
    average_review_score,
    average_delivery_days,
    average_delivery_delay_days
FROM vw_seller_summary
WHERE total_orders >= 100
ORDER BY total_sales_value DESC
LIMIT 30;
-- Q19: Where are the biggest weaknesses in the overall marketplace performance?
-- Delivery Reliability
SELECT
    COUNT(*) AS total_delivered_orders,

    SUM(
        CASE
            WHEN delivery_delay_days < 0 THEN 1
            ELSE 0
        END
    ) AS early_orders,

    SUM(
        CASE
            WHEN delivery_delay_days = 0 THEN 1
            ELSE 0
        END
    ) AS on_time_orders,

    SUM(
        CASE
            WHEN delivery_delay_days > 0 THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivery_delay_days > 0 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS late_percentage

FROM vw_order_summary

WHERE order_status = 'delivered'
  AND delivery_delay_days IS NOT NULL;
-- Weakest Product Categories
SELECT
    product_category,
    total_orders,
    total_sales_value,
    average_review_score,
    average_delivery_days,
    average_delivery_delay_days
FROM vw_category_summary

WHERE total_orders >= 500

ORDER BY
    average_review_score ASC,
    average_delivery_days DESC

LIMIT 10;
-- Weak Sellers
SELECT
    seller_id,
    seller_city,
    seller_state,
    total_orders,
    total_sales_value,
    average_review_score,
    average_delivery_days,
    average_delivery_delay_days
FROM vw_seller_summary

WHERE total_orders >= 100

ORDER BY
    average_review_score ASC,
    average_delivery_days DESC

LIMIT 15;
-- Non-Delivered Orders
SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN order_status <> 'delivered' THEN 1
            ELSE 0
        END
    ) AS non_delivered_orders,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN order_status <> 'delivered' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS non_delivered_percentage,

    SUM(
        CASE
            WHEN order_status <> 'delivered'
            THEN COALESCE(order_value, 0)
            ELSE 0
        END
    ) AS non_delivered_order_value

FROM vw_order_summary;
-- Q20: Where should the marketplace focus its improvement efforts to increase revenue, customer retention, and customer satisfaction while reducing operational problems?
-- Category opportunities
SELECT
    product_category,
    total_orders,
    total_sales_value,
    average_review_score,
    average_delivery_days,
    average_delivery_delay_days
FROM vw_category_summary
WHERE total_orders >= 500
  AND total_sales_value >= 300000
ORDER BY
    average_review_score ASC,
    total_sales_value DESC;
-- Seller opportunities
SELECT
    seller_id,
    seller_city,
    seller_state,
    total_orders,
    total_sales_value,
    average_review_score,
    average_delivery_days,
    average_delivery_delay_days
FROM vw_seller_summary
WHERE total_orders >= 100
  AND total_sales_value >= 50000
ORDER BY
    average_review_score ASC,
    total_sales_value DESC;