WITH customer_phone_number AS (
  select sc.customer_number, pn.phone_number_key
  from stage.dbo.customer sc
  inner join nds.dbo.phone_number pn
  on COALESCE(sc.phone_number,'') = coalesce(pn.phone_number,'')
)

INSERT INTO phone_number_junction
    (customer_key,phone_number_key, phone_number_type_key,
	 source_system_code, create_timestamp,update_timestamp)
SELECT DISTINCT c.customer_key, cpn.phone_number_key, 1 AS address_type_key,
	c.source_system_code*100+a.source_system_code*10 AS source_system_code,
	GETDATE() AS create_timestamp,
	GETDATE() AS update_timestamp
FROM customer_phone_number cpn
	 INNER JOIN customer AS c ON cpn.customer_number = c.customer_id
	 INNER JOIN phone_number AS a ON cpn.phone_number_key = a.phone_number_key
WHERE NOT EXISTS
		(SELECT aj.phone_number_junction_key 
		 FROM phone_number_junction AS aj
		 WHERE aj.customer_key = c.customer_key
		   AND aj.phone_number_key = cpn.phone_number_key);