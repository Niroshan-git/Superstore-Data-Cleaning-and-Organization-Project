------------------ Hard Questions-------------------------------------------------------
---01. Calculate the rolling average sales for each product over the past 06 months -------------

/*	The rolling average, also known as a moving average, is a calculation used to 
	analyze data points by creating a series of averages of different subsets of the full data set */

WITH monthly_sales AS (
    SELECT 
        product_id,
        EXTRACT(YEAR FROM order_date) AS year,
        EXTRACT(MONTH FROM order_date) AS month,
        SUM(sales) AS total_sales
    FROM 
        sales
    GROUP BY 
        product_id, EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
)
SELECT 
    product_id,
    year,
    month,
    ROUND(AVG(total_sales) OVER (
        PARTITION BY product_id
        ORDER BY year, month
        ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_avg_sales
FROM 
    monthly_sales
ORDER BY 
    product_id, year, month;


-- 02. Identify the top 03 regions contributing to 80% of the sales revenue

WITH region_sales AS (
    SELECT 
        l.region,
        SUM(s.sales) AS total_sales,
        SUM(SUM(s.sales)) OVER () AS overall_total_sales
    FROM sales s
    JOIN location l ON s.location_id = l.location_id
    GROUP BY l.region
),
ranked_regions AS (
    SELECT 
        region,
        total_sales,
        total_sales / overall_total_sales * 100 AS percentage_of_total_sales,
        SUM(total_sales) OVER (ORDER BY total_sales DESC) / overall_total_sales * 100 AS cumulative_percentage
    FROM region_sales
    ORDER BY total_sales DESC
)
SELECT 
    region,
    ROUND(percentage_of_total_sales, 2) AS percentage_of_total_sales,
    ROUND(cumulative_percentage, 2) AS cumulative_percentage
FROM ranked_regions
WHERE cumulative_percentage <= 80
LIMIT 3;

-- 03. Use window function to rank customers based on total purchase frequency--------------------

WITH customer_purchase_frequency AS (
    SELECT 
        c.customer_name,
        COUNT(*) AS purchase_count
    FROM 
        sales s
		join order_details od on s.order_id = od.order_id
		join customer c on od.customer_id = c.customer_id
    GROUP BY 
        c.customer_name
)
SELECT 
    customer_name,
    purchase_count,
    RANK() OVER (ORDER BY purchase_count DESC) AS purchase_rank,
    DENSE_RANK() OVER (ORDER BY purchase_count DESC) AS purchase_dense_rank,
    ROW_NUMBER() OVER (ORDER BY purchase_count DESC) AS purchase_row_number
FROM 
    customer_purchase_frequency
ORDER BY 
    purchase_count DESC, customer_name;


--- 04. Write the query to find the monthly trend for the average order value--------------------------------------

WITH monthly_orders AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS order_month,
        order_id,
        SUM(sales) AS order_value
    FROM 
        sales
    GROUP BY 
        DATE_TRUNC('month', order_date),
        order_id
)
SELECT 
    order_month,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(order_value), 2) AS average_order_value,
    ROUND(SUM(order_value), 2) AS total_sales
FROM 
    monthly_orders
GROUP BY 
    order_month
ORDER BY 
    order_month;

-- 05. Determine the percentage conribution of each product category to the overall sales----------------

with category_sales as
			(select 
				pc.category,
				sum(s.sales) as "Category Total Sales"
			from sales s
			join product p on s.product_id = p.product_id
			join product_category pc on p.category_id = pc.category_id
			group by 1),
grand_total as 
			(select 
			sum(sales) as "Total Sales"
			from sales)

select 
	cs.category,
	cs."Category Total Sales",
	ROUND((cs."Category Total Sales" / gt."Total Sales")* 100 ,2) AS "Percentage Contribution"
from category_sales cs
cross join grand_total gt
order by 2 DESC

-- 06. Identify products with declining sales over the last three quarters-----------------------------------------------

WITH quarterly_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        DATE_TRUNC('quarter', s.order_date) AS quarter,
        SUM(s.sales) AS total_sales,
        ROW_NUMBER() OVER (PARTITION BY p.product_id ORDER BY DATE_TRUNC('quarter', s.order_date) DESC) AS quarter_rank
    FROM 
        sales s
    JOIN 
        product p ON s.product_id = p.product_id
    GROUP BY 
        p.product_id, p.product_name, DATE_TRUNC('quarter', s.order_date)
),
last_three_quarters AS (
    SELECT *
    FROM quarterly_sales
    WHERE quarter_rank <= 3
)
SELECT 
    product_id,
    product_name,
    MAX(CASE WHEN quarter_rank = 3 THEN quarter END) AS oldest_quarter,
    MAX(CASE WHEN quarter_rank = 3 THEN total_sales END) AS oldest_quarter_sales,
    MAX(CASE WHEN quarter_rank = 2 THEN quarter END) AS middle_quarter,
    MAX(CASE WHEN quarter_rank = 2 THEN total_sales END) AS middle_quarter_sales,
    MAX(CASE WHEN quarter_rank = 1 THEN quarter END) AS latest_quarter,
    MAX(CASE WHEN quarter_rank = 1 THEN total_sales END) AS latest_quarter_sales
FROM 
    last_three_quarters
GROUP BY 
    product_id, product_name
HAVING 
    MAX(CASE WHEN quarter_rank = 1 THEN total_sales END) < MAX(CASE WHEN quarter_rank = 2 THEN total_sales END)
    AND MAX(CASE WHEN quarter_rank = 2 THEN total_sales END) < MAX(CASE WHEN quarter_rank = 3 THEN total_sales END)
ORDER BY 
    product_id;


-- 07. Write a query to generate a cohort analysis of customer acqusition.-----------------------------------------------------------

WITH cohort AS (
    -- Assign each customer to a cohort based on their acquisition month
    SELECT 
		c.customer_id,
        c.customer_name,
        MIN(DATE_TRUNC('month', od.order_date)) AS cohort_month
    FROM customer c
	join order_details od on c.customer_id = od.customer_id
	
    GROUP BY 1, c.customer_name
),
activity AS (
    -- Calculate the number of active customers in each cohort over time
    SELECT 
        c.cohort_month,
        DATE_TRUNC('month', od.order_date) AS activity_month,
        COUNT(DISTINCT c.customer_id) AS active_customers
    FROM cohort c
   	join order_details od on c.customer_id = od.customer_id
    GROUP BY c.cohort_month, activity_month
),
cohort_size AS (
    -- Calculate the size of each cohort
    SELECT 
        cohort_month,
        COUNT(customer_id) AS cohort_size
    FROM cohort
    GROUP BY cohort_month
)
-- Final output: calculate retention rate for each cohort over time
SELECT 
    a.cohort_month,
    a.activity_month,
    a.active_customers,
    cs.cohort_size,
    ROUND(a.active_customers::numeric / cs.cohort_size * 100, 2) AS retention_rate
FROM activity a
JOIN cohort_size cs ON a.cohort_month = cs.cohort_month
ORDER BY a.cohort_month, a.activity_month;


/*A cohort is a group of individuals who share a common characteristic or experience within a defined time period. 
In business and data analysis, cohort analysis refers to studying these groups over time to track and understand their behavior.

In the context of customer acquisition, a cohort might refer to a group of customers who were acquired during the same period, 
such as a month, a week, or a specific campaign. You can then track how this group (or cohort) behaves over time, 
such as how many of them make repeat purchases, engage with the product, or stay active.

For example:

Acquisition Cohort: Customers who signed up in January 2024 form one cohort. 
	Another cohort might be customers who signed up in February 2024. You can analyze how each of these cohorts engages with your business over time.
Behavioral Cohort: 
	A cohort could also be defined by actions like making a first purchase, activating a subscription, or downloading an app.
Cohort analysis allows businesses to track retention, customer lifetime value, or other performance metrics by group, 
helping identify patterns and trends over time, such as retention rates or revenue growth for each cohort. */


--- 08 Calculate the running total of sales each region---------------------------------

select 
l.region,
s.order_date,
s.sales,
sum(s.sales) over (partition by l.region order by s.order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  ) as "Running Total"
from sales s
join location l on s.location_id = l.location_id


-- 09 Find products that have consistently grown in sales every quarter-------------------------------------------------

WITH quarterly_sales AS (
    -- Summarize sales by product and quarter
    SELECT 
        product_id,
        DATE_TRUNC('quarter', order_date) AS quarter,
        SUM(sales) AS total_sales
    FROM sales
    GROUP BY product_id, DATE_TRUNC('quarter', order_date)
),
growth_check AS (
    -- Rank the quarters for each product and calculate sales difference
    SELECT 
        product_id,
        quarter,
        total_sales,
        LAG(total_sales) OVER (PARTITION BY product_id ORDER BY quarter) AS previous_sales
    FROM quarterly_sales
),
consistently_growing AS (
    -- Check if sales grew each quarter
    SELECT 
        product_id
    FROM growth_check
    WHERE previous_sales IS NOT NULL   -- Ignore the first quarter for comparison
    AND total_sales > previous_sales   -- Ensure current sales are greater than the previous quarter
    GROUP BY product_id
    HAVING COUNT(*) = (SELECT COUNT(*) FROM quarterly_sales qs WHERE qs.product_id = growth_check.product_id) - 1
    -- The product must show growth in all quarters (one less because we can't compare the first quarter)
)
-- Select final list of products with consistent sales growth
SELECT DISTINCT product_id
FROM consistently_growing;

---10. create a query that segments customers in to high, medium and low spenders-----------------------------------------


WITH customer_spending AS (
    -- Calculate total spending for each customer
    SELECT 
        c.customer_id,
		c.customer_name,
        SUM(s.sales) AS total_spending
    FROM sales s
	join order_details od on s.order_id = od.order_id
	join customer c on c.customer_id = od.customer_id
    GROUP BY c.customer_id , 2
)
-- Segment customers based on their total spending
SELECT 
    customer_id,
	customer_name,
    total_spending,
    CASE 
        WHEN total_spending > 10000 THEN 'High Spender'   -- Define threshold for high spenders
        WHEN total_spending BETWEEN 5000 AND 10000 THEN 'Medium Spender' -- Threshold for medium spenders
        ELSE 'Low Spender'    -- Threshold for low spenders
    END AS spender_segment
FROM customer_spending
ORDER BY total_spending DESC;






