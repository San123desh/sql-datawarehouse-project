/*
========================================================
Quality Checks
========================================================
Script Purpose:
	This script performs various quality checks for data consistency, accuracy,
	and standardization across the 'silver' schemas. It includes checks for:
		- Null or duplicate primary keys.
		- Unwanted spaces in string fields.
		- Data standardization and consistency.
		- Invalid date ranges and orders
		- Data consistency between related fields.

Usage Notes:
	- Run these checks after data loading Silver Layer.
	- Investigate and resolve any discrepancies found during the checks.
========================================================
*/

-- ======================================================
-- Checking 'silver.crm_cust_info'
-- ======================================================
-- check for nulls or duplicates in primary key
-- Exceptation: No Result

SELECT 
	cst_id,
	count(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id is NULL


-- check for unwanted spaces
-- Exceptation: No Result
SELECT 
	cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)


-- Data Standardization & Consistency
SELECT DISTINCT 
	cst_gndr
FROM silver.crm_cust_info


/* FOR ANOTHER TABLE - PRD*/
-- ==================================================
-- Checking 'silver.crm_prd_info'

-- check for nulls or duplicates in primary key
-- Exceptation: No Result

SELECT 
	prd_id,
	count(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id is NULL


-- Check for unwanted Spaces
-- Expectation: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--Check for null or negative values
SELECT 
	prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standradization & Consistency
SELECT DISTINCT 
	prd_line
FROM silver.crm_prd_info


-- check for Invalid Date Orders(start date > end date)
SELECT 
	*
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

-- ==================================================
-- Checking silver.crm_sales_details

-- check for invalid dates

SELECT
	NULLIF(sls_order_dt,0) sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0
	OR LEN(sls_order_dt) != 8
	OR sls_order_dt > 20500101
	OR sls_order_dt < 19000101

-- check for invalid date orders (order date > shipping/due dates)
SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
	OR sls_order_dt > sls_due_dt


-- check Data consistency: Between Sales, Quantity and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL zero, or negative.

SELECT DISTINCT
	sls_sales ,
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
ORDER BY sls_sales, sls_quantity, sls_price




-- =================================================
-- FOR ERP
-- =================================================

-- Checking silver.erp_cust_az12

-- Identify Out of Range Dates
-- Expectation: Birthdates between 1924-01-01
SELECT DISTINCT
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
	OR bdate > GETDATE()


-- Data Standardization & Consistency
SELECT DISTINCT 
	gen
FROM silver.erp_cust_az12

-- ======================================================
-- Checking silver.erp_loc_a101

-- Data Standardization & Consistency
SELECT DISTINCT 
	cntry
FROM silver.erp_loc_a101
ORDER BY cntry

-- ======================================================
-- Checking silver.erp_px_cat_g1v2

-- check for unwanted spaces
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)


-- Data Standardization & Consistency
SELECT DISTINCT
cat
FROM silver.erp_px_cat_g1v2

-- check data
SELECT * FROM silver.erp_px_cat_g1v2


