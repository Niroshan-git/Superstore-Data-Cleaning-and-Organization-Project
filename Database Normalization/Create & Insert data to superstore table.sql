----01. Create the table
----02. Insert the data to the table

----- Create a table to get the all the data--------------

DROP TABLE IF EXISTS superstore;
CREATE TABLE superstore (
    Category VARCHAR,
    City VARCHAR,
    Country VARCHAR,
    Customer_ID VARCHAR,
    Customer_Name VARCHAR, 
    Discount DECIMAL (10,2),
    Market VARCHAR,
    Invalid_Column VARCHAR,
    Order_Date VARCHAR, 
    Order_ID VARCHAR, 
    Order_Priority VARCHAR, 
    Product_ID VARCHAR, 
    Product_Name VARCHAR,
	Profit float,
    Quantity INT,
    Region VARCHAR,
    Row_ID VARCHAR,
    Sales VARCHAR,
    Segment VARCHAR,
    Ship_Date VARCHAR, 
    Ship_Mode VARCHAR, 
    Shipping_Cost VARCHAR, 
    State VARCHAR,
    Sub_Category VARCHAR, 
    Year VARCHAR,
    Market2 VARCHAR,
    weeknum INT
);


----------Insert the data to the table ------------------------------

COPY superstore
FROM 'D:\Projects\SQL\Portfolio\PF 01 -Sales Performance/superstore.csv'
DELIMITER ',' 
CSV HEADER;


-------------Check the column are created correctly--------------------

select * from superstore

------------Check the data count in the table -------------------------

select count(*) as "Data_Count" from superstore












