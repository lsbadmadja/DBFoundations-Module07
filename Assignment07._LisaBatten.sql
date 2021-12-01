--*************************************************************************--
-- Title: Assignment07
-- Author: LisaBatten
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2021-11-30,LisaBatten,Created file
-- 2021-11-30,LisaBatten,Created tables
-- 2021-11-30,LisaBatten,Added constraints
-- 2021-11-30,LisaBatten,Added data
-- 2021-11-30,LisaBatten,Checked data in each table
-- 2021-11-30,LisaBatten,Showed a List of product names & the price in US Dollars ordered by product name
-- 2021-11-30,LisaBatten,Showed a List of category, product names, & the price in US Dollars 
-- ordered by Category and Product Name
-- 2021-11-30,LisaBatten,Used functions to show a list of product names, each inventory date, and the inventory count.
-- Formated the date like 'January, 2017' and ordered the results by the Product and Date
-- 2021-11-30,LisaBatten,Created a view called vProductInventories that shows a list of product names, each inventory date, 
-- and the inventory count. Formated the date like 'January, 2017' and ordered the results by the Product and Date
-- 2021-11-30,LisaBatten, Created a view called vCategoryInventories that shows a list of category names, inventory dates, 
-- and a TOTAL inventory count by category. Formated the date like 'January, 2017' and ordered the results by the category and date.
-- 2021-11-30,LisaBatten,Created a view called vProductInventoriesWithPreviouMonthCounts using vProductInventories view that shows  
-- a list of product names, inventory dates, inventory count, AND the previous month count. Used functions to set any January 
-- NULL counts to zero. Ordered the results by the product and date
-- 2021-11-30,LisaBatten,Created a view called vProductInventoriesWithPreviousMonthCountsWithKPIs using vProductInventoriesWithPreviouMonthCounts that
-- shows columns for the product names, inventory dates, inventory count, previous month count. The Previous Month Count is 
-- a KPI. The result shows only KPIs with a value of either 1, 0, or -1. . Month are displayed with increased counts as 1, 
-- same counts as 0, and decreased counts as -1. Results are ordered by the product and date
-- 2021-11-30,LisaBatten,Created User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs using 
-- vProductInventoriesWithPreviousMonthCountsWithKPIs that shows columns for the product names, inventory dates, 
-- inventory count, the previous month count. The Previous Month Count is a KPI. The result shows only KPIs with a value of either 
-- 1, 0, or -1. Months are displayed with increased counts as 1, same counts as 0, and decreased counts as -1. Results are ordered by 
-- the product and date
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_LisaBatten')
	 Begin 
	  Alter Database [Assignment07DB_LisaBatten] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_LisaBatten;
	 End
	Create Database Assignment07DB_LisaBatten;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_LisaBatten;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

BEGIN TRY
	BEGIN TRAN;
		SELECT ProductName
             , FORMAT (UnitPrice, 'C', 'en-US') AS 'UnitPrice' 
		FROM dbo.vProducts
		ORDER BY ProductName;	
	COMMIT TRAN;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
END CATCH;
GO

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
BEGIN TRY
	BEGIN TRAN;
		SELECT a.CategoryName
            , b.ProductName
            , FORMAT (b.UnitPrice, 'C', 'en-US') AS 'UnitPrice'
		FROM dbo.vCategories AS a
        INNER JOIN dbo.vProducts AS b
        ON a.CategoryID = b.CategoryID
		ORDER BY a.CategoryName, b.ProductName;	
	COMMIT TRAN;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
END CATCH;
GO

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
CREATE FUNCTION dbo.fProductInventory()
RETURNS TABLE
AS
    RETURN 
        (SELECT TOP 1000000 a.ProductName
                          , CONCAT (DATENAME(MONTH, b.InventoryDate), ',', ' ', DATEPART(YYYY, b.InventoryDate)) AS 'InventoryDate'
                          , b.Count
    FROM dbo.vProducts AS a
    INNER JOIN dbo.vInventories AS b
    ON a.ProductID = b.ProductID
    ORDER BY a.ProductName, b.InventoryDate)
;
GO
--To check if the funciton is correct:
SELECT * FROM dbo.fProductInventory();
GO

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
CREATE VIEW dbo.vProductInventories
WITH SCHEMABINDING
AS
    SELECT TOP 100000 a.ProductName
                    , CONCAT (DATENAME(MONTH, b.InventoryDate), ',', ' ', DATEPART(YYYY, b.InventoryDate)) AS 'InventoryDate'
                    , b.Count
    FROM dbo.vProducts AS a
    INNER JOIN dbo.vInventories AS b
    ON a.ProductID = b.ProductID
    ORDER BY a.ProductName, b.InventoryDate
;
GO
--To check if vProductInventories is correct
SELECT * FROM dbo.vProductInventories;
GO

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Category and Date.
CREATE VIEW dbo.vCategoryInventories
WITH SCHEMABINDING
AS
    SELECT TOP 100000 a.CategoryName
                    , CONCAT (DATENAME(MONTH, c.InventoryDate), ',', ' ', DATEPART(YYYY, c.InventoryDate)) AS 'InventoryDate'
                    , SUM(c.Count) AS InventoryCountByCategory
    FROM dbo.vCategories AS a
	INNER JOIN dbo.vProducts AS b
	ON a.CategoryID = b.CategoryID
	INNER JOIN dbo.vInventories AS c
    ON b.ProductID = c.ProductID
    GROUP BY a.CategoryName, c.InventoryDate
    ORDER BY a.CategoryName, c.InventoryDate
;
GO
-- Check that it works: 
SELECT * FROM dbo.vCategoryInventories;
GO

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.
CREATE VIEW dbo.vProductInventoriesWithPreviouMonthCounts
WITH SCHEMABINDING
AS
    SELECT TOP 100000 ProductName
                    , InventoryDate
                    , Count
                    , LAG(Count, 1, 0) OVER (PARTITION BY ProductName ORDER BY MONTH(InventoryDate), YEAR(InventoryDate)) AS 'PreviousMonthCount'               
    FROM dbo.vProductInventories
    ORDER BY ProductName, MONTH(InventoryDate), YEAR(InventoryDate)
;
GO

-- Check that it works: 
SELECT * FROM dbo.vProductInventoriesWithPreviouMonthCounts;
GO

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.
CREATE FUNCTION dbo.CountKPI()
RETURNS TABLE
AS
    RETURN 
        (SELECT ProductName
              , InventoryDate
              , Count
              , PreviousMonthCount
              , CASE
                 WHEN Count > PreviousMonthCount Then 1
                 WHEN Count = PreviousMonthCount Then 0
                 WHEN Count < PreviousMonthCount Then -1
                END AS CountVsPreviousCountKPI
        FROM dbo.vProductInventoriesWithPreviouMonthCounts)
;
GO

CREATE VIEW dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
    SELECT TOP 100000 ProductName
                    , InventoryDate
                    , Count
                    , PreviousMonthCount
                    , CountVsPreviousCountKPI
    FROM dbo.CountKPI()
    ORDER BY ProductName, MONTH(InventoryDate), YEAR(InventoryDate)
;
GO
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: 
SELECT * FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;
GO

----------------------
--Another Solution:
CREATE VIEW dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs2
WITH SCHEMABINDING
AS
    SELECT TOP 100000 ProductName
                    , InventoryDate
                    , Count
                    , PreviousMonthCount
                    , CASE
                        WHEN Count > PreviousMonthCount Then 1
                        WHEN Count = PreviousMonthCount Then 0
                        WHEN Count < PreviousMonthCount Then -1
                        END AS CountVsPreviousCountKPI
    FROM dbo.vProductInventoriesWithPreviouMonthCounts
    ORDER BY ProductName, MONTH(InventoryDate), YEAR(InventoryDate)
;
GO
-- Check that it works: 
SELECT * FROM vProductInventoriesWithPreviousMonthCountsWithKPIs2;
GO

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.
CREATE FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs (@CountVsPreviousCountKPI AS INT)
RETURNS TABLE
AS
    RETURN 
        (SELECT TOP 1000000 ProductName
                          , InventoryDate
                          , Count
                          , PreviousMonthCount
                          , CountVsPreviousCountKPI
        FROM dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
        WHERE CountVsPreviousCountKPI = @CountVsPreviousCountKPI
        ORDER BY ProductName, MONTH(InventoryDate), YEAR(InventoryDate))
;
GO

--Check that it works:
Select * From dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
GO

/***************************************************************************************/