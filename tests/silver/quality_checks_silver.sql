-- Quality checks for silver layer
-- Run this after loading silver layer data
-- If anything comes back investigate it

-- =============================================
-- Silver.crm_cust_info
-- =============================================

-- Making sure there are no duplicate or null primary keys
-- Should return nothing
SELECT 
	cst_id,
	COUNT(*)  
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Checking for extra spaces in cst_key
SELECT 
	cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Just checking what values we have in marital status
SELECT DISTINCT 
	cst_marital_status 
FROM silver.crm_cust_info;


-- =============================================
-- Silver.crm_prd_info
-- =============================================

-- Duplicate/null check on primary key
SELECT 
	prd_id,
	COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Spaces check
SELECT 
	prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- No negative or null costs allowed
SELECT 
	prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check product line values
SELECT DISTINCT 
	prd_line 
FROM silver.crm_prd_info;

-- Start date should never be after end date
SELECT 
	* 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- =============================================
-- Silver.crm_sales_details
-- =============================================

-- Checking for bad dates in bronze before they get loaded
SELECT 
	NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
	OR LEN(sls_due_dt) != 8 
	OR sls_due_dt > 20500101 
	OR sls_due_dt < 19000101;

-- Order date should come before ship and due dates
SELECT 
	* 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Sales must equal quantity * price, also no nulls or zeros
SELECT DISTINCT 
	sls_sales,
	sls_quantity,
	sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- =============================================
-- Silver.erp_cust_az12
-- =============================================

-- Birthdates should be less than equal today
SELECT DISTINCT 
	bdate 
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();

-- Checking gender values
SELECT DISTINCT 
	gen 
FROM silver.erp_cust_az12;


-- =============================================
-- Silver.erp_loc_a101
-- =============================================

-- Checking what countries we have
SELECT DISTINCT 
	cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;


-- =============================================
-- Silver.erp_px_cat_g1v2
-- =============================================

-- Checking for spaces in cat, subcat and maintenance columns
SELECT 
	* 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- See what maintenance values exist
SELECT DISTINCT 
	maintenance 
FROM silver.erp_px_cat_g1v2;
