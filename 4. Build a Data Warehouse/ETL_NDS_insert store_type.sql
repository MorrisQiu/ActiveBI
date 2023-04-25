INSERT INTO NDS.dbo.store_type
	(store_type_code,store_type, description,
	source_system_code,create_timestamp,update_timestamp)
SELECT DISTINCT 
	CONCAT(
	  SUBSTRING(ss.store_type,1,1),
	  CASE WHEN CHARINDEX(' ',ss.store_type) > 0 THEN
	    SUBSTRING(ss.store_type, CHARINDEX(' ',ss.store_type) +1,1) 
		ELSE '' END) AS store_type_code,
	LEFT(TRIM(ss.store_type),10) AS store_type,
	ss.store_type AS description,
	2 AS source_system_code, 
	GETDATE() AS create_timestamp,
	GETDATE() AS update_timestamp
FROM Stage.dbo.store ss
WHERE NOT EXISTS
	(SELECT * FROM NDS.dbo.store_type st
	 WHERE st.store_type = LEFT(TRIM(ss.store_type),10));