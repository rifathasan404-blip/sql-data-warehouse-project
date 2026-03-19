-- =============================================================================
-- View:         gold.vw_dim_products
-- Description:  Dimension view for product data, consolidating product details
--               and category classifications from CRM and ERP source systems
--               into a unified, analytics-ready format for the Gold layer.
-- Dependencies: silver.crm_prd_info | silver.erp_px_cat_g1v2
-- =============================================================================

CREATE OR ALTER VIEW gold.vw_dim_products AS

SELECT
    ROW_NUMBER() OVER (ORDER BY cp.prd_start_dt, cp.prd_key)  AS product_key,  -- Surrogate key
    cp.prd_id        AS product_id,
    cp.prd_key       AS product_number,
    cp.prd_nm        AS product_name,
    cp.cat_id        AS category_id,
    pxc.cat          AS category,
    pxc.subcat       AS sub_category,
    pxc.maintenance,
    cp.prd_cost      AS product_cost,
    cp.prd_line      AS product_line,
    cp.prd_start_dt  AS product_start_date,
    cp.prd_end_dt    AS product_end_date

FROM silver.crm_prd_info cp
LEFT JOIN silver.erp_px_cat_g1v2 pxc ON cp.cat_id = pxc.id  -- Enrich with ERP category classifications

WHERE cp.prd_end_dt IS NULL  -- Active products only; excludes historically versioned records
