USE NDS;
GO

UPDATE artist
SET artist_code = ?,
artist_name = ?,
genre = ?,
country_key = ?,
city_key =?,
source_system_code =?,
update_timestamp = ?
WHERE artist_name = ?