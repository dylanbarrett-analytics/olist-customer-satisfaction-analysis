-- ================================================================================
-- File: 03_data_validation.sql
-- Project: Olist E-commerce Customer Satisfaction Analysis
-- Author: Dylan Barrett
-- Last Updated: April 30, 2025
--
-- Description:
-- This script performs sanity checks after table creation and data import.
-- Each table is tested for:
-- - Row count (to confirm full import)
-- - Data preview using LIMIT 10
-- ================================================================================

-- --------------------------------------------------------------------------------
-- Step 2: Sanity checks on imported tables
-- --------------------------------------------------------------------------------
-- Goal: Confirm that each table was successfully created and populated
-- Logic:
-- - Use SELECT COUNT(*) to check row totals
-- - Use SELECT * LIMIT 10 to preview structure and values

-- Check total number of rows in each table
SELECT COUNT(*) AS order_count FROM olist_orders;
SELECT COUNT(*) AS order_items_count FROM olist_order_items;
SELECT COUNT(*) AS order_reviews_count FROM olist_order_reviews;
SELECT COUNT(*) AS order_payments_count FROM olist_order_payments;
SELECT COUNT(*) AS customer_count FROM olist_customers;
SELECT COUNT(*) AS product_count FROM olist_products;
SELECT COUNT(*) AS seller_count FROM olist_sellers;

-- Preview the first 10 rows of each table
SELECT * FROM olist_orders LIMIT 10;
SELECT * FROM olist_order_items LIMIT 10;
SELECT * FROM olist_order_reviews LIMIT 10;
SELECT * FROM olist_order_payments LIMIT 10;
SELECT * FROM olist_customers LIMIT 10;
SELECT * FROM olist_products LIMIT 10;
SELECT * FROM olist_sellers LIMIT 10;
