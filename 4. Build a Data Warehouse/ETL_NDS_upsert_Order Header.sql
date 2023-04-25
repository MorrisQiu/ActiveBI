INSERT INTO NDS.dbo.order_header
 (order_id,sales_date,customer_key,store_key,currency_key,
  source_system_code,create_timestamp,update_timestamp)

SELECT sod.order_id, sod.order_date AS sales_date,cr.customer_key,
	   s.store_key, c.currency_key, 2 AS source_system_code,
	   sod.created AS create_timestamp, sod.last_updated AS update_timestamp
FROM Stage.dbo.order_header sod
	INNER JOIN NDS.dbo.customer cr ON sod.customer_number = cr.customer_id
	INNER JOIN NDS.dbo.store s ON sod.store_number = s.store_number
	INNER JOIN NDS.dbo.currency c ON sod.currency = c.currency_code
WHERE NOT EXISTS
	(SELECT nod.order_key
	 FROM NDS.dbo.order_header nod
	 WHERE nod.order_id = sod.order_id
		AND	nod.sales_date = sod.order_date
		AND nod.customer_key = cr.customer_key
		AND nod.store_key = s.store_key
		AND nod.currency_key = c.currency_key);

UPDATE NDS.dbo.order_header
SET order_id = sod.order_id
	,sales_date = sod.order_date
	,customer_key = cr.customer_key
	,store_key = s.store_key
	,currency_key = c.currency_key
	,source_system_code = 2
	,create_timestamp = sod.created
	,update_timestamp = sod.last_updated
FROM Stage.dbo.order_header sod
	INNER JOIN NDS.dbo.order_header nod ON sod.order_id = nod.order_id
	INNER JOIN NDS.dbo.customer cr ON sod.customer_number = cr.customer_id
	INNER JOIN NDS.dbo.store s ON sod.store_number = s.store_number
	INNER JOIN NDS.dbo.currency c ON sod.currency = c.currency_code
WHERE sod.order_id <> nod.order_id
	OR sod.order_date <> nod.sales_date
	OR sod.customer_number <> cr.customer_id
	OR sod.store_number <> s.store_number
	OR sod.currency <> c.currency_code
	OR sod.last_updated <> nod.update_timestamp;

-- below are for testing 
SELECT top(10) *
FROM NDS.dbo.currency

SELECT top(10) *
FROM Stage.dbo.order_header

SELECT *
FROM NDS.dbo.currency

SELECT *
FROM NDS.dbo.currency_rate

SELECT *
FROM Meta.dbo.data_flow
WHERE name = 'stg_country'

SELECT 'NDS Order_Header', COUNT(*) AS numsrows 
FROM NDS.dbo.order_header
UNION
SELECT 'Stage Order_Header', COUNT(*) AS numsrows 
FROM Stage.dbo.order_header
