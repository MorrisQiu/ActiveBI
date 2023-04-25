INSERT INTO email_address
    (email_address, source_system_code, create_timestamp, update_timestamp)

SELECT DISTINCT sc.email_address AS email_address,
	2 AS source_system_code,
	GETDATE() AS create_timestamp,
	GETDATE() AS update_timestamp
FROM Stage.dbo.customer sc
WHERE (NOT EXISTS
		(SELECT email_address_key, email_address, source_system_code, create_timestamp, update_timestamp
		 FROM email_address AS ea
		 WHERE ea.email_address = sc.email_address))