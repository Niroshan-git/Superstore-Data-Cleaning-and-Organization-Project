# Superstore Data Cleaning and Organization Project

## Project Overview
This project demonstrates comprehensive SQL data cleaning and organization techniques using a Superstore dataset. It covers data validation, cleaning, normalization, and restructuring to ensure data integrity and optimal organization.

## Table of Contents
- [Data Cleaning Process](#data-cleaning-process)
  - [Initial Data Import](#initial-data-import)
  - [Data Cleaning Steps](#data-cleaning-steps)
- [Database Normalization](#database-normalization)
- [Key Features](#key-features)
- [Database Schema](#database-schema)
- [Scripts Description](#scripts-description)
- [Skills Demonstrated](#skills-demonstrated)
- [SQL Practice_Questions](#SQL-Practice-Questions)
- [Tools Used](#tools-used)

## Data Cleaning Process

### Initial Data Import
- Created initial table structure
- Imported data from CSV file using the `COPY` command
- Performed initial data validation

### Data Cleaning Steps
- Removed duplicate records
- Eliminated invalid columns
- Cleaned whitespace using `TRIM()`
- Removed special characters from fields
- Standardized date formats to `TIMESTAMP`
- Fixed duplicate product IDs
- Resolved duplicate order IDs

## Database Normalization
The database was normalized into several related tables:

- **location**: Geographic information
- **product_category**: Product categories and subcategories
- **product**: Product details
- **customer**: Customer information
- **order_details**: Order information
- **sales**: Sales transactions (fact table)

## Key Features
- Comprehensive data validation and cleaning
- Handles duplicate product and order IDs
- Proper data type conversion
- Special character removal
- Normalized database structure
- Referential integrity with foreign key constraints

## Database Schema
```sql
location (
    location_id SERIAL PRIMARY KEY,
    region VARCHAR,
    country VARCHAR,
    state VARCHAR,
    city VARCHAR
)

product_category (
    category_id SERIAL PRIMARY KEY,
    category VARCHAR,
    sub_category VARCHAR
)

product (
    product_id VARCHAR PRIMARY KEY,
    product_name VARCHAR,
    category_id INT REFERENCES product_category(category_id)
)

customer (
    customer_id VARCHAR PRIMARY KEY,
    customer_name VARCHAR,
    segment VARCHAR
)

order_details (
    order_id VARCHAR PRIMARY KEY,
    customer_id VARCHAR REFERENCES customer(customer_id),
    order_date TIMESTAMP,
    order_priority VARCHAR,
    ship_mode VARCHAR,
    ship_date TIMESTAMP
)

sales (
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
)
```
## SQL Practice Questions
This project includes a comprehensive set of SQL practice questions divided into three difficulty levels. These questions are designed to help users understand and practice various SQL concepts using the Superstore dataset.

### Easy Questions
```sql

-- Calculate the total revenue for each region
SELECT 
    l.region,
    SUM(s.sales) as "Total Revenue"
FROM sales s
JOIN location l ON s.location_id = l.location_id
WHERE s.sales IS NOT NULL 
GROUP BY l.region
ORDER BY 2 DESC;
```

- Total sales calculation
- Unique regions identification
- Sales transactions per product
- Regional revenue calculation
- Average order value computation
- Customer order analysis
- Regional customer count
- Last month sales calculation
- High-frequency product identification
- Maximum sale value identification

### Medium Questions

```sql
-- Determine the top 5 products by total sales values
SELECT 
    p.product_name,
    SUM(s.sales) as "Total Sale Value"
FROM sales s
JOIN product p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

```


- Monthly sales analysis
- Top 5 products by sales
- Regional sales growth comparison
- Top customer spending analysis
- Regional transaction volume
- Year-over-year category growth
- New customer acquisition tracking
- Annual top-selling products
- Category average order value
- Profit margin analysis

### Hard Questions

```sql

-- Customer Segmentation Example
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(s.sales) AS total_spending
    FROM sales s
    JOIN order_details od ON s.order_id = od.order_id
    JOIN customer c ON c.customer_id = od.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT 
    customer_id,
    customer_name,
    total_spending,
    CASE 
        WHEN total_spending > 10000 THEN 'High Spender'
        WHEN total_spending BETWEEN 5000 AND 10000 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS spender_segment
FROM customer_spending
ORDER BY total_spending DESC;

```

- Rolling average sales calculation
- Pareto analysis (80-20 rule)
- Customer ranking system
- Monthly order value trends
- Category contribution analysis
- Sales decline identification
- Cohort analysis
- Running total calculations
- Quarterly growth analysis
- Customer segmentation

### Key Concepts Covered
- Aggregate Functions
- Window Functions
- CTEs (Common Table Expressions)
- Joins (Inner, Left, Cross)
- Date/Time Functions
- Case Statements
- Subqueries
- Group By and Having Clauses
- Ranking Functions
- Rolling Calculations
- Cohort Analysis
- Customer Segmentation

### Learning Outcomes
After completing these practice questions, users will be able to:
- Write complex SQL queries for business analysis
- Understand and implement data aggregation techniques
- Create meaningful business insights from raw data
- Handle time-series analysis in SQL
- Perform customer segmentation and cohort analysis
- Calculate growth metrics and KPIs
- Implement window functions for advanced analysis

### Tools Used
- PostgreSQL
- SQL

> **Note:** This project is for educational purposes and demonstrates SQL data cleaning, organization techniques, and advanced query writing.
