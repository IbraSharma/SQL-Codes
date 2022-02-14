-- The clients who had cancelled orders (fields to be extracted: client name, country, city);
SELECT 
c.customerName AS ClientName,
c.country AS Country,
c.city AS City
FROM orders o
JOIN customers c ON c.customerNumber = o.customerNumber
WHERE status = 'Cancelled'

--  Total orders which were not cancelled, split per year and month (fields to be extracted: year, month, orders);

SELECT 
YEAR(orderDate) AS Year,
MONTH(orderDate) AS Month,
COUNT(orderNumber) AS Count_Orders
FROM orders 
WHERE status <>  'Cancelled'
GROUP BY 
YEAR(orderDate),
MONTH(orderDate)
ORDER BY Year, Month

 /* the top 3 products for each product line with the highest inventory value (by inventory value we 
refer to the total value of the cars that are the same - fields to be extracted: product line, 
productcode, productname, total value); */

WITH CTE AS (
SELECT 
productLine AS ProductLine,
productName AS ProductName,
productcode AS ProductCode,
sum(quantityInstock) as Total_Inventory,
DENSE_RANK() OVER ( PARTITION BY ProductLine ORDER BY sum(quantityInstock) DESC) AS rn
FROM products
GROUP BY productLine, productName, productcode
)
SELECT 
*
FROM CTE
WHERE rn < 4
