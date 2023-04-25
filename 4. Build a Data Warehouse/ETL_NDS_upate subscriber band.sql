MERGE subscriber_band AS target
USING (VALUES ('A', 0.00, 49.99, 'band 50', 2),
			  ('B', 50.00, 99.99, 'band 100', 2),
			  ('C', 100.00, 199.99, 'band 200', 2),
			  ('D', 200.00, 500.00, 'band 200 +', 2))
		AS source(band_code,lower_limit,upper_limit,
				description,source_system_code)
ON target.band_code = source.band_code
WHEN MATCHED THEN
	UPDATE SET lower_limit = source.lower_limit,
			   upper_limit = source.upper_limit,
			   description = source.description,
			   source_system_code = source.source_system_code,
			   update_timestamp = GETDATE()
WHEN NOT MATCHED THEN
	INSERT (band_code,lower_limit,upper_limit,description,
			source_system_code,create_timestamp,update_timestamp)
	VALUES(source.band_code,source.lower_limit,source.upper_limit,source.description,
			source.source_system_code,GETDATE(),GETDATE());

SELECT *
FROM subscriber_band