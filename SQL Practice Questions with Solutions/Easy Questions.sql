-------------------------------EASY----------------------------------------------------------

-----------01. Retrive the total sales for all products--------------------------------------

select SUM(sales) from sales

-----------02.List all unqiue Regions where sales occured-----------------------------------

SELECT DISTINCT l.region FROM sales s
join location l on s.location_id = l.location_id
where s.sales IS NOT NULL 
ORDER BY l.region ASC;

-----------03. Find the number of sales transactions for each product----------------------

SELECT 
p.product_id,
p.product_name,
COUNT(s.sale_id) as "Number of Sales"
FROM sales s
join product p on s.product_id = p.product_id
GROUP BY p.product_id , p.product_name
ORDER BY 3 DESC;


---------04. Calculate the total revenue for each region------------------------------------

SELECT 
l.region,
sum(s.sales) as "Total Revenue"
FROM sales s
join location l on s.location_id = l.location_id
where s.sales IS NOT NULL 
GROUP BY l.region
ORDER BY 2 DESC;

-------05. Retrieve the average order value--------------------------------------------

SELECT ROUND(AVG(sales) / AVG(quantity), 2) AS "Average Order Value"
FROM sales;

-------06. List all customers who have placed atleast onde order---------------------------

SELECT 
c.customer_id,
c.customer_name,
count(od.order_id) as "Total Orders Placed"
FROM order_details od
join customer c on od.customer_id = c.customer_id
Group By c.customer_id, c.customer_name
HAVING count(od.order_id) >= 1
ORDER BY 3 DESC


------07.Find the total number of customers in each region-------------------------------------

select 
l.region,
count(DISTINCT c.customer_name)
FROM
order_details od
inner join sales s on od.order_id = s.order_id
inner join location l on s.location_id = l.location_id
inner join customer c on od.customer_id = c.customer_id
GROUP BY 1


------08. Calculate the number of sales made in the last month-----------------------------------
--- Get the last order date & from that calculate the last month

WITH last_order AS (
  SELECT MAX(order_date) AS max_order_date
  FROM sales
)
SELECT COUNT(sale_id) 
FROM sales, last_order
WHERE order_date >= DATE_TRUNC('month', max_order_date) - INTERVAL '1 month'
AND order_date < DATE_TRUNC('month', max_order_date);


------09. List products that have been sold 20 times OR more --------------------------------

SELECT 
p.product_id,
p.product_name,
COUNT(s.sale_id) as "Number of Sales"
FROM sales s
join product p on s.product_id = p.product_id
GROUP BY p.product_id , p.product_name
HAVING COUNT(s.sale_id) >= 20
ORDER BY 3 DESC;

-----10. Find the highest sale value for a single order-------------------------------

SELECT 
  order_id,
  sales
FROM sales
WHERE sales = (SELECT MAX(sales) FROM sales);







