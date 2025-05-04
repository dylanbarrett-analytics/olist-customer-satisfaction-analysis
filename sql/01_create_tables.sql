-- ================================================================================
-- File: 01_create_tables.sql
-- Project: Olist E-commerce Customer Satisfaction Analysis
-- Author: Dylan Barrett
-- Last Updated: April 30, 2025
--
-- Description:
-- This script creates all database tables for the Olist e-commerce project.
-- Tables reflect key CSV datasets used in the analysis:
-- - Orders
-- - Order items
-- - Order reviews
-- - Order payments
-- - Customers
-- - Products
-- ================================================================================

-- --------------------------------------------------------------------------------
-- Step 1: Create base tables (excluding products)
-- --------------------------------------------------------------------------------
-- Goal: Create core tables for 5 key datasets (orders, order_items, order_reviews, order_payments, customers)
-- Logic:
-- - Mirror original CSV structure
-- - Define appropriate data types (TEXT, INTEGER, TIMESTAMP, NUMERIC) for relational joins
CREATE TABLE olist_orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE olist_order_items (
    order_id TEXT,
    order_item_id INTEGER,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2)
);

CREATE TABLE olist_order_reviews (
    review_id TEXT PRIMARY KEY,
    order_id TEXT,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE olist_order_payments (
    order_id TEXT,
    payment_sequential INTEGER,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value NUMERIC(10,2)
);

CREATE TABLE olist_customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state TEXT
);

-- --------------------------------------------------------------------------------
-- Step 1.1: Create olist_products table
-- --------------------------------------------------------------------------------
-- Goal: Add table to support product-level analysis and joins with order_items
CREATE TABLE olist_products (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g NUMERIC(10,2),
    product_length_cm NUMERIC(10,2),
    product_height_cm NUMERIC(10,2),
    product_width_cm NUMERIC(10,2)
);

-- --------------------------------------------------------------------------------
-- Step 1.2: Create olist_sellers table
-- --------------------------------------------------------------------------------
-- Goal: Add seller metadata to support performance analysis by seller
CREATE TABLE olist_sellers (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city TEXT,
    seller_state TEXT
);
