WITH customer_unpivoted AS (
  SELECT customer_number, 
		 interest, 
		 CAST(RIGHT(interest_type,1) AS INT) AS interest_type
  FROM (
    SELECT customer_number,interest1, interest2, interest3
    FROM Stage.dbo.customer
    ) AS original
  UNPIVOT (
		interest FOR interest_type IN (interest1, interest2, interest3)
  )   AS unpivoted
)
INSERT INTO interest_junction (
	customer_key, interest_key, interest_type_key, 
	source_system_code, create_timestamp, update_timestamp)
SELECT c.customer_key, i.interest_key, sc.interest_type,
  c.source_system_code * 10 + i.source_system_code AS source_system_code,
  GETDATE() AS create_timestamp, GETDATE() AS update_timestamp
FROM customer_unpivoted AS sc 
  INNER JOIN interest AS i ON sc.interest = i.interest
  INNER JOIN customer AS c ON sc.customer_number = c.customer_id
WHERE(NOT EXISTS
		(SELECT interest_junction_key, customer_key, interest_key, 
				interest_type_key, source_system_code, create_timestamp, 
				update_timestamp
		 FROM interest_junction AS j
		 WHERE (customer_key = c.customer_key)
			AND (interest_key = i.interest_key)
			AND (interest_type_key = sc.interest_type)));

