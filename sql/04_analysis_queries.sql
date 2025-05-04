-- ================================================================================
-- File: 04_analysis_queries.sql
-- Project: Olist E-commerce Customer Satisfaction Analysis
-- Author: Dylan Barrett
-- Last Updated: May 1, 2025
--
-- Description:
-- This script contains all major analysis queries used to uncover business insights 
-- from the Olist e-commerce dataset. Queries cover review score behavior, delivery 
-- performance, product category impact, seller performance, and geographic trends.
--
-- Steps Included:
-- - Step 3: Join orders and reviews
-- - Step 4: Create late delivery flag
-- - Step 5: Create clean working dataset
-- - Step 6: Analyze delivery delays vs. review scores
-- - Step 7: Analyze late delivery rates by month
-- - Step 8: Analyze review scores by product category
-- - Step 9: Analyze review scores by payment type
-- - Step 10: Analyze review scores by seller
-- - Step 11: Analyze review scores by seller state
-- ================================================================================

-- --------------------------------------------------------------------------------
-- Step 3: Join orders and reviews
-- --------------------------------------------------------------------------------
-- Goal: Link orders to customer reviews to begin customer satisfaction analysis
-- - Join orders with reviews using order_id
-- - Select key fields like purchase timestamp and review score
SELECT 
    o.order_id,
    o.customer_id,
    o.order_purchase_timestamp,
    r.review_score,
    r.review_comment_message
FROM 
    olist_orders o
INNER JOIN
	olist_order_reviews r ON o.order_id = r.order_id
LIMIT 100;

-- --------------------------------------------------------------------------------
-- Step 4: Create late delivery flag
-- --------------------------------------------------------------------------------
-- Goal: Identify if orders were delivered late compared to estimated delivery date
-- Logic:
-- - Compare delivery date vs. estimated date
-- - Assign flag: 1 = late, 0 = on-time
-- - Filter out orders with missing dates
SELECT
	o.order_id,
    o.customer_id,
    o.order_purchase_timestamp,
	o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    r.review_score,
	CASE
		WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
		ELSE 0
	END AS late_delivery_flag
FROM 
    olist_orders o
INNER JOIN
	olist_order_reviews r ON o.order_id = r.order_id
WHERE
	o.order_delivered_customer_date IS NOT NULL
	AND o.order_estimated_delivery_date IS NOT NULL
LIMIT 100;

-- --------------------------------------------------------------------------------
-- Step 5: Create clean working dataset
-- --------------------------------------------------------------------------------
-- Goal: Build a clean dataset linking orders, reviews, and delivery timing
-- Logic:
-- - Join orders and reviews
-- - Add the late_delivery_flag
-- - Exclude records with missing delivery or estimated dates
SELECT
	o.order_id,
    o.customer_id,
    o.order_purchase_timestamp,
	o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    r.review_score,
	CASE
		WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
		ELSE 0
	END AS late_delivery_flag
FROM 
    olist_orders o
INNER JOIN
	olist_order_reviews r ON o.order_id = r.order_id
WHERE
	o.order_delivered_customer_date IS NOT NULL
	AND o.order_estimated_delivery_date IS NOT NULL;

-- --------------------------------------------------------------------------------	
-- Step 6: Analyze delivery delays vs review scores
-- --------------------------------------------------------------------------------
-- Goal: Explore how late deliveries affect customer review scores
-- Logic:
-- - Group by late_delivery_flag
-- - Calculate average score and total orders
-- - Add percentage of total orders for context
WITH total_orders_cte AS (
	SELECT COUNT(*) AS grand_total
	FROM olist_orders o
	INNER JOIN olist_order_reviews r ON o.order_id = r.order_id
	WHERE o.order_delivered_customer_date IS NOT NULL
		AND o.order_estimated_delivery_date IS NOT NULL
)

SELECT
	CASE
		WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late'
		ELSE 'On-time'
	END AS delivery_status,
    ROUND(AVG(r.review_score),2) AS average_review_score,
	COUNT(*) AS total_orders,
	ROUND((COUNT(*) * 100.0 / t.grand_total),2) AS percentage_of_total_orders
FROM 
    olist_orders o
INNER JOIN
	olist_order_reviews r ON o.order_id = r.order_id
CROSS JOIN
	total_orders_cte t
WHERE
	o.order_delivered_customer_date IS NOT NULL
	AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY
	delivery_status, t.grand_total
ORDER BY
	delivery_status;

-- --------------------------------------------------------------------------------	
-- Step 7: Analyze late delivery rates by month
-- --------------------------------------------------------------------------------	
-- Goal: Explore late delivery trends over time (by month)
-- Logic:
-- - Create delivery flag
-- - Extract month from order date
-- - Aggregate late and total orders per month
WITH orders_with_delivery_flag AS (
	SELECT
		o.order_id,
		o.customer_id,
		DATE_TRUNC('month', o.order_purchase_timestamp)::DATE AS raw_month,
		TO_CHAR(DATE_TRUNC('month', o.order_purchase_timestamp),'FMMonth YYYY') AS order_month,
		CASE
			WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late'
			ELSE 'On-time'
		END AS delivery_status
	FROM 
		olist_orders o
	WHERE
		o.order_delivered_customer_date IS NOT NULL
		AND o.order_estimated_delivery_date IS NOT NULL
)

SELECT
	order_month,
	COUNT(CASE WHEN delivery_status = 'Late' THEN 1 END) AS late_orders,
	COUNT(*) AS total_orders,
	ROUND(COUNT(CASE WHEN delivery_status = 'Late' THEN 1 END) * 100.0 / COUNT(*),2) AS late_delivery_percentage
FROM 
	orders_with_delivery_flag
GROUP BY 
	raw_month, order_month
ORDER BY 
	raw_month;

-- --------------------------------------------------------------------------------	
-- Step 8: Analyze review scores by product category
-- --------------------------------------------------------------------------------	
-- Goal: Explore how customer satisfaction varies by product category
-- Logic:
-- - Join order items to products and reviews
-- - Group by category and calculate average review score
SELECT
	p.product_category_name,
	ROUND(AVG(r.review_score),2) AS average_review_score,
	COUNT(*) AS total_reviews
FROM
	olist_order_items i
INNER JOIN
	olist_products p ON i.product_id = p.product_id
INNER JOIN
	olist_order_reviews r ON i.order_id = r.order_id
WHERE
	p.product_category_name IS NOT NULL
GROUP BY
	p.product_category_name
ORDER BY
	average_review_score DESC;

-- --------------------------------------------------------------------------------	
-- Step 9: Analyze review scores by payment type
-- --------------------------------------------------------------------------------	
-- Goal: Understand how different payment methods affect customer satisfaction
-- Logic:
-- - Join order reviews with order payments on order_id
-- - Group by payment_type
-- - Calculate average review score and number of reviews per type
SELECT
	p.payment_type,
	ROUND(AVG(r.review_score),2) AS average_review_score,
	COUNT(*) AS total_reviews
FROM
	olist_order_reviews r
INNER JOIN
	olist_order_payments p ON r.order_id = p.order_id
GROUP BY
	p.payment_type
ORDER BY
	average_review_score DESC;

-- --------------------------------------------------------------------------------	
-- Step 10: Analyze review scores by seller
-- --------------------------------------------------------------------------------
-- Goal: Evaluate how customer satisfaction varies by seller
-- Logic:
-- - Join order_reviews → order_items → sellers using order_id and seller_id
-- - Group by seller
-- - Calculate average review score and total number of reviews
-- - Show top and bottom performers based on review count thresholds

-- Top 10 sellers with 50+ reviews
SELECT
	s.seller_id,
	s.seller_city,
	s.seller_state,
	ROUND(AVG(r.review_score),2) AS average_review_score,
	COUNT(*) AS total_reviews
FROM
	olist_order_reviews r
INNER JOIN
	olist_order_items i ON r.order_id = i.order_id
INNER JOIN
	olist_sellers s ON i.seller_id = s.seller_id
GROUP BY
	s.seller_id
HAVING
	COUNT(*) >= 50
ORDER BY
	average_review_score DESC,
	total_reviews DESC;

-- Bottom 10 sellers with 10+ reviews
SELECT
	s.seller_id,
	s.seller_city,
	s.seller_state,
	ROUND(AVG(r.review_score),2) AS average_review_score,
	COUNT(*) AS total_reviews
FROM
	olist_order_reviews r
INNER JOIN
	olist_order_items i ON r.order_id = i.order_id
INNER JOIN
	olist_sellers s ON i.seller_id = s.seller_id
GROUP BY
	s.seller_id
HAVING
	COUNT(*) >= 10
ORDER BY
	average_review_score,
	total_reviews DESC
LIMIT 10;

-- --------------------------------------------------------------------------------
-- Step 11: Analyze average review scores by seller state
-- --------------------------------------------------------------------------------
-- Goal: Evaluate how seller performance varies by geographic region
-- Logic:
-- - Join order_reviews → order_items → sellers
-- - Group by seller_state
-- - Calculate average review score and number of reviews per state
-- - Filter for states with a minimum review count to ensure reliability
SELECT
	s.seller_state,
	ROUND(AVG(r.review_score),2) AS average_review_score,
	COUNT(*) AS total_reviews
FROM
	olist_order_reviews r
INNER JOIN
	olist_order_items i ON r.order_id = i.order_id
INNER JOIN
	olist_sellers s ON i.seller_id = s.seller_id
GROUP BY
	s.seller_state
HAVING
	COUNT(*) >= 10
ORDER BY
	average_review_score DESC,
	total_reviews DESC;
