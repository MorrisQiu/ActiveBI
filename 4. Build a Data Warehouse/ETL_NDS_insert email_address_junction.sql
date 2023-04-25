WITH customer_email_address AS (
  select sc.customer_number, ea.email_address_key
  from stage.dbo.customer sc
  inner join nds.dbo.email_address ea
  on COALESCE(sc.email_address,'') = coalesce(ea.email_address,'')
)

INSERT INTO email_address_junction
    (customer_key,email_address_key, email_address_type_key,
	 source_system_code, create_timestamp,update_timestamp)
SELECT DISTINCT c.customer_key, cea.email_address_key, 1 AS address_type_key,
	c.source_system_code*100+a.source_system_code*10 AS source_system_code,
	GETDATE() AS create_timestamp,
	GETDATE() AS update_timestamp
FROM customer_email_address cea
	 INNER JOIN customer AS c ON cea.customer_number = c.customer_id
	 INNER JOIN email_address AS a ON cea.email_address_key = a.email_address_key
WHERE NOT EXISTS
		(SELECT aj.email_address_junction_key 
		 FROM email_address_junction AS aj
		 WHERE aj.customer_key = c.customer_key
		   AND aj.email_address_key = ca.email_address_key);