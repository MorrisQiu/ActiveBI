WITH customer_address AS (
  select c.customer_number, z.address_key
  from stage.dbo.customer c
  inner join (
    select a.address_key, a.address1, a.address2, a.address3, a.address4
        , ci.city_name as city, s.state_name as state
        , a.post_code as zipcode, co.country_name as country
    from nds.dbo.address a
    join nds.dbo.city ci on a.city_key = ci.city_key
	left join nds.dbo.state s on a.state_key = s.state_key
	join nds.dbo.country co on a.country_key = co.country_key) z
  on coalesce(c.address1,'') = coalesce(z.address1,'')
	and coalesce(c.address2,'') = coalesce(z.address2,'')
	and coalesce(c.address3,'') = coalesce(z.address3,'')
	and coalesce(c.address4,'') = coalesce(z.address4,'')
)

INSERT INTO NDS.dbo.address_junction
    (customer_key,address_key, address_type_key,
	 source_system_code, create_timestamp,update_timestamp)
SELECT DISTINCT c.customer_key, ca.address_key, 22 AS address_type_key,
	c.source_system_code*100+a.source_system_code*10 AS source_system_code,
	GETDATE() AS create_timestamp,
	GETDATE() AS update_timestamp
FROM customer_address ca
	 INNER JOIN NDS.dbo.customer AS c ON ca.customer_number = c.customer_id
	 INNER JOIN NDS.dbo.address AS a ON ca.address_key = a.address_key
WHERE NOT EXISTS
		(SELECT aj.address_junction_key 
		 FROM NDS.dbo.address_junction AS aj
		 WHERE aj.customer_key = c.customer_key
		   AND aj.address_key = ca.address_key);