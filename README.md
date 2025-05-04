# Olist E-commerce Customer Satisfaction Analysis

This project analyzes customer satisfaction using real-world data from the Brazilian e-commerce platform, Olist.  
Through SQL-based data preparation and analysis, key insights are uncovered about delivery performance, product categories, and review trends.

**About Olist:**  
Olist is a Brazilian e-commerce platform that connects small and medium-sized businesses with major online marketplaces. By handling logistics, payments, and customer service support, Olist enables sellers to scale efficiently while offering buyers a wide selection of products through centralized storefronts.

## Table of Contents
- [About Olist](#about-olist)
- [Tools Used](#tools-used)
- [Step 1: Data Preparation](#step-1-data-preparation)
  - [Step 1.1: Create olist_products table](#step-11-create-olist_products-table)
  - [Step 1.2: Create olist_sellers table](#step-12-create-olist_sellers-table)
  - [Step 1.3: Import datasets using pgAdmin](#step-13-import-datasets-using-pgadmin)
  - [Step 1.5: Data quality handling – review_id conflict](#step-15-data-quality-handling--review_id-conflict)
- [Step 2: Data sanity check](#step-2-data-sanity-check)
- [Step 3: Join orders and reviews](#step-3-join-orders-and-reviews)
- [Step 4: Create late delivery flag](#step-4-create-late-delivery-flag)
- [Step 5: Create clean working dataset](#step-5-create-clean-working-dataset)
- [Step 6: Analyze delivery delays vs review scores](#step-6-analyze-delivery-delays-vs-review-scores)
- [Step 7: Analyze late delivery rates by month](#step-7-analyze-late-delivery-rates-by-month)
- [Step 8: Analyze review scores by product category](#step-8-analyze-review-scores-by-product-category)
- [Step 9: Analyze review scores by payment type](#step-9-analyze-review-scores-by-payment-type)
- [Step 10: Analyze review scores by seller](#step-10-analyze-review-scores-by-seller)
- [Step 11: Analyze review scores by seller state](#step-11-analyze-review-scores-by-seller-state)
- [Project Summary](#project-summary)
- [Next Steps](#next-steps)

## Tools Used
- PostgreSQL (via pgAdmin 4) — for database setup and management
- SQL — used for data transformation, joins, aggregations, filtering
- Tableau — used for final visualizations

## Project Files
| File | Description |
|------|-------------|
| `01_create_tables.sql` | Creates base and lookup tables |
| `02_import_data.sql` | Imports CSV datasets |
| `03_data_validation.sql` | Performs row count and preview checks |
| `04_analysis_queries.sql` | Contains all analytical SQL steps (Steps 3–11) |

### Step 1: Data preparation

**Goal:**  
Create base tables that mirror the structure of Olist’s original CSV datasets.

**Actions Taken:**  
- Created tables for 5 core datasets: `orders`, `order_items`, `order_reviews`, `order_payments`, and `customers`  
- Defined appropriate data types (TEXT, INTEGER, TIMESTAMP, NUMERIC) to support clean joins and queries

**Purpose:**  
Establish a relational database schema to enable accurate data merging and analysis in future steps.

---

### Step 1.1: Create olist_products table

**Goal:**  
Support product-level analysis by creating a structured reference table.

**Actions Taken:**  
- Created `olist_products` table with fields for product ID, category, dimensions, and weight

**Purpose:**  
Enable joins between products, orders, and reviews to assess satisfaction by product category.

---

### Step 1.2: Create olist_sellers table

**Goal:**  
Add seller-level metadata to support performance analysis by seller.

**Actions Taken:**  
- Created `olist_sellers` table with fields for seller ID, zip code prefix, city, and state

**Purpose:**  
Enable joins between sellers and order-level data to evaluate seller-specific satisfaction and operational metrics.

---

### Step 1.3: Import datasets using pgAdmin Import/Export Tool

**Goal:**  
Load all Olist CSV datasets into their corresponding SQL tables.

**Actions Taken:**  
- Used pgAdmin’s GUI to import the following datasets:
  - `olist_orders`
  - `olist_order_items`
  - `olist_order_payments`
  - `olist_customers`
  - `olist_products`
  - `olist_sellers`  
- Verified UTF-8 encoding and structural alignment  
- Confirmed no constraint violations during import

**Purpose:**  
Populate the database for analysis while maintaining clean, structured table relationships.

---

### Step 1.5: Data quality handling – review_id conflict

**Goal:**  
Address import issues related to duplicate `review_id` values in the `olist_order_reviews` dataset.

**Actions Taken:**  
- Dropped the primary key constraint on `olist_order_reviews`  
- Used the `COPY` command to import data directly from UTF-8 encoded file

**Purpose:**  
Allow full dataset import for analysis while acknowledging real-world data integrity issues.  
(Note: In production, deduplication should occur prior to import.)

---

### Step 2: Data sanity check

**Goal:**  
Verify that all tables were successfully created and populated.

**Actions Taken:**  
- Ran `SELECT COUNT(*)` to confirm row totals per table  
- Ran `SELECT * LIMIT 10` to preview structure and values in each table

**Purpose:**  
Validate that the import process worked and ensure all tables are ready for analysis.

---

### Step 3: Join orders and reviews

**Goal:**  
Link customer orders with their review data to prepare for satisfaction analysis.

**Actions Taken:**  
- Performed an `INNER JOIN` between `olist_orders` and `olist_order_reviews` using `order_id`  
- Selected key fields: order ID, customer ID, purchase timestamp, review score, and comments

**Purpose:**  
Enable later analysis on how delivery timing and other variables impact customer satisfaction.

---

### Step 4: Create late delivery flag

**Goal:**  
Identify whether each order was delivered late or on time.

**Actions Taken:**  
- Compared `order_delivered_customer_date` to `order_estimated_delivery_date`  
- Created a binary flag: 1 = Late, 0 = On-time  
- Filtered out orders with null delivery or estimated dates

**Purpose:**  
Add a critical feature for analyzing how delivery performance influences customer reviews.

**Result Summary:**  
Successfully created a `late_delivery_flag` field to distinguish between on-time and late orders.  
This will serve as a foundational column for customer satisfaction analysis in later steps.

---

### Step 5: Create clean working dataset

**Goal:**  
Prepare a reliable dataset for analysis and visualization.

**Actions Taken:**  
- Removed row limit to analyze full dataset  
- Included delivery flag, review scores, and timestamps  
- Excluded rows with missing delivery or estimated dates

**Purpose:**  
Establish a trusted dataset that will power the remainder of the project, including Tableau dashboarding.

**Result Summary:**  
Built a clean, ready-to-query dataset with complete delivery information and satisfaction indicators.  
Serves as the central dataset for all future aggregations and visualizations.

---

### Step 6: Analyze impact of late deliveries on review scores

**Goal:**  
Determine how late deliveries affect customer satisfaction.

**Actions Taken:**  
- Grouped orders by delivery status (Late vs On-time)  
- Calculated average review score per group  
- Counted total orders and calculated each group’s share of total orders

**Purpose:**  
Identify whether delivery delays have a measurable negative impact on review scores.

**Result Summary:**  
Late deliveries averaged a review score of **2.57**, while on-time deliveries averaged **4.29**.  
This confirms a strong negative correlation between delivery delays and customer satisfaction.

---

### Step 7: Analyze late delivery trends over time

**Goal:**  
Explore how late delivery rates change by month.

**Actions Taken:**  
- Extracted year-month from `order_purchase_timestamp`  
- Calculated the percentage of late deliveries for each month  
- Grouped by month and delivery flag

**Purpose:**  
Spot seasonal trends or operational inefficiencies tied to delivery performance.

**Result Summary:**  
Late delivery rates generally stayed below 10% but spiked in certain months (e.g., August 2018 = 10.39%).  
This indicates potential fulfillment challenges during peak seasons or promotional periods.

---

### Step 8: Analyze review scores by product category

**Goal:**  
Understand how satisfaction varies by product category.

**Actions Taken:**  
- Joined `olist_order_items`, `olist_order_reviews`, and `olist_products`  
- Grouped by `product_category_name`  
- Calculated average review score and total reviews per category

**Purpose:**  
Help business units identify which product types generate strong or weak customer satisfaction.

**Result Summary:**  
Most product categories scored between 4.0–4.5 on average.  
Some outliers scored lower, providing opportunities for category-specific quality or logistics improvements.

---

### Step 9: Analyze review scores by payment type

**Goal:**  
Identify whether certain payment methods are associated with higher or lower customer satisfaction.

**Actions Taken:**  
- Joined `olist_order_reviews` with `olist_order_payments` on `order_id`  
- Grouped results by `payment_type`  
- Calculated average review score and total number of reviews for each type  
- Ordered results from highest to lowest satisfaction

**Purpose:**  
Explore whether payment behavior influences customer satisfaction — e.g. whether credit card or boleto users leave better reviews.

**Result Summary:**  
There was no significant difference across the top four payment methods — all averaged around a review score of 4.0.  
This suggests payment type does not strongly influence customer satisfaction in the Olist dataset.

---

### Step 10: Analyze review scores by seller

**Goal:**  
Evaluate how customer satisfaction varies across different sellers on the Olist platform.

**Actions Taken:**  
- Joined `olist_order_reviews`, `olist_order_items`, and `olist_sellers` to link each review to its seller  
- Grouped results by `seller_id`, `seller_city`, and `seller_state`  
- Calculated average review scores and total reviews per seller  
- Isolated:
  - Top 10 sellers with **50+ reviews**
  - Bottom 10 sellers with **10+ reviews**

**Purpose:**  
Identify consistently high-performing and underperforming sellers to inform marketplace quality, onboarding strategies, and seller support initiatives.

**Result Summary:**  
Among sellers with at least 50 reviews, the top 10 consistently achieved average review scores ranging from **4.59 to 4.82**. These high-performing sellers were largely based in **São Paulo (SP)** and **Rio de Janeiro (RJ)**, indicating that sellers in major urban centers may benefit from stronger infrastructure, faster delivery times, or more refined customer service practices.  
This insight helps Olist spotlight what’s working well within its seller network and potentially replicate those strengths across other regions.

---

### Step 11: Analyze average review scores by seller state

**Goal:**  
Evaluate how customer satisfaction varies across geographic regions by analyzing seller performance by state.

**Actions Taken:**  
- Joined `olist_order_reviews`, `olist_order_items`, and `olist_sellers`  
- Grouped results by `seller_state`  
- Calculated the average review score and total reviews per state  
- Filtered out states with fewer than 100 reviews to ensure statistical reliability

**Purpose:**  
Identify regional patterns in seller performance that may reflect logistical issues, service quality differences, or support needs.

**Result Summary:**  
Seller performance by state revealed modest variation in customer satisfaction. States like **MS (4.47)** and **RN (4.27)** led in average review scores but had relatively low review counts. Meanwhile, **SP**, the state with the highest number of reviews (80,153), maintained a solid average of **4.03**, indicating strong consistency at scale.  

Lower-performing states such as **SE (3.90)** and **PB (3.86)** may require further investigation or seller support, especially if volume increases over time.

---

## Tableau Dashboard Summary

The final dashboard, **Brazil E-Commerce Customer Satisfaction & Delivery Performance**, translates SQL findings into an interactive visual experience using Tableau.

### 📌 Key Features:
- **Interactive map** of Brazil showing average review scores by seller state  
- **Bar chart comparing on-time vs. late deliveries**, with dynamic tooltips summarizing review scores and delivery share  
- **Pie chart** visualizing the proportion of on-time vs. late orders  
- **Decomposition chart** of review scores based on delivery deviation (early, on time, or late), uncovering clear satisfaction patterns

### 🎯 Design Highlights:
-Used **map-based filtering** to update KPIs and all supporting visualizations by state (except the bottom right visualization which is static)
-Applied **custom color schemes** using Tableau Public’s limited palette and hex values (#006400, soft greens, orange, dark gray text)
-Incorporated **sheet-specific shading** for visual segmentation
-Limited dashboard to **one screen**, allowing focused storytelling without excess interactivity

> 📍 View the interactive dashboard: [Tableau Public – Dylan Barrett](https://public.tableau.com/app/profile/dylan.barrett)

---

## Project Summary

This project explored key drivers of customer satisfaction on the Olist platform using SQL-based analysis.  
By joining and transforming multiple datasets, we identified how delivery timing, product categories, seller performance, and geographic patterns affect review scores.

The analysis provides actionable insights for improving seller support, logistics performance, and overall marketplace experience.  
This project also demonstrates end-to-end data preparation, business-oriented querying, and readiness for visualization through tools like Tableau.

## Next Steps

-Expand the dashboard to include more advanced segmentation (e.g., repeat customers, order value)
-Apply predictive modeling to forecast satisfaction based on order conditions
-Consider benchmarking Olist’s performance against industry standards or other marketplaces
