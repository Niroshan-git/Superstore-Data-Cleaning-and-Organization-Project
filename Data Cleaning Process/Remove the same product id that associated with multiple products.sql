-- Remove the same product id that associated with multiple products
-- Step 1: Identify product IDs associated with multiple product names
WITH duplicate_products AS (
    SELECT product_id, COUNT(DISTINCT product_name) AS name_count
    FROM superstore_cleaned
    GROUP BY product_id
    HAVING COUNT(DISTINCT product_name) > 1
)
SELECT sc.product_id, sc.product_name
FROM superstore_cleaned sc
JOIN duplicate_products dp ON sc.product_id = dp.product_id
ORDER BY sc.product_id, sc.product_name;


-- Step 2: Create a new table with correct product IDs
CREATE TABLE corrected_products AS
WITH ranked_products AS (
    SELECT 
        product_id,
        product_name,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_name) AS row_num
    FROM superstore_cleaned
)
SELECT 
    CASE 
        WHEN row_num > 1 THEN product_id || '-' || row_num
        ELSE product_id
    END AS new_product_id,
    product_id AS original_product_id,
    product_name
FROM ranked_products;



-- Step 3: Update the main table with the new product IDs
UPDATE superstore_cleaned sc
SET product_id = cp.new_product_id
FROM corrected_products cp
WHERE sc.product_id = cp.original_product_id
  AND sc.product_name = cp.product_name;


--- Check the data----
SELECT * FROM corrected_products

