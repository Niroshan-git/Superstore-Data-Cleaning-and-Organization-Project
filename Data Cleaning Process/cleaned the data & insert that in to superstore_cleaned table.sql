-----01.Data Cleaning-------------------


---- Check all the columns that has dublicate values-------------

select DISTINCT  * from superstore;

-----Insert not dublicated values to new table-----------------

CREATE TABLE superstore_cleaned as
(select DISTINCT  * from superstore)

------Delete the invalid column--------------------

ALTER TABLE superstore_cleaned
DROP COLUMN invalid_column;

-------Remove unwanted Spaces-----------------------

UPDATE superstore_cleaned
SET 
    Category = TRIM(Category),
    City = TRIM(City),
    Country = TRIM(Country),
    Customer_ID = TRIM(Customer_ID),
    Customer_Name = TRIM(Customer_Name),
    Market = TRIM(Market),
    Order_Date = TRIM(Order_Date),
    Order_ID = TRIM(Order_ID),
    Order_Priority = TRIM(Order_Priority),
    Product_ID = TRIM(Product_ID),
    Product_Name = TRIM(Product_Name),
    Region = TRIM(Region),
    Row_ID = TRIM(Row_ID),
    Sales = TRIM(Sales),
    Segment = TRIM(Segment),
    Ship_Date = TRIM(Ship_Date),
    Ship_Mode = TRIM(Ship_Mode),
    Shipping_Cost = TRIM(Shipping_Cost),
    State = TRIM(State),
    Sub_Category = TRIM(Sub_Category),
    Year = TRIM(Year),
    Market2 = TRIM(Market2);

-----------Remove Special Characters------------------

UPDATE superstore_cleaned
SET 
    Customer_Name = REPLACE(Customer_Name, '@', ''),
    Sales = REPLACE(Sales, '$', ''),
    Product_Name = REPLACE(Product_Name, '#', ''),
    state = REPLACE(REPLACE(state, '#', ''), '''', ''),
	city = REPLACE(REPLACE(city, '#', ''), '''', ''),
	country = REPLACE(REPLACE(country, '#', ''), '''', '');


--------Conver the dates to timestamp--------------------

ALTER TABLE superstore_cleaned
ALTER COLUMN order_date TYPE TIMESTAMP USING order_date::TIMESTAMP,
ALTER COLUMN ship_date TYPE TIMESTAMP USING ship_date::TIMESTAMP;



select * from superstore_cleaned

