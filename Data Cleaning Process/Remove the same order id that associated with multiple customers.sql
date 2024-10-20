-- Remove the same order id that associated with multiple customers
-- Step 1: Identify order IDs associated with multiple customer names
WITH duplicate_order_id AS (
    SELECT order_id, COUNT(DISTINCT customer_name) AS name_count
    FROM superstore_cleaned
    GROUP BY order_id
    HAVING COUNT(DISTINCT customer_name) > 1
)
SELECT sc.order_id, sc.customer_name
FROM superstore_cleaned sc
JOIN duplicate_order_id di ON sc.order_id = di.order_id
ORDER BY sc.order_id, sc.customer_name;


-- Step 2: Create a new table with correct order IDs
DROP TABLE IF EXISTS corrected_order_id;
CREATE TABLE corrected_order_id AS
WITH ranked_order_id AS (
    SELECT 
        order_id,
        customer_name,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY customer_name) AS row_num
    FROM superstore_cleaned
)
SELECT 
    CASE 
        WHEN row_num > 1 THEN order_id || '-' || row_num
        ELSE order_id
    END AS new_order_id,
    order_id AS original_order_id,
    customer_name
FROM ranked_order_id;



-- Step 3: Update the main table with the new product IDs
UPDATE superstore_cleaned sc
SET order_id = cp.new_order_id
FROM corrected_order_id cp
WHERE sc.order_id = cp.original_order_id
  AND sc.customer_name = cp.customer_name;


--- Check the data----
SELECT * FROM corrected_order_id
