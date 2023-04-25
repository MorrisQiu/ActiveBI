
--Create Index 
CREATE INDEX index_name ON table_name (column1, column2, ...);
-- 
--Show the list of index

EXEC NDS.sys.sp_helpindex 'customer' 