WITH customer_preferred_channel AS (
  SELECT customer_number,
         preferred_channel1,
         preferred_channel2
  FROM Stage.dbo.customer
),
channel_type AS (
  SELECT 'preferred_channel1' AS channel_column, 1 AS channel_type
  UNION ALL
  SELECT 'preferred_channel2' AS channel_column, 2 AS channel_type
),
customer_unpivoted AS (
  SELECT customer_number,
         channel_type,
         CASE channel_type
           WHEN 1 THEN preferred_channel1
           WHEN 2 THEN preferred_channel2
         END AS channel
  FROM customer_preferred_channel
  CROSS JOIN channel_type
)

INSERT INTO channel_junction (
  customer_key,
  channel_key,
  channel_type_key,
  source_system_code,
  create_timestamp,
  update_timestamp
)
SELECT c.customer_key,
       i.channel_key,
       sc.channel_type,
       c.source_system_code * 10 + i.source_system_code AS source_system_code,
       GETDATE() AS create_timestamp,
       GETDATE() AS update_timestamp
FROM customer_unpivoted AS sc
INNER JOIN channel AS i ON sc.channel = i.name
INNER JOIN customer AS c ON sc.customer_number = c.customer_id
WHERE NOT EXISTS (
  SELECT channel_junction_key
  FROM channel_junction AS j
  WHERE j.customer_key = c.customer_key
  AND j.channel_key = i.channel_key
  AND j.channel_type_key = sc.channel_type
);