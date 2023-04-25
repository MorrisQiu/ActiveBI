-- checking no of lines in stage and NDS
SELECT *
FROM (
select 'stage' AS 'db', 'Order_detail' AS 'table',count(*) as num_lines
from stage.dbo.order_detail
UNION
select 'NDS','Order_detail',count(*)
from nds.dbo.order_item
) AS src
PIVOT(
	SUM(num_lines)
	FOR db IN (stage, NDS)
) AS piv



--from chatgpt
SELECT 
  product, 
  ABS(SUM(CASE WHEN date = '2022-01-01' THEN revenue ELSE 0 END) - SUM(CASE WHEN date = '2022-01-02' THEN revenue ELSE 0 END)) AS revenue_diff,
  [2022-01-01], 
  [2022-01-02]
FROM (
  SELECT date, product, revenue
  FROM sales
  WHERE date IN ('2022-01-01', '2022-01-02')
) AS src
PIVOT (
  SUM(revenue)
  FOR date IN ([2022-01-01], [2022-01-02])
) AS piv
GROUP BY product, [2022-01-01], [2022-01-02]

date         | product | revenue
---------------------------------
2022-01-01   | A       | 100
2022-01-01   | B       | 200
2022-01-02   | A       | 150
2022-01-02   | B       | 250

product | revenue_diff | 2022-01-01 | 2022-01-02
-------------------------------------------------
A       | 50           | 100        | 150
B       | 50           | 200        | 250

---Count the row for all tables from a database
USE Stage;
GO

SELECT *
FROM Stage.sys.tables

SELECT *
FROM Stage.sys.dm_db_partition_stats

DECLARE @database_name NVARCHAR(50) = 'Stage';
DECLARE @query NVARCHAR(MAX);

SET @query = '
SELECT 
  t.name AS table_name, 
  SUM(p.row_count) AS row_count
FROM 
  ' + QUOTENAME(@database_name) + '.sys.tables AS t
  INNER JOIN 
    (SELECT 
       object_id, SUM(row_count) AS row_count 
     FROM 
       ' + QUOTENAME(@database_name) + '.sys.dm_db_partition_stats
     WHERE 
       index_id < 2
     GROUP BY 
       object_id) AS p 
  ON t.object_id = p.object_id
--WHERE 
--  t.type = ''U'' 
--  AND t.name IN (''package'', ''package_type'', ''product_type'') -- Replace with your own table names
ORDER BY 
  t.name;
';

EXEC(@query);

--without variables row counts for Stage
SELECT 
  'Stage' AS db,t.name AS table_name,
  SUM(p.row_count) AS row_count
FROM 
  Stage.sys.tables AS t
  INNER JOIN 
    (SELECT ss.object_id, SUM(ss.row_count) AS row_count 
     FROM Stage.sys.dm_db_partition_stats ss
     WHERE ss.index_id < 2
     GROUP BY ss.object_id) AS p 
  ON t.object_id = p.object_id
GROUP BY t.name
ORDER By t.name;
--WHERE t.type = 'U' 
--  AND t.name IN ('package', 'package_type', 'product_type') -- Replace with your own table names
--ORDER BY 
--  t.name;

--without variables row counts for NDS
SELECT 
  'NDS' AS db,t.name AS table_name,
  SUM(p.row_count) AS row_count
FROM 
  NDS.sys.tables AS t
  INNER JOIN 
    (SELECT ss.object_id, SUM(ss.row_count) AS row_count 
     FROM NDS.sys.dm_db_partition_stats ss
     WHERE ss.index_id < 2
     GROUP BY ss.object_id) AS p 
  ON t.object_id = p.object_id
GROUP BY t.name
ORDER By t.name;


-- Conbine row count from tables of Stage and NDS
SELECT table_name,[NDS],[Stage], 
	   COALESCE([NDS],0) - COALESCE([Stage],0) AS nds_Stage_diff
FROM (
	SELECT 
		  'Stage' AS db,t.name AS table_name,
		   SUM(p.row_count) AS row_count
		FROM 
	  Stage.sys.tables AS t
	  INNER JOIN 
		(SELECT ss.object_id, SUM(ss.row_count) AS row_count 
		 FROM Stage.sys.dm_db_partition_stats ss
		 WHERE ss.index_id < 2
		 GROUP BY ss.object_id) AS p 
	  ON t.object_id = p.object_id
	GROUP BY t.name
	UNION
	SELECT 
	  'NDS' AS db,t.name AS table_name,
	  SUM(p.row_count) AS row_count
	FROM 
	  NDS.sys.tables AS t
	  INNER JOIN 
		(SELECT ss.object_id, SUM(ss.row_count) AS row_count 
		 FROM NDS.sys.dm_db_partition_stats ss
		 WHERE ss.index_id < 2
		 GROUP BY ss.object_id) AS p 
	  ON t.object_id = p.object_id
	GROUP BY t.name
	) as src
	PIVOT(SUM(row_count)
	  FOR db IN (NDS,Stage)
	  ) AS piv

--
SELECT *
FROM Meta.dbo.data_flow
WHERE name ='stg_currency_rate'

SELECT *
FROM jupiter.dbo.currency_rate

SELECT *
FROM Stage.dbo.currency_rate

UPDATE Meta.dbo.data_flow
SET LSET = NULL
WHERE name = 'stg_currency_rate'

