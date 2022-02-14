--- STAFF SALES --- 
CREATE VIEW sales.vw_staff_sales(
    staff_id, 
    year, 
    net_sales
) AS
SELECT 
    staff_id, 
    YEAR(order_date), 
    ROUND(SUM(quantity*list_price*(1-discount)),0)
FROM 
    sales.orders o
INNER JOIN sales.order_items i on i.order_id = o.order_id
WHERE 
    staff_id IS NOT NULL
GROUP BY 
    staff_id, 
    YEAR(order_date);
    
 ---------------------------------------------------------------
--- CATEGORY SALES --- 

 CREATE VIEW 
    sales.vw_category_sales_volume 
AS
SELECT 
    category_name, 
    YEAR(order_date) year, 
    SUM(quantity) qty
FROM 
    sales.orders o
INNER JOIN sales.order_items i 
    ON i.order_id = o.order_id
INNER JOIN production.products p 
    ON p.product_id = i.product_id
INNER JOIN production.categories c 
    ON c.category_id = p.product_id
GROUP BY 
    category_name, 
    YEAR(order_date);
    
    ---------------------------------------------------------------
    
    --- BRANDS NET SALES --- 
    CREATE VIEW sales.vw_netsales_brands
AS
	SELECT 
		c.brand_name, 
		MONTH(o.order_date) month, 
		YEAR(o.order_date) year, 
		CONVERT(DEC(10, 0), SUM((i.list_price * i.quantity) * (1 - i.discount))) AS net_sales
	FROM sales.orders AS o
		INNER JOIN sales.order_items AS i ON i.order_id = o.order_id
		INNER JOIN production.products AS p ON p.product_id = i.product_id
		INNER JOIN production.brands AS c ON c.brand_id = p.brand_id
	GROUP BY c.brand_name, 
			MONTH(o.order_date), 
			YEAR(o.order_date);
    ---------------------------------------------------------------
    
    --- CATEGORY NET SALES 2017--- 
    
    CREATE VIEW sales.vw_netsales_2017 AS
SELECT 
	c.category_name,
	DATENAME(month, o.shipped_date) month, 
	CONVERT(DEC(10, 0), SUM(i.list_price * quantity * (1 - discount))) net_sales
FROM 
	sales.orders o
INNER JOIN sales.order_items i ON i.order_id = o.order_id
INNER JOIN production.products p on p.product_id = i.product_id
INNER JOIN production.categories c on c.category_id = p.category_id
WHERE 
	YEAR(shipped_date) = 2017
GROUP BY
	c.category_name,
	DATENAME(month, o.shipped_date);
    
     
     
    
