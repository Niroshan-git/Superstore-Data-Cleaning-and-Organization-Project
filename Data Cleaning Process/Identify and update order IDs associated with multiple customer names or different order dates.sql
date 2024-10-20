-- Step 1: Identify and update order IDs associated with multiple customer names or different order dates
WITH ranked_order_id AS (
    SELECT 
        order_id,
        customer_name,
        order_date,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY customer_name, order_date) AS row_num
    FROM superstore_cleaned
),
new_order_ids AS (
    SELECT 
        order_id,
        customer_name,
        order_date,
        CASE 
            WHEN row_num > 1 THEN order_id || '-' || row_num
            ELSE order_id
        END AS new_order_id
    FROM ranked_order_id
)
UPDATE superstore_cleaned sc
SET order_id = noi.new_order_id
FROM new_order_ids noi
WHERE sc.order_id = noi.order_id
  AND sc.customer_name = noi.customer_name
  AND sc.order_date = noi.order_date
  AND (
    EXISTS (
      SELECT 1
      FROM new_order_ids
      WHERE order_id = sc.order_id
      GROUP BY order_id
      HAVING COUNT(DISTINCT customer_name) > 1 OR COUNT(DISTINCT order_date) > 1
    )
  );

-- Check the updated data
SELECT order_id, customer_name, order_date
FROM superstore_cleaned
WHERE order_id ISNULL
ORDER BY order_id, customer_name, order_date;