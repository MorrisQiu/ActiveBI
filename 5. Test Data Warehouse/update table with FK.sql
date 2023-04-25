--create a temple table 
CREATE TABLE dbo.tem_table1
AS
SELECT DISTINCT store_type_code,store_type,description,source_system_code
FROM NDS.dbo.store_type;

-- alter FK
ALTER TABLE NDS.dbo.store NOCHECK CONSTRAINT fk_store_store_type

-- delete the record
DELETE FROM NDS.dbo.store_type 

-- add constraint
ALTER TABLE NDS.dbo.store_type
ADD CONSTRAINT uq_store_type_code UNIQUE (store_type_code);

-- update the table
INSERT INTO NDS.dbo.store_type 
	 (store_type_code,store_type,description,source_system_code,
		create_timestamp,update_timestamp)
SELECT *
FROM tem_table

-- bring FK back
ALTER TABLE NDS.dbo.store WITH CHECK CHECK CONSTRAINT fk_store_store_type

DELETE FROM NDS.dbo.address_type
ALTER TABLE NDS.dbo.address_type
ADD CONSTRAINT uq_address_type_code UNIQUE (address_type_code)
--TRUNCATE TABLE NDS.dbo.store_type

SELECT *
FROM Stage.dbo.store
WHERE country = 'US'

-- alter addree type with address_type_code as unique
SELECT *
FROM NDS.dbo.address_type

ALTER TABLE NDS.dbo.address_junction NOCHECK CONSTRAINT fk_address_junction_address_type
-- TRUNCATE TABLE NDS.dbo.address_type 
DELETE FROM NDS.dbo.address_type
ALTER TABLE NDS.dbo.address_type
ADD CONSTRAINT uq_address_type_code UNIQUE (address_type_code)
ALTER TABLE NDS.dbo.address_junction WITH CHECK CHECK CONSTRAINT fk_address_junction_address_type

-- find the foreign key containers
SELECT *
FROM NDS.information_schema.key_column_usage
WHERE table_name = 'address_type';

SELECT
    fk.name AS foreign_key_name,
    OBJECT_NAME(fk.parent_object_id) AS referencing_table_name,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS referencing_column_name,
    OBJECT_NAME(fk.referenced_object_id) AS referenced_table_name,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS referenced_column_name
FROM
    NDS.sys.foreign_keys AS fk
INNER JOIN
    NDS.sys.foreign_key_columns AS fc
ON
    fk.object_id = fc.constraint_object_id
WHERE
    OBJECT_NAME(fk.parent_object_id) = 'dbo.address_type';

