/* רשימת הלקוחות מאיזור המרכז בסדר יורד של הכנסה (5 המרוויחים הגבוהים ביותר */

WITH CTE_loan AS (
SELECT 
Region AS Region,
ID AS CustomerID,
sum(Income) as Total_Income,
DENSE_RANK() OVER ( PARTITION BY Region ORDER BY sum(Income) DESC) AS rn
FROM loan
GROUP BY Region, ID
)
SELECT 
*
FROM CTE_loan
WHERE rn < 6 AND Region = 'Center'

/* סכום וכמות הלוואות בכשל בחודש העוקב לעומת לא בכשל בחודש העוקב*/

WITH CTE_loan AS (
SELECT 
Is_Default AS Is_Default,
SUM(Loan_Sum) as Total_loan,
COUNT(Loan_Sum) as Count_loan
FROM loan
GROUP BY Is_Default
)
SELECT 
*
FROM CTE_loan

/* ממוצעי הוצאות לפי טווחי וותק בקפיצות של 5 שנים. יוצג רק במקרה וכמות הלקוחות בטווח גדולה מ- 3*/

SELECT 
a.*
FROM 
(
SELECT
CASE 
WHEN  Seniority > 0 AND  Seniority  <= 5 THEN '0-5'
WHEN  Seniority > 5 AND  Seniority  <= 10 THEN '5-10'
WHEN  Seniority > 10 AND  Seniority  <= 15 THEN '10-15'
WHEN  Seniority > 15 AND  Seniority  <= 20 THEN '15-20'
WHEN  Seniority > 20 AND  Seniority  <= 25 THEN '20-25'
WHEN  Seniority > 25 AND  Seniority  <= 30 THEN '25-30'
ELSE NULL END  AS Seniority,
AVG(Outcome) AVG_Outcome,
COUNT(ID) Count_Customers
FROM loan
GROUP BY 
CASE 
WHEN  Seniority > 0 AND  Seniority  <= 5 THEN '0-5'
WHEN  Seniority > 5 AND  Seniority  <= 10 THEN '5-10'
WHEN  Seniority > 10 AND  Seniority  <= 15 THEN '10-15'
WHEN  Seniority > 15 AND  Seniority  <= 20 THEN '15-20'
WHEN  Seniority > 20 AND  Seniority  <= 25 THEN '20-25'
WHEN  Seniority > 25 AND  Seniority  <= 30 THEN '25-30'
ELSE NULL END
HAVING COUNT(ID) > 3) a
ORDER BY AVG_Outcome DESC

/* 
ספור את כל צמדי הלקוחות (ללא כפילויות של אותו הצמד) , שהפרש ההוצאות בינהם קטן מ- 1000 שח ושניהם נכנסו לכשל או שניהם לא נכנסו לכשל
הצג את ממוצע פער ההכנסות (בערך מוחלט) של כל הצמדים, כמה צמדים כאלה בכשל וכמה לא בכשל.
*/
SELECT 
sub.Is_Default,
Count(*) AS Count_Customers,
CAST(AVG(Income_diff) as int) AS AVG_Diff_Income, -- e.g. one pair equal 1
CAST(AVG(Income_diff) as int)/2 AS AVG_Diff_Income_2 -- e.g. one pair equal 2

FROM

(
SELECT 
a.ID AS a_ID,
a.Income AS a_Income,
a.outcome AS a_Outcome,
a.Is_Default AS a_Is_Default,
b.ID AS b_ID,
b.Income AS b_Income,
b.Outcome AS b_Outcome,
b.Is_Default,
abs(a.Outcome - b.Outcome) As Outcome_diff,
abs(a.Income - b.Income) As Income_diff
FROM Loan a, Loan b
WHERE a.ID > b.ID 
and abs(a.Outcome - b.Outcome) < 1000
and a.Is_Default = b.Is_Default
) sub

GROUP BY sub.Is_Default


/*
נתונים סיכומיים על כל איזור (בשאילתא אחת): כמות לקוחות בעלי הכנסה גדולה מהוצאה באיזור
אחוז ההלוואות של לקוחות מהאיזור לעומת כלל הלקוחות (לפי כמות ולפי סכום), חציון של הוותק באיזור
*/

SELECT 
sub.*,
CAST(CAST((Total_Loan_Region / Total_Loan *100 ) AS decimal(7,2)) as varchar(5)) + ' %'  AS Percentage_Loan
FROM 
(SELECT 
DISTINCT Region,
CAST(PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Seniority) OVER (PARTITION BY Region) AS decimal(7,2)) AS Median_Seniority,
SUM(Loan_Sum) OVER (PARTITION BY Region) AS Total_Loan_Region,
COUNT(ID) OVER (PARTITION BY Region) AS Total_Customers_Region,
SUM(Loan_Sum) OVER () AS Total_Loan
FROM loan
WHERE (Income - Outcome) > 0) sub
