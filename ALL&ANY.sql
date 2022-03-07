/* find the products that were sold with more than two units in a sales order:*/
SELECT
product_name,
list_price
FROM production.products
WHERE product_id = ANY
(SELECT
product_id
FROM sales.order_items
WHERE quantity >= 2 )
ORDER BY product_name;


/* Returns Product Name that has over each record in the Order items table has Quantity larger than 1 */
SELECT product_name
FROM production.products
WHERE product_id = ANY
  (SELECT product_id
  FROM sales.order_items
  WHERE quantity > 1)

/* its like this one - we have 257 products sold qith quantity > 1*/
SELECT distinct(product_id)
FROM sales.order_items where quantity > 1

/* Returns Product Name the product price > average product price in Order items */
SELECT product_name, list_price
FROM production.products
WHERE list_price > ALL
  (SELECT avg(list_price) 
  FROM sales.order_items )
order by list_price

/* Find the products whose list prices are bigger than the average list price of products of all brands:*/
SELECT
product_name,
list_price
FROM  production.products
WHERE list_price > ALL 
(SELECT
AVG (list_price) avg_list_price
FROM production.products
GROUP BY
    brand_id)
ORDER BY  list_price;
