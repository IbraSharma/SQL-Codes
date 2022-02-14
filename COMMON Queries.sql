-- https://www.youtube.com/watch?v=L-URbfgxBMQ

-- count rows 
SELECT
     product_name
    ,list_price,
     ROW_NUMBER() OVER(ORDER BY list_price DESC) RowNumber
FROM production.products

-- count of unique categories
select count(distinct(category_name))
from production.categories


--Rank without tie
SELECT
     product_name
    ,list_price,
     RANK() OVER(ORDER BY list_price DESC) RowNumber
FROM production.products

-- Rank with ties 
SELECT 
     product_name
    ,list_price,
       DENSE_RANK() OVER(ORDER BY list_price DESC) Rank
FROM production.products
ORDER BY Rank;

-- SQL PARTITION By clause to divide the data into a smaller subset (Rank without tie)
-- each category_name get rank as per their list_price irrespective of the specific product_name
SELECT 
category_name
,product_name
,list_price,
RANK() OVER(PARTITION BY category_name ORDER BY list_price DESC) Rank
FROM production.products p
JOIN production.categories g ON p.category_id = g.category_id
ORDER BY category_name, Rank;

--Rank with ties 

SELECT 
category_name
,product_name
,list_price,
DENSE_RANK() OVER(PARTITION BY category_name ORDER BY list_price DESC) Rank
FROM production.products p
JOIN production.categories g ON p.category_id = g.category_id
ORDER BY category_name, Rank;


-- Second High price 1

SELECT
    list_price
	FROM (
	SELECT product_name, list_price,
     ROW_NUMBER() OVER(ORDER BY list_price DESC) RowNumber
FROM production.products) b
WHERE RowNumber =  2

-- Second High price 2 

SELECT DISTINCT
list_price AS SecondHighestPrice
FROM production.products
ORDER BY list_price DESC
OFFSET 1 ROWS
FETCH NEXT 1 ROWS ONLY

-- Ninght Highest Salary

SELECT DISTINCT
list_price AS SecondHighestPrice
FROM production.products
ORDER BY list_price DESC
OFFSET 8 ROWS
FETCH NEXT 1 ROWS ONLY

-- Unique value of categorires and thier lenght
SELECT distinct
category_name
,LEN(category_name) AS ctegorylenght
from production.categories

-- dateiff 
SELECT 
customer_id,
order_id,
order_date,
Year(order_date) * 10000 + Month(order_date) * 100 + Day(order_date) AS DateKey,
shipped_date,
required_date,
DATEDIFF(day, order_date, required_date) + 1 AS ORRQd_inclusive,
DATEDIFF(day, order_date, shipped_date) + 1 AS ORSHd_inclusive,
DATEDIFF(day,order_date,convert(date, GETDATE()))  LastOrderDays
FROM sales.orders
ORDER BY order_id

-- Today in Date
SELECT convert(date, GETDATE())

-- Category that have more than 50 product
SELECT 
category_name
,COUNT(product_id) as ProductCount
from production.categories c
JOIN production.products p ON c.category_id = p.category_id
GROUP BY category_name
HAVING COUNT(product_id) > 50

-- Display details of all category except  Children Bicycles
SELECT * FROM production.categories 
WHERE category_name <> 'Children Bicycles'

SELECT * FROM production.categories 
WHERE category_name != 'Children Bicycles'

-- Print details of order sales before 2018-04-28 and after may 2017 order date
SELECT 
customer_id,
order_id,
order_date
FROM sales.orders
WHERE order_date > '2016-05-31' AND order_date < '2018-04-28'

-- Third High price 

SELECT
    list_price
	FROM (
	SELECT product_name, list_price,
     ROW_NUMBER() OVER(ORDER BY list_price DESC) RowNumber
FROM production.products) b
WHERE RowNumber =  3


-- Third High price 

SELECT
    *
	FROM (
	SELECT * FROM production.products order by list_price desc OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY) as t
	order by list_price desc OFFSET 2 ROWS


-- Print al Alternate rows in a table
-- product_id is not divided by 2 

SELECT * FROM production.products WHERE product_id % 2 = 1

-- Alternate
WITH CTE AS 
(
SELECT *, ROW_NUMBER() OVER(ORDER BY product_id DESC) RowNumber
FROM production.products )

SELECT * FROM cte WHERE RowNumber % 2 = 0

-- fitch all duplicates in production.products table
SELECT 
product_id,
product_name,
COUNT(*) as dupproduct
FROM production.products
GROUP BY product_id,product_name
HAVING COUNT(product_id) > 1 AND COUNT(product_name) > 1

-- Display prodcuts with exactly 2 S's in thier name

SELECT * SELECT * FROM production.products WHERE product_id % 2 = 1

SELECT LEN(REPLACE(UPPER(product_name), 'S', ''))
FROM production.products

SELECT * FROM production.products 
WHERE LEN(product_name) - LEN(REPLACE(UPPER(product_name), 'C', '')) = 2

-- Extract string 
SELECT SUBSTRING('Michel Balack', 2, 4) -- from the second charachter included return next 4 charachters included
SELECT SUBSTRING('Michel Balack', 4, 3)

-- self join herarchy Employee ro report to manager 

SELECT 
e.first_name +' '+ e.last_name AS Emplyee,
m.first_name +' '+ m.last_name AS Manager
FROM sales.staffs e
JOIN sales.staffs m ON m.staff_id = e.manager_id
ORDER BY Manager

-- Virtual table = View table on database

-- Write sql table to fetch the list of prodcut with the same price
SELECT DISTINCT p.product_id,
p.product_name,
p.list_price
FROM production.products p, production.products p1
WHERE p.list_price = p1.list_price
AND p.product_id > p1.product_id
ORDER BY p.list_price

-- Write an SQL query to print one row twice in results from a table ( duplicate)
SELECT * FROM production.categories c WHERE c.category_name = 'Electric Bikes'
UNION ALL 
SELECT * FROM production.categories c1 WHERE c1.category_name = 'Electric Bikes'

-- Using the num table, write qyery to add 10 where number is 1, 20 when number is 2, esle print the number intself
SELECT category_id,
CASE 
WHEN category_id = 1  THEN category_id + 10
WHEN category_id = 2  THEN category_id + 20
ELSE category_id END AS num_add
FROM production.categories

--  write a query to find the sum of all quanitity values below 10 sum of all quanitity values above 10 
-- Using simple CASE expression in aggregate function example
SELECT
SUM (CASE WHEN quantity < 10 THEN quantity ELSE 0 END) as sum_under_10,
SUM (CASE WHEN quantity > 10 THEN quantity ELSE 0 END) as sum_above_10
FROM production.products p 
JOIN production.stocks s ON p.product_id = s.product_id

-- Diffrent between Primary Key and Foreign Key
-- Primery Key: uniquely identify a record in the table. can't accept null values. only one primary key in a table.
-- Foriegn Key: Field in a table that is primary key in another table. can't accept null values. More than one foriegn key in a table.

-- What is a check constraint in SQL?
-- Assuming we have created this table:
CREATE TABLE dummy1 (eid int PRIMARY KEY, city VARCHAR(30)
CHECK (city= 'Mumbai'), age int CHECK (age>0));

--the below inset command will throw an error
insert into dummy1 values(101, 'Delhi', 10);

-- Given 2 tables A (sales.order_items) and B (production.products) write a query to fetch values in table B that are not present in A
SELECT 
product_name,
order_id
FROM production.products p 
LEFT JOIN sales.order_items i ON p.product_id= i.product_id
WHERE order_id IS NULL
ORDER BY order_id

-- another way
SELECT product_name FROM production.products 
WHERE product_id NOT IN 
(SELECT product_id FROM sales.order_items)

-- Find customers who don't have any orders. First check distinct both tables
SELECT DISTINCT customer_id FROM sales.customers
SELECT DISTINCT customer_id FROM sales.orders

-- then extract null 
SELECT 
first_name,
order_id
FROM sales.customers c 
LEFT JOIN sales.orders o ON o.customer_id= c.customer_id
WHERE c.customer_id IS NULL
ORDER BY c.customer_id

-- or another way 
SELECT 
customer_id
FROM sales.customers  WHERE customer_id NOT IN 
( SELECT customer_id FROM sales.orders)

-- Using Orders table find all the month end orders
SELECT * FROM sales.orders
WHERE order_date = EOMONTH(order_date)
ORDER BY 2

--Find the to 5 highest product price in  2017
SELECT DISTINCT
list_price,
product_name,
model_year
FROM production.products
WHERE model_year = 2017
ORDER BY list_price DESC
OFFSET 0 ROWS
FETCH NEXT 5 ROWS ONLY 

-- Another way 
SELECT TOP 5 list_price, product_name
FROM production.products
WHERE model_year = 2017
ORDER BY list_price DESC

-- Display the total products in each category
SELECT 
category_name
,COUNT(product_id) as ProductCount
from production.categories c
JOIN production.products p ON c.category_id = p.category_id
GROUP BY category_name
ORDER BY ProductCount DESC
-- Another way 
SELECT category_name, COUNT(*) totalProducts
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id
GROUP BY category_name
ORDER BY COUNT(*) DESC

-- Find the late orders for all customers 
SELECT 
first_name + ' ' + last_name Fullname,
COUNT(*) Lateorder
FROM sales.customers c 
JOIN sales.orders o ON o.customer_id= c.customer_id
WHERE required_date <= shipped_date
GROUP BY first_name + ' ' + last_name
ORDER BY Lateorder DESC

