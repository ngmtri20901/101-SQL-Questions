--Question 11:
--a. How many employees exist in the Database?

SELECT 
	COUNT( DISTINCT BusinessEntityID) AS CNT
FROM HumanResources.Employee hre

--b. How many of these employees are active employees?
SELECT 
	COUNT( DISTINCT BusinessEntityID) AS CNT
FROM HumanResources.Employee hre
WHERE CurrentFlag=1
--c. How many Job Titles equal the 'SP' Person type?
--d. How many of these employees are sales people?
SELECT 
	hre.JobTitle,
	COUNT(DISTINCT hre.BusinessEntityID) AS CNT
FROM HumanResources.Employee hre
INNER JOIN Person.Person p ON hre.BusinessEntityID=p.BusinessEntityID
WHERE p.PersonType='SP'
GROUP BY hre.JobTitle

--Question 12:
--a. What is the name of the CEO? Concatenate first and last name.
--b. When did this person start working for AdventureWorks
SELECT 
	CONCAT(p.FirstName,' ',p.LastName) AS CEO_Name,
	hre.HireDate
FROM HumanResources.Employee hre
INNER JOIN Person.Person p ON hre.BusinessEntityID=p.BusinessEntityID
WHERE Jobtitle='Chief Executive Officer'
--c. Who reports to the CEO? Includes their names and title
SELECT 
	CONCAT(p.FirstName,' ',p.LastName) AS Fullname,
	hre.JobTitle
FROM HumanResources.Employee hre
INNER JOIN Person.Person p ON hre.BusinessEntityID=p.BusinessEntityID
WHERE OrganizationLevel='1'

--Question 13
--a. What is the job title for John Evans
--b. What department does John Evans work in?
SELECT 
	hre.BusinessEntityID,
	CONCAT(p.FirstName,' ',p.LastName) AS Fullname,
	hre.JobTitle,
	hrd.name AS Department
FROM HumanResources.Employee hre
INNER JOIN Person.Person p ON hre.BusinessEntityID=p.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory edh ON hre.BusinessEntityID=edh.BusinessEntityID
INNER JOIN HumanResources.Department hrd ON edh.DepartmentID=hrd.DepartmentID
WHERE FirstName='John' AND LastName='Evans'

--Question 14
--a. Which Purchasing vendors have the highest credit rating?
SELECT 
	v.name,
	MAX(v.CreditRating) AS CreditRating
FROM Purchasing.Vendor AS v
GROUP BY name
ORDER BY CreditRating DESC
--b. Using a case statement replace the 1 and 0 in Vendor.PreferredVendorStatus to "Preferred" vs "Not Preferred." How many vendors are considered Preferred?
--c. For Active Vendors only, do Preferred vendors have a High or lower average credit rating?
--d. How many vendors are active and Not Preferred?
SELECT
		CASE WHEN v.PreferredVendorStatus='1' THEN 'Preferred'
				ELSE 'Not Preferred'
				END AS [Status],
		AVG(CAST(v.CreditRating AS DECIMAL)) AS AvgRating,
		COUNT(*) AS COUNT
FROM Purchasing.Vendor AS v
WHERE v.ActiveFlag=1
GROUP BY 		CASE WHEN v.PreferredVendorStatus='1' THEN 'Preferred'
				ELSE 'Not Preferred'
				END
--Question 15:
--Assume today is August 15, 2014.
--a. Calculate the age for every current employee. What is the age of the oldest employee?
SELECT 
	e.BusinessEntityID,
	CONCAT(p.FirstName,' ',p.LastName) AS Fullname,
	e.Jobtitle,
	DATEDIFF(Year,e.BirthDate, '2014-08-15') AS Age
FROM HumanResources.Employee e
INNER JOIN Person.Person p ON e.BusinessEntityID=p.BusinessEntityID
ORDER BY Age DESC 
--b. What is the average age by Organization level? Show answer with a single decimal
--c. Use the ceiling function to round up
--d. Use the floor function to round down
SELECT 
	e.OrganizationLevel AS OrganizationLevel,
	FORMAT(AVG(CAST(DATEDIFF(Year,e.BirthDate, '2014-08-15') AS DECIMAL)),'n1') as Age,
	CEILING(Avg(cast(DATEDIFF(Year,BirthDate,'2014-08-15') as decimal))) as RoundUp,
	FLOOR(Avg(cast(DATEDIFF(Year,BirthDate,'2014-08-15') as decimal))) as RoundDown
FROM HumanResources.Employee e
GROUP BY OrganizationLevel
ORDER BY OrganizationLevel DESC

--Question 16:
--a. How many products are sold by AdventureWorks?
--b. How many of these products are actively being sold by AdventureWorks?
--c. How many of these active products are made in house vs. purchased? (MakeFlag: 0=Purchased, 1=Inhouse)
SELECT 
	COUNT(CASE WHEN MakeFlag=0 THEN 'ProductID' ELSE NULL END) AS Purchased,
	COUNT(CASE WHEN MakeFlag=1 THEN 'ProductID' ELSE NULL END) AS Inhouse,
	COUNT(*) as ProductCNT
FROM Production.Product
WHERE FinishedGoodsFlag = 1 AND SellEndDate IS NULL

--Question 17: We learned in Question 16 that the product table includes a few different type of products - i.e., manufactured vs. purchased.
--a. Sum the LineTotal in SalesOrderDetail. Format as currency
--b. Sum the LineTotal in SalesOrderDetail by the MakeFlag in the product table. Use a case statement to specify manufactured vs. purchased. Format as currency.
--c. Add a count of distinct SalesOrderIDs
--d. What is the average LineTotal per SalesOrderID?
SELECT 
	CASE WHEN MakeFlag=1 THEN 'Manufactured' ELSE 'Purchased' END AS MakeFlag,
	FORMAT(SUM(ord.LineTotal),'C0') AS SumLinetotal,
	COUNT(DISTINCT ord.SalesOrderID) AS CountOrder,
	FORMAT(SUM(ord.LineTotal)/COUNT(DISTINCT ord.SalesOrderID),'C0') AS AvgLinetotal
FROM Sales.SalesOrderDetail AS ord
INNER JOIN Production.Product p ON p.ProductID = ord.ProductID
GROUP BY MakeFlag
--Question 18: The AdventureWorks Cyclery database includes historical and present transactions.
--a.In the TransactionHistory and TransactionHistoryArchive tables a "W","S", and "P" are used as Transaction types. What do these abbreviations mean?
SELECT t.name AS TableName,
		c.name AS ColumnName,
		ep.value AS Definition
FROM sys.extended_properties AS ep
INNER JOIN sys.tables AS t ON ep.major_id=t.object_id
INNER JOIN sys.columns AS c ON ep.minor_id=c.column_id
							AND c.object_id = ep.major_id
WHERE ep.class=1 AND t.name IN ('TransactionHistory')

--b.Union TransactionHistory and TransactionHistoryArchive
--c.Find the First and Last TransactionDate in the TransactionHistory and TransactionHistoryArchive tables. Use the union written in part b. The current data type for TransactionDate is datetime. Convert or Cast the data type to date.
--d.Find the First and Last Date for each transaction type. Use a case statement to specify the transaction types.
SELECT 
	CASE WHEN TransactionType = 'W' THEN 'WorkOrder'
		 WHEN TransactionType = 'S' THEN 'SalesOrder'
		 WHEN TransactionType = 'P' THEN 'PurchaseOrder'
		 ELSE Null END AS TransactionType,
	CAST(MIN(a.TransactionDate) AS Date) AS FirstDate,
	CAST(MAX(a.TransactionDate) AS Date) AS LastDate
FROM (SELECT * FROM Production.TransactionHistory
UNION
SELECT * FROM Production.TransactionHistoryArchive) a
GROUP BY TransactionType--Question 19: Does the SalesOrderHeader table show a similar Order date for the first and Last Sale? Format as DateSELECT 
	CAST(MIN(soh.OrderDate) AS Date) AS FirstDate,
	CAST(MAX(soh.OrderDate) AS Date) AS LastDateFROM Sales.SalesOrderHeader AS soh--Question 20--a. Find the other tables and dates that should match the WorkOrder and PurchaseOrder Dates. Format these dates as a date in the YYYY-MM-DD format.
--b. Do the dates match? Why/Why not?SELECT 
	Status
	,CONVERT(date,MIN(OrderDate)) AS FirstDate --matches the pending status
	,CONVERT(date,MAX(OrderDate)) AS LastDate
FROM Purchasing.PurchaseOrderHeader
GROUP BY Status

SELECT 
	CONVERT(date,MIN(DueDate)) AS FirstDate
	,CONVERT(date,MAX(DueDate)) AS LastDate
	,CONVERT(date,MIN(StartDate)) AS FirstStartDate -- TransactionHistory
	,CONVERT(date,MAX(StartDate)) AS LastStartDate -- TransactionHistory
	,CONVERT(date,MIN(EndDate)) AS FirstEndDate
	,CONVERT(date,MAX(EndDate)) AS LastEndDate
FROM Production.WorkOrder

