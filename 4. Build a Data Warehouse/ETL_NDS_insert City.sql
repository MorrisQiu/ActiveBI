INSERT INTO city
    (city_name, source_system_code, create_timestamp, update_timestamp)

SELECT DISTINCT sc.city AS city_name,
	2 AS source_system_code,
	GETDATE() AS create_timestamp,
	GETDATE() AS update_timestamp
FROM Stage.dbo.customer sc
WHERE (NOT EXISTS
		(SELECT city_key, city_name, source_system_code, create_timestamp, update_timestamp
		 FROM city AS c
		 WHERE C.city_name = sc.city))