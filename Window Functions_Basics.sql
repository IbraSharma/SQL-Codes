-- Window functions  

Select * from employee
-----------
select max(salary) as max_salary
from employee
-----------
select dept_name, max(salary) as max_salary
from employee
group by DEPT_NAME
-----------

-- USE WINDOW FUNCTION (ANALYTICS) 
-- Max salary cross all
select 
e.*,
max(salary) over() as max_salary
from employee e

-- max salary cross Department 
select 
e.*,
max(salary) over(partition by dept_name) as max_salary_department
from employee e

-- USING ROW_NUMBER, rank, dese_rank, lead and lag
-- ROW_NUMBER assign a unique value to each of the record
select 
e.*,
ROW_NUMBER() over(order by emp_id asc) as rownum
from employee e

-- ROW_NUMBER assign a unique value to each of the department
select 
e.*,
ROW_NUMBER() over(partition by dept_name order by emp_id asc) as rownum
from employee e

-- -- Fetch the first 2 employees from each department to join the company.
select * from (
select 
e.*,
ROW_NUMBER() over(partition by dept_name order by emp_id asc) as rownum
from employee e) x
where x.rownum < 3

-- -- Fetch the top 3 employees in each department earning the max salary.
select * from (
select 
e.*,
RANK() over(partition by dept_name order by salary desc) as rownum
from employee e) x
where x.rownum < 4

-- -- Checking the different between rank, dense_rnk and row_number window functions:
select e.*,
rank() over(partition by dept_name order by salary desc) as rnk,
dense_rank() over(partition by dept_name order by salary desc) as dense_rnk,
row_number() over(partition by dept_name order by salary desc) as rn
from employee e;

-- -- lead and lag
-- -- fetch a query to display if the salary of an employee is higher, lower or equal to the previous employee.
select e.*,
lag(salary) over(partition by dept_name order by emp_id) as prev_empl_sal,
case when e.salary > lag(salary) over(partition by dept_name order by emp_id) then 'Higher than previous employee'
     when e.salary < lag(salary) over(partition by dept_name order by emp_id) then 'Lower than previous employee'
	 when e.salary = lag(salary) over(partition by dept_name order by emp_id) then 'Same than previous employee' end as sal_range
from employee e;

-- -- Similarly using lead function to see how it is different from lag.
select e.*,
lag(salary) over(partition by dept_name order by emp_id) as prev_empl_sal,
lead(salary) over(partition by dept_name order by emp_id) as next_empl_sal
from employee e;

-- -- FIRST_VALUE 
-- Write query to display the most expensive product under each category (corresponding to each record)
select * from product

select *,
first_value(product_name) over(partition by product_category order by price desc) as most_exp_product
from product;

-- LAST_VALUE 
-- Write query to display the least expensive product under each category (corresponding to each record) - last record in product name
-- current row vs next row in category product name
select *,
first_value(product_name) over(partition by product_category order by price desc)  as most_exp_product,
last_value(product_name) over(partition by product_category order by price desc range between unbounded preceding and current row) as least_exp_product      
from product

-- current row vs last row in category product name
select *,
first_value(product_name) over(partition by product_category order by price desc)  as most_exp_product,
last_value(product_name) over(partition by product_category order by price desc range between unbounded preceding and unbounded following) as least_exp_product      
from product
WHERE product_category ='Phone';

-- each row 
select *,
first_value(product_name) over(partition by product_category order by price desc)  as most_exp_product,
last_value(product_name) over(partition by product_category order by price desc rows between unbounded preceding and current row) as least_exp_product      
from product
WHERE product_category ='Phone';

-- certain rows
select *,
first_value(product_name) over(partition by product_category order by price desc)  as most_exp_product,
last_value(product_name) over(partition by product_category order by price desc rows between 2 preceding and 2 following) as least_exp_product      
from product
WHERE product_category ='Phone';

-- if we have same price it will return last row of same prices ' galaxy s21'
select *,
first_value(product_name) over(partition by product_category order by price desc)  as most_exp_product,
last_value(product_name) over(partition by product_category order by price desc range between unbounded preceding and current row) as least_exp_product      
from product
WHERE product_category ='Phone';


-- cumulative distribution
select product_name, cume_distribution_percentage 
from (
select *,
CUME_DIST() OVER (ORDER BY price DESC) as cume_distribution,
CAST(ROUND(CUME_DIST() OVER (ORDER BY price DESC),2) * 100 as nvarchar(5))  + '%'  cume_distribution_percentage
from product)x

---- cumulative distribution 
/*  Formula = Current Row no (or Row No with value same as current row) / Total no of rows */
select product_name, cume_distribution_percentage 
from (
select *,
CUME_DIST() OVER (ORDER BY price DESC) as cume_distribution,
CAST(ROUND(CUME_DIST() OVER (ORDER BY price DESC),2) * 100 as nvarchar(5))  + '%'  cume_distribution_percentage
from product)x 


-- PERCENT_RANK (relative rank of the current row / Percentage Ranking)
/* Formula = Current Row No - 1 / Total no of rows - 1 */
-- Query to identify how much percentage more expensive is "Galaxy Z Fold 3" when compared to all products.
select product_name, per
from (
select *,
FORMAT(PERCENT_RANK() OVER (ORDER BY price),'P')  as per
from product)x
