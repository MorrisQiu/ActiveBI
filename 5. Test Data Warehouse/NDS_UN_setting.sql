/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [NDS].[dbo].[state]

set identity_insert country on
insert into country
( country_key, country_code, country_name, source_system_code,
create_timestamp, update_timestamp )
values
( 0, 'UN', 'Unknown', 0,
'1900-01-01', '1900-01-01' )
set identity_insert country off

set identity_insert state on
insert into state
( state_key, state_code, state_name, formal_name,
admission_to_statehood, population,
capital, largest_city, source_system_code,
create_timestamp, update_timestamp )
values
( 0, 'UN', 'Unknown', 'Unknown',
'1900-01-01', 0,
'Unknown', 'Unknown', 0,
'1900-01-01', '1900-01-01' )
set identity_insert state off

-- checking stage and NDS
SELECT * FROM Stage.dbo.state s
WHERE not exists
(select * from NDS.dbo.state n
	WHERE s.state_code = n.state_code)

--check population of AZ 
use Stage
select population from state where state_code='AZ' --6166318

update state set population = 6167318 where state_code ='AZ'
-- run SSIS and check NDS
select population from NDS.dbo.state where state_code ='AZ'

--set back to original number
use Stage
update state set population = 6166318 where state_code ='AZ'