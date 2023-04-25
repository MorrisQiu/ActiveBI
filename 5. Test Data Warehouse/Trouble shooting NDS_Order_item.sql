
SELECT *
FROM NDS.dbo.currency_rate cr
INNER JOIN 
(SELECT MAX(effective_date) AS latest_date,currency_key
FROM NDS.dbo.currency_rate
GROUP BY currency_key) latest 
	ON cr.effective_date = latest.latest_date 
		AND cr.currency_key = latest.currency_key

WITH missing AS
(
SELECT sod.order_id,sod.line_no
FROM Stage.dbo.order_detail sod
EXCEPT
(SELECT noh.order_id, noi.line_number
FROM NDS.dbo.order_item noi
INNER JOIN NDS.dbo.order_header noh ON noi.order_key = noh.order_key)
)
--ORDER BY sod.order_id,sod.line_no)

SELECT *
FROM Stage.dbo.order_detail sod
JOIN missing m ON sod.order_id = m.order_id;


SELECT soh.order_id, m.line_no,soh.customer_number,soh.store_number,soh.currency
FROM Stage.dbo.order_header soh
JOIN missing m ON soh.order_id = m.order_id;

--result of sod
order_id	line_no	product_code	qty	price	unit_cost	order_id	line_no
26521	1	NULL	1.00	1.09	0.87	26521	1
42306	1	NULL	1.00	4.99	3.93	42306	1
42306	2	540401	1.00	0.89	0.62	42306	1
49526	1	NULL	2.00	2.59	1.52	49526	1
63315	1	618038	1.00	17.99	12.97	63315	2
63315	2	NULL	1.00	4.99	3.57	63315	2
67395	1	576936	1.00	1.09	0.55	67395	2
67395	2	NULL	1.00	1.09	0.65	67395	2
67395	3	482739	1.00	1.09	0.69	67395	2
67395	4	908432	1.00	1.09	0.84	67395	2
83434	1	NULL	1.00	2.59	1.71	83434	1
83434	2	727856	1.00	1.99	1.19	83434	1
83919	1	NULL	1.00	1.99	1.48	83919	1
95054	1	NULL	2.00	2.59	1.34	95054	1

-- Result of soh
order_id	line_no	customer_number	store_number	currency
26521	1	84478	2023	USD
42306	1	47769	2003	USD
49526	1	76025	1806	AUD
63315	2	21621	2230	GBP
67395	2	24593	1701	GBP
83434	1	11091	2239	GBP
83919	1	90765	2020	USD
95054	1	23723	2026	USD

---
-- Checking stage.dbo.order_detail with no product_code
SELECT *
FROM Stage.dbo.order_detail
WHERE COALESCE(product_code,'') =''

order_id	line_no	product_code	qty	price	unit_cost
26521	1	NULL	1.00	1.09	0.87
42306	1	NULL	1.00	4.99	3.93
49526	1	NULL	2.00	2.59	1.52
63315	2	NULL	1.00	4.99	3.57
67395	2	NULL	1.00	1.09	0.65
83434	1	NULL	1.00	2.59	1.71
83919	1	NULL	1.00	1.99	1.48
95054	1	NULL	2.00	2.59	1.34

-- 8 lines of order details from jade with product_code missing
SELECT *
FROM jade.dbo.order_detail
WHERE COALESCE(product_code,'') =''
order_id	line_no	product_code	qty	price	unit_cost
26521	1	NULL	1.00	1.09	0.87
42306	1	NULL	1.00	4.99	3.93
49526	1	NULL	2.00	2.59	1.52
63315	2	NULL	1.00	4.99	3.57
67395	2	NULL	1.00	1.09	0.65
83434	1	NULL	1.00	2.59	1.71
83919	1	NULL	1.00	1.99	1.48
95054	1	NULL	2.00	2.59	1.34


SELECT *
FROM NDS.dbo.order_header
WHERE order_id = 26521

SELECT *
FROM Stage.dbo.order_detail
WHERE order_id = 26521 --AND line_no = 1

SELECT *
FROM NDS.dbo.order_item noi
JOIN NDS.dbo.order_header noh ON noi.order_key = noh.order_key
WHERE  noh.order_id = 26521

SELECT *
FROM NDS.dbo.order_item noi
JOIN NDS.dbo.order_header noh ON noi.order_key = noh.order_key
WHERE noh.order_id = 513 AND noi.line_number = 1

SELECT *
FROM Stage.dbo.order_detail sod
	INNER JOIN NDS.dbo.order_header oh ON sod.order_id = oh.order_id
	--INNER JOIN NDS.dbo.product p ON sod.product_code = p.product_code
	--LEFT JOIN NDS.dbo.currency c ON oh.currency_key = c.currency_key
	--INNER JOIN 
	--	(SELECT cr.currency_key,latest.latest_date,cr.currency_rate 
	--	 FROM NDS.dbo.currency_rate cr
	--		INNER JOIN 
	--		(SELECT MAX(effective_date) AS latest_date,currency_key
	--		FROM NDS.dbo.currency_rate GROUP BY currency_key) latest 	
	--		ON cr.effective_date = latest.latest_date 
	--			AND cr.currency_key = latest.currency_key) lcr
	--	ON oh.currency_key = lcr.currency_key
WHERE sod.order_id = 513 AND sod.line_no = 1

SELECT *
FROM NDS.dbo.product
WHERE product_code = '540401' --missing

SELECT *
FROM Stage.dbo.product sp
WHERE product_code = '162043'

SELECT *
FROM NDS.dbo.artist WHERE artist_code = 'NIC001'

SELECT *
FROM Stage.dbo.artist WHERE artist_code = 'NIC001'

SELECT *
FROM NDS.dbo.address_type

SELECT sp.product_code,sp.name,sp.artist_code,sp.format
FROM Stage.dbo.product sp
JOIN NDS.dbo.artist a ON a.artist_code = sp.artist_code
WHERE product_code = '162043'

-- checking no of lines in stage and NDS
SELECT *
FROM (
select 'stage' AS 'db', 'Order_detail' AS 'table',count(*) as num_lines
from stage.dbo.order_detail
UNION
select 'NDS','Order_detail',count(*)
from nds.dbo.order_item
) AS src
PIVOT(
	SUM(num_lines)
	FOR db IN (stage, NDS)
) AS piv