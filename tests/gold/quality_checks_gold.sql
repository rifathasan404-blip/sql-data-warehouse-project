/*
===============================================================================
Quality Checks -- Gold Layer
===============================================================================
Script Purpose:
    Validates the integrity, consistency, and accuracy of the Gold Layer views
    by performing the following checks:
    - Uniqueness of surrogate keys in dimension views.
    - Referential integrity between the fact view and dimension views.

Usage Notes:
    - Each check includes an expectation comment indicating the desired result.
    - Any returned rows indicate a data quality issue that must be investigated
      and resolved before promoting to production.
===============================================================================
*/


-- ============================================================================
-- Checking 'gold.vw_dim_customers'
-- ============================================================================

-- Uniqueness of customer_key
-- Expectation: No results
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.vw_dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ============================================================================
-- Checking 'gold.vw_dim_products'
-- ============================================================================

-- Uniqueness of product_key
-- Expectation: No results
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.vw_dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ============================================================================
-- Checking 'gold.vw_fact_sales'
-- ============================================================================

-- Referential integrity between fact and dimension views
-- Expectation: No results; every sales record must resolve to a valid customer and product
SELECT * 
FROM gold.vw_fact_sales f
LEFT JOIN gold.vw_dim_customers c ON c.customer_key = f.customer_key
LEFT JOIN gold.vw_dim_products  p ON p.product_key  = f.product_key
WHERE c.customer_key IS NULL 
   OR p.product_key  IS NULL;
