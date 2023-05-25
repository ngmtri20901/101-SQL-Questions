--Question 31:
--a. What is Ken's current email address?
--b. Update his email address to 'Ken.Sánchez@adventure-works.com'

SELECT 
	ea.EmailAddress
FROM Person.Person p 
INNER JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
INNER JOIN Person.EmailAddress ea ON ea.BusinessEntityID = p.BusinessEntityID
WHERE p.FirstName ='Ken'
	AND p.LastName = 'Sánchez'

	UPDATE Person.EmailAddress
	SET EmailAddress= 'Ken.Sánchez@adventure-works.com'
	WHERE BusinessEntityID=1

--Question 32: In this question we are going to set Ken's (the CEO) email back to the original email (assuming it has been updated from question 31). Then we are going to use BEGIN TRANSACTION, ROLLBACK, and COMMIT to fix/correct a mistake.
/*a. Update Ken's Email Address to the orginial address using the script below:
        Update Person.EmailAddress
	Set EmailAddress = 'ken0@adventure-works.com'
	Where BusinessEntityID = 1
b. Check the number of open transactions by running: Select @@TranCount
c. Start the transaction with the BEGIN TRAN statement. You can use BEGIN TRANSACTION or BEGIN TRAN. Then check the number of open transactions again.
d. Run our incorrect update statement
        Update Person.EmailAddress
	Set EmailAddress = 'Ken.Sánchez@adventure-works.com'
	From Person.EmailAddress ea
	    Inner Join Person.Person p on p.BusinessEntityID = ea.BusinessEntityID
	Where p.FirstName ='Ken'
	  and p.LastName = 'Sánchez'
e. Correct the mistake/error by running the ROLLBACK statement 
f. Check to see if the mistake has been fixed.
g. Start the transaction, run the correct update statement, COMMIT the transaction
h. Question 33 we will automate whether the Transaction commits or rollsback. */
Update Person.EmailAddress
	Set EmailAddress = 'ken0@adventure-works.com'
	Where BusinessEntityID = 1
SELECT * FROM Person.EmailAddress
WHERE EmailAddress = 'ken0@adventure-works.com'

Select @@TranCount as OpenTransactions
BEGIN TRAN
        Update Person.EmailAddress
	Set EmailAddress = 'Ken.Sánchez@adventure-works.com'
	From Person.EmailAddress ea
	    Inner Join Person.Person p on p.BusinessEntityID = ea.BusinessEntityID
	Where p.FirstName ='Ken'
	  and p.LastName = 'Sánchez'
ROLLBACK

Select * From Person.EmailAddress
Where EmailAddress = 'Ken.Sánchez@adventure-works.com'

BEGIN TRAN

Update Person.EmailAddress
Set EmailAddress = 'Ken.Sánchez@adventure-works.com'
Where BusinessEntityID = 1
COMMIT
Select * From Person.EmailAddress
Where EmailAddress = 'Ken.Sánchez@adventure-works.com'  
--Q33: Write a script that will commit if the update is correct. If the update is not correct then rollback. 
--For example, If we know how many rows need to be updated then we can use a @@ROWCOUNT and if that number doesn't meet the condition then rollsback. If it does meet the condition then it commits.
        Update Person.EmailAddress
	Set EmailAddress = 'ken0@adventure-works.com'
	Where BusinessEntityID = 1
 
	Update Person.EmailAddress
	Set EmailAddress = 'ken3@adventure-works.com'
	Where BusinessEntityID = 1726

SELECT @@TRANCOUNT AS OpenTransaction
SELECT * FROM Person.EmailAddress
BEGIN TRAN
UPDATE Person.EmailAddress
SET EmailAddress='Ken.Sánchez@adventure-works.com'
WHERE BusinessEntityID = 1
IF @@ROWCOUNT=1
COMMIT
ELSE 
ROLLBACK 

--Question 34:
--a. Using the RANK function rank the employees in the Employee table by the hiredate. Label the column as 'Seniority'
--b. Assuming Today is March 3, 2014, add 3 columns for the number of days, months, and years the employee has been employed.
DECLARE @@CurrentDate date ='2014-03-03'
SELECT 
	RANK() OVER (ORDER BY HireDate ASC) AS Seniority,
	DATEDIFF(day,HireDate, @@CurrentDate) AS DaysEmployed,
	DATEDIFF(MONTH,HireDate, @@CurrentDate) AS DaysEmployed,
	DATEDIFF(YEAR,HireDate, @@CurrentDate) AS DaysEmployed,
	*
FROM HumanResources.Employee
	
/*Question 35:
a. Using a Select Into Statement put this table into a Temporary Table. Name the table '#Temp1'
b. Run this statement:
Select * 
From #Temp1
Where BusinessEntityID in ('288','286')
Update the YearsEmployed to "0" for these two Employees.
c. Using the Temp table, how many employees have worked for AdventureWorks over 5 years and 6 months?
d. Create a YearsEmployed Grouping
e. Show the average VacationHours and SickLeaveHours by the YearsEmployed Group. Which Group has the highest average Vacation and SickLeave Hours?
*/
SELECT 
	RANK() OVER (ORDER BY Hiredate asc) AS 'Seniority',
	DATEDIFF(Day,HireDate,'2014-03-03') AS 'DaysEmployed',
	DATEDIFF(Month,HireDate,'2014-03-03') AS 'MonthsEmployed',
	DATEDIFF(Year,HireDate,'2014-03-03') AS 'YearsEmployed',
	* 
INTO #Temp1
FROM HumanResources.Employee 
Select * 
From #Temp1
Where BusinessEntityID in ('288','286')

UPDATE #Temp1
SET YearsEmployed=0
WHERE BusinessEntityID IN ('288','286') 

Select * 
From #Temp1

SELECT  
	CASE WHEN YearsEmployed = 0 THEN 'EmployedLessThan1Year'
		  WHEN YearsEmployed between 1 and 2 THEN 'Employed1-2Years'
		  WHEN YearsEmployed between 3 and 4 THEN 'Employed3-4Years'
		  WHEN YearsEmployed between 5 and 6 THEN 'Employed5-6Years'
		  ELSE 'EmployedOver6years'
		  END AS YearsEmployedGroup,
	COUNT(*) AS EmpCNT
	AVG(YearsEmployed) AS Sort,
	AVG(VacationHours) AS VacationHours,
	AVG(SickLeaveHours) AS SickLeaveHours
From #Temp1
GROUP BY
	CASE WHEN YearsEmployed = 0 THEN 'EmployedLessThan1Year',
		  WHEN YearsEmployed between 1 and 2 THEN 'Employed1-2Years',
		  WHEN YearsEmployed between 3 and 4 THEN 'Employed3-4Years',
		  WHEN YearsEmployed between 5 and 6 THEN 'Employed5-6Years',
		  ELSE 'EmployedOver6years', 
		  END YearsEmployedGroup
ORDER BY 3 DESC 

--Question 36:
--a. Pull a distinct list of every region. Use the SalesTerritory as the region.
--b. Add the Sum(TotalDue) to the list of regions
--c. Add each customer name. Concatenate First and Last Names
--d. Using ROW_NUMBER and a partition rank each customer by region. For example, Australia is a region and we want to rank each customer by the Sum(TotalDue). 

--Question 37:
--a. Limit the results in question 36 to only show the top 25 customers in  each region. There are 10 regions so you should have 250 rows.
--b. What is the average TotalDue per Region? Leave the top 25 filter

SELECT 
	RegionName,
	FORMAT(AVG(TotalDue),'C0') AS AvgTotalDue,
	AVG(TotalDue) AS Sort
FROM (
	SELECT 
		DISTINCT st.Name AS RegionName,
		SUM(TotalDue) AS TotalDue,
		CONCAT(p.FirstName,' ',p.LastName) AS CustomerName,
		ROW_NUMBER() OVER(PARTITION BY st.Name ORDER BY SUM(TotalDue) DESC) AS RowNum
	FROM Sales.SalesTerritory st
	INNER JOIN Sales.SalesOrderHeader soh ON soh.TerritoryID = st.TerritoryID
	INNER JOIN Sales.Customer c on c.CustomerID = soh.CustomerID
	INNER JOIN Person.Person p on p.BusinessEntityID = c.PersonID
	GROUP BY st.Name, CONCAT(p.FirstName,' ',p.LastName) ) AS a
WHERE RowNum <= 25 
GROUP BY RegionName
ORDER BY 3 DESC

--Question 38
--a. How much has AdventureWorks spent on freight in totality?
SELECT *
FROM Sales.SalesOrderHeader

--b. Show how much has been spent on freight by year (ShipDate)
--c. Add the average freight per SalesOrderID
--d. Add a Cumulative/Running Total sum

--Question 39
--a. How many months were completed in each Year. 
--b. Calculate the average Total Freight by completed month
SELECT 
	ShipYear,
	ShipMonth,
	FORMAT(TotalFreight,'C0') AS TotalFreight,
	FORMAT(AvgFreight,'C0') AS AvgFreight,
	FORMAT(SUM(TotalFreight) OVER (ORDER BY ShipYear),'C0') AS RunningTotal,
	FORMAT(TotalFreight/ShipMonth,'C0') AS AvgTotalFreight
FROM (
	SELECT 
		DATEPART(YEAR, ShipDate) AS ShipYear,
		COUNT(DISTINCT DATEPART(MONTH, ShipDate)) AS ShipMonth,
		SUM(Freight) AS TotalFreight,
		AVG(Freight) AS AvgFreight
	FROM Sales.SalesOrderHeader
	GROUP BY DATEPART(YEAR, ShipDate)) AS a 
--Question 40
--a. Start by writing a query that shows freight costs by Month (use ShipDate). Be sure to include year. Include two Month columns one where month is 1-12 and another with the full month written out 
--b. Add an average
--c. Add acumulative Sum start with June 2011 and go to July 2014.
--d. Add a yearly cumulative Sum, which means every January will start over.
SELECT 
		ShipYear,
		ShipMonth,
		ShipMonthName,
		FORMAT(TotalFreight,'C0') AS TotalFreight,
		FORMAT(AvgFreight,'C0') AS AvgFreight,
		FORMAT(SUM(TotalFreight) OVER (ORDER BY ShipYear, ShipMonth),'C0') AS CumulativeSum,  
		FORMAT(SUM(TotalFreight) OVER (PARTITION BY ShipYear ORDER BY ShipYear,ShipMonth),'C0') AS CumulativeSum_Year
FROM (
	SELECT 
		DATEPART(YEAR, ShipDate) AS ShipYear,
		DATEPART(MONTH, ShipDate) AS ShipMonth,
		DATENAME(MONTH, ShipDate) AS ShipMonthName,
		SUM(Freight) AS TotalFreight,
		AVG(Freight) AS AvgFreight
	FROM Sales.SalesOrderHeader
	GROUP BY DATEPART(YEAR, ShipDate), DATEPART(MONTH, ShipDate), DATENAME(MONTH, ShipDate)) AS a



