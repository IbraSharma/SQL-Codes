-- SQL employee salary department scenario questions

-- Average salary of all employees department
SELECT 
DEPARTMENT,
AVG(SALARY) AvgSalary
FROM Worker
GROUP BY DEPARTMENT

-- Find the second highest salary in employees
SELECT 
DISTINCT(SALARY)
FROM Worker
ORDER BY SALARY DESC
OFFSET 1 ROWS
FETCH NEXT 1 ROWS ONLY

-- Another way (advance) since we have 2 employees with same salary
SELECT
    FIRST_NAME,
    SALARY
	FROM (
	SELECT  FIRST_NAME,SALARY,
     ROW_NUMBER() OVER(ORDER BY SALARY DESC) RowNumber
FROM Worker) b
WHERE RowNumber < 3

-- Fetch employee data from worker table that are from same city and country
SELECT DISTINCT w.WORKERID, 
w.FIRST_NAME,
w1.FIRST_NAME,
w.DEPARTMENT
FROM Worker w, Worker w1
WHERE w.WORKERID > w1.WORKERID  -- using > remove duplicates instead of != which not remove duplicates
AND w.DEPARTMENT = w1.DEPARTMENT 

-- display worker details , its salary and total salary of its department 
SELECT WORKERID, FIRST_NAME, LAST_NAME, DEPARTMENT, SALARY,
SUM(SALARY) OVER (PARTITION BY DEPARTMENT) AS SumSalary,
CAST(SALARY AS decimal)/ (SUM(SALARY) OVER (PARTITION BY DEPARTMENT)) AS PercentageSalary
FROM Worker
ORDER BY WORKERID

--- top 5 max salary 
SELECT 
TOP 5 FIRST_NAME,
SALARY
FROM Worker
ORDER BY SALARY DESC

-- Another way
SELECT
    FIRST_NAME,
    SALARY
	FROM (
	SELECT  FIRST_NAME,SALARY,
     ROW_NUMBER() OVER(ORDER BY SALARY DESC) RowNumber
FROM Worker) b
WHERE RowNumber < 6

-- fitch name of employee who are also manager
SELECT 
DISTINCT WORKERID,
WORKER_TITLE
FROM Worker w
JOIN Title t ON w.WORKERID = t.WORKER_REF_ID
WHERE WORKER_TITLE = 'manager'



-- fetch all duplicate records from employee
SELECT 
FIRST_NAME,
COUNT(*)
FROM Worker
GROUP BY FIRST_NAME
HAVING COUNT(*) > 1

