
-- Homework
-- Find all sales records (and all columns) that took place in the London store, not in December, but sales concluded by Bill or Frank for the amount higher than £50
SELECT * FROM SALES1
WHERE Store = "London"
AND Month <> "Dec"
AND SalesPerson IN("Bill", "Frank")
AND SalesAmount > 50;

-- Find out how many sales took place each week (in no particular order)
SELECT S.WEEK, COUNT(S.Week) AS Count
FROM SALES1 AS S
GROUP BY Week;

-- Find out how many sales took place each week (and present data by week in descending and then in ascending order)
SELECT S.WEEK, COUNT(*) AS Count
FROM SALES1 AS S
GROUP BY Week
ORDER BY Week DESC;

SELECT S.WEEK, COUNT(*) AS Count
FROM SALES1 AS S
GROUP BY Week
ORDER BY Week ASC;

-- Find out how many sales were recorded each week on different days of the week
SELECT S.Week, S.Day, COUNT(*)
FROM SALES1 AS S
GROUP BY Week, Day
ORDER BY Week;

--  We need to change the name Inga to Annette
UPDATE SALES1
SET SalesPerson = "Annette"
WHERE SalesPerson = "Inga";
SELECT * FROM SALES1;

-- Find out how many sales Annette did
SELECT COUNT(*)
FROM SALES1
WHERE SalesPerson = "Annette";

-- Find the total sales amount by each person by day
SELECT S.SalesPerson, S.Day, SUM(SalesAmount) AS TotalSales
FROM SALES1 AS S
GROUP BY SalesPerson, Day;

-- How much each person sold for the given period
SELECT S.SalesPerson, SUM(SalesAmount) AS TotalSales
FROM SALES1 AS S
GROUP BY SalesPerson;

-- How much each person sold for the given period, including the number of sales per person, their average, lowest and highest sale amounts
SELECT S.SalesPerson, SUM(S.SalesAmount) AS TotalSales, COUNT(S.SalesAmount) AS NumberOfSales, AVG(S.SalesAmount) AS AverageSalesAmount, MIN(S.SalesPerson) AS LowestSale, MAX(S.SalesPerson) AS HighestSale
FROM SALES1 AS S
GROUP BY SalesPerson;

-- Find the total monetary sales amount achieved by each store
SELECT S.Store, SUM(S.SalesAmount) AS TotalSalesAmount
FROM SALES1 AS S
GROUP BY Store;

-- Find the number of sales by each person if they did less than 3 sales for the past period
SELECT S.SalesPerson, COUNT(SalesAmount) AS NumberOfSales
FROM SALES1 AS S
GROUP BY S.SalesPerson
HAVING COUNT(SalesAmount) < 3;

-- Find the total amount of sales by month where combined total is less than £100
SELECT S.Month, SUM(S.SalesAmount) AS TotalSales
FROM SALES1 AS S
GROUP BY S.Month
HAVING SUM(SalesAmount) < 100;
