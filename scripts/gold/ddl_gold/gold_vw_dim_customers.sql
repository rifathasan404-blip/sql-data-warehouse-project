-- =============================================================================
-- View:         gold.vw_dim_customers
-- Description:  Dimension view for customer data, consolidating customer profile
--               information from CRM and ERP source systems into a unified, 
--               analytics-ready format for the Gold layer.
-- Dependencies: silver.crm_cust_info | silver.erp_cust_az12 | silver.erp_loc_a101
-- =============================================================================

CREATE OR ALTER VIEW gold.vw_dim_customers AS

SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_id)  AS customer_key,      -- Surrogate key
    ci.cst_id                               AS customer_id,
    ci.cst_key                              AS customer_number,
    ci.cst_firstname                        AS first_name,
    ci.cst_lastname                         AS last_name,
    loc.cntry                               AS country,
    ci.cst_marital_status                   AS marital_status,

    -- Derive gender from CRM; fall back to ERP if CRM value is unavailable
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr 
         ELSE ISNULL(az.gen, 'n/a') 
    END                                     AS gender,

    az.bdate                                AS birthdate,
    ci.cst_create_date                      AS create_date

FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12  az  ON ci.cst_key = az.cid   -- Enrich with ERP demographics
LEFT JOIN silver.erp_loc_a101   loc ON ci.cst_key = loc.cid  -- Enrich with ERP location
