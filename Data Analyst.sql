
-- https://www.youtube.com/watch?v=8pfE57Y8TnM
-- SQL Examples For Practice
-- 1 - What is the total Revenue of the company this year?
-- 2 - What is the total Revenue Performance YoY?
-- 3 - What is the MoM Revenue Performance?
-- 4 - What is the Total Revenue Vs Target performance for the Year?
-- 5 - What is the Revenue Vs Target performance Per Month?

-- https://www.youtube.com/watch?v=vEOi1QmWdLM
-- 6 - What is the best performing product in terms of revenue this year?
-- 7 - What is the product performance Vs Target for the month?
-- 8 - Which account is performing the best in terms of revenue?
-- 9 - Which account is performing the best in terms of revenue vs Target?
-- 10 - Which account is performing the worst in terms of meeting targets for the year?
-- 11 - Which opportunity has the highest potential and what are the details?


-- 1 - What is the total Revenue of the company this year (2021)?
-- fy21
SELECT SUM(Revenue) AS Total_Revenue_FY21 FROM Revenue
WHERE Month_ID IN 
(SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21')

-- By month 
SELECT Month_ID, SUM(Revenue) AS Total_Revenue_FY21 FROM Revenue
WHERE Month_ID IN 
(SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21')
GROUP BY Month_ID

-- 2 - What is the total Revenue Performance YoY? 
-- be careful since we compare 6 month with 12 months and must fit months between tables
SELECT a.Total_Revenue_FY21, b.Total_Revenue_FY20, a.Total_Revenue_FY21 - b.Total_Revenue_FY20 AS Dollar_Diff_YoY, a.Total_Revenue_FY21 / b.Total_Revenue_FY20 -1 AS Percentage_Diff_YoY
FROM
	(
	SELECT SUM(Revenue) AS Total_Revenue_FY21 FROM Revenue
	WHERE Month_ID IN 
	(SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21')
	) a, 

	(
	--fy20
	SELECT SUM(Revenue) AS Total_Revenue_FY20 FROM Revenue
	WHERE Month_ID IN 
	(SELECT DISTINCT  Month_ID - 12 FROM Revenue WHERE Month_ID IN 
	(SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21'))
	)b


-- 3 - What is the MoM Revenue Performance?
SELECT a.Total_Revenue_this_month, b.Total_Revenue_prevoius_month, a.Total_Revenue_this_month - b.Total_Revenue_prevoius_month AS Dollar_Diff_YoY, a.Total_Revenue_this_month / b.Total_Revenue_prevoius_month -1 AS Percentage_Diff_MoM
FROM
	(
	-- This month
	SELECT --Month_ID,
	SUM(Revenue) AS Total_Revenue_this_month FROM Revenue
	WHERE Month_ID IN 
	(SELECT MAX(Month_ID) FROM Revenue)
	--GROUP BY Month_ID
	) a, 

	(
	-- Previous month
	SELECT --Month_ID,
	SUM(Revenue) AS Total_Revenue_prevoius_month FROM Revenue
	WHERE Month_ID IN 
	(SELECT MAX(Month_ID) -1  FROM Revenue)
	--GROUP BY Month_ID
	) b

-- 4 - What is the Total Revenue Vs Target performance for the Year?
SELECT a.Total_Revenue_FY21, b.Total_Targets_FY21, a.Total_Revenue_FY21 - b.Total_Targets_FY21 AS Dollar_Diff_YoY, a.Total_Revenue_FY21 / b.Total_Targets_FY21 -1 AS Percentage_Diff
FROM
	(
	SELECT SUM(Revenue) AS Total_Revenue_FY21 FROM Revenue
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21')
	) a,

	(
	SELECT 
	--Month_ID,
	SUM(Target) AS Total_Targets_FY21 FROM Targets
	WHERE Month_ID IN ((SELECT DISTINCT  Month_ID  FROM Revenue WHERE Month_ID IN 
	(SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21')))
	--GROUP BY Month_ID
	) b

-- 5 - What is the Revenue Vs Target performance Per Month?
SELECT a.Month_ID, c.[Fiscal Month], a.Total_Revenue_FY21, b.Total_Targets_FY21, a.Total_Revenue_FY21 - b.Total_Targets_FY21 AS Dollar_Diff_MoM, a.Total_Revenue_FY21 / b.Total_Targets_FY21 -1 AS Percentage_Diff
FROM
	(
	SELECT 
	Month_ID,
	SUM(Revenue) AS Total_Revenue_FY21 FROM Revenue
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21')
	GROUP BY Month_ID
	) a
	LEFT JOIN
	(
	SELECT 
	Month_ID,
	SUM(Target) AS Total_Targets_FY21 FROM Targets
	WHERE Month_ID IN ((SELECT DISTINCT  Month_ID  FROM Revenue WHERE Month_ID IN 
	(SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21')))
	GROUP BY Month_ID) b
	ON a.Month_ID = b.Month_ID

	-- For Month Name
	LEFT JOIN 
	(SELECT DISTINCT Month_ID, [Fiscal Month]  FROM Calendar ) c
	ON a.Month_ID = c.Month_ID

	ORDER BY a.Month_ID 


-- 6 - What is the best performing product in terms of revenue this year?

SELECT * FROM Revenue

SELECT Product_Category, SUM(Revenue) AS Revenue FROM Revenue
WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21')
GROUP BY Product_Category

-- 7 - What is the product performance Vs Target for the month?
SELECT a.Product_Category, a.Month_ID, Targets, Revenue, Revenue/Targets - 1 AS Rev_vs_Target
FROM
	(
	SELECT Product_Category,Month_ID, SUM(Revenue) AS Revenue FROM Revenue
	WHERE Month_ID IN (SELECT MAX(Month_ID) FROM Revenue)
	GROUP BY Product_Category, Month_ID
	) a
	LEFT JOIN 
	(
	SELECT Product_Category,Month_ID, SUM(Target) AS Targets FROM Targets
	WHERE Month_ID IN (SELECT MAX(Month_ID) FROM Revenue)
	GROUP BY Product_Category, Month_ID
	) b
	ON a.Month_ID = b.Month_ID AND a.Product_Category = b.Product_Category

-- 8 - Which account is performing the best in terms of revenue?
SELECT a.Account_No, b.[New Account Name], Revenue
FROM
	(
	SELECT Account_No, SUM(Revenue) AS Revenue FROM Revenue
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21') -- option for ceratin year
	GROUP BY Account_No 
	--ORDER BY Revenue DESC
	)a

	-- Get account name
	LEFT JOIN 
	(
	SELECT * FROM account) b

ON a.Account_No = b.[ New Account No ]
ORDER BY Revenue DESC

-- 9 - Which account is performing the best in terms of revenue vs Target?

SELECT a.Account_No, b.[New Account Name], Revenue, Targets, Revenue/NULLIF(Targets,0) - 1 AS Rev_vs_Targets
FROM
(
SELECT 
ISNULL(a.Account_No, b.Account_No) AS Account_No, Revenue, Targets
FROM
	(
	SELECT Account_No, SUM(Revenue) AS Revenue FROM Revenue
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21') -- option for ceratin year
	GROUP BY Account_No 
	--ORDER BY Revenue DESC
	)a
	FULL JOIN 
	(
	SELECT Account_No, SUM(Target) AS Targets FROM Targets
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21') -- option for ceratin year
	GROUP BY Account_No
	) b
	ON a.Account_No = b.Account_No
 ) a
	-- Get account name
	LEFT JOIN 
	
	(SELECT * FROM account) b
	ON a.Account_No = b.[ New Account No ]

ORDER BY Rev_vs_Targets DESC

-- Always be careful before doing joins making sure all the data existed ( last table exist in table a if not so full join)
-- below can see in table targets we have 445 but in revenue we have 400

SELECT DISTINCT Account_No FROM 
	(SELECT Account_No, SUM(Target) AS Targets FROM Targets
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21') -- option for ceratin year
	GROUP BY Account_No) a

SELECT DISTINCT Account_No FROM
	(SELECT Account_No, SUM(Revenue) AS Revenue FROM Revenue
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21') -- option for ceratin year
	GROUP BY Account_No)b

-- 10 - Which account is performing the worst in terms of meeting targets for the year?

SELECT a.Account_No, b.[New Account Name], Revenue, Targets, ISNULL(Revenue,0)/NULLIF(ISNULL(Targets,0),0) - 1 AS Rev_vs_Targets
FROM
(
SELECT 
ISNULL(a.Account_No, b.Account_No) AS Account_No, Revenue, Targets
FROM
	(
	SELECT Account_No, SUM(Revenue) AS Revenue FROM Revenue
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21') -- option for ceratin year
	GROUP BY Account_No 
	--ORDER BY Revenue DESC
	)a
	FULL JOIN 
	(
	SELECT Account_No, SUM(Target) AS Targets FROM Targets
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21') -- option for ceratin year
	GROUP BY Account_No
	) b
	ON a.Account_No = b.Account_No
 ) a
	-- Get account name
	LEFT JOIN 
	
	(SELECT * FROM account) b
	ON a.Account_No = b.[ New Account No ]

ORDER BY Rev_vs_Targets

-- 11 - Which account is performing the worst in terms of meeting targets for the year?

	SELECT * FROM Opportunities
	WHERE [Est Completion Month ID] IN (SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21') 
	ORDER BY [Est Completion Month ID] DESC

-- 12 - Which opportunity has the highest potential and what are the details this year?
SELECT ISNULL(a.Account_No, b.Account_No) AS Account_No, Revenue, Marketing_Spend, ISNULL(Revenue,0)/NULLIF(ISNULL(Marketing_Spend,0),0) - 1 AS Rev_vs_Spend
FROM
	(SELECT Account_No, SUM(Revenue) AS Revenue FROM Revenue
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21') -- option for ceratin year
	GROUP BY Account_No
	) a

	FULL JOIN 
	(SELECT Account_No, SUM([ Marketing Spend ]) AS Marketing_Spend FROM Marketing
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM Calendar WHERE [Fiscal Year] = 'fy21')
	GROUP BY Account_No
	) b
	ON a.Account_No = b.Account_No

ORDER BY Rev_vs_Spend DESC
