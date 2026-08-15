-- MGMT 59900
-- Group 6 - Supply Chain Analytics
-- Athena Transformation

CREATE DATABASE IF NOT EXISTS mgmt59900_group6;

-- Convert the raw fact_orders data from CSV to Parquet
CREATE TABLE mgmt59900_group6.fact_orders_parquet
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://YOUR-BUCKET/curated/fact_orders/'
)
AS
SELECT
    CAST(order_id AS INTEGER) AS order_id,
    CAST(customer_id AS INTEGER) AS customer_id,
    CAST(total_items AS INTEGER) AS total_items,
    CAST(total_price AS DOUBLE) AS total_price,
    CAST(total_profit AS DOUBLE) AS total_profit,
    CAST(late_delivery_risk AS INTEGER) AS late_delivery_risk,
    order_date,
    shipping_date,
    region,
    shipping_mode
FROM mgmt59900_group6.fact_orders_csv;
-- MGMT 59900
-- Group 6 - Supply Chain Analytics
-- Redshift Load

CREATE SCHEMA IF NOT EXISTS curated;

CREATE TABLE IF NOT EXISTS curated.fact_orders (
    order_id INTEGER,
    customer_id INTEGER,
    total_items INTEGER,
    total_price DOUBLE PRECISION,
    total_profit DOUBLE PRECISION,
    late_delivery_risk INTEGER,
    order_date TIMESTAMP,
    shipping_date TIMESTAMP,
    region VARCHAR(100),
    shipping_mode VARCHAR(100)
);

COPY curated.fact_orders
FROM 's3://YOUR-BUCKET/curated/fact_orders/'
IAM_ROLE 'arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_REDSHIFT_ROLE'
FORMAT AS PARQUET;

-- Validate the load
SELECT COUNT(*) AS total_rows
FROM curated.fact_orders;

-- Review sample records
SELECT *
FROM curated.fact_orders
LIMIT 10;
SELECT
    customer_segment,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS order_percentage
FROM curated.fact_orders
GROUP BY customer_segment
ORDER BY total_orders DESC;
SELECT
    region,
    COUNT(*) AS total_orders,
    SUM(late_delivery_risk) AS late_orders,
    ROUND(
        100.0 * SUM(late_delivery_risk) / COUNT(*),
        2
    ) AS late_delivery_rate
FROM curated.fact_orders
GROUP BY region
ORDER BY late_delivery_rate DESC;
SELECT
    shipping_mode,
    COUNT(*) AS total_orders,
    SUM(late_delivery_risk) AS late_orders,
    ROUND(
        100.0 * SUM(late_delivery_risk) / COUNT(*),
        2
    ) AS late_delivery_rate,
    SUM(total_profit) AS total_profit
FROM curated.fact_orders
GROUP BY shipping_mode
ORDER BY total_orders DESC;
SELECT
    region,
    COUNT(*) AS total_orders,
    SUM(total_price) AS total_revenue,
    SUM(total_profit) AS total_profit,
    AVG(total_profit) AS average_profit_per_order
FROM curated.fact_orders
GROUP BY region
ORDER BY total_profit DESC;
SELECT
    DATE_TRUNC('month', order_date) AS order_month,
    COUNT(*) AS total_orders,
    SUM(total_price) AS total_revenue,
    SUM(total_profit) AS total_profit
FROM curated.fact_orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_month;
