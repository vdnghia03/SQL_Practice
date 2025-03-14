
/*
========================================
	SQL WINDOW BASIC
========================================
Script Purpose:
	- 



========================================
*/

-- ==========================================
--		WINDOW FUNCTION V/S GROUP BY
-- ==========================================

-- Fine the total sales across all order 
SELECT 
	SUM(Sales) AS Total_sales
FROM Sales.Orders


-- Fine the total sales for each product
SELECT 
	ProductID
	, SUM(Sales) AS Total_sales
FROM Sales.Orders
GROUP BY ProductID

-- Fine the total sales for each product. Additionally provide detail such order Id, Order date..

SELECT 
	OrderID
	, OrderDate
	, ProductID
	, SUM(Sales) OVER (PARTITION BY ProductID) AS TotalSalesByProducts
FROM Sales.Orders


-- Find the total sales across all orders
-- Find the total sales for each product
-- Addition provide detail such OrderID, OrderDate,...

SELECT
	OrderID
	, OrderDate
	, ProductID
	, Sales
	, SUM(Sales) OVER() TotalSale
	, SUM(Sales) OVER(PARTITION BY ProductID) SalesByProduct
FROM Sales.Orders

-- Find the total sales for each combination of product and order status
SELECT
	OrderID
	, OrderDate
	, ProductID
	, OrderStatus
	, Sales
	, SUM(Sales) OVER() TotalSale
	, SUM(Sales) OVER(PARTITION BY ProductID) SalesByProduct
	, SUM(Sales) OVER(PARTITION BY ProductID, OrderStatus) SalesByProductAndStatus
FROM Sales.Orders

-- Rank each order based on their sales from highest to lowest
-- Additionally provide detail such order id, order date

SELECT 
	OrderID
	, OrderDate
	, Sales
	, RANK() OVER (ORDER BY Sales DESC) RankSales
FROM Sales.Orders


-- ===============

SELECT 
	OrderID
	, OrderDate
	, OrderStatus
	, Sales
	, SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS TotalSales
FROM Sales.Orders

