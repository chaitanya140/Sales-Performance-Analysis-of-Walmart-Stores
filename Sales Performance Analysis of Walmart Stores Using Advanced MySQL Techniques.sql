use walmart;

#Task 1: Identifying the Top Branch by Sales Growth Rate.
SELECT Branch, AVG(GrowthRate) AS AvgGrowthRate
FROM (
    SELECT Branch, 
           DATE_FORMAT(Date, '%Y-%m') AS Month,
           SUM(Total) AS MonthlySales,
           (SUM(Total) - LAG(SUM(Total)) OVER (PARTITION BY Branch ORDER BY DATE_FORMAT(Date, '%Y-%m'))) / 
            LAG(SUM(Total)) OVER (PARTITION BY Branch ORDER BY DATE_FORMAT(Date, '%Y-%m')) AS GrowthRate
    FROM sales
    GROUP BY Branch, DATE_FORMAT(Date, '%Y-%m')
) AS SalesGrowth
GROUP BY Branch
ORDER BY AvgGrowthRate DESC LIMIT 1;

#Task 2: Finding the Most Profitable Product Line for Each Branch.
SELECT Branch, `Product line`, SUM(`gross income`) AS TotalProfit FROM sales
GROUP BY Branch, `Product line`
ORDER BY Branch, TotalProfit DESC;

#Task 3: Analyzing Customer Segmentation Based on Spending.
SELECT `Customer ID`, AVG(Total) AS AvgSpending,
       CASE
           WHEN AVG(Total) >= 400 THEN 'High'
           WHEN AVG(Total) BETWEEN 200 AND 399 THEN 'Medium'
           ELSE 'Low'
       END AS SpendingTier
FROM sales
GROUP BY `Customer ID`;

# Task 4: Detecting Anomalies in Sales Transactions.
SELECT * FROM sales s
JOIN (
    SELECT `Product line`,
           AVG(Total) AS AvgTotal,
           STDDEV(Total) AS StdDevTotal
    FROM sales
    GROUP BY `Product line`
) stats ON s.`Product line` = stats.`Product line`
WHERE ABS(s.Total - stats.AvgTotal) > 2 * stats.StdDevTotal;

# Task 5: Most Popular Payment Method by City.
SELECT City, Payment, COUNT(*) AS UsageCount FROM sales
GROUP BY City, Payment
HAVING COUNT(*) = (
    SELECT MAX(payment_count) FROM (
        SELECT City AS c, Payment AS p, COUNT(*) AS payment_count FROM sales
        GROUP BY City, Payment
        HAVING c = City
    ) AS inner_counts
);

# Task 6: Monthly Sales Distribution by Gender.
SELECT DATE_FORMAT(Date, '%Y-%m') AS Month, Gender, SUM(Total) AS MonthlySales FROM sales
GROUP BY Month, Gender
ORDER BY Month;

# Task 7: Best Product Line by Customer Type.
SELECT `Customer type`, `Product line`, SUM(Total) AS TotalSales FROM sales
GROUP BY `Customer type`, `Product line`
ORDER BY `Customer type`, TotalSales DESC;

# Task 8: Identifying Repeat Customers.
SELECT DISTINCT a.`Customer ID`
FROM sales a
JOIN sales b 
ON a.`Customer ID` = b.`Customer ID`
AND a.Date != b.Date
WHERE DATEDIFF(a.Date, b.Date) BETWEEN 1 AND 30;

# Task 9: Finding Top 5 Customers by Sales Volume.
SELECT `Customer ID`, SUM(Total) AS TotalSpent FROM sales
GROUP BY `Customer ID`
ORDER BY TotalSpent DESC LIMIT 5;

# Task 10: Analyzing Sales Trends by Day of the Week.
SELECT DAYNAME(Date) AS DayOfWeek, SUM(Total) AS TotalSales FROM sales
GROUP BY DayOfWeek
ORDER BY TotalSales DESC;