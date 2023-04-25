SELECT 'Stage Order Detail', COUNT(*) As rows
FROM Stage.dbo.order_detail
UNION
SELECT 'Stage Order Header', COUNT(*)
FROM Stage.dbo.order_header
UNION
SELECT 'NDS Order header',COUNT(*)
FROM NDS.dbo.order_header
UNION
SELECT 'NDS Product', count(*)
FROM NDS.dbo.product 
UNION
SELECT 'Stage Product', count(*)
FROM Stage.dbo.product
UNION
SELECT 'Stage Currency', COUNT(*)
FROM stage.dbo.currency
UNION
SELECT 'NDS Currency', COUNT(*)
FROM NDS.dbo.currency 
UNION
SELECT 'Stage currency rate',COUNT(*)
FROM Stage.dbo.currency_rate 
UNION
SELECT 'NDS currency rate',COUNT(*)
FROM NDS.dbo.currency_rate 
ORDER BY rows DESC

SELECT COUNT(DISTINCT CONCAT(order_id,'-',line_no) ) AS unique_combinations
FROM Stage.dbo.order_detail
SELECT COUNT(*)
FROM Stage.dbo.order_detail

SELECT soh.order_id, soh.currency, soh.store_number
FROM Stage.dbo.order_header soh
EXCEPT
SELECT NOH.order_id, nc.currency_code,ns.store_number
FROM NDS.dbo.order_header noh
INNER JOIN NDS.dbo.currency nc ON noh.currency_key = nc.currency_key
INNER JOIN NDS.dbo.store ns ON noh.store_key = ns.store_key

SEL
FROM NDS.dbo.currency_rate 

SELECT 63778.0* 2426 * 13202 * 121 * 44425 * 175 -- 1,921,552,597,320,771,415,000.0

SELECT  convert(datetime,
 convert(varchar, year(getdate())) 
 + '-' 
 + right('0'+convert(varchar, month(getdate())),2) 
 +  '-01')

SELECT convert(varchar, year(getdate())) +'-'
 + right('0'+convert(varchar,month(getdate())),2) + '-01'


--FROM Stage.dbo.order_detail sod 63778
--	INNER JOIN NDS.dbo.order_header oh ON sod.order_id = oh.order_id 13202
--	INNER JOIN NDS.dbo.product p ON sod.product_code = p.product_code 2426
--	INNER JOIN Stage.dbo.order_header soh ON sod.order_id = oh.order_id 44425
--	INNER JOIN NDS.dbo.currency c ON soh.currency = c.currency_code 175
--	INNER JOIN NDS.dbo.currency_rate cr ON c.currency_key = cr.currency_key 121

SELECT TOP(100) *
FROM Stage.dbo.order_header
ORDER By order_id DESC

Select *
FROM NDS.dbo.currency_rate
WHERE currency_key =
 convert(datetime,
 convert(varchar, year(getdate())) 
 + '-' 
 + right('0'+convert(varchar, month(getdate())),2) 
 +  '-01') 