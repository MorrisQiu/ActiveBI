
-- Insert all comlumns except related interest
INSERT INTO NDS.dbo.interest (interest, description, interest_group, associated_product_type,
	   source_system_code,create_timestamp,update_timestamp)
SELECT si.interest, si.description, si.interest_group, si.associated_product_type,
	   2 AS source_system_code,GETDATE() AS create_timestamp, GETDATE() AS update_timestamp
FROM Stage.dbo.interest si
WHERE NOT EXISTS
 (SELECT *
  FROM Stage.dbo.interest si
  INNER JOIN NDS.dbo.interest ni ON si.interest = ni.interest);

--- update the remaining columns related interest
UPDATE NDS.dbo.interest
SET related_interest_key = ni1.interest_key
FROM Stage.dbo.interest si
INNER JOIN NDS.dbo.interest ni1 ON si.related_interest = ni1.interest
INNER JOIN NDS.dbo.interest ni2 ON si.interest = ni2.interest
WHERE ;


SELECT *
FROM Stage.dbo.interest

INNER JOIN NDS.dbo.interest ni ON si.related_interest = ni.interest

SELECT *
FROM nds.dbo.interest
