--Question 21:
--a. Pull a list of every country and state in the database.
--b. Includes tax rates.
--c. Find the countries / states that have more than 1 tax rate .
--d. Which location has the highest tax rate?

SELECT 
	sp.name AS Province,
	cr.Name AS Country,
	tr.TaxRate AS Taxrate
FROM Person.StateProvince AS sp
INNER JOIN Person.CountryRegion cr ON cr.CountryRegionCode=sp.CountryRegionCode
LEFT JOIN Sales.SalesTaxRate tr ON  tr.StateProvinceID=sp.StateProvinceID
ORDER BY tr.TaxRate DESC

	SELECT * FROM Sales.SalesTaxRate	
	WHERE StateProvinceID IN (
		SELECT 
			sp.StateProvinceID
		FROM Person.StateProvince AS sp
		INNER JOIN Person.CountryRegion cr ON cr.CountryRegionCode=sp.CountryRegionCode
		LEFT JOIN Sales.SalesTaxRate tr ON  tr.StateProvinceID=sp.StateProvinceID
		GROUP BY sp.StateProvinceID
		HAVING COUNT(*) > 1)

--Question 22
--The Marketing Department has never ran ads in the United Kingdom and would like you pull a list of every individual customer (PersonType = IN) by country.
--a. How many individual (retail) customers exist in the person table?
--b. Show this breakdown by country
--c. What percent of total customers reside in each country. For Example,  if there are 1000 total customers and 200 live in the United States then 20% of the customers live in the United States. 
SELECT 
	cr.Name as Country,
	COUNT(*) AS CNT,
	FORMAT(CAST(COUNT(*) AS FLOAT)
		/(SELECT COUNT(*) 
		  FROM Person.Person 
		  WHERE PersonType = 'IN'),'P') AS '%ofTotal'
FROM Person.Person AS p
INNER JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = p.BusinessEntityID
INNER JOIN Person.Address a ON a.AddressID = bea.AddressID
INNER JOIN Person.StateProvince sp ON sp.StateProvinceID = a.StateProvinceID
INNER JOIN Person.CountryRegion cr ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE PersonType = 'IN'
GROUP BY cr.Name
ORDER BY CNT DESC
--Question 23: Take the query and replace the denomiator with a declare/local variable.
DECLARE @TotalRetailCustomers FLOAT =
	(SELECT COUNT(BusinessEntityID) 
 	 FROM Person.Person 
	 WHERE PersonType = 'IN')
SELECT 
	cr.Name as Country,
	COUNT(*) AS CNT,
	FORMAT(CAST(COUNT(*) AS FLOAT)
		/@TotalRetailCustomers,'P') AS '%ofTotal'
FROM Person.Person AS p
INNER JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = p.BusinessEntityID
INNER JOIN Person.Address a ON a.AddressID = bea.AddressID
INNER JOIN Person.StateProvince sp ON sp.StateProvinceID = a.StateProvinceID
INNER JOIN Person.CountryRegion cr ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE PersonType = 'IN'
GROUP BY cr.Name
ORDER BY CNT DESC

--Question 24: In this question use SalesOrderID '69411' to determine answer.
--a. In the SalesOrderHeader what is the difference between "SubTotal" and "TotalDue"?
--b. Which one of these matches the "LineTotal" in the SalesOrderDetail?
--c. How is TotalDue calculated in SalesOrderHeader?
--d. How is LineTotal calculated in SalesOrderDetail?
SELECT 
	FORMAT(SUM(SubTotal),'C0') AS SubTotal,
	FORMAT(SUM(TotalDue),'C0') AS TotalDue,
	FORMAT(SUM(SubTotal)-SUM(TotalDue),'C0') AS 'Difference',
	FORMAT(SUM(SubTotal)+SUM(TaxAmt)+SUM(Freight),'C0') AS TotalDue2
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesOrderID = '69411'
SELECT 
	FORMAT(SUM(LineTotal),'C0') AS LineTotal,
	FORMAT(SUM(UnitPrice*(1-UnitPriceDiscount)*OrderQty),'C0') AS LineTotal
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = '69411'

--Question 25: Which product has the best margins? 
SELECT 
	p.name,
	FORMAT(ListPrice, 'C0') AS ListPrice,
	FORMAT(StandardCost, 'C0') AS StandardCost,
	FORMAT((ListPrice-StandardCost), 'C0') AS ProductMargins,
	(ListPrice - StandardCost) as Sort
FROM Production.Product AS p
ORDER BY Sort DESC

--Question 26: 
--a.Within the Production.Product table find a identifier that groups the 8 "Mountain-100" bicycles (4 Silver and 4 Black).
--b.How many special offers have been applied to these 8 bicycles? When did the special offer start? When did the special offer end? What was the special offer?
--c.Based on the most recent special offer start date is the product actually discontinued? Is the product still sold?
--d.When was the last date the product was sold to an actual customer?
SELECT 
	so.StartDate,
	so.EndDate,
	so.Type,
	so.Category,
	so.Description,
	so.DiscountPct,
	COUNT(DISTINCT p.name) as CNT
FROM Production.Product p
INNER JOIN Sales.SpecialOfferProduct sop ON sop.ProductID = p.ProductID
INNER JOIN Sales.SpecialOffer so ON so.SpecialOfferID = sop.SpecialOfferID
WHERE p.ProductModelID='19'
GROUP BY
	so.StartDate,
	so.EndDate,
	so.Type,
	so.Category,
	so.Description,
	so.DiscountPct

SELECT  
	SellStartDate,
	SellEndDate,
	DiscontinuedDate
FROM Production.Product
WHERE ProductModelID = '19'

SELECT 
	MIN(OrderDate) AS FirstDate,
	MAX(OrderDate) AS MostRecentDate
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
INNER JOIN Production.Product p ON p.ProductID = sod.ProductID
WHERE ProductModelID = '19'
--Question 27
--We learned in Question 26 that the 8 bicycles that fall under the 19 ProductModelID don't have a discontinued  date. 
--However, this model hasn't been ordered since  May 29, 2012. The most recent purchase (any item) was June 30, 2014. Which means this product either has been discounted and there isn't a discontinued date. 
--Or the product is still being sold, but hasn't been purchased in 2 years. Which is it?	
SELECT 
	p.name,
	SUM(i.quantity) AS Inventory
FROM Production.Product p
INNER JOIN Production.ProductInventory I ON i.ProductID = p.ProductID
WHERE ProductModelID = '19'
GROUP BY p.Name

--Question 28
--a. Using Sales.SalesReason pull a distinct list of every sales reason.
--b. Add a count of SalesOrderID's to the sales reason.
--c. Which Sales Reason is most common?
SELECT 
	sr.Name,
	COUNT(sohsr.SalesOrderID) as CNT
FROM Sales.SalesReason sr
INNER JOIN Sales.SalesOrderHeaderSalesReason sohsr ON sohsr.SalesReasonID=sr.SalesReasonID
GROUP BY sr.Name
ORDER BY CNT DESC 

--Question 29: Using a CTE find the number of SalesOrderIDs that have zero, one, two, and three sales reasons.
WITH CTE AS(
	SELECT 
		soh.SalesOrderID,
		COUNT(hsr.SalesOrderID) AS CNT
	FROM Sales.SalesOrderHeader soh
LEFT JOIN Sales.SalesOrderHeaderSalesReason hsr ON hsr.SalesOrderID = soh.SalesOrderID
GROUP BY soh.SalesOrderID)
 
SELECT 
	CNT
	,Count(CNT) as CNTofSalesOrderIDS
FROM CTE
GROUP BY CNT
ORDER BY 1 ASC

--Question 30:  Find the customers that left a review in the Person table? 
SELECT * FROM Production.ProductReview
/*
Select * From Person.EmailAddress
Where EmailAddress in (
					Select 
						EmailAddress
					from Production.ProductReview pr)
	*/			 
SELECT 
	CONCAT(FirstName,' ',LastName) AS name,
	* 
FROM HumanResources.Employee
INNER JOIN Person.Person ON Person.BusinessEntityID = Employee.BusinessEntityID
WHERE (FirstName = 'Laura' 
		AND LastName = 'Norman') OR 
		(FirstName = 'John' 
		AND LastName = 'Smith') OR 
		(FirstName ='David')  OR 
		(FirstName ='Jill')
