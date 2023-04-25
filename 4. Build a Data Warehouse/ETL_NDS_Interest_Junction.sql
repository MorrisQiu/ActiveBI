WITH customer_interests AS (
  SELECT customer_number,
         interest1,
         interest2,
         interest3
  FROM Stage.dbo.customer
),
interest_type AS (
  SELECT 'interest1' AS interest_column, 1 AS interest_type
  UNION ALL
  SELECT 'interest2' AS interest_column, 2 AS interest_type
  UNION ALL
  SELECT 'interest3' AS interest_column, 3 AS interest_type
),
customer_unpivoted AS (
  SELECT customer_number,
         interest_type,
         CASE interest_type
           WHEN 1 THEN interest1
           WHEN 2 THEN interest2
           WHEN 3 THEN interest3
         END AS interest
  FROM customer_interests
  CROSS JOIN interest_type
)

INSERT INTO interest_junction (
  customer_key,
  interest_key,
  interest_type_key,
  source_system_code,
  create_timestamp,
  update_timestamp
)
SELECT c.customer_key,
       i.interest_key,
       sc.interest_type,
       c.source_system_code * 10 + i.source_system_code AS source_system_code,
       GETDATE() AS create_timestamp,
       GETDATE() AS update_timestamp
FROM customer_unpivoted AS sc
INNER JOIN interest AS i ON sc.interest = i.interest
INNER JOIN customer AS c ON sc.customer_number = c.customer_id
WHERE NOT EXISTS (
  SELECT interest_junction_key
  FROM interest_junction AS j
  WHERE j.customer_key = c.customer_key
  AND j.interest_key = i.interest_key
  AND j.interest_type_key = sc.interest_type
);