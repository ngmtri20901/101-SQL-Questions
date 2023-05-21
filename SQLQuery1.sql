--Q1: Write a SQL Statement that will give you a count of each object type in the AdventureWorks database. Order by count descending

SELECT 
	type_desc
    ,Count(*) as CNT
FROM sys.objects
GROUP BY type_desc
ORDER BY CNT DEST 


--Q2: a. Write a SQL Statement that will show a count of schemas, tables, and columns (do not include views) in the AdventureWorks database.

SELECT 
	COUNT (DISTINCT s.name) AS count_schema,
	COUNT (DISTINCT t.name) AS count_table,
	COUNT(c.name) AS count_column
FROM sys.tables AS t
INNER JOIN sys.columns AS c
ON c.object_id=t.object_id
INNER JOIN sys.schemas AS s
ON s.schema_id=t.schema_id
SELECT 
	COUNT (DISTINCT table_schema) AS count_schema,
	COUNT (DISTINCT table_name) AS count_table,
	COUNT(column_name) AS count_column
	FROM INFORMATION_SCHEMA.columns
	WHERE table_name  NOT IN(
		SELECT DISTINCT table_name  
		FROM information_schema.views)

--b. Write a similar statement as part a but list each schema, table, and column (do not include views). 

SELECT 
	s.name AS SchemaName,
	t.name AS TableName,
	c.name AS ColumnName
FROM sys.tables t
	INNER JOIN sys.columns c on c.object_id = t.object_id
	INNER JOIN sys.schemas s on s.schema_id = t.schema_id	
 
SELECT 
	table_schema as SchemaName,
	table_name as TableName,
	column_name as ColumnName
FROM INFORMATION_SCHEMA.columns
WHERE table_name NOT IN(
			SELECT DISTINCT table_name 
			FROM information_schema.views)


--Question 3:
--a Create a new database called "Edited_AdventureWorks" (we are creating another database so we don't overwrite or change the AdventureWorks database). Then write a USE statement to connect to the new database.

CREATE DATABASE Edited_AdventureWorks
USE Edited_AdventureWorks

--b Using the following tables - sys.check_constraints, sys.tables, and sys.columns to write a query that will give you TableName, ColumnName, CheckConstraintName, and CheckConstraintDefinition

SELECT 
	t.name AS TableName,
	c.name AS ColumnName,
	cc.name AS CheckConstraintName,
	cc.definition AS CheckConstraintDefinition
FROM AdventureWorks2019.sys.check_constraints CC
INNER JOIN AdventureWorks2019.sys.tables T 
ON T.object_id = CC.parent_object_id
LEFT JOIN AdventureWorks2019.sys.columns C 
ON C.column_id = CC.parent_column_id
AND C.object_id = CC.parent_object_id 

--c. Create a table named "tbl_CheckConstraint" in the "Edited_AdventureWorks" database with the following  columns and data types:

CREATE TABLE tbl_CheckConstraint(
TableName varchar(100),
ColumnName varchar(100),
CheckConsraint varchar(250),
[Definition] varchar(500),
ConstraintLevel varchar(100)) 
--d. Using the query in part b insert the data into "tbl_CheckConstraint"
INSERT INTO tbl_CheckConstraint
	(TableName,
	ColumnName,
	CheckConsraint, 
	[Definition])
		SELECT DISTINCT
			t.name AS TableName,
			c.name AS ColumnName,
			cc.name AS CheckConstraintName,
			cc.definition AS CheckConstraintDefinition
				FROM AdventureWorks2019.sys.check_constraints CC
				INNER JOIN AdventureWorks2019.sys.tables T 
				ON T.object_id = CC.parent_object_id
				LEFT JOIN AdventureWorks2019.sys.columns C 
				ON C.column_id = CC.parent_column_id
				AND C.object_id = CC.parent_object_id 

--e. Using a case statement write an update statement (update ConstraintLevel) that will specify whether the constraint is assigned to the column or the table.
UPDATE tbl_CheckConstraint
SET ConstraintLevel =
	CASE WHEN ColumnName IS NULL
	THEN 'TableLevel'
	ELSE 'ColumnLevel'
	END
--f. drop the tbl_CheckConstraint table
DROP TABLE tbl_CheckConstraint

--Question 4: Replicate 7 columns for every Foreign Key in the AdventureWorks database.

SELECT 
	O.name AS FK_Name,
	S1.name AS SchemaName,
	T1.name AS TableName,
	C1.name AS ColumnName,
	S2.name AS ReferencedSchemaName,
	T2.name AS ReferencedTableName,
	C2.name AS ReferencedColumnName
FROM sys.foreign_key_columns FKC
    INNER JOIN sys.objects O ON O.object_id = FKC.constraint_object_id
    INNER JOIN sys.tables T1 ON T1.object_id = FKC.parent_object_id
    INNER JOIN sys.tables T2 ON T2.object_id = FKC.referenced_object_id
    INNER JOIN sys.columns C1 ON C1.column_id = parent_column_id 
				AND C1.object_id = T1.object_id
    INNER JOIN sys.columns C2 ON C2.column_id = referenced_column_id 
				AND C2.object_id = T2.object_id
    INNER JOIN sys.schemas S1 ON T1.schema_id = S1.schema_id
    INNER JOIN sys.schemas S2 ON T2.schema_id = S2.schema_id 

--Question 5: a. To keep the AdventureWorks database clean create a new database called "Edited_AdventureWorks"
--b. Using a Select Into put the script in question 4 into a table named "Table_Relationships" be sure to put this table in the Edited_AdventureWorks database.

SELECT 
	O.name AS FK_Name,
	S1.name AS SchemaName,
	T1.name AS TableName,
	C1.name AS ColumnName,
	S2.name AS ReferencedSchemaName,
	T2.name AS ReferencedTableName,
	C2.name AS ReferencedColumnName
INTO Edited_AdventureWorks.dbo.Table_Relationships
FROM sys.foreign_key_columns FKC
    INNER JOIN sys.objects O ON O.object_id = FKC.constraint_object_id
    INNER JOIN sys.tables T1 ON T1.object_id = FKC.parent_object_id
    INNER JOIN sys.tables T2 ON T2.object_id = FKC.referenced_object_id
    INNER JOIN sys.columns C1 ON C1.column_id = parent_column_id 
				AND C1.object_id = T1.object_id
    INNER JOIN sys.columns C2 ON C2.column_id = referenced_column_id 
				AND C2.object_id = T2.object_id
    INNER JOIN sys.schemas S1 ON T1.schema_id = S1.schema_id
    INNER JOIN sys.schemas S2 ON T2.schema_id = S2.schema_id 
	
--c. Find the Table in Object Explorer
--d. Find the foreign key that has been used twice. 
SELECT 
	FK_Name,
	COUNT(*) AS CNT
FROM Table_Relationships
GROUP BY FK_Name
ORDER BY 2 DESC

--e. How many Distinct Foreign Keys include BusinessEntityID as a column or referenced column?
SELECT 
	COUNT(DISTINCT FK_Name) AS COUNT
FROM Table_Relationships
WHERE ColumnName='BusinessEntityID' OR ReferencedColumnName='BusinessEntityID'

--Q6: AdventureWorks has 152 Default Constraints. What tables and columns are these constraints on? And what are the default values?
SELECT 
	s.name AS SchemaName,
	t.name AS TableName,
	c.name AS ColumnName,
	dc.name AS DefaultConstraint,
	dc.definition AS DefaultDefinition
FROM  sys.default_constraints AS dc
INNER JOIN sys.tables t ON  t.object_id=dc.parent_object_id
INNER JOIN sys.schemas s ON s.schema_id=dc.schema_id 
INNER JOIN sys.columns c ON  c.column_id=dc.parent_column_id
						AND  c.object_id=dc.parent_object_id

--Q7: a. Write a script that find every column in the database that includes "rate" in the column name.
SELECT c.name AS ColumnName
FROM sys.columns c
WHERE c.name LIKE '%rate%'
--b. Write a script that find every table in the database that includes "History" in the table name.
SELECT t.name AS TableName
FROM sys.tables t
WHERE t.name LIKE '%History%' 

--Q8: a. Use information_schema.columns table to get a count of each data type in the AdventureWorks. Which data type is used the most?
SELECT 
	DATA_TYPE,
	COUNT(*) AS COUNT
FROM information_schema.columns
GROUP BY DATA_TYPE
ORDER BY COUNT DESC 

--b. Using a case statement create a data type grouping that summarizes each data type
SELECT 
	CASE WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN 'Character'
		WHEN NUMERIC_PRECISION IS NOT NULL THEN 'Numeric'
		WHEN DATETIME_PRECISION IS NOT NULL THEN 'Datetime'
		ELSE NULL
		END AS 'DataTypeGroup',
	COUNT(*) AS COUNT
FROM information_schema.columns
GROUP BY 	CASE WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN 'Character'
		WHEN NUMERIC_PRECISION IS NOT NULL THEN 'Numeric'
		WHEN DATETIME_PRECISION IS NOT NULL THEN 'Datetime'
		ELSE NULL
		END
ORDER BY COUNT DESC
--c. What data types are in the "Null" group
SELECT *
FROM information_schema.columns
WHERE CHARACTER_MAXIMUM_LENGTH IS NULL 
	AND NUMERIC_PRECISION IS NULL 
	AND	 DATETIME_PRECISION IS NULL
	
--Q9: Write a script that will show you each view name and the number of tables used to create the view.
SELECT 
	VIEW_NAME,
	COUNT(DISTINCT TABLE_NAME) AS COUNT_TABLE
FROM information_schema.view_column_usage
GROUP BY VIEW_NAME

--Q10: a. Write a script that will give you the TableName, ColumnName and each value (definition) where class = 1
--b. What is the find the value (definition) for every Column in the Person table
SELECT t.name AS TableName,
		c.name AS ColumnName,
		ep.value AS Definition
FROM sys.extended_properties AS ep
INNER JOIN sys.tables AS t ON ep.major_id=t.object_id
INNER JOIN sys.columns AS c ON ep.minor_id=c.column_id
							AND c.object_id = ep.major_id
WHERE ep.class=1 AND t.name = 'Person'
--Select * From sys.extended_properties