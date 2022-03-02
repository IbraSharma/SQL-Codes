
/****** Northwind Script   ******/

/* -- https://www.geeksengine.com/database/problem-solving/northwind-queries-part-1.php -- */

/* 1. Order Subtotals
For each order, calculate a subtotal for each Order (identified by OrderID).
This is a simple query using GROUP BY to aggregate data for each order. */
SELECT
o.OrderID,
CONVERT(DEC(10, 0), SUM((d.UnitPrice * d.Quantity) * (1 - d.Discount))) AS net_sales_subtotal
FROM Orders o
JOIN OrderDetails d ON d.OrderID = o.OrderID
GROUP BY o.OrderID
ORDER BY net_sales_subtotal DESC

/* 2. Sales by Year
This query shows how to get the year part from Shipped_Date column. A subtotal is calculated by a sub-query for each order.
The sub-query forms a table and then joined with the Orders table. */

SELECT 
DISTINCT CAST(o.ShippedDate AS date) AS ShippedDate,
o.OrderID,
sub.net_sales_subtotal,
YEAR(o.ShippedDate) AS Year
FROM Orders o
JOIN
(
SELECT
o.OrderID AS OrderID,
CONVERT(DEC(10, 0), SUM((d.UnitPrice * d.Quantity) * (1 - d.Discount))) AS net_sales_subtotal
FROM Orders o
JOIN OrderDetails d ON d.OrderID = o.OrderID
GROUP BY o.OrderID
) sub ON o.OrderID = sub.OrderID
WHERE o.ShippedDate IS NOT NULL
AND o.ShippedDate BETWEEN CAST('1996-12-24' as date) and CAST('1997-09-30' as date)
order by  ShippedDate

/* 3. Employee Sales by Country
For each employee, get their sales amount, broken down by country name. */


SELECT
Country,
FirstName +' '+ LastName AS FullName,
sub.net_sales_subtotal AS EmployeeSales
FROM Employees e
JOIN 
(
SELECT
o.EmployeeID AS EmployeeID,
CONVERT(DEC(10, 0), SUM((d.UnitPrice * d.Quantity) * (1 - d.Discount))) AS net_sales_subtotal
FROM Orders o
JOIN OrderDetails d ON d.OrderID = o.OrderID
GROUP BY o.EmployeeID) sub ON e.EmployeeID = sub.EmployeeID



/*  ---  JOIN a table with a subquery --- 
For each product category, we want to know at what average unit 
price they were sold and what the average unit price we would 
like to sell for.
 
Subquery is used in FROM clause to get table x which returns the 
average unit price sold for each product category.
 
Table y in the join clause returns the average unit price 
we'd like to sell for each product category.
 
Then table x is joined with table y for each category to prevent dupicates
*/

SELECT 
y.CategoryID,
y.CategoryName,
ROUND(x.Actual_Unit_Price,2) AS Actual_Avg_Unit_Price,
ROUND(y.Planned_Unit_Price,2) AS Planned_Avg_Unit_Price
FROM
(
SELECT 
c.CategoryID,
AVG(a.UnitPrice) AS Actual_Unit_Price
FROM OrderDetails AS a
JOIN Products AS p on P.ProductID = a.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryID
) AS x

JOIN 
(
SELECT 
c.CategoryID , c.CategoryName,
AVG(p.UnitPrice) AS Planned_Unit_Price
FROM Products AS p
JOIN Categories c ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName, c.CategoryID
) AS y ON x.CategoryID = y.CategoryID


                  --- Using subquery to return a single value (known as single-value subquery or scalar subquery ---

-- Use subquery in WHERE clause with an aggregate function:
/*  
This query returns data for all customers and their 
orders where the orders were shipped on the most 
recent recorded day.
 
The execution steps:
 
1. The subquery 
 
   select max(ShippedDate) from orders
 
in the WHERE clause uses aggregate function max to return 
the maximum ship date in the orders table and it returns 
1998-05-06 00:00:00
 
2. Then, 1998-05-06 00:00:00 is used in the outer query to 
compare with ShippedDate.
 
   select OrderID, CustomerID
   from orders
   where ShippedDate = '1998-05-06 00:00:00'
 
*/
select OrderID, CustomerID
from orders
where ShippedDate = (select max(ShippedDate) from orders);


-- Use subquery in WHERE clause with an aggregate function:
/*
This query returns all products whose unit price
is greater than average unit price.
*/
select distinct ProductName, UnitPrice
from products
where UnitPrice>(select avg(UnitPrice) from products)
order by UnitPrice desc;

-- Use subquery in SELECT statement with an aggregate function
/*
This query lists the percentage of total units in 
stock for each product.
 
The subquery 
 
    select sum(UnitsInStock) from products
 
works out the total units in stock which is 3119.
 
Then 3119 is used in the outer query to calculate the
percentage of total units in stock for each product.
*/
select ProductID,
       ProductName,
		CAST(CAST((UnitsInStock / (select cast(sum(UnitsInStock) as decimal) from products)) * 100 AS decimal(7,2)) as varchar(5)) + ' %' AS Percent_of_total_units_in_stock
from products
order by ProductID;

-- Use subquery and join clause.

/* to retrieve the shipping company's ID and name in the
joined table shippers. */

select a.ShipperID, 
       a.CompanyName,
       b.Freight
from shippers as a
join orders as b on a.ShipperID=b.ShipVia
where b.Freight = (select max(Freight) from orders);


---      Using subquery to return a list of values (known as column subquery)  ----------
--Use subquery to return a list of values.
/*
This query retrieves a list of customers that made 
purchases after the date 1998-05-01.
 
The subquery returns a list of CustomerIDs which is
used in outer query.
*/
select CustomerID, CompanyName
from customers
where CustomerID IN
(
   select CustomerID 
   from orders 
   where orderDate > '1998-05-01'
);

-- Use inner join to return the same result as using a subquery
/*
This query returns the same result as the one
in Practice #1 but here no subquery is used. 
Instead, we used inner join. 
 
Often, a query that contains subqueries can be 
rewritten as a join.
 
Using inner join allows the query optimizer to 
retrieve data in the most efficient way.
*/
select a.CustomerID, a.CompanyName
from customers as a
inner join orders as b on a.CustomerID = b.CustomerID
where b.orderDate > '1998-05-01'

---      Using subquery to return one or more rows of values (known as row subquery) ---
--- Use subquery to return rows of values

/*
This query finds out all the employees who live
in the same city and country as customers.
 
The subquery returns a table of two columns and
91 rows. It's returned to outer query and City
and Country in employees table are compared with
each row in the table.
Note: without DISTINCT we wil see each row of employee vs customers (there is employee live togather in same city and country of many customers)
*/

SELECT 
DISTINCT EmployeeID , EmployeeName, City, Country
FROM

(
select 
EmployeeID,
FirstName + '' + LastName AS EmployeeName,
City,
Country
from employees
) AS Employee

JOIN
(
SELECT 
ContactName AS CustomerName,
City AS CustomerCity,
Country AS CustomerCountry
from Customers
) AS Customers 
ON Employee.City = Customers.CustomerCity 
AND Employee.Country = Customers.CustomerCountry


/*
Because a product can be sold at a discount, 
we want to know the highest unit price ever 
sold for each product.
 
This query reveals the highest unit price
for each product sold. 
 
The inner query returns a temporary table that 
contains ProductID and maximum price for the product.
 
This temporary table is then returned to outer query to use.
*/

select distinct a.ProductID, a.UnitPrice as Max_unit_price_sold
from OrderDetails as a
JOIN
(
    select ProductID, max(UnitPrice) as Max_unit_price_sold
    from OrderDetails 
    group by ProductID
) as b
on a.ProductID=b.ProductID and a.UnitPrice=b.Max_unit_price_sold
order by a.ProductID;

-- Another way to solve it getting the same result

SELECT DISTINCT a.ProductID, a.Max_unit_price_sold
FROM 
(
SELECT ProductID AS ProductID, max(UnitPrice) AS Max_unit_price_sold
FROM OrderDetails 
GROUP BY ProductID
) a
JOIN 
(
select ProductID AS ProductID, UnitPrice as Max_unit_price_sold
from OrderDetails
) b ON a.ProductID =b.ProductID AND a.Max_unit_price_sold = b.Max_unit_price_sold
ORDER BY a.ProductID

-- https://www.geeksengine.com/database/subquery/return-rows-of-values.php -- 