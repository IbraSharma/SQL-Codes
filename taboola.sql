
SELECT * FROM Taboola_Feed

/* 1a.	For every publisher that has mobile traffic, find that publisher’s total amount of page views across all platforms. */

SELECT
Pubilsher,
Total_Amount,
CAST(CAST((Total_Amount / cast(Grand_Amount_All_Platforms as decimal)) * 100 AS decimal(7,2)) as varchar(5)) + ' %' AS Percentage_From_Platforms
FROM
(
SELECT 
publisher_id AS Pubilsher,
SUM(pageviews) AS Total_Amount,
(SELECT SUM(pageviews) FROM Taboola_Feed) AS Grand_Amount_All_Platforms
FROM Taboola_Feed
WHERE platform = 'Mobile'
GROUP BY publisher_id
) sub

/* 1b.	For publisher_id 106, calculate the change in Organic CTR as a percentage between groups A and B.
show the results broken down by platform. */

SELECT 
Platform, 
CAST(CAST((MIN(Total1) / CAST(MAX(Total1) as decimal)) * 100 as decimal(7,2)) as varchar(5)) + ' %' AS Percentage_group
FROM 
(
SELECT platform AS Platform , group_name AS group_name1, 
SUM(organic_clicks) AS Total1 FROM Taboola_Feed
WHERE publisher_id = 106 
GROUP BY platform, group_name
)a
LEFT JOIN
(
SELECT platform AS Platform2, group_name AS group_name1, SUM(organic_clicks) AS Total2 FROM Taboola_Feed
WHERE publisher_id = 106 
GROUP BY platform, group_name 
)b
ON a.Platform = b.Platform2 AND a.group_name1 = b.group_name1
GROUP BY Platform, Platform2



/* KPIs */
SELECT
CAST((SUM(pageviews) / CAST(SUM(sessions) as decimal))  as decimal(7,2))  AS Pages_per_session,
(SUM(revenue) / SUM(pageviews)) * 1000 AS RPM,
(SUM(revenue) / SUM(sessions)) * 1000 AS RPS,
CAST(CAST((SUM(organic_clicks) / CAST(SUM(pageviews) as decimal)) * 100 as decimal(7,2)) as varchar(5)) + ' %' AS Organic_CTR,
CAST(CAST((SUM(sponsord_clicks) / CAST(SUM(pageviews) as decimal)) * 100 as decimal(7,2)) as varchar(5)) + ' %' AS paid_CTR,
CAST(CAST((SUM(visible_pageviews) / CAST(SUM(pageviews) as decimal)) * 100 as decimal(7,2)) as varchar(5)) + ' %' AS Visibility_Rate
FROM Taboola_Feed


