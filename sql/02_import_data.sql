-- ================================================================================
-- File: 02_import_data.sql
-- Project: Olist E-commerce Customer Satisfaction Analysis
-- Author: Dylan Barrett
-- Last Updated: April 30, 2025
--
-- Description:
-- This script imports all CSV datasets into their corresponding SQL tables.
-- It includes:
-- - Standard data imports using the pgAdmin Import/Export tool or COPY command
-- - Constraint handling to allow successful import of duplicate keys
-- - UTF-8 encoding and quote handling for special characters
-- ================================================================================

-- --------------------------------------------------------------------------------
-- Step 1.3: Import datasets using pgAdmin GUI
-- --------------------------------------------------------------------------------
-- Datasets imported using the Import/Export Tool:
-- - olist_orders
-- - olist_order_items
-- - olist_order_payments
-- - olist_customers
-- - olist_products
-- - olist_sellers
-- No encoding or constraint issues encountered.
-- (Note: All imports matched the structure defined in 01_create_tables.sql)

-- --------------------------------------------------------------------------------
-- Step 1.5: Data quality handling – Duplicate review_id issue during import
-- --------------------------------------------------------------------------------
-- Dropping primary key constraint temporarily to allow full data import
-- (Note: In production, better practice would be to deduplicate data before import)
ALTER TABLE olist_order_reviews
DROP CONSTRAINT olist_order_reviews_pkey;

-- Importing review data from UTF-8 encoded CSV with proper quoting
COPY olist_order_reviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
)
FROM 'C:\temp\olist_order_reviews_utf8.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8'
QUOTE '"';
