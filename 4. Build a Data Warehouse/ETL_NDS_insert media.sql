INSERT INTO NDS.dbo.media
	(media_code, media, source_system_code,create_timestamp, update_timestamp)
SELECT DISTINCT sf.media AS media_code, sf.media,
		3 AS source_system_code, GETDATE() AS create_timestamp,
		GETDATE() AS update_timestamp
FROM Stage.dbo.format sf
WHERE NOT EXISTS
	(SELECT *
	 FROM NDS.dbo.media m
	 WHERE m.media_code <> sf.media) 



