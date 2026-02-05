use ecommerce_analysis;

-- Delivered orders view
CREATE VIEW delivered_orders AS
SELECT *
FROM olist_orders_dataset
WHERE order_status = 'delivered';

-- Total Revenue
SELECT 
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM olist_order_payments_dataset;

-- Total Orders
SELECT 
    COUNT(DISTINCT order_id) AS total_orders
FROM delivered_orders;

-- Average Order Value
SELECT 
    ROUND(
        SUM(payment_value) / COUNT(DISTINCT order_id),
        2
    ) AS avg_order_value
FROM olist_order_payments_dataset;

-- Monthly Revenue
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(p.payment_value), 2) AS monthly_revenue
FROM delivered_orders o
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;

-- New vs Repeat Customers
SELECT 
    customer_type,
    COUNT(*) AS customer_count
FROM (
    SELECT 
        customer_unique_id,
        CASE 
            WHEN COUNT(order_id) = 1 THEN 'New Customer'
            ELSE 'Repeat Customer'
        END AS customer_type
    FROM delivered_orders
    GROUP BY customer_unique_id
) t
GROUP BY customer_type;

-- Revenue by State
SELECT 
    g.customer_state,
    ROUND(SUM(p.payment_value), 2) AS state_revenue
FROM delivered_orders o
JOIN olist_customers_dataset c
ON o.customer_id = c.customer_id
JOIN olist_geolocation_dataset g
ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
GROUP BY g.customer_state
ORDER BY state_revenue DESC;
