-- Version 2.0, fixed the issue
--Insert when not exist
INSERT INTO NDS.dbo.order_item
 (order_key,line_number,product_key,quantity,unit_price,unit_cost,sales_value,
  sales_cost,margin,currency_key,currency_rate,unit_price_usd,unit_cost_usd,
  sales_value_usd,sales_cost_usd,margin_usd,
  source_system_code,create_timestamp,update_timestamp)

SELECT oh.order_key,sod.line_no AS line_number,p.product_key,sod.qty AS quantity,
	   sod.price AS unit_price,sod.unit_cost, sod.qty * sod.price AS sales_value,
	   sod.qty * sod.unit_cost AS sales_cost, 
	   sod.qty * (sod.price - sod.unit_cost) AS margin, c.currency_key,
	   lcr.currency_rate, sod.price * lcr.currency_rate AS unit_price_usd,
	   sod.unit_cost * lcr.currency_rate AS unit_cost_usd,
	   sod.qty * sod.price * lcr.currency_rate AS sales_value_usd,
	   sod.qty * sod.unit_cost * lcr.currency_rate AS sales_cost_usd,
	   sod.qty * (sod.price - sod.unit_cost) * lcr.currency_rate AS margin_usd,	   
	   2 AS source_system_code,oh.create_timestamp, oh.update_timestamp
FROM Stage.dbo.order_detail sod
	INNER JOIN NDS.dbo.order_header oh ON sod.order_id = oh.order_id
	INNER JOIN NDS.dbo.product p ON sod.product_code = p.product_code
	LEFT JOIN NDS.dbo.currency c ON oh.currency_key = c.currency_key
	INNER JOIN 
		(SELECT cr.currency_key,latest.latest_date,cr.currency_rate 
		 FROM NDS.dbo.currency_rate cr
			INNER JOIN 
			(SELECT MAX(effective_date) AS latest_date,currency_key
			FROM NDS.dbo.currency_rate GROUP BY currency_key) latest 	
			ON cr.effective_date = latest.latest_date 
				AND cr.currency_key = latest.currency_key) lcr
		ON oh.currency_key = lcr.currency_key
WHERE NOT EXISTS
	(SELECT noi.order_key, noi.line_number
	 FROM NDS.dbo.order_item noi
	   INNER JOIN NDS.dbo.order_header noh ON noi.order_key = noh.order_key
	 WHERE noh.order_id = sod.order_id
		AND	noi.line_number = sod.line_no);

-- Example from solution
use nds
go

-- Insert where not exists
insert into order_item
( order_key, line_number, product_key, quantity
, unit_price, unit_cost, sales_value, sales_cost
, margin, currency_key, currency_rate
, unit_price_usd, unit_cost_usd
, sales_value_usd, sales_cost_usd
, margin_usd, source_system_code
, create_timestamp, update_timestamp )
select oh.order_key as order_key
, coalesce(od.line_no, 0) as line_number
, coalesce(p.product_key, 0) as product_key
, od.qty as quantity, od.price as unit_price
, od.unit_cost as unit_cost
, od.qty * od.price as sales_value
, od.qty * od.unit_cost as sales_cost
, od.qty * (od.price-od.unit_cost) as margin
, oh.currency_key, cr.currency_rate
, od.price * cr.currency_rate as unit_price_usd
, od.unit_cost * cr.currency_rate as unit_cost_usd
, od.qty * od.price * cr.currency_rate as sales_value_usd
, od.qty * od.unit_cost * cr.currency_rate as sales_cost_usd
, od.qty * (od.price-od.unit_cost) * cr.currency_rate as margin_usd
, 1 as source_system_code
, getdate() as create_timestamp
, getdate() as update_timestamp
from stage.dbo.order_detail od
left join nds.dbo.product p
  on od.product_code = p.product_code
join nds.dbo.order_header oh
  on od.order_id = oh.order_id
left join nds.dbo.currency_rate cr
  on cr.currency_key = oh.currency_key 
 and cr.currency_key = 
 convert(datetime,
 convert(varchar, year(getdate())) 
 + '-' 
 + right('0'+convert(varchar, month(getdate())),2) 
 +  '-01')
where not exists 
( select * from order_item oi
  where oi.order_key = oh.order_key )
go

-- version 2.0 thoughts






-- update when there are changes
--UPDATE NDS.dbo.order_item
--SET order_key = nod.order_key, line_number = sod.line_no, product_key = p.product_key,
--	quantity = sod.qty, unit_price = sod.price, unit_cost = sod.unit_cost,
--	sales_value = sod.qty * sod.price, sales_cost = sod.qty*sod.unit_cost ,
--	margin = (sod.price-sod.unit_cost)*sod.qty,
--	currency_key = c.currency_key, currency_rate = cr.currency_rate,
--	unit_price_usd = sod.price * cr.currency_rate,
--	unit_cost_usd = sod.unit_cost * cr.currency_rate,
--    sales_value_usd = sod.qty * sod.price * cr.currency_rate,
--	sales_cost_usd = sod.qty*sod.unit_cost * cr.currency_rate,
--	margin_usd = (sod.price-sod.unit_cost)*sod.qty*cr.currency_rate,
--    source_system_code = 2, create_timestamp = soh.created, 
--	update_timestamp = soh.last_updated
--FROM Stage.dbo.order_detail sod
--	INNER JOIN NDS.dbo.order_header nod ON sod.order_id = nod.order_id
--	INNER JOIN NDS.dbo.order_item noi 
--		ON nod.order_key = noi.order_key AND noi.line_number = sod.line_no
--	INNER JOIN NDS.dbo.product p ON noi.product_key = p.product_key
--	INNER JOIN Stage.dbo.order_header soh ON sod.order_id = soh.order_id
--	INNER JOIN NDS.dbo.currency c ON soh.currency = c.currency_code
--	INNER JOIN NDS.dbo.currency_rate cr ON c.currency_key =cr.currency_key
--WHERE sod.product_code <> p.product_code
--	OR sod.qty <> noi.quantity
--	OR sod.price <> noi.unit_price
--	OR sod.unit_cost <> noi.unit_cost;

---- below are for testing 
--SELECT COUNT(*)
--FROM Stage.dbo.order_detail

--SELECT COUNT (*)
--FROM NDS.dbo.order_item

--SELECT top(10) *
--FROM Stage.dbo.order_header

--SELECT cy.currency_code,cr.currency_rate, cr.effective_date
--FROM NDS.dbo.currency cy
--  INNER JOIN NDS.dbo.currency_rate cr
--    ON cy.currency_key = cr.currency_key

--SELECT *
--FROM NDS.dbo.currency_rate

--SELECT *
--FROM Meta.dbo.data_flow
--WHERE name = 'stg_country'

--SELECT 'NDS Order_Header', COUNT(*) AS numsrows 
--FROM NDS.dbo.order_header
--UNION
--SELECT 'Stage Order_Header', COUNT(*) AS numsrows 
--FROM Stage.dbo.order_header

--SELECT *
--FROM Stage.dbo.currency_rate

--SELECT *
----UPDATE Meta.dbo.data_flow
----SET LSET = NULL, CET = NULL
--FROM Meta.dbo.data_flow
--WHERE name ='stg_currency_rate'

--UNION
--SELECT '2007-01-01' AS effective_date, 'USD' AS currency_code, 1.0 AS currency_rate, GETDATE() AS created, GETDATE() AS last_updated