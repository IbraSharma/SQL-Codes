-- Totals
SELECT store_name,Net_Sales,
SUM(Net_Sales) OVER(ORDER BY Net_Sales DESC) AS Runn_Total,
SUM(Net_Sales) OVER() AS Grand_Sales
FROM 
(
SELECT 
store_name,
ROUND(SUM(quantity * list_price * (1 - discount)),0) AS Net_Sales
FROM sales.orders s, sales.stores st, sales.order_items ot
WHERE s.store_id = st.store_id AND s.store_id = ot.order_id
GROUP BY store_name) a
ORDER BY Net_Sales DESC
------------------
-- Which account (by name) placed the earliest order
SELECT o.*,
first_name + ' ' + last_name AS FullName
FROM sales.orders o
JOIN sales.customers c ON o.customer_id = c.customer_id
WHERE order_date =
(SELECT MIN(order_date)  FROM sales.orders)
---------------------

-- Find the number of customers in each prodcut
SELECT product_name ,COUNT(customer_id) AS Count_Customers FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id
JOIN production.products p ON p.product_id = i.product_id 
GROUP BY product_name
HAVING COUNT(customer_id) > 99
ORDER BY Count_Customers DESC

--------------

--Find the sales in terms of total dollars for all 
SELECT Date_Year,store_name,Net_Sales

FROM 
(
SELECT 
DATEPART(YEAR,order_date) AS Date_Year,
store_name,
ROUND(SUM(quantity * list_price * (1 - discount)),0) AS Net_Sales
FROM sales.orders s, sales.stores st, sales.order_items ot
WHERE s.store_id = st.store_id AND s.store_id = ot.order_id
GROUP BY DATEPART(YEAR,order_date), store_name) a
ORDER BY Date_Year ASC,Net_Sales DESC

-- Which month did Parch & Posey have the greatest sales
SELECT Date_Month, Net_Sales, Order_Count

FROM 
(
SELECT 
DATEPART(MONTH,order_date) AS Date_Month,
ROUND(SUM(quantity * list_price * (1 - discount)),0) AS Net_Sales,
COUNT(*) AS Order_Count
FROM sales.orders s, sales.stores st, sales.order_items ot
WHERE s.store_id = st.store_id AND s.store_id = ot.order_id
GROUP BY DATEPART(MONTH,order_date)) a
ORDER BY Date_Month ASC,Net_Sales DESC

-- 3 different levels of customers based on the amount associated with their total purchases.
-- greater than 200,000 usd top, between 200,000 and 100,000 middle, else lowest

SELECT *,
CASE 
WHEN Net_Sales > 20000 THEN 'top'
WHEN Net_Sales BETWEEN 10000 AND  20000 THEN 'middle'
ELSE 'lowest' END AS class
FROM
(
SELECT 
first_name + ' ' + last_name AS FullName,
ROUND(SUM(quantity * list_price * (1 - discount)),0) AS Net_Sales
FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id
JOIN sales.customers c ON c.customer_id = o.customer_id
GROUP BY first_name + ' ' + last_name
) a
ORDER BY Net_Sales DESC

-- We would like to identify top performing sales staff, which are sales reps associated with more than 1000 orders.
-- Create a table with the sales rep name, the total number of orders, and a column with top or not depending on if they have more than 200 orders.

SELECT *,
CASE 
WHEN Net_Sales > 20000 THEN 'top'
WHEN Net_Sales BETWEEN 10000 AND  20000 THEN 'middle'
ELSE 'lowest' END AS class,
CASE WHEN Count_Order > 1000 THEN 'top'
ELSE 'not' END AS top_or_not
FROM
(
SELECT 
first_name + ' ' + last_name AS FullName_Staff,
ROUND(SUM(quantity * list_price * (1 - discount)),0) AS Net_Sales,
COUNT(*) AS Count_Order
FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id
--JOIN sales.customers c ON c.customer_id = o.customer_id
JOIN sales.staffs sf ON sf.staff_id = o.staff_id
GROUP BY first_name + ' ' + last_name
) a
ORDER BY Count_Order DESC

-- We would like to identify top performing sales reps, which are sales reps associated with more 
-- than 200 orders or more than 750000 in total sales. The middle group 
-- has any rep with more than 150 orders or 500000 in sales

SELECT *,
CASE 
WHEN Count_Order > 1000 OR Net_Sales > 1000000 THEN 'top'
WHEN Count_Order BETWEEN 500 AND 1000 OR Net_Sales BETWEEN 600000 AND 1000000 THEN 'middle'
ELSE 'low' END AS top_or_not
FROM
(
SELECT 
first_name + ' ' + last_name AS FullName_Staff,
ROUND(SUM(quantity * list_price * (1 - discount)),0) AS Net_Sales,
COUNT(*) AS Count_Order
FROM sales.orders o
JOIN sales.order_items i ON i.order_id = o.order_id
--JOIN sales.customers c ON c.customer_id = o.customer_id
JOIN sales.staffs sf ON sf.staff_id = o.staff_id
GROUP BY first_name + ' ' + last_name
) a
ORDER BY Count_Order DESC
