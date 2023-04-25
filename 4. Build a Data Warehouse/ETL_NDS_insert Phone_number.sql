INSERT INTO phone_number
    (phone_number, source_system_code, create_timestamp, update_timestamp)

SELECT DISTINCT sc.phone_number AS phone_number,
	2 AS source_system_code,
	GETDATE() AS create_timestamp,
	GETDATE() AS update_timestamp
FROM Stage.dbo.customer sc
WHERE (NOT EXISTS
		(SELECT phone_number_key, phone_number, source_system_code, create_timestamp, update_timestamp
		 FROM phone_number AS pn
		 WHERE pn.phone_number = sc.phone_number))