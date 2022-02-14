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
