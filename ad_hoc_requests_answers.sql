-- 1. List of products with a base price greater than $500 and that are featured in promo type of 'BOGOF' (Buy One Get One Free).
SELECT DISTINCT p.product_name, e.base_price, e.promo_type
FROM dim_products p
JOIN fact_events e ON p.product_code = e.product_code
WHERE e.base_price > 500 AND e.promo_type = 'BOGOF';

-- ---------------------------------------------------------------------
-- 2. Generate a report that provides an overview of the number of stores in each city. 
-- The results will be sorted in descending order of store counts, allowing us to identify the cities with the highest store presence. 
-- The report includes two essential fields: city and store count, which will assist in optimizing our retail operations.

SELECT city, COUNT(*) AS store_count
FROM dim_stores
GROUP BY city
ORDER BY store_count DESC;

-- ---------------------------------------------------------------------
--  3. Total revenue generated before and after the campaign
SELECT c.campaign_name,
    ROUND(SUM(CASE WHEN e.`quantity_sold(before_promo)` IS NOT NULL THEN e.base_price * e.`quantity_sold(before_promo)` ELSE 0 END) / 1000000, 2) AS total_revenue_before_promotion_millions,
    ROUND(SUM(CASE WHEN e.`quantity_sold(after_promo)` IS NOT NULL THEN e.base_price * e.`quantity_sold(after_promo)` ELSE 0 END) / 1000000, 2) AS total_revenue_after_promotion_millions
FROM dim_campaigns c
LEFT JOIN fact_events e ON c.campaign_id = e.campaign_id
GROUP BY c.campaign_name;

-- ---------------------------------------------------------------------
-- 4.  Produce a report that calculates the Incremental Sold Quantity (ISU%) for each category during the Diwali campaign. 
-- Additionally, provide rankings for the categories based on their ISU%. The report will include three key fields:
-- category, isu%, and rank order. This information will assist in assessing the category-wise success and impact of the Diwali campaign on incremental sales.
-- Note: ISU% (Incremental Sold Quantity Percentage) is calculated as the percentage increase/decrease in quantity sold (after promo) compared to quantity sold (before promo)

SELECT p.category,
    ROUND(((SUM(e.`quantity_sold(before_promo)`) - SUM(e.`quantity_sold(after_promo)`)) / SUM(e.`quantity_sold(before_promo)`)) * 100, 2) AS isu_percentage,
    RANK() OVER (ORDER BY ((SUM(e.`quantity_sold(after_promo)`) - SUM(e.`quantity_sold(before_promo)`)) / SUM(e.`quantity_sold(before_promo)`)) DESC) AS rank_order
FROM dim_products p
JOIN fact_events e ON p.product_code = e.product_code
JOIN dim_campaigns c ON e.campaign_id = c.campaign_id
WHERE c.campaign_name = 'Diwali'
GROUP BY p.category;

-- ---------------------------------------------------------------------
-- Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), across all campaigns. The report will provide essential information including product name, category, and ir%. 
-- This analysis helps identify the most successful products in terms of incremental revenue across our campaigns, assisting in product optimization.

SELECT p.product_name, p.category,
    ROUND(((SUM(e.`quantity_sold(before_promo)` * e.base_price) - SUM(e.`quantity_sold(after_promo)` * e.base_price)) / (SUM(e.`quantity_sold(before_promo)` * e.base_price))) * 100, 2) AS ir_percentage
FROM dim_products p
JOIN fact_events e ON p.product_code = e.product_code
GROUP BY p.product_name, p.category
ORDER BY ir_percentage DESC
LIMIT 5;
