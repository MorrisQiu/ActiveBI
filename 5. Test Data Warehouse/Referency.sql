USE NDS;  
GO  
SELECT OBJECT_NAME(referencing_id) AS referencing_entity_name,   
    o.type_desc AS referencing_desciption,   
    COALESCE(COL_NAME(referencing_id, referencing_minor_id), '(n/a)') AS referencing_minor_id,   
    referencing_class_desc,  
    referenced_server_name, referenced_database_name, referenced_schema_name,  
    referenced_entity_name,   
    COALESCE(COL_NAME(referenced_id, referenced_minor_id), '(n/a)') AS referenced_column_name,  
    is_caller_dependent, is_ambiguous  
FROM sys.sql_expression_dependencies AS sed  
INNER JOIN sys.objects AS o ON sed.referencing_id = o.object_id  
--WHERE referencing_id = OBJECT_ID('dbo.customer');  
GO 

/* Find all object which are referencing to "dbo.customer" table */
SELECT 
referencing_schema_name +'.'+ referencing_entity_name AS ReferencedEntityName,
referencing_class_desc AS ReferencingEntityDescription 
FROM sys.dm_sql_referencing_entities ('dbo.customer', 'OBJECT');
GO
USE NDS;  
GO

USE AdventureWorks2012;   
GO  
SELECT * FROM sys.sql_expression_dependencies  
WHERE referenced_id = OBJECT_ID(N'Production.Product');   
GO
SELECT OBJECT_NAME(referencing_id) AS referencing_entity_name,
       referenced_server_name       AS server_name,
       referenced_database_name     AS database_name,
       referenced_schema_name       AS schema_name,
       referenced_entity_name
  FROM sys.sql_expression_dependencies 
 WHERE referencing_id = OBJECT_ID(N'dbo.customer')
GO

USE NDS;  
GO
 
 GO


SELECT referencing_schema_name, referencing_entity_name, referencing_id,   referencing_class_desc, is_caller_dependent
	FROM sys.dm_sql_referencing_entities ('dbo.customer', 'OBJECT')
GO