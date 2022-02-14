-- calculates the sales percentile for each sales staff in 2017
SELECT 
CONCAT_WS(' ',first_name,last_name) full_name,
net_sales, 
CUME_DIST() OVER ( ORDER BY net_sales DESC ) cume_dist
FROM sales.vw_staff_sales t
JOIN sales.staffs m on m.staff_id = t.staff_id
WHERE year = 2017;

--------------------------------------

--- CUME_DIST() function over a partition
-- calculate the sales percentile for each sales staff in 2016 and 2017.
SELECT 
CONCAT_WS(' ',first_name,last_name) full_name,
net_sales, 
CUME_DIST() OVER ( PARTITION BY YEAR ORDER BY net_sales DESC ) cume_dist
FROM sales.vw_staff_sales t
JOIN sales.staffs m on m.staff_id = t.staff_id
WHERE YEAR IN (2016,2017);

--------------------------------------

-- get the top 20% of sales staff by net sales in 2016 and 2017‎
WITH cte_sales AS (
SELECT 
CONCAT_WS(' ',first_name,last_name) full_name,
net_sales, 
CUME_DIST() OVER ( PARTITION BY YEAR ORDER BY net_sales DESC ) cume_dist
FROM sales.vw_staff_sales t
JOIN sales.staffs m on m.staff_id = t.staff_id
WHERE YEAR IN (2016,2017)
)
SELECT * FROM cte_sales WHERE cume_dist <= 0.2;

--------------------------------------

-- DENSE_RANK() ‎
--- function returns consecutive rank
-- rank products by list prices

SELECT 
product_id,
product_name,
list_price,
DENSE_RANK() OVER ( ORDER BY list_price DESC) price_rank
FROM production.products

-- ranks products in each category by list prices‎. returns only the top 3 products per category by list prices.
SELECT * FROM 
(
SELECT 
product_id,
product_name,
category_id,
list_price,
DENSE_RANK() OVER ( PARTITION BY category_id ORDER BY list_price DESC) price_rank
FROM production.products) t 
WHERE price_rank < 3;


--------------------------------------

-- FIRST_VALUE Function
-- Comfort Bicycles was the lowest volume in 2017
SELECT * FROM sales.vw_category_sales_volume
WHERE year = 2017
ORDER BY year, category_name, qty

---- return category name with the lowest sales volume in 2017‎
SELECT 
category_name,
year,
qty,
FIRST_VALUE(category_name) OVER ( ORDER BY qty) lowest_sales_volume
FROM sales.vw_category_sales_volume
WHERE YEAR = 2017

-- return product categories with the lowest sales volumes in 2016 and 2017.
SELECT 
category_name,
year,
qty,
FIRST_VALUE(category_name) OVER (PARTITION BY year ORDER BY qty) lowest_sales_volume
FROM sales.vw_category_sales_volume
WHERE YEAR IN (2016,2017);

--------------------------------------

-- LAST_VALUE 
SELECT * FROM sales.vw_category_sales_volume
WHERE year = 2016
ORDER BY year, category_name, qty

--- -- return category name with the highest sales volume in 2016
SELECT 
category_name,
year,
qty,
LAST_VALUE(category_name) OVER ( ORDER BY qty RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) highest_sales_volume 
FROM sales.vw_category_sales_volume
WHERE YEAR = 2016

-- return product categories with the highest sales volumes in 2016 and 2017‎
SELECT 
category_name,
year,
qty,
LAST_VALUE(category_name) OVER ( PARTITION BY year ORDER BY qty RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) highest_sales_volume 
FROM sales.vw_category_sales_volume
WHERE YEAR IN (2016,2017)

--------------------------------------
-- LAG Function

SELECT * FROM sales.vw_netsales_brands
ORDER BY year, month, brand_name, net_sales

-- return the net sales of the current month and the previous month in the year 2018‎
WITH cte_netsales_2018 AS (
SELECT 
month, 
SUM(net_sales) net_sales
FROM  sales.vw_netsales_brands
WHERE year = 2018 
GROUP BY month)
SELECT 
month,
net_sales,
LAG(net_sales,1) OVER ( ORDER BY month) previous_month_sale
FROM cte_netsales_2018

-- compare the sales of the current month with the previous month of each brand in the year ‎‎2018‎
SELECT 
month,
brand_name,
net_sales,
LAG(net_sales,1) OVER ( PARTITION BY brand_name ORDER BY month) previous_month_sale
FROM sales.vw_netsales_brands
WHERE year = 2018

-- compare the sales of the current month with the previous month of net sales by brand in 2018 % 
WITH cte_sales AS (
SELECT 
month,
brand_name,
net_sales,
LAG(net_sales,1) OVER ( PARTITION BY brand_name ORDER BY month) previous_month_sale
FROM sales.vw_netsales_brands
WHERE year = 2018)
SELECT 
month,
brand_name,
net_sales,
previous_month_sale,
FORMAT((net_sales - previous_month_sale) / previous_month_sale, 'P') vs_previous_month_sale
FROM cte_sales

--------------------------------------

-- LEAD Function
SELECT * FROM sales.vw_netsales_brands
ORDER BY year, month, brand_name, net_sales

-- return the net sales of the current month and the next month in the year 2017

WITH cte_netsales_2017 AS(
SELECT 
MONTH, 
SUM(net_sales) net_sales
FROM sales.vw_netsales_brands
WHERE YEAR = 2018
GROUP BY MONTH)
SELECT 
MONTH,
net_sales,
LEAD(net_sales,1) OVER ( ORDER BY MONTH) next_month_sales
FROM cte_netsales_2017

-- compare the sales of the current month with the next month of each brand in the year 2018

SELECT 
month,
brand_name,
net_sales,
LEAD(net_sales,1) OVER ( PARTITION BY brand_name ORDER BY month) next_month_sale
FROM sales.vw_netsales_brands
WHERE year = 2018

--------------------------------------

-- NTILE() function

SELECT 
category_name,
month,
net_sales
FROM sales.vw_netsales_2017
ORDER BY category_name, net_sales

-- distribute the months to 4 buckets based on net sales
WITH cte_by_month AS 
(SELECT 
month,
sum(net_sales) net_sales
FROM sales.vw_netsales_2017
GROUP BY month)
SELECT
month,
FORMAT(net_sales, 'C', 'en-US') net_sales,
NTILE(4) OVER ( ORDER BY net_sales DESC) net_sales_group
FROM cte_by_month

-- divide the net sales by month into 4 groups for each product category‎

SELECT 
category_name,
month,
FORMAT(net_sales, 'C', 'en-US') net_sales,
NTILE(4) OVER ( PARTITION BY category_name ORDER BY net_sales DESC) net_sales_group
FROM sales.vw_netsales_2017

--------------------------------------

-- PERCENT_RANK
SELECT 
staff_id,
year,
net_sales
FROM sales.vw_staff_sales
WHERE YEAR = 2016
--- calculate the sales percentile of each sales staff in 2016‎

SELECT 
CONCAT(' ', first_name, last_name) full_name,
net_sales,
PERCENT_RANK() OVER ( ORDER BY net_sales DESC) percent_rank
FROM sales.vw_staff_sales t
JOIN sales.staffs m ON m.staff_id = t.staff_id
WHERE YEAR = 2016

-- MORE READABLE 
SELECT 
CONCAT(' ', first_name, last_name) full_name,
net_sales,
FORMAT(PERCENT_RANK() OVER ( ORDER BY net_sales DESC),'P') percent_rank
FROM sales.vw_staff_sales t
JOIN sales.staffs m ON m.staff_id = t.staff_id
WHERE YEAR = 2016

-- calculate the sales percentile for each staff in 2016 and 2017‎
SELECT 
CONCAT(' ', first_name, last_name) full_name,
net_sales,
FORMAT(PERCENT_RANK() OVER ( PARTITION BY year ORDER BY net_sales DESC),'P') percent_rank
FROM sales.vw_staff_sales t
JOIN sales.staffs m ON m.staff_id = t.staff_id
WHERE YEAR IN (2016,2017)

--------------------------------------

-- Rank()
-- assign ranks to the products by their list prices‎
SELECT 
product_id,
product_name,
list_price,
RANK() OVER ( ORDER BY list_price DESC) price_rank
FROM production.products 

-- assign a rank to each product by list price in each brand and returns products with rank less than or equal to three

SELECT * FROM (
SELECT 
product_id,
product_name,
brand_id,
list_price,
RANK() OVER ( PARTITION BY brand_id ORDER BY list_price DESC) price_rank
FROM production.products) t
WHERE price_rank <=3


--------------------------------------

-- ROW_NUMBER
-- assign each customer row a sequential number‎
SELECT 
customer_id,
ROW_NUMBER() OVER ( ORDER BY first_name) row_num,
first_name,
last_name, 
city
FROM sales.customers ORDER BY customer_id

-- assign a sequential integer to each customer. It resets the number when the city changes‎

SELECT 
first_name,
last_name, 
city,
ROW_NUMBER() OVER ( PARTITION BY city ORDER BY first_name) row_num
FROM sales.customers
ORDER BY city

-- ROW_NUMBER() for pagination 
-- return customers from row 11 to 20, which is the second page

WITH cte_customers AS (
SELECT 
ROW_NUMBER() OVER ( ORDER BY first_name, last_name) row_num,
customer_id,
first_name,
last_name,
city
FROM sales.customers)
SELECT 
row_num,
customer_id,
first_name,
last_name
FROM cte_customers
WHERE row_num > 20 AND row_num <=30;
