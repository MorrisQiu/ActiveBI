INSERT INTO address
    (address1,address2,address3,address4, 
	 city_key, post_code, state_key,country_key,
	 source_system_code, create_timestamp,update_timestamp
)

SELECT DISTINCT sc.address1, sc.address2, sc.address3,sc.address4,
	c.city_key,sc.zipcode AS post_code, s.state_key, co.country_key,
	2 AS source_system_code,
	GETDATE() AS create_timestamp,
	GETDATE() AS update_timestamp
FROM Stage.dbo.customer sc
	 LEFT OUTER JOIN city AS c ON sc.city = c.city_name
	 LEFT OUTER JOIN state AS s ON sc.state = s.state_name
	 LEFT OUTER JOIN country AS co ON sc.country = co.country_name
WHERE (NOT EXISTS
		(SELECT address1,address2,address3,address4, 
			city_key, post_code, state_key,country_key,
			source_system_code, create_timestamp,update_timestamp 
		 FROM address AS ad
		 WHERE (COALESCE(address1,'') = COALESCE(sc.address1,''))
			AND (COALESCE(address2,'') = COALESCE(sc.address2,''))
			AND (COALESCE(address3,'') = COALESCE(sc.address3,''))
			AND (COALESCE(address4,'') = COALESCE(sc.address4,''))
			AND (COALESCE(city_key,0) = COALESCE(c.city_key,0))
			AND (COALESCE(post_code,'') = COALESCE(sc.zipcode,'')) 
			AND (COALESCE(state_key,0) = COALESCE(s.state_key,0))
			AND (COALESCE(country_key, 0) = COALESCE(co.country_key,0))));