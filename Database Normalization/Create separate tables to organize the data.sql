----01. Create separate tables to organize the data------------------
----02. Inster the data from superstore_cleaned table to newly created tables-----------------

------------------------------------------------ Location table---------------------------------------------------------------------------------------------------------------
--	create the table

DROP TABLE IF EXISTS location;
CREATE TABLE location (
    location_id SERIAL PRIMARY KEY,
    region VARCHAR,
    country VARCHAR,
    state VARCHAR,
    city VARCHAR,
    UNIQUE (region, country, state, city)
);

-- Insert data to the table
INSERT INTO location (region, country, state, city)
SELECT DISTINCT Region, Country, State, City FROM superstore_cleaned;

-- Check the data
SELECT * FROM location;



-------------------------------------------------------------- Product Category table------------------------------------------------------------------------------------------
-- Create the table
CREATE TABLE product_category (
    category_id SERIAL PRIMARY KEY,
    category VARCHAR,
    sub_category VARCHAR,
    UNIQUE (category, sub_category)
);

-- Insert data to the table
INSERT INTO product_category (category, sub_category)
SELECT DISTINCT Category, Sub_Category FROM superstore;

-- Check the data
SELECT * FROM product_category;



----------------------------------------------------- Product table--------------------------------------------------------------------------------
-- Create the table
CREATE TABLE product (
    product_id VARCHAR PRIMARY KEY,
    product_name VARCHAR,
    category_id INT REFERENCES product_category(category_id)
);



-- Insert data to the table
INSERT INTO product (product_id, product_name, category_id)
SELECT DISTINCT s.Product_ID, s.Product_Name, pc.category_id
FROM superstore_cleaned s
JOIN product_category pc ON s.Category = pc.category AND s.Sub_Category = pc.sub_category


-- Check the data
SELECT DISTINCT Product_id, Product_name FROM product
order by product_id



--------------------------------------------------------------- Customer table--------------------------------------------------------------------------------
DROP TABLE IF EXISTS customer;
CREATE TABLE customer (
    customer_id VARCHAR PRIMARY KEY,
    customer_name VARCHAR,
    segment VARCHAR
);


-- Insert data to the table
INSERT INTO customer (customer_id, customer_name, segment)
SELECT DISTINCT Customer_ID, Customer_Name, Segment FROM superstore_cleaned;


-- Check the data
SELECT * FROM customer;

-------------------------------------------------------------- Order table-------------------------------------------------------------------------------------
DROP TABLE IF EXISTS order_details;
CREATE TABLE order_details (
    order_id VARCHAR PRIMARY KEY ,
    customer_id VARCHAR REFERENCES customer(customer_id),
    order_date TIMESTAMP,
    order_priority VARCHAR,
    ship_mode VARCHAR,
    ship_date TIMESTAMP
);



-- Insert data to the table
INSERT INTO order_details (order_id, customer_id, order_date, order_priority, ship_mode, ship_date)
SELECT DISTINCT Order_ID, Customer_ID, order_date, Order_Priority, Ship_Mode, ship_date
FROM superstore_cleaned
;





------------------------------------------------------------ Sales table (fact table)-------------------------------------------------------------------------
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    order_id VARCHAR REFERENCES order_details(order_id),
    product_id VARCHAR REFERENCES product(product_id),
    location_id INT REFERENCES location(location_id),
    quantity INT,
    sales DECIMAL(10,2),
    discount DECIMAL(10,2),
    profit DECIMAL(10,2),
    shipping_cost DECIMAL(10,2),
    order_date TIMESTAMP,
    ship_date TIMESTAMP,
    year INT,
    weeknum INT
);

-- Insert data into the sales table
INSERT INTO sales (order_id, product_id, location_id, quantity, sales, discount, profit, shipping_cost, order_date, ship_date, year, weeknum)
SELECT 
    s.Order_ID, 
    s.Product_ID, 
    l.location_id, 
    s.Quantity, 
    CAST(REPLACE(s.Sales, '$', '') AS DECIMAL(10,2)),
    s.Discount,
    s.Profit,
    CAST(REPLACE(s.Shipping_Cost, '$', '') AS DECIMAL(10,2)),
    s.Order_Date,  -- Directly use the timestamp
    s.Ship_Date,   -- Directly use the timestamp
    CAST(s.Year AS INT),
    s.weeknum
FROM superstore_cleaned s
JOIN location l ON s.Region = l.region AND s.Country = l.country AND s.State = l.state AND s.City = l.city;

select * from product
where product_id = 'OFF-PA-10002005'

select * from product
where product_id = 'OFF-PA-10002005'
