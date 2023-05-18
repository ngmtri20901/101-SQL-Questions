--Q1: Write a SQL Statement that will give you a count of each object type in the AdventureWorks database. Order by count descending
Select 
    type_desc
    ,Count(*) as CNT
From sys.objects
Group by type_desc
Order by CNT desc
--Q2: a. Write a SQL Statement that will show a count of schemas, tables, and columns (do not include views) in the AdventureWorks database.
--b. Write a similar statement as part a but list each schema, table, and column (do not include views). 

