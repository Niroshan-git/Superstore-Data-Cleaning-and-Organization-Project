-----------------------Medium Questions------------------------------------

------01. Calculate the total sales by month---------------------

select 
DATE_TRUNC('month', order_date) as "Sale Month",
sum(sales)
from sales
group by 1
order by 1


-----02. Determine the top 05 products by total sales values--------------

select 
p.product_name,
sum(s.sales) as "Total Sale Value"
FROM sales s
join product p on s.product_id = p.product_id
group by 1
order by 2 Desc
Limit 5


----03. Find the regions with the highest sales growth compared to last year---------------------
WITH max_year AS (
    SELECT EXTRACT(YEAR FROM MAX(order_date))  AS year
    FROM sales
),
current_year_sales AS (
    SELECT 
        l.region,
        EXTRACT(YEAR FROM MAX(s.order_date)) AS year,
        SUM(s.sales) AS total_sales
    FROM 
        sales s
    JOIN 
        location l ON s.location_id = l.location_id
    JOIN
        max_year my ON EXTRACT(YEAR FROM s.order_date) = my.year
    GROUP BY 
        l.region
),
last_year_sales AS (
    SELECT 
        l.region,
        EXTRACT(YEAR FROM MAX(s.order_date)) AS year,
        SUM(s.sales) AS total_sales
    FROM 
        sales s
    JOIN 
        location l ON s.location_id = l.location_id
    JOIN
        max_year my ON EXTRACT(YEAR FROM s.order_date) = my.year - 1
    GROUP BY 
        l.region
)
SELECT 
    cys.region,
    cys.year AS current_year,
    cys.total_sales AS current_year_sales,
    lys.year AS last_year,
    lys.total_sales AS last_year_sales,
   	ROUND( (cys.total_sales - lys.total_sales) / lys.total_sales * 100,2) AS growth_percentage
FROM 
    current_year_sales cys
JOIN 
    last_year_sales lys ON cys.region = lys.region
ORDER BY 
    growth_percentage DESC;

----04. Retrive top 10 customers by total spending---------------------------------------------

select 
c.customer_name,
sum(sales) as "Total spend by customer"
from sales s
join order_details od on s.order_id = od.order_id
join customer c on od.customer_id = c.customer_id
group by 1
order by 2 DESC
LIMIT 10

---05. Identify the region with the most sales transations----------------------------------------

select 
l.region,
count(s.order_id) as "Number of Sales Transactions"
from sales s
join location l on s.location_id = l.location_id
group by 1
order by 2 Desc
Limit 1


--06. Calculate the year over year growth for each product category------------------------------------------------------

WITH sales_data AS (
    SELECT 
        p.category_id,
        pc.category,
        s.year,
        SUM(s.sales) AS total_sales
    FROM 
        sales s
    JOIN product p ON s.product_id = p.product_id
    JOIN product_category pc ON p.category_id = pc.category_id
    GROUP BY 
        p.category_id,
        pc.category,
        s.year
),
yearly_growth AS (
    SELECT 
        sd1.category_id,
        sd1.category,
        sd1.year,
        sd1.total_sales,
        CASE WHEN sd2.total_sales IS NULL THEN NULL
             ELSE sd1.total_sales - sd2.total_sales
        END AS sales_difference,
        CASE WHEN sd2.total_sales IS NULL THEN NULL
             ELSE ROUND(((sd1.total_sales - sd2.total_sales) / sd2.total_sales) * 100, 2)
        END AS yoy_growth_percentage
    FROM 
        sales_data sd1
    LEFT JOIN 
        sales_data sd2 ON sd1.category_id = sd2.category_id AND sd1.year = sd2.year + 1
)
SELECT 
    category,
    year,
    SUM(total_sales) AS "Total Sales",
    SUM(sales_difference) AS "Total Sales Difference",
    CASE WHEN SUM(total_sales) = 0 THEN NULL
         ELSE ROUND((SUM(sales_difference) / SUM(total_sales)) * 100, 2)
    END AS yoy_growth_percentage
FROM 
    yearly_growth
GROUP BY 
    category,
    year
ORDER BY
    category ASC,
    year ASC;

-- 07. Find the number of new customers aquired each month------------------------------------------

WITH first_order_date AS (
    SELECT 
        od.customer_id,
        EXTRACT(year FROM MIN(od.order_date)) AS year,
        EXTRACT(month FROM MIN(od.order_date)) AS month
    FROM order_details od
    JOIN customer c ON od.customer_id = c.customer_id
    GROUP BY od.customer_id
)
SELECT 
    COUNT(customer_id) AS new_customers,
    year,
    month
FROM first_order_date
GROUP BY year, month
ORDER BY year, month;

---08. Determine the top selling product in each year------------------------------------

WITH products_sell AS (
    SELECT 
        p.product_name,
        EXTRACT(YEAR FROM s.order_date) AS year,
        SUM(s.sales) AS "Total Sales"
    FROM sales s
    JOIN product p ON s.product_id = p.product_id
    JOIN location l ON s.location_id = l.location_id 
    GROUP BY 1, 2),
	
ranked_products AS (
    SELECT 
        product_name,
        year,
        "Total Sales",
        RANK() OVER (PARTITION BY year ORDER BY "Total Sales" DESC) AS rank
    FROM products_sell
)
SELECT 
    product_name,
    year,
    "Total Sales"
FROM ranked_products
WHERE rank = 1
ORDER BY year;

-- 09.Calculate the average order value for each product category--------------------------------

select 
pc.category,
ROUND(AVG(s.sales),2) AS "Average Sale"
from sales s
join product p on s.product_id = p.product_id
join product_category pc on p.category_id = pc.category_id
group by 1

--- 10. List the top 05 products with highest ptofit margins--------------------------------------

SELECT 
    p.product_name,
    round((SUM(s.profit) / NULLIF(SUM(s.sales), 0)) * 100, 2) AS "Profit Margin"
FROM 
    sales s
JOIN 
    product p ON s.product_id = p.product_id
GROUP BY 
    p.product_name
ORDER BY 
    "Profit Margin" DESC
LIMIT 5;











