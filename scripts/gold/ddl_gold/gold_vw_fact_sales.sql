-- =============================================================================
-- View:         gold.vw_fact_sales
-- Description:  Fact view for sales transactions, integrating sales order details
--               with customer and product dimension keys to support dimensional
--               analysis and reporting in the Gold layer.
-- Dependencies: silver.crm_sales_details | gold.vw_dim_customers | gold.vw_dim_products
-- =============================================================================

CREATE OR ALTER VIEW gold.vw_fact_sales AS

SELECT
    sd.sls_ord_num   AS order_number,
    c.customer_key,                     -- FK to gold.vw_dim_customers
    p.product_key,                      -- FK to gold.vw_dim_products
    sd.sls_order_dt  AS order_date,
    sd.sls_ship_dt   AS shipping_date,
    sd.sls_due_dt    AS due_date,
    sd.sls_sales     AS sales_amount,
    sd.sls_quantity  AS quantity,
    sd.sls_price     AS price

FROM silver.crm_sales_details sd
LEFT JOIN gold.vw_dim_customers c  ON sd.sls_cust_id  = c.customer_id    -- Resolve customer surrogate key
LEFT JOIN gold.vw_dim_products  p  ON sd.sls_prd_key  = p.product_number  -- Resolve product surrogate key
