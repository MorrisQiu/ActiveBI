-- Working statement to get the tree structure of NDS tables
USE NDS
GO

WITH nds (foreign_table,rel,primary_table)
AS
(

select distinct 
    schema_name(fk_tab.schema_id) + '.' + fk_tab.name as foreign_table,
    '>-' as rel,
    schema_name(pk_tab.schema_id) + '.' + pk_tab.name as primary_table
from sys.foreign_keys fk
    inner join sys.tables fk_tab
        on fk_tab.object_id = fk.parent_object_id
    inner join sys.tables pk_tab
        on pk_tab.object_id = fk.referenced_object_id
)
,

nds_all (foreign_table,rel,primary_table)
AS (
SELECT a.primary_table AS foreign_table,'>-' as rel, NULL AS primary_table
FROM nds a
LEFT JOIN
nds b
ON a.primary_table = b.foreign_table
WHERE b.foreign_table IS NULL
UNION ALL SELECT * from nds
),

nds_hierarchy 
AS (
SELECT foreign_table,rel,primary_table, 0 as level
		,CAST(foreign_table  AS varchar(100) ) AS path
FROM nds_all
WHERE primary_table is NULL

UNION ALL

SELECT nds_all.foreign_table, nds_all.rel, nds_all.primary_table,
		nds_hierarchy.level + 1 AS level,
		CAST(nds_hierarchy.path + '->' + nds_all.foreign_table AS varchar(100)) AS path
FROM nds_all, nds_hierarchy
WHERE nds_all.primary_table = nds_hierarchy.foreign_table
)
SELECT *
FROM nds_hierarchy

--End of the working NDS Table Tree 

-- The following is from ChatGPT by adding the tables with no dependencies.
-- Need correction
USE NDS;
GO

WITH nds_with_fk (foreign_table, rel, primary_table)
AS
(
    SELECT DISTINCT
        SCHEMA_NAME(fk_tab.schema_id) + '.' + fk_tab.name AS foreign_table,
        '>-' AS rel,
        SCHEMA_NAME(pk_tab.schema_id) + '.' + pk_tab.name AS primary_table
    FROM
        sys.foreign_keys fk
        INNER JOIN sys.tables fk_tab ON fk_tab.object_id = fk.parent_object_id
        INNER JOIN sys.tables pk_tab ON pk_tab.object_id = fk.referenced_object_id
),
nds_without_fk (table_name)
AS
(
    SELECT 
        SCHEMA_NAME(schema_id) + '.' + name AS table_name
    FROM 
        sys.tables t
    WHERE 
        NOT EXISTS (
            SELECT 1 FROM sys.foreign_keys fk WHERE fk.parent_object_id = t.object_id
        )
),
nds_all (foreign_table, rel, primary_table)
AS (
    SELECT 
        NULL AS foreign_table,
        '>-' AS rel,
        t.table_name AS primary_table
    FROM 
        nds_without_fk t
    
    UNION ALL
    
	SELECT 
        SCHEMA_NAME(fk_tab.schema_id) + '.' + fk_tab.name AS foreign_table,
        '>-' AS rel,
        SCHEMA_NAME(pk_tab.schema_id) + '.' + pk_tab.name AS primary_table
    FROM
        sys.foreign_keys fk
        INNER JOIN sys.tables fk_tab ON fk_tab.object_id = fk.parent_object_id
        INNER JOIN sys.tables pk_tab ON pk_tab.object_id = fk.referenced_object_id
),

nds_hierarchy (foreign_table, rel, primary_table, level, path)
AS (
    SELECT 
        foreign_table,
        rel,
        primary_table,
        0 AS level,
        CAST(foreign_table AS varchar(100)) AS path
    FROM 
        nds_all
    WHERE 
        primary_table IS NULL

    UNION ALL

    SELECT 
        nds_all.foreign_table,
        nds_all.rel,
        nds_all.primary_table,
        nds_hierarchy.level + 1 AS level,
        CAST(nds_hierarchy.path + '->' + nds_all.foreign_table AS varchar(100)) AS path
    FROM 
        nds_all 
        INNER JOIN nds_hierarchy ON nds_all.primary_table = nds_hierarchy.foreign_table
)
SELECT 
    *
FROM 
    nds_hierarchy
ORDER BY 
    level, 
    path;

--End of Query

SELECT COUNT(*) FROM sys.foreign_keys;

-- 2nd version from CGPT
WITH nds_with_fk (foreign_table, rel, primary_table)
AS
(
    SELECT DISTINCT
        SCHEMA_NAME(fk_tab.schema_id) + '.' + fk_tab.name AS foreign_table,
        '>-' AS rel,
        SCHEMA_NAME(pk_tab.schema_id) + '.' + pk_tab.name AS primary_table
    FROM
        sys.foreign_keys fk
        INNER JOIN sys.tables fk_tab ON fk_tab.object_id = fk.parent_object_id
        INNER JOIN sys.tables pk_tab ON pk_tab.object_id = fk.referenced_object_id
),
nds_without_fk (table_name)
AS
(
    SELECT 
        SCHEMA_NAME(schema_id) + '.' + name AS table_name
    FROM 
        sys.tables t
    WHERE 
        NOT EXISTS (
            SELECT 1 FROM sys.foreign_keys fk WHERE fk.parent_object_id = t.object_id
        )
),
nds_all (foreign_table, rel, primary_table)
AS (
    SELECT 
        NULL AS foreign_table,
        '>-' AS rel,
        table_name AS primary_table
    FROM 
        nds_without_fk
    
    UNION ALL
    
    SELECT 
        SCHEMA_NAME(fk_tab.schema_id) + '.' + fk_tab.name AS foreign_table,
        '>-' AS rel,
        SCHEMA_NAME(pk_tab.schema_id) + '.' + pk_tab.name AS primary_table
    FROM
        sys.foreign_keys fk
        INNER JOIN sys.tables fk_tab ON fk_tab.object_id = fk.parent_object_id
        INNER JOIN sys.tables pk_tab ON pk_tab.object_id = fk.referenced_object_id
),
nds_hierarchy (foreign_table, rel, primary_table, level, path)
AS (
    SELECT 
        foreign_table,
        rel,
        primary_table,
        0 AS level,
        CAST(foreign_table AS varchar(100)) AS path
    FROM 
        nds_all
    WHERE 
        primary_table IS NULL

    UNION ALL

    SELECT 
        nds_all.foreign_table,
        nds_all.rel,
        nds_all.primary_table,
        nds_hierarchy.level + 1 AS level,
        CAST(nds_hierarchy.path + '->' + nds_all.foreign_table AS varchar(100)) AS path
    FROM 
        nds_all 
        INNER JOIN nds_hierarchy ON nds_all.primary_table = nds_hierarchy.foreign_table
)
SELECT 
    *
FROM 
    nds_hierarchy
ORDER BY 
    level, 
    path;

 -- end of 2nd version

 -- 3rd version

 WITH nds_without_fk (table_name)
AS
(
    SELECT 
        SCHEMA_NAME(schema_id) + '.' + name AS table_name
    FROM 
        sys.tables t
    WHERE 
        NOT EXISTS (
            SELECT 1 FROM sys.foreign_keys fk WHERE fk.parent_object_id = t.object_id
        )
)
SELECT * FROM nds_without_fk;

WITH nds_with_fk (foreign_table, rel, primary_table)
AS
(
    SELECT DISTINCT
        COALESCE(SCHEMA_NAME(fk_tab.schema_id) + '.', '') + fk_tab.name AS foreign_table,
        '>-' AS rel,
        COALESCE(SCHEMA_NAME(pk_tab.schema_id) + '.', '') + pk_tab.name AS primary_table
    FROM
        sys.foreign_keys fk
        INNER JOIN sys.tables fk_tab ON fk_tab.object_id = fk.parent_object_id
        INNER JOIN sys.tables pk_tab ON pk_tab.object_id = fk.referenced_object_id
)

SELECT * FROM nds_with_fk;

nds_all (foreign_table, rel, primary_table)
AS (
    SELECT 
        NULL AS foreign_table,
        '>-' AS rel,
        name AS primary_table
    FROM 
        nds_without_fk
    
    UNION ALL
    
	SELECT 
        SCHEMA_NAME(fk_tab.schema_id) + '.' + fk_tab.name AS foreign_table,
        '>-' AS rel,
        SCHEMA_NAME(pk_tab.schema_id) + '.' + pk_tab.name AS primary_table
    FROM
        sys.foreign_keys fk
        INNER JOIN sys.tables fk_tab ON fk_tab.object_id = fk.parent_object_id
        INNER JOIN sys.tables pk_tab ON pk_tab.object_id = fk.referenced_object_id
)

SELECT * FROM nds_all;

-- end of 3rd version
where pk_tab.[name] = 'dbo.customer' -- enter table name here
--  and schema_name(pk_tab.schema_id) = 'Your table schema name'
order by schema_name(fk_tab.schema_id) + '.' + fk_tab.name,
    schema_name(pk_tab.schema_id) + '.' + pk_tab.name

-- using coomon table expression 
WITH CTE (f_id, depth, f_id_depth) AS (
  --Anchor statement
  --(This provides the starting result set of the CTE.)
  SELECT DISTINCT
    f_id,
    1,
    f_id
  FROM
    file_table
  UNION ALL
  --Recursive statement
  --(Note this contains the CTE itself in the FROM-clause.)
  --(This statement gets executed repeatedly until it returns no rows anymore.)
  --(Each time, its results are added to the CTE's result set.)
  SELECT
    CTE.f_id,
    CTE.depth + 1,
    F.f_id
  FROM
    CTE
    INNER JOIN group_table AS G ON G.child = CTE.f_id_depth
    INNER JOIN folder_table AS F ON F.f_id = G.parent
)
SELECT
  --Use a SELECT ... FOR XML subquery to concatenate the folder names (each prefixed with a slash) in a single string.
  --Additionally, wrap the subquery in a STUFF function to remove the leading slash.
  STUFF((SELECT '/' + FF.f_name
         FROM CTE INNER JOIN folder_table AS FF ON FF.f_id = CTE.f_id_depth
         WHERE CTE.f_id = F.f_id
         ORDER BY CTE.depth DESC
         FOR XML PATH('')), 1, 1, '') AS f_name,
  F.file_name
FROM
  file_table AS F; 


