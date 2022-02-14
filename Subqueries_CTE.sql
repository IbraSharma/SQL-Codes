-- SQL Subqueries and Temporary Tables

-- Find the average number of orders for each day for each Brand.

SELECT Brand_Name, AVG(num_orders) AS Avg_Number_Orders
FROM 
(
SELECT
brand_name AS Brand_Name,
DATEPART(DAY,order_date) AS daily,
COUNT(*) AS num_orders
FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id
JOIN production.products p ON p.product_id = i.product_id
JOIN production.brands b ON b.brand_id = p.brand_id
GROUP BY brand_name, DATEPART(DAY,order_date)
) a
GROUP BY Brand_Name

---  first sum qty at first month each brand

SELECT * FROM 
(
SELECT 
brand_name,
order_date,
sum(quantity) as QTY,
ROW_NUMBER() OVER (PARTITION BY YEAR(order_date), MONTH(order_date) ORDER BY order_date) AS rn
--SUM(quantity)  OVER (PARTITION BY order_date) AS sum_qty
FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id
JOIN production.products p ON p.product_id = i.product_id
JOIN production.brands b ON b.brand_id = p.brand_id
GROUP BY brand_name, order_date
) a
WHERE rn = 1

-- Provide the name of the product in each brand with the largest amount of total_qty sales from its brand.
SELECT
sub2.Brand,
sub1.Product,
sub2.Max_Total_QTY
FROM
(
SELECT 
brand_name AS Brand,
product_name AS Product,
sum(quantity) as Total_QTY
FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id
JOIN production.products p ON p.product_id = i.product_id
JOIN production.brands b ON b.brand_id = p.brand_id
GROUP BY brand_name, product_name
) sub1
JOIN
(
SELECT Brand, MAX(Total_QTY) Max_Total_QTY
FROM
(
SELECT 
brand_name AS Brand,
product_name AS Product,
sum(quantity) as Total_QTY
FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id
JOIN production.products p ON p.product_id = i.product_id
JOIN production.brands b ON b.brand_id = p.brand_id
GROUP BY brand_name, product_name
) sub
GROUP BY Brand 
) sub2
ON sub1.Brand = sub2.Brand
AND sub1.Total_QTY = sub2.Max_Total_QTY
ORDER BY 3

--For the Brand with the largest (sum) of QTY, how many total (count) orders were placed? 

SELECT 
brand_name AS Brand,
sum(quantity) as Total_QTY,
COUNT(*) AS Count_orders
FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id
JOIN production.products p ON p.product_id = i.product_id
JOIN production.brands b ON b.brand_id = p.brand_id
GROUP BY brand_name
ORDER BY Total_QTY DESC
OFFSET 0 ROWS 
FETCH NEXT 1 ROWS ONLY

-- For the name of the account that purchased the most (in total over their
-- lifetime as a customer) Total_QTY, how many customers still had more in total purchases?
SELECT COUNT(*)
FROM
(
SELECT 
c.first_name,
ROUND(SUM(list_price * quantity),0) Total_Sales
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
JOIN sales.order_items i ON i.order_id = o.order_id
GROUP BY c.first_name
HAVING ROUND(SUM(list_price * quantity),0) > 
(
SELECT Total_Sales
FROM 
(
		SELECT 
		SUM(quantity) as Total_QTY,
		ROUND(SUM(list_price * quantity),0) as Total_Sales
		FROM sales.orders o
		JOIN sales.order_items i ON i.order_id = o.order_id
		JOIN sales.customers c ON c.customer_id = o.customer_id
		GROUP BY o.customer_id
		ORDER BY Total_QTY DESC
		OFFSET 0 ROWS 
		FETCH NEXT 1 ROWS ONLY
		) sub1

 /*
What is the lifetime average amount spent in terms of total_amt_usd for 
the top 10 total spending accounts?
*/

SELECT AVG(Total_Sales) Avg_spent
FROM
(
SELECT 
o.customer_id,
ROUND(SUM(list_price * quantity),0) as Total_Sales
FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id
JOIN sales.customers c ON c.customer_id = o.customer_id
GROUP BY o.customer_id
ORDER BY Total_Sales DESC
OFFSET 0 ROWS 
FETCH NEXT 10 ROWS ONLY
) sub

/*
What is the lifetime average amount spent in terms of total_amt_usd for 
only the companies that spent more than the average of all orders.
*/

SELECT AVG(Avg_Total_Sales) AVG_Total
FROM
(
SELECT 
o.customer_id,
ROUND(AVG(list_price * quantity),0) as Avg_Total_Sales
FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id
JOIN sales.customers c ON c.customer_id = o.customer_id
GROUP BY o.customer_id
) sub

WHERE Avg_Total_Sales > 
(SELECT ROUND(AVG(list_price * quantity),0) as Avg_Total_Sales
FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id)

/*
For the name of the customer that purchased the most (in total over their 
lifetime as a customer) , how many accounts still had 
more in total purchases?
*/


WITH 
sub1  AS (
SELECT 
SUM(quantity) as Total_QTY,
ROUND(SUM(list_price * quantity),0) as Total_Sales
FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id
JOIN sales.customers c ON c.customer_id = o.customer_id
GROUP BY o.customer_id
ORDER BY Total_Sales DESC
OFFSET 0 ROWS 
FETCH NEXT 1 ROWS ONLY
),
sub2 AS (
SELECT 
c.first_name AS Name,
ROUND(SUM(list_price * quantity),0) as Total_Sales
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
JOIN sales.order_items i ON i.order_id = o.order_id
GROUP BY c.first_name
HAVING ROUND(SUM(list_price * quantity),0) > ( SELECT Total_Sales FROM sub1)
)
SELECT COUNT(*) FROM sub2

-------

SELECT 
brand_name AS Brand,
sum(quantity) as Total_QTY,
COUNT(*) AS Count_orders
FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id
JOIN production.products p ON p.product_id = i.product_id
JOIN production.brands b ON b.brand_id = p.brand_id
GROUP BY brand_name
ORDER BY Total_QTY DESC


-- Count of products for each brand
SELECT 
brand_name AS Brand,
ProductCount = ( SELECT COUNT(p.product_id) FROM production.products p WHERE p.brand_id = b.brand_id)
FROM production.brands b
---
SELECT 
DATEPART(MONTH,order_date) As order_month,
DATEPART(YEAR,order_date) As order_year,
COUNT(DISTINCT o.order_id) AS num_orders,
COUNT(p.product_id) AS num_products,
ROUND(SUM(i.list_price * quantity),0) as Total_Sales
FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id
JOIN production.products p ON p.product_id = i.product_id
JOIN production.brands b ON b.brand_id = p.brand_id
GROUP BY  
DATEPART(MONTH,order_date),
DATEPART(YEAR,order_date)
ORDER BY 1
