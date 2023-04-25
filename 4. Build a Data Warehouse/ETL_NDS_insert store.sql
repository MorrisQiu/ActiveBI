INSERT INTO NDS.dbo.store
		(store_number, store_name, web_site,store_type_key,
		 address_key, phone_number_key, region_key,
		 source_system_code,create_timestamp, update_timestamp)
SELECT ss.store_number,ss.store_name,ss.web_site, st.store_type_key,
	   ad.address_key,pn.phone_number_key,rg.region_key,
	   2 AS source_system_code,
	   ss.created AS create_timestamp, ss.last_updated AS update_timestamp
FROM Stage.dbo.store ss
	INNER JOIN NDS.dbo.store_type st ON ss.store_type = st.description
	INNER JOIN NDS.dbo.country cy 
		ON COALESCE(ss.country,'') = COALESCE(cy.country_code,'')
	LEFT JOIN NDS.dbo.state s 
		ON COALESCE(ss.state,'') = COALESCE(s.state_name,'')
	INNER JOIN NDS.dbo.city ct 
		ON COALESCE(ss.city,'') = COALESCE(ct.city_name,'')
	INNER JOIN NDS.dbo.address ad 
		ON COALESCE(ss.address1,'') = COALESCE(ad.address1,'')
		AND COALESCE(ss.address2,'') = COALESCE(ad.address2,'')
		AND COALESCE(ss.address3,'') = COALESCE(ad.address3,'')
		AND COALESCE(ss.address4,'') = COALESCE(ad.address4,'')
		AND COALESCE(ss.zipcode,'') = COALESCE(ad.post_code,'')
	INNER JOIN NDS.dbo.phone_number pn 
		ON COALESCE(ss.phone_number,'') = COALESCE(pn.phone_number,'')
	INNER JOIN NDS.dbo.region rg ON ss.region = rg.region_name
WHERE NOT EXISTS
	(SELECT ss.store_number,ss.store_name,ss.web_site, st.store_type_key,
	   ss.country,ss.state,ss.city,
	   2 AS source_system_code,
	   ss.created AS create_timestamp, ss.last_updated AS update_timestamp
	FROM NDS.dbo.store ns
	WHERE ns.store_type_key = st.store_type_key
		AND ns.address_key = ad.address_key
		AND ns.phone_number_key = pn.phone_number_key
		AND ns.region_key = rg.region_key);

SELECT COUNT(*)
FROM NDS.dbo.store

SELECT COUNT(*)
FROM Stage.dbo.store