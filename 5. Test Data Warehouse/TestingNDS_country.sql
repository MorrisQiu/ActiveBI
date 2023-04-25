/****** Script for SelectTopNRows command from SSMS  ******/
USE NDS

SELECT * from country where country_code in ('ad','tc')

update nds.dbo.country set country_name = 'Andorra1'
where country_code = 'ad'
delete from nds.dbo.country where country_code = 'tc'

insert into nds.dbo.country
( country_code, 
country_name, 
source_system_code,
create_timestamp, update_timestamp )
select s.country_code, s.country_name,
2 as source_system_code,
getdate() as create_timestamp,
getdate() as update_timestamp
from stage.dbo.country s
left join nds.dbo.country n
on s.country_code = n.country_code
where n.country_key is null
