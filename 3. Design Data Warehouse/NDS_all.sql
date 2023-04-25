
-- create database
use master
go

if db_id ('NDS') is not null
drop database NDS;
go

create database NDS 
on primary (name = 'nds_fg1'
, filename = 'c:\disk\data1\nds_fg1.mdf'
, size = 10 MB, filegrowth = 2 MB)
, filegroup nds_fg2 (name = 'nds_fg2'
, filename = 'c:\disk\data2\nds_fg2.ndf'
, size = 10 MB, filegrowth = 2 MB)
, filegroup nds_fg3 (name = 'nds_fg3'
, filename = 'c:\disk\data3\nds_fg3.ndf'
, size = 10 MB, filegrowth = 2 MB)
, filegroup nds_fg4 (name = 'nds_fg4'
, filename = 'c:\disk\data4\nds_fg4.ndf'
, size = 10 MB, filegrowth = 2 MB)
, filegroup nds_fg5 (name = 'nds_fg5'
, filename = 'c:\disk\data5\nds_fg5.ndf'
, size = 10 MB, filegrowth = 2 MB)
, filegroup nds_fg6 (name = 'nds_fg6'
, filename = 'c:\disk\data6\nds_fg6.ndf'
, size = 10 MB, filegrowth = 2 MB)
log on (name = 'nds_log'
, filename = 'c:\disk\log2\nds_log.ldf'
, size = 1 MB, filegrowth = 512 KB)
collate SQL_Latin1_General_CP1_CI_AS
go

alter database NDS set recovery simple 
go
alter database NDS set auto_shrink off
go
alter database NDS set auto_create_statistics on
go
alter database NDS set auto_update_statistics on
go

-- create table contact 

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_supplier_contact'
   and parent_object_id = object_id('supplier'))
alter table supplier
  drop constraint fk_supplier_contact
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'contact')
drop table contact
go

-- Create the table:

create table contact
( contact_key              int not null identity(1,1)
, contact_code             char(10) not null
, contact_name             varchar(100) not null
, title                    varchar(35)
, source_system_code       tinyint not null
, create_timestamp         datetime not null
, update_timestamp         datetime not null
, constraint pk_contact
  primary key clustered (contact_key)
  on nds_fg6
) on nds_fg5
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'supplier')
alter table supplier
  add constraint pk_supplier_contact
  foreign key (contact_key)
  references contact(contact_key)
go

-- Build indexes:

if exists
  (select * from sys.indexes
   where name = 'contact_code'
   and object_id = object_id('contact'))
drop index contact.contact_code
go

create unique index contact_code
  on contact(contact_code)
  on nds_fg6
go

if exists
  (select * from sys.indexes
   where name = 'contact_name'
   and object_id = object_id('contact'))
drop index contact.contact_name
go

create unique index contact_name
  on contact(contact_name)
  on nds_fg6
go

-- supplier_status 

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_supplier_supplier_status'
   and parent_object_id = object_id('supplier'))
alter table supplier
  drop constraint fk_supplier_supplier_status
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'supplier_status')
drop table supplier_status
go

-- Create the table:

create table supplier_status
( supplier_status_key      int not null identity(1,1)
, supplier_status_code     char(2) not null
, supplier_status          varchar(15) not null
, source_system_code       tinyint not null
, create_timestamp         datetime not null
, update_timestamp         datetime not null
, constraint pk_supplier_status
  primary key clustered (supplier_status_key)
  on nds_fg6
) on nds_fg5
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'supplier')
alter table supplier
  add constraint pk_supplier_supplier_status
  foreign key (supplier_status_key)
  references supplier_status(supplier_status_key)
go

-- There is no point creating index as this is a tiny table

-- artist 

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_product_artist'
   and parent_object_id = object_id('product'))
alter table product
  drop constraint fk_product_artist
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'artist')
drop table artist
go

-- Create the table:

create table artist
( artist_key           int not null identity(1,1)
, artist_code          char(10) not null
, artist_name          varchar(100) not null
, genre                varchar(30)
, country_key          int
, city_key             int
, source_system_code   tinyint not null
, create_timestamp     datetime not null
, update_timestamp     datetime not null
, constraint pk_artist
  primary key clustered (artist_key)
  on nds_fg6
) on nds_fg5
go

-- Insert Unknown Record:
set identity_insert artist on

insert into artist
( artist_key, artist_code, artist_name
, genre, country_key, city_key
, source_system_code
, create_timestamp, update_timestamp )
values
( 0, 'Unknown', 'Unknown'
, 'Unknown', 0, 0
, 0
, '1900-01-01', '1900-01-01' )

set identity_insert artist off
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'product')
alter table product
  add constraint pk_product_artist
  foreign key (artist_key)
  references artist(artist_key)
go

-- product_status

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_product_product_status'
   and parent_object_id = object_id('product'))
alter table product
  drop constraint fk_product_product_status
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'product_status')
drop table product_status
go

-- Create the table:

create table product_status
( product_status_key      int not null identity(1,1)
, product_status_code     char(2) not null
, product_status          varchar(15) not null
, source_system_code      tinyint not null
, create_timestamp        datetime not null
, update_timestamp        datetime not null
, constraint pk_product_status
  primary key clustered (product_status_key)
  on nds_fg6
) on nds_fg5
go

-- Populate data:

insert into product_status
( product_status_code, product_status
, source_system_code, create_timestamp, update_timestamp )
values ( 'AC', 'Active', 3, getdate(), getdate())
insert into product_status
( product_status_code, product_status
, source_system_code, create_timestamp, update_timestamp )
values ( 'IN', 'Inactive', 3, getdate(), getdate())
insert into product_status
( product_status_code, product_status
, source_system_code, create_timestamp, update_timestamp )
values ( 'QC', 'Quality Control', 3, getdate(), getdate())
insert into product_status
( product_status_code, product_status
, source_system_code, create_timestamp, update_timestamp )
values ( 'WD', 'Withdrawn', 3, getdate(), getdate())
go

-- Insert unknown record:

set identity_insert product_status on
insert into product_status
( product_status_key, product_status_code, product_status
, source_system_code, create_timestamp, update_timestamp )
values ( 0, 'UN', 'Unknown', 0, getdate(), getdate())
set identity_insert product_status off
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'product')
alter table product
  add constraint fk_product_product_status
  foreign key (product_status_key)
  references product_status(product_status_key)
go

-- There is no point creating index as this is a tiny table

-- product_category 

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_product_type_product_category'
   and parent_object_id = object_id('product_type'))
alter table product_type
  drop constraint fk_product_type_product_category
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'product_category')
drop table product_category
go

-- Create the table:

create table product_category
( product_category_key  int not null identity(1,1)
, product_category      varchar(20) 
, description           varchar(50)
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_product_category
  primary key clustered (product_category_key)
  on nds_fg6
) on nds_fg5
go

-- Insert Unknown Record

set identity_insert product_category on

insert into product_category
( product_category_key, product_category
, description, source_system_code
, create_timestamp, update_timestamp )
values 
( 0, 'Unknown'
, 'Unknown', 0
, '1900-01-01', '1900-01-01' )

set identity_insert product_category off

go

-- Create FK:
if exists
  (select * from sys.tables
   where name = 'product_type')
alter table product_type
add constraint fk_product_type_product_category
  foreign key (product_category_key)
  references product_category(product_category_key)
go

-- product_type

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_product_product_type'
   and parent_object_id = object_id('product'))
alter table product
  drop constraint fk_product_product_type
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'product_type')
drop table product_type
go

-- Create the table:

create table product_type
( product_type_key      int not null identity(1,1)
, product_type_code     char(2) not null
, product_type          varchar(15) not null
, product_category_key  int
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_product_type
  primary key clustered (product_type_key)
  on nds_fg6
, constraint fk_product_type_product_category
  foreign key (product_category_key)
  references product_category(product_category_key)
) on nds_fg5
go

-- Insert Unknown Record:

set identity_insert product_type on

insert into product_type
( product_type_key, product_type_code, product_type
, product_category_key, source_system_code
, create_timestamp, update_timestamp )
values
( 0, '', 'Unknown'
, 0, 0
, '1900-01-01', '1900-01-01' )

set identity_insert product_type off

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'product')
alter table product
  add constraint fk_product_product_type
  foreign key (product_type_key)
  references product_type(product_type_key)
go

-- Create indexes:

if exists
  (select * from sys.indexes
   where name = 'product_type_code'
   and object_id = object_id('product_type'))
drop index product_type.product_type_code
go

create unique index product_type_code
  on product_type(product_type_code)
  on nds_fg6
go

if exists
  (select * from sys.indexes
   where name = 'product_type'
   and object_id = object_id('product_type'))
drop index product_type.product_type
go

create unique index product_type
  on product_type(product_type)
  on nds_fg6
go

-- country

use NDS
go

-- Remove FK if exists:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_address_country'
   and parent_object_id = object_id('address'))
alter table address
  drop constraint fk_address_country
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'country')
drop table country
go

-- Create the table:

create table country
( country_key         int not null identity(1,1)
, country_code        char(2)
, country_name        varchar(50)
, source_system_code  tinyint not null
, create_timestamp    datetime not null
, update_timestamp    datetime not null
, constraint pk_country 
  primary key clustered (country_key)
  on nds_fg6
) on nds_fg3
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'address')
alter table address
  add constraint fk_address_country
  foreign key (country_key)
  references country(country_key)
go

-- Build indexes:

if exists
  (select * from sys.indexes
   where name = 'country_name'
   and object_id = object_id('country_name'))
drop index country.country_name
go

create unique index country_name
  on country(country_name)
  on nds_fg6
go

-- state 

use NDS
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_address_state'
   and parent_object_id = object_id('address'))
alter table address
  drop constraint fk_address_state
go

if exists 
  (select * from sys.tables 
   where name = 'state')
drop table state
go

create table state
( state_key                int not null identity(1,1)
, state_code               varchar(2)
, state_name               varchar(50)
, formal_name              varchar(100)
, admission_to_statehood   datetime
, population               int
, capital                  varchar(50)
, largest_city             varchar(50)
, source_system_code       tinyint not null
, create_timestamp         datetime not null
, update_timestamp         datetime not null
, constraint pk_state 
  primary key clustered (state_key)
  on nds_fg6
) on nds_fg3
go

if exists
  (select * from sys.tables
   where name = 'address')
alter table address
  add constraint fk_address_state
  foreign key (state_key)
  references state(state_key)
go

if exists
  (select * from sys.indexes
   where name = 'state_name'
   and object_id = object_id('state'))
drop index state.state_name
go

create unique index state_name
  on state(state_name)
  on nds_fg6
go

-- city

use NDS
go

-- Remove FK if exists:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_address_city'
   and parent_object_id = object_id('address'))
alter table address
  drop constraint fk_address_city
go

-- Drop and create table:

if exists 
  (select * from sys.tables 
   where name = 'city')
drop table city
go

create table city
( city_key            int not null identity(1,1)
, city_name           varchar(50)
, source_system_code  tinyint not null
, create_timestamp    datetime not null
, update_timestamp    datetime not null
, constraint pk_city 
  primary key clustered (city_key)
  on nds_fg6
) on nds_fg3
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'address')
alter table address
  add constraint fk_address_city
  foreign key (city_key)
  references city(city_key)
go

-- Build indexes:

if exists
  (select * from sys.indexes
   where name = 'city_name'
   and object_id = object_id('city_name'))
drop index city.city_name
go

create unique index city_name
  on city(city_name)
  on nds_fg6
go

-- address

use NDS
go

-- Drop FK if exists:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_store_address'
   and parent_object_id = object_id('store'))
alter table store
  drop constraint fk_store_address
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_address_junction_address'
   and parent_object_id = object_id('address_junction'))
alter table address_junction
  drop constraint fk_address_junction_address
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_supplier_address'
   and parent_object_id = object_id('supplier'))
alter table supplier
  drop constraint fk_supplier_address
go

-- Drop and create table:

if exists 
  (select * from sys.tables 
   where name = 'address')
drop table address
go

create table address
( address_key         int not null identity(1,1)
, address1            varchar(50)
, address2            varchar(50)
, address3            varchar(50)
, address4            varchar(50)
, city_key            int
, post_code           varchar(10)
, state_key           int
, country_key         int
, source_system_code  tinyint not null
, create_timestamp    datetime not null
, update_timestamp    datetime not null
, constraint pk_address 
  primary key clustered (address_key)
  on nds_fg6
, constraint fk_address_city
  foreign key (city_key)
  references city(city_key)
, constraint fk_address_state
  foreign key (state_key)
  references state(state_key)
, constraint fk_address_country
  foreign key (country_key)
  references country(country_key)
) on nds_fg3
go

-- Create FKs:

if exists
  (select * from sys.tables
   where name = 'store')
alter table store
  add constraint fk_store_address
  foreign key (address_key)
  references address(address_key)
go

if exists
  (select * from sys.tables
   where name = 'address_junction')
alter table address_junction
  add constraint fk_address_junction_address
  foreign key (address_key)
  references address(address_key)
go

if exists
  (select * from sys.tables
   where name = 'supplier')
alter table supplier
  add constraint fk_supplier_address
  foreign key (address_key)
  references address(address_key)
go

-- there is no point creating a cover index as it would contain almost every column

-- address_type

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_address_junction_address_type'
   and parent_object_id = object_id('address_junction'))
alter table address_junction
  drop constraint fk_address_junction_address_type
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'address_type')
drop table address_type
go

-- Create the table:

create table address_type
( address_type_key    int not null identity(1,1)
, address_type_code   char(2)
, address_type        varchar(10)
, description         varchar(30)
, source_system_code  tinyint not null
, create_timestamp    datetime not null
, update_timestamp    datetime not null
, constraint pk_address_type
  primary key clustered (address_type_key)
  on nds_fg6
) on nds_fg3
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'address_junction')
alter table address_junction
  add constraint fk_address_junction_address_type
  foreign key (address_type_key)
  references address_type(address_type_key)
go

-- There is no point creating index as this is a tiny table

-- phone_number

use NDS
go

-- Remove FK if exists:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_store_phone_number'
   and parent_object_id = object_id('store'))
alter table store
  drop constraint fk_store_phone_number
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_phone_number_junction_phone_number'
   and parent_object_id = object_id('phone_number_junction'))
alter table phone_number_junction
  drop constraint fk_phone_number_junction_phone_number
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_supplier_phone_number'
   and parent_object_id = object_id('supplier'))
alter table supplier
  drop constraint fk_supplier_phone_number
go

-- Drop the table if exists:

if exists 
  (select * from sys.tables 
   where name = 'phone_number')
drop table phone_number
go

-- Create the table:

create table phone_number
( phone_number_key        int not null identity(1,1)
, phone_number            varchar(20)
, source_system_code      tinyint not null
, create_timestamp        datetime not null
, update_timestamp        datetime not null
, constraint pk_phone_number
  primary key clustered (phone_number_key)
  on nds_fg6
) on nds_fg2
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'store')
alter table store
  add constraint fk_store_phone_number
  foreign key (phone_number_key)
  references phone_number(phone_number_key)
go

if exists
  (select * from sys.tables
   where name = 'phone_number_junction')
alter table phone_number_junction
  add constraint fk_phone_number_junction_phone_number
  foreign key (phone_number_key)
  references phone_number(phone_number_key)
go

if exists
  (select * from sys.tables
   where name = 'supplier')
alter table supplier
  add constraint fk_supplier_phone_number
  foreign key (phone_number_key)
  references phone_number(phone_number_key)
go

-- Build indexes:

if exists
  (select * from sys.indexes
   where name = 'phone_number'
   and object_id = object_id('phone_number'))
drop index phone_number.phone_number
go

create unique index phone_number
  on phone_number(phone_number)
  on nds_fg6
go

-- phone_number_type

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_phone_number_junction_phone_number_type'
   and parent_object_id = object_id('phone_number_junction'))
alter table phone_number_junction
  drop constraint fk_phone_number_junction_phone_number_type
go

-- Drop the table if exists:

if exists 
  (select * from sys.tables 
   where name = 'phone_number_type')
drop table phone_number_type
go

-- Create the table:

create table phone_number_type
( phone_number_type_key    int not null identity(1,1)
, phone_number_type_code   char(2)
, phone_number_type        varchar(10)
, description               varchar(30)
, source_system_code        tinyint not null
, create_timestamp          datetime not null
, update_timestamp          datetime not null
, constraint pk_phone_number_type
  primary key clustered (phone_number_type_key)
  on nds_fg6
) on nds_fg2
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'phone_number_junction')
alter table phone_number_junction
  add constraint fk_phone_number_junction_phone_number_type
  foreign key (phone_number_type_key)
  references phone_number_type(phone_number_type_key)
go

-- There is no point creating index as this is a tiny table

-- email_address

use NDS
go

-- Remove FK if exists:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_email_address_junction_email_address'
   and parent_object_id = object_id('email_address_junction'))
alter table email_address_junction
  drop constraint fk_email_address_junction_email_address
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_supplier_email_address'
   and parent_object_id = object_id('supplier'))
alter table supplier
  drop constraint fk_supplier_email_address
go

-- Drop and create table:

if exists 
  (select * from sys.tables 
   where name = 'email_address')
drop table email_address
go

create table email_address
( email_address_key   int not null identity(1,1)
, email_address       varchar(200)
, source_system_code  tinyint not null
, create_timestamp    datetime not null
, update_timestamp    datetime not null
, constraint pk_email_address 
  primary key clustered (email_address_key)
  on nds_fg6
) on nds_fg2
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'email_address_junction')
alter table email_address_junction
  add constraint fk_email_address_junction_email_address
  foreign key (email_address_key)
  references email_address(email_address_key)
go

if exists
  (select * from sys.tables
   where name = 'supplier')
alter table supplier
  add constraint fk_supplier_email_address
  foreign key (email_address_key)
  references email_address(email_address_key)
go

-- Insert Unknown Record:
set identity_insert email_address on

insert into email_address
( email_address_key, email_address, source_system_code
, create_timestamp, update_timestamp )
values
( 0, 'Unknown', 0
, '1900-01-01', '1900-01-01' )

set identity_insert email_address off
go

-- Build indexes:

if exists
  (select * from sys.indexes
   where name = 'email_address_email_address'
   and object_id = object_id('email_address'))
drop index email_address.email_address_email_address
go

create unique index email_address_email_address
  on email_address(email_address)
  on nds_fg6
go

-- email_address_type

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_email_address_junction_email_address_type'
   and parent_object_id = object_id('email_address_junction'))
alter table email_address_junction
  drop constraint fk_email_address_junction_email_address_type
go

-- Drop the table if exists:

if exists 
  (select * from sys.tables 
   where name = 'email_address_type')
drop table email_address_type
go

-- Create the table:

create table email_address_type
( email_address_type_key    int not null identity(1,1)
, email_address_type_code   char(2)
, email_address_type        varchar(10)
, description               varchar(30)
, source_system_code        tinyint not null
, create_timestamp          datetime not null
, update_timestamp          datetime not null
, constraint pk_email_address_type
  primary key clustered (email_address_type_key)
  on nds_fg6
) on nds_fg2
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'email_address_junction')
alter table email_address_junction
  add constraint fk_email_address_junction_email_address_type
  foreign key (email_address_type_key)
  references email_address_type(email_address_type_key)
go

-- There is no point creating index as this is a tiny table

-- currency

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_currency_rate_currency'
   and parent_object_id = object_id('currency_rate'))
alter table currency_rate
  drop constraint fk_currency_rate_currency
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'currency')
drop table currency
go

-- Create the table:

create table currency
( currency_key        int not null identity(1,1)
, currency_code       char(3)
, currency_name       varchar(30)
, source_system_code  tinyint not null
, create_timestamp    datetime not null
, update_timestamp    datetime not null
, constraint pk_currency
  primary key clustered (currency_key)
  on nds_fg6
) on [primary]
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'currency_rate')
alter table currency_rate
  add constraint fk_currency_rate_currency
  foreign key (currency_key)
  references currency(currency_key)
go

-- There is no point creating index as this is a small table

-- currency rate 

use NDS
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'currency_rate')
drop table currency_rate
go

-- Create the table:

create table currency_rate
( currency_rate_key   int not null identity(1,1)
, effective_date      datetime
, currency_key        int
, currency_rate       money
, source_system_code  tinyint not null
, create_timestamp    datetime not null
, update_timestamp    datetime not null
, constraint pk_currency_rate
  primary key clustered (currency_rate_key)
  on nds_fg6
, constraint fk_currency_rate_currency
  foreign key (currency_key)
  references currency(currency_key)
) on [primary]
go

-- There is no point creating index as this is a small table

-- media

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_format_media'
   and parent_object_id = object_id('format'))
alter table format
  drop constraint fk_format_media
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'media')
drop table media
go

-- Create the table:

create table media
( media_key               int not null identity(1,1)
, media_code              char(10) not null
, media                   varchar(15) not null
, source_system_code      tinyint not null
, create_timestamp        datetime not null
, update_timestamp        datetime not null
, constraint pk_media
  primary key clustered (media_key)
  on nds_fg6
) on nds_fg5
go

-- Insert Unknown Record

set identity_insert media on
insert into media
( media_key, media_code, media
, source_system_code
, create_timestamp, update_timestamp )
values ( 0, 'Unknown', 'Unknown'
, 0, getdate(), getdate())
set identity_insert media off
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'format')
alter table format
  add constraint pk_format_media
  foreign key (media_key)
  references media(media_key)
go

-- There is no point creating index as this is a tiny table

-- format

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_product_format'
   and parent_object_id = object_id('product'))
alter table product
  drop constraint fk_product_format
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_subscription_sales_format'
   and parent_object_id = object_id('subscription_sales'))
alter table subscription_sales
  drop constraint fk_subscription_sales_format
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'format')
drop table format
go

-- Create the table:

create table format
( format_key              int not null identity(1,1)
, format_name             varchar(30) not null
, description             varchar(50)
, media_key               int
, source_system_code      tinyint not null
, create_timestamp        datetime not null
, update_timestamp        datetime not null
, constraint pk_format
  primary key clustered (format_key)
  on nds_fg6
, constraint fk_format_media
  foreign key (media_key)
  references media(media_key)
) on nds_fg5
go

-- Insert Unknown Record

set identity_insert format on

insert into format
( format_key, format_name
, description, media_key, source_system_code
, create_timestamp, update_timestamp )
values
( 0, 'Unknown'
, 'Unknown', 0, 0
, '1900-01-01', '1900-01-01' )

set identity_insert format off
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'product')
alter table product
  add constraint fk_product_format
  foreign key (format_key)
  references format(format_key)
go

if exists
  (select * from sys.tables
   where name = 'subscription_sales')
alter table subscription_sales
  add constraint fk_subscription_sales_format
  foreign key (format_key)
  references format(format_key)
go
-- There is no point creating index as this is a tiny table

-- package_type

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_package_package_type'
   and parent_object_id = object_id('package'))
alter table package
  drop constraint fk_package_package_type
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'package_type')
drop table package_type
go

-- Create the table:

create table package_type
( package_type_key      int not null identity(1,1)
, package_type_code     char(5) not null
, package_type          varchar(15) not null
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_package_type
  primary key clustered (package_type_key)
  on nds_fg6
) on [primary]
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'package')
alter table package
  add constraint fk_package_package_type
  foreign key (package_type_key)
  references package_type(package_type_key)
go

-- There is no point creating indexes as this is a small table

-- package

use NDS
go

-- Remove FK if exists:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_subscription_sales_package'
   and parent_object_id = object_id('subscription_sales'))
alter table subscription_sales
  drop constraint fk_subscription_sales_package
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'package')
drop table package
go

-- Create the table:

create table package
( package_key           int not null identity(1,1)
, name                  varchar(30) 
, description           varchar(100)
, package_type_key      int
, package_price         money
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_package
  primary key clustered (package_key)
  on nds_fg6
, constraint fk_package_package_type
  foreign key (package_type_key)
  references package_type(package_type_key)
) on [primary]
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'subscription_sales')
alter table subscription_sales
  add constraint fk_subscription_sales_package
  foreign key (package_key)
  references package(package_key)
go

-- There is no point creating indexes as this is a small table

-- lead

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_subscription_sales_lead'
   and parent_object_id = object_id('subscription_sales'))
alter table subscription_sales
  drop constraint fk_subscription_sales_lead
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'lead')
drop table lead
go

-- Create the table:

create table lead
( lead_key              int not null identity(1,1)
, lead_name             varchar(30) not null
, source_site           varchar(50) not null
, lead_url              varchar(100)
, lead_timestamp        datetime
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_lead
  primary key clustered (lead_key)
  on nds_fg6
) on [primary]
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'subscription_sales')
alter table subscription_sales
  add constraint pk_subscription_sales_lead
  foreign key (lead_key)
  references lead(lead_key)
go

-- Build indexes:

if exists
  (select * from sys.indexes
   where name = 'lead_name'
   and object_id = object_id('lead'))
drop index lead.lead_name
go

create unique index lead_name
  on lead(lead_name)
  on nds_fg6
go

if exists
  (select * from sys.indexes
   where name = 'source_site'
   and object_id = object_id('lead'))
drop index lead.source_site
go

create unique index source_site
  on lead(source_site)
  on nds_fg6
go

-- store_type

use NDS
go

-- Remove FK before dropping table:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_store_store_type'
   and parent_object_id = object_id('store'))
alter table store
  drop constraint fk_store_store_type
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'store_type')
drop table store_type
go

-- Create the table:

create table store_type
( store_type_key      int not null identity(1,1)
, store_type_code     char(2)
, store_type          varchar(10)
, description         varchar(30)
, source_system_code  tinyint not null
, create_timestamp    datetime not null
, update_timestamp    datetime not null
, constraint pk_store_type
  primary key clustered (store_type_key)
  on nds_fg6
) on nds_fg3
go

-- Create the FK:

if exists
  (select * from sys.tables
   where name = 'store')
alter table store
  add constraint fk_store_store_type
  foreign key (store_type_key)
  references store_type(store_type_key)
go

-- There is no point creating index as this is a tiny table

-- division

use NDS
go

-- Remove FK before dropping table:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_region_division'
   and parent_object_id = object_id('region'))
alter table region
  drop constraint fk_region_division

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'division')
drop table division
go

create table division
( division_key        int not null identity(1,1)
, division_code       varchar(5)
, division_name       varchar(50)
, source_system_code  tinyint not null
, create_timestamp    datetime not null
, update_timestamp    datetime not null
, constraint pk_division
  primary key clustered (division_key)
  on nds_fg6
) on nds_fg3
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'region')
alter table region
  add constraint fk_region_division
  foreign key (division_key)
  references division(division_key)
go

-- there is no point creating index as this is a tiny table

-- region

use NDS
go

-- Remove FK before dropping table:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_store_region'
   and parent_object_id = object_id('store'))
alter table store
  drop constraint fk_store_region
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'region')
drop table region
go

-- Create the table:

create table region
( region_key          int not null identity(1,1)
, region_code         varchar(5)
, region_name         varchar(50)
, division_key        int
, source_system_code  tinyint not null
, create_timestamp    datetime not null
, update_timestamp    datetime not null
, constraint pk_region
  primary key clustered (region_key)
  on nds_fg6
, constraint fk_region_division
  foreign key (division_key)
  references division(division_key)
) on nds_fg3
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'store')
alter table store
  add constraint fk_store_region
  foreign key (region_key)
  references region(region_key)
go

-- There is no point creating index as this is a small table

-- occupation

use NDS
go

-- Remove FK if exists:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_customer_occupation'
   and parent_object_id = object_id('customer'))
alter table customer
  drop constraint fk_customer_occupation
go

-- Drop and create table:

if exists 
  (select * from sys.tables 
   where name = 'occupation')
drop table occupation
go

create table occupation
( occupation_key       int not null identity(1,1)
, occupation_code      varchar(10) not null
, occupation           varchar(30)
, description          varchar(50)
, category             varchar(30)
, source_system_code   tinyint  not null
, create_timestamp     datetime  not null
, update_timestamp     datetime  not null
, constraint pk_occupation 
  primary key clustered (occupation_key)
  on nds_fg6
) on nds_fg2
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'customer')
alter table customer 
  add constraint fk_customer_occupation
  foreign key (occupation_key)
  references occupation(occupation_key)
go

-- Build indexes:

if exists
  (select * from sys.indexes
   where name = 'occupation_code'
   and object_id = object_id('occupation'))
drop index occupation.occupation_code
go

create unique index occupation_code
  on occupation(occupation_code)
  on nds_fg6
go

-- subscriber_band --

use NDS
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_customer_subscriber_band'
   and parent_object_id = object_id('customer'))
alter table customer
  drop constraint fk_customer_subscriber_band
go

if exists 
  (select * from sys.tables 
   where name = 'subscriber_band')
drop table subscriber_band
go

create table subscriber_band
( subscriber_band_key   int not null identity(1,1)
, band_code             varchar(2) not null unique
, lower_limit           decimal(9,2)
, upper_limit           decimal(9,2)
, description           varchar(30)
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_subscriber_band 
  primary key clustered (subscriber_band_key)
  on nds_fg6
) on nds_fg2
go

if exists
  (select * from sys.tables
   where name = 'customer')
alter table customer 
  add constraint fk_customer_subscriber_band
  foreign key (subscriber_band_key)
  references subscriber_band(subscriber_band_key)
go

-- there is no point creating index as this is a tiny table

--subscriber_classs

use NDS
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_customer_subscriber_class'
   and parent_object_id = object_id('customer'))
alter table customer
  drop constraint fk_customer_subscriber_class
go

if exists 
  (select * from sys.tables 
   where name = 'subscriber_class' and type = 'U')
drop table subscriber_class
go

create table subscriber_class
( subscriber_class_key   int not null identity(1,1)
, class_code             varchar(2) not null unique
, lower_limit            money
, upper_limit            money
, description            varchar(30)
, source_system_code     tinyint not null
, create_timestamp       datetime not null
, update_timestamp       datetime not null
, constraint pk_subscriber_class 
  primary key clustered (subscriber_class_key)
  on nds_fg6
) on nds_fg2
go

if exists
  (select * from sys.tables
   where name = 'customer')
alter table customer 
  add constraint fk_customer_subscriber_class
  foreign key (subscriber_class_key)
  references subscriber_class(subscriber_class_key)
go

-- there is no point creating index as this is a tiny table

-- household_income

use NDS
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_customer_household_income'
   and parent_object_id = object_id('customer'))
alter table customer
  drop constraint fk_customer_household_income
go

if exists 
  (select * from sys.tables 
   where name = 'household_income')
drop table household_income
go

create table household_income
( household_income_key   int not null identity(1,1)
, household_income_code  int not null unique
, lower_limit            money
, upper_limit            money
, description            varchar(30)
, source_system_code     tinyint not null
, create_timestamp       datetime not null
, update_timestamp       datetime not null
, constraint pk_household_income 
  primary key clustered (household_income_key)
  on nds_fg6
) on nds_fg2
go

if exists
  (select * from sys.tables
   where name = 'customer')
alter table customer 
  add constraint fk_customer_household_income
  foreign key (household_income_key)
  references household_income(household_income_key)
go

-- There is no point creating index as this is a tiny table

-- interest

use NDS
go

-- Remove FK

if exists
  (select * from sys.foreign_keys
   where name = 'fk_interest_junction_interest'
   and parent_object_id = object_id('interest_junction'))
alter table interest_junction
  drop constraint fk_interest_junction_interest
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'interest')
drop table interest
go

-- Create the table:

create table interest
( interest_key             int not null identity(1,1)
, interest                 varchar(30)
, description              varchar(50)
, interest_group           varchar(30)
, associated_product_type  varchar(15)
, related_interest_key     int
, source_system_code       tinyint not null
, create_timestamp         datetime not null
, update_timestamp         datetime not null
, constraint pk_interest 
  primary key clustered (interest_key)
  on nds_fg6
) on nds_fg2
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'interest_junction')
alter table interest_junction
  add constraint fk_interest_junction_interest
  foreign key (interest_key)
  references interest(interest_key)
go

-- Build indexes:

if exists
  (select * from sys.indexes
   where name = 'interest_code'
   and object_id = object_id('interest'))
drop index interest.interest_code
go

create unique index interest
  on interest(interest)
  on nds_fg6
go

-- permission

use NDS
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_customer_permission'
   and parent_object_id = object_id('customer'))
alter table customer
  drop constraint fk_customer_permission
go

if exists 
  (select * from sys.tables 
   where name = 'permission')
drop table permission
go

create table permission
( permission_key        int not null identity(1,1)
, permission_code       varchar(2) not null unique
, description           varchar(30)
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_permission 
  primary key clustered (permission_key)
  on nds_fg6
) on nds_fg2
go

if exists
  (select * from sys.tables
   where name = 'customer')
alter table customer 
  add constraint fk_customer_permission
  foreign key (permission_key)
  references permission(permission_key)
go

-- There is no point creating index as this is a tiny table

-- customer_status

use NDS
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_customer_customer_status'
   and parent_object_id = object_id('customer'))
alter table customer
  drop constraint fk_customer_customer_status
go

if exists 
  (select * from sys.tables 
   where name = 'customer_status')
drop table customer_status
go

create table customer_status
( customer_status_key    int not null identity(1,1)
, customer_status_code   varchar(3) not null unique
, description            varchar(10)
, source_system_code     tinyint not null
, create_timestamp       datetime not null
, update_timestamp       datetime not null
, constraint pk_customer_status 
  primary key clustered (customer_status_key)
  on nds_fg6
) on nds_fg2
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'customer')
alter table customer 
  add constraint fk_customer_customer_status
  foreign key (customer_status_key)
  references customer_status(customer_status_key)
go

-- customer_type

use NDS
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_customer_customer_type'
   and parent_object_id = object_id('customer'))
alter table customer
  drop constraint fk_customer_customer_type
go

if exists 
  (select * from sys.tables 
   where name = 'customer_type')
drop table customer_type
go

create table customer_type
( customer_type_key      int not null identity(1,1)
, customer_type_code     char(3) not null unique
, description            varchar(30)
, source_system_code     tinyint not null
, create_timestamp       datetime not null
, update_timestamp       datetime not null
, constraint pk_customer_type 
  primary key clustered (customer_type_key)
  on nds_fg6
) on nds_fg2
go

if exists
  (select * from sys.tables
   where name = 'customer')
alter table customer 
  add constraint fk_customer_customer_type
  foreign key (customer_type_key)
  references customer_type(customer_type_key)
go

-- there is no point creating index as this is a tiny table

-- subscription_status

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_communication_subscription_subscription_status'
   and parent_object_id = object_id('communication_subscription'))
alter table communication_subscription
  drop constraint fk_communication_subscription_subscription_status
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'subscription_status')
drop table subscription_status
go

-- Create the table:

create table subscription_status
( subscription_status_key    int not null identity(1,1)
, subscription_status_code   char(3) not null
, description                varchar(50)
, source_system_code         tinyint not null
, create_timestamp           datetime not null
, update_timestamp           datetime not null
, constraint pk_subscription_status
  primary key clustered (subscription_status_key)
  on nds_fg6
) on nds_fg4
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'communication_subscription')
alter table communication_subscription
  add constraint fk_communication_subscription_subscription_status
  foreign key (subscription_status_key)
  references subscription_status(subscription_status_key)
go

-- There is no need creating indexes as this is a tiny table

-- business_unit

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_communication_business_unit'
   and parent_object_id = object_id('communication'))
alter table communication
  drop constraint fk_communication_business_unit
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'business_unit')
drop table business_unit
go

-- Create the table:

create table business_unit
( business_unit_key     int not null identity(1,1)
, business_unit_code    char(3) not null
, business_unit_name    varchar(30) not null
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_business_unit
  primary key clustered (business_unit_key)
  on nds_fg6
) on nds_fg4
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'communication')
alter table communication
  add constraint fk_communication_business_unit
  foreign key (issuing_unit_key)
  references business_unit(business_unit_key)
go

-- Build indexes:

if exists
  (select * from sys.indexes 
   where name = 'business_unit_code' 
   and object_id = object_id('business_unit'))
drop index business_unit.business_unit_code
go

create unique index business_unit_code
  on business_unit(business_unit_code)
  on nds_fg6
go

-- communication_category

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_communication_communication_category'
   and parent_object_id = object_id('communication'))
alter table communication
  drop constraint fk_communication_communication_category
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'communication_category')
drop table communication_category
go

-- Create the table:

create table communication_category
( communication_category_key       int not null identity(1,1)
, communication_category_code      char(3) not null
, communication_category_name      varchar(20) not null
, source_system_code               tinyint not null
, create_timestamp                 datetime not null
, update_timestamp                 datetime not null
, constraint pk_communication_category
  primary key clustered (communication_category_key)
  on nds_fg6
) on nds_fg4
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'communication')
alter table communication
  add constraint fk_communication_communication_category
  foreign key (category_key)
  references communication_category(communication_category_key)
go

-- Build indexes:

if exists
  (select * from sys.indexes 
   where name = 'communication_category_code' 
   and object_id = object_id('communication_category'))
drop index communication_category.communication_category_code
go

create unique index communication_category_code
  on communication_category(communication_category_code)
  on nds_fg6
go

-- language

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_communication_language'
   and parent_object_id = object_id('communication'))
alter table communication
  drop constraint fk_communication_language
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'language')
drop table language
go

-- Create the table:

create table language
( language_key          int not null identity(1,1)
, language_code         char(3) not null
, language_name         varchar(50) not null
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_language
  primary key clustered (language_key)
  on nds_fg6
) on nds_fg4
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'communication')
alter table communication
  add constraint fk_communication_language
  foreign key (language_key)
  references language(language_key)
go

-- Build indexes:

if exists
  (select * from sys.indexes 
   where name = 'language_code' 
   and object_id = object_id('language'))
drop index language.language_code
go

create unique index language_code
  on language(language_code)
  on nds_fg6
go

-- campaign

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_campaign_result_campaign'
   and parent_object_id = object_id('campaign_result'))
alter table campaign_result
  drop constraint fk_campaign_result_campaign
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'campaign')
drop table campaign
go

-- Create the table:

create table campaign
( campaign_key          int not null identity(1,1)
, campaign_code         char(5) not null
, campaign_title        varchar(50) null
, description           varchar(100)
, planned_send_date     datetime
, number_of_recipients  int
, communication_name    varchar(50)
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_campaign
  primary key clustered (campaign_key)
  on nds_fg6
) on nds_fg4
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'campaign_result')
alter table campaign_result
  add constraint fk_campaign_result_campaign
  foreign key (campaign_key)
  references campaign(campaign_key)
go

-- Build indexes:

if exists
  (select * from sys.indexes 
   where name = 'campaign_code' 
   and object_id = object_id('campaign'))
drop index campaign.campaign_code
go

create unique index campaign_code
  on campaign(campaign_code)
  on nds_fg6
go

-- delivery_status_category

use NDS
go

-- Remove FK if exists:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_delivery_status_delivery_status_category'
   and parent_object_id = object_id('delivery_status'))
alter table delivery_status
  drop constraint fk_delivery_status_delivery_status_category
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'delivery_status_category')
drop table delivery_status_category
go

-- Create the table:

create table delivery_status_category
( delivery_status_category_key   int not null identity(1,1)
, delivery_status_category_code  int
, category                       varchar(20)
, source_system_code             tinyint not null
, create_timestamp               datetime not null
, update_timestamp               datetime not null
, constraint pk_delivery_status_category
  primary key clustered (delivery_status_category_key)
  on nds_fg6
) on nds_fg4
go

-- Create FK:
if exists
  (select * from sys.tables
   where name = 'delivery_status')
alter table delivery_status
  add constraint fk_delivery_status_delivery_status_category
  foreign key (category_key)
  references delivery_status_category(delivery_status_category_key)
go

-- There is no point creating indexes as this is a small table

-- delivery_status

use NDS
go

-- Remove FK if exist:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_campaign_result_delivery_status'
   and parent_object_id = object_id('campaign_result'))
alter table campaign_result
  drop constraint fk_campaign_result_delivery_status
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'delivery_status')
drop table delivery_status
go

-- Create the table:

create table delivery_status
( delivery_status_key   int not null identity(1,1)
, delivery_status_code  int
, description           varchar(50)
, category_key          int
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_delivery_status
  primary key clustered (delivery_status_key)
  on nds_fg6
, constraint fk_delivery_status_delivery_status_category
  foreign key (category_key)
  references delivery_status_category(delivery_status_category_key)
) on nds_fg4
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'campaign_result')
alter table campaign_result
  add constraint fk_campaign_result_delivery_status
  foreign key (delivery_status_key)
  references delivery_status(delivery_status_key)
go

-- There is no point creating indexes as this is a small table

-- store

use NDS
go

-- Remove FK if exists:

if exists
  (select * from sys.foreign_keys
   where name like 'fk_subscription_sales_store'
   and parent_object_id = object_id('subscription_sales'))
alter table subscription_sales
  drop constraint fk_subscription_sales_store
go

if exists
  (select * from sys.foreign_keys
   where name like 'fk_order_header_store'
   and parent_object_id = object_id('order_header'))
alter table order_header
  drop constraint fk_order_header_store
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'store')
drop table store
go

-- Create the table:

create table store
( store_key           int not null identity(1,1)
, store_number        smallint
, store_name          varchar(50)
, store_type_key      int
, address_key   int
, phone_number_key    int
, web_site            varchar(100)
, region_key          int
, source_system_code  tinyint not null
, create_timestamp    datetime not null
, update_timestamp    datetime not null
, constraint pk_store
  primary key clustered (store_key)
  on nds_fg6
, constraint fk_store_store_type
  foreign key (store_type_key)
  references store_type(store_type_key)
, constraint fk_store_address
  foreign key (address_key)
  references address(address_key)
, constraint fk_store_phone_number
  foreign key (phone_number_key)
  references phone_number(phone_number_key)
, constraint fk_store_region
  foreign key (region_key)
  references region(region_key)
) on nds_fg3
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'subscription_sales')
alter table subscription_sales
  add constraint fk_subscription_sales_store
  foreign key (store_key)
  references store(store_key)
go

if exists
  (select * from sys.tables
   where name = 'order_header')
alter table order_header
  add constraint fk_order_header_store
  foreign key (store_key)
  references store(store_key)
go

-- Create indexes:

if exists
  (select * from sys.indexes
   where name = 'store_number'
   and object_id = object_id('store'))
drop index store.store_number
go

create unique index store_number
  on store(store_number)
  on nds_fg6
go

-- supplier

use NDS
go

-- Drop FK from other table if exists:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_supplier_performance_supplier'
   and parent_object_id = object_id('supplier_performance'))
alter table supplier_performance
  drop constraint fk_supplier_performance_supplier
go

-- Drop table if exists:

if exists 
  (select * from sys.tables 
   where name = 'supplier')
drop table supplier
go

-- Create supplier table:

create table supplier
( supplier_key           int not null identity(1,1)
, supplier_code          varchar(12) not null
, account_number         int
, short_name             varchar(30)
, full_name              varchar(50)
, address_key            int
, phone_number_key       int
, supplier_status_key    int
, email_address_key      int
, website                varchar(100)
, contact_key            int
, effective_timestamp    datetime not null
, expiry_timestamp       datetime not null
, is_current             tinyint not null
, source_system_code     tinyint not null
, create_timestamp       datetime not null
, update_timestamp       datetime not null
, constraint pk_supplier 
  primary key clustered (supplier_key)
  on nds_fg6
, constraint fk_supplier_address
  foreign key (address_key)
  references address(address_key)
, constraint fk_supplier_phone_number
  foreign key (phone_number_key)
  references phone_number(phone_number_key)
, constraint fk_supplier_supplier_status
  foreign key (supplier_status_key)
  references supplier_status(supplier_status_key)
, constraint fk_supplier_email_address
  foreign key (email_address_key)
  references email_address(email_address_key)
, constraint fk_supplier_contact
  foreign key (contact_key)
  references contact(contact_key)
) on nds_fg5
go

-- Establish FK from other tables:

if exists
  (select * from sys.tables
   where name = 'supplier_performance')
alter table supplier_performance
  add constraint fk_supplier_performance_supplier
  foreign key (supplier_key)
  references supplier(supplier_key)
go

-- Build indexes:

if exists
  (select * from sys.indexes 
   where name = 'supplier_code' 
   and object_id = object_id('supplier'))
drop index supplier.supplier_code
go

create unique index supplier_code
  on supplier(supplier_code)
  on nds_fg6
go

-- product

use NDS
go

-- Remove FK if exists:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_order_item_product'
   and parent_object_id = object_id('order_item'))
alter table order_item
  drop constraint fk_order_item_product
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'product')
drop table product
go

-- Create the table:

create table product
( product_key           int not null identity(1,1)
, product_code          varchar(10) not null
, name                  varchar(50) 
, description           varchar(100)
, title                 varchar(100)
, artist_key            int
, product_type_key      int
, format_key            int
, unit_price            smallmoney
, unit_cost             smallmoney
, product_status_key    int
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_product
  primary key clustered (product_key)
  on nds_fg6
, constraint fk_product_product_type
  foreign key (product_type_key)
  references product_type(product_type_key)
, constraint fk_product_format
  foreign key (format_key)
  references format(format_key)
, constraint fk_product_product_status
  foreign key (product_status_key)
  references product_status(product_status_key)
) on [primary]
go

-- Insert Unknown Record:

set identity_insert product on

insert into product
( product_key, product_code, [name]
, description, title, artist_key
, product_type_key, format_key
, unit_price, unit_cost
, product_status_key, source_system_code
, create_timestamp, update_timestamp )
values
( 0, 'Unknown', 'Unknown'
, 'Unknown', 'Unknown', 0
, 0, 0
, 0, 0
, 0, 0
, '1900-01-01', '1900-01-01' )

set identity_insert product off
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'order_item')
alter table order_item
  add constraint fk_order_item_product
  foreign key (product_key)
  references product(product_key)
go

-- Create indexes:

if exists
  (select * from sys.indexes 
   where name = 'product_code' 
   and object_id = object_id('product'))
drop index product.product_code
go

create unique index product_code
  on product(source_system_code, product_code)
  on nds_fg6
go

if exists
  (select * from sys.indexes 
   where name = 'title' 
   and object_id = object_id('product'))
drop index product.title
go

create index title
  on product(title)
  on nds_fg6
go

if exists
  (select * from sys.indexes 
   where name = 'artist_key' 
   and object_id = object_id('product'))
drop index product.artist_key
go

create index artist_key
  on product(artist_key)
  on nds_fg6
go

-- channel

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_communication_subscription_channel'
   and parent_object_id = object_id('communication_subscription'))
alter table communication_subscription
  drop constraint fk_communication_subscription_channel
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_campaign_result_channel'
   and parent_object_id = object_id('campaign_result'))
alter table campaign_result
  drop constraint fk_campaign_result_channel
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_channel_junction_channel'
   and parent_object_id = object_id('channel_junction'))
alter table channel_junction
  drop constraint fk_channel_junction_channel
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'channel')
drop table channel
go

-- Create the table:

create table channel
( channel_key          int not null identity(1,1)
, name                 varchar(20) not null
, description          varchar(50)
, start_date           datetime
, end_date             datetime
, status               varchar(10)
, source_system_code   tinyint not null
, create_timestamp     datetime not null
, update_timestamp     datetime not null
, constraint pk_channel
  primary key clustered (channel_key)
  on nds_fg6
) on nds_fg4
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'communication_subscription')
alter table communication_subscription
  add constraint fk_communication_channel
  foreign key (channel_key)
  references channel(channel_key)
go

if exists
  (select * from sys.tables
   where name = 'campaign_result')
alter table campaign_result
  add constraint fk_campaign_result_channel
  foreign key (channel_key)
  references channel(channel_key)
go

if exists
  (select * from sys.tables
   where name = 'channel_junction')
alter table channel_junction
  add constraint fk_channel_junction_channel
  foreign key (channel_key)
  references channel(channel_key)
go

-- There is no point creating indexes as this is a small table

-- communication

use NDS
go

-- Remove FK:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_communication_subscription_communication'
   and parent_object_id = object_id('communication_subscription'))
alter table communication_subscription
  drop constraint fk_communication_subscription_communication
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_campaign_result_communication'
   and parent_object_id = object_id('campaign_result'))
alter table campaign_result
  drop constraint fk_campaign_result_communication
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'communication')
drop table communication
go

-- Create the table:

create table communication
( communication_key    int not null identity(1,1)
, title                varchar(50) not null
, description          varchar(200)
, format               varchar(20)
, language_key         int
, category_key         int
, issuing_unit_key     int
, start_date           datetime
, end_date             datetime
, status               varchar(10)
, source_system_code   tinyint not null
, create_timestamp     datetime not null
, update_timestamp     datetime not null
, constraint pk_communication
  primary key clustered (communication_key)
  on nds_fg6
, constraint fk_communication_language
  foreign key (language_key)
  references language(language_key)
, constraint fk_communication_communication_category
  foreign key (category_key)
  references communication_category(communication_category_key)
, constraint fk_communication_business_unit
  foreign key (issuing_unit_key)
  references business_unit(business_unit_key)
) on nds_fg4
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'communication_subscription')
alter table communication_subscription
  add constraint fk_communication_subscription_communication
  foreign key (communication_key)
  references communication(communication_key)
go

if exists
  (select * from sys.tables
   where name = 'campaign_result')
alter table campaign_result
  add constraint fk_campaign_result_communication
  foreign key (communication_key)
  references communication(communication_key)

-- Build indexes:

if exists
  (select * from sys.indexes
   where name = 'communication_title'
   and object_id = object_id('communication'))
drop index communication.communication_title
go

create unique index communication_title
  on communication(title)
  on nds_fg6
go

-- customer

use NDS
go

-- Drop FK from other tables:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_address_junction_customer'
   and parent_object_id = object_id('address_junction'))
alter table address_junction
  drop constraint fk_address_junction_customer
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_phone_number_junction_customer'
   and parent_object_id = object_id('phone_number_junction'))
alter table phone_number_junction
  drop constraint fk_phone_number_junction_customer
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_email_address_junction_customer'
   and parent_object_id = object_id('email_address_junction'))
alter table email_address_junction
  drop constraint fk_email_address_junction_customer
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_interest_junction_customer'
   and parent_object_id = object_id('interest_junction'))
alter table interest_junction
  drop constraint fk_interest_junction_customer
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_subscription_sales_customer'
   and parent_object_id = object_id('subscription_sales'))
alter table subscription_sales
  drop constraint fk_subscription_sales_customer
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_communication_subscription_customer'
   and parent_object_id = object_id('communication_subscription'))
alter table communication_subscription
  drop constraint fk_communication_subscription_customer
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_campaign_result_customer'
   and parent_object_id = object_id('campaign_result'))
alter table campaign_result
  drop constraint fk_campaign_result_customer
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_channel_junction_customer'
   and parent_object_id = object_id('channel_junction'))
alter table channel_junction
  drop constraint fk_channel_junction_customer
go

if exists
  (select * from sys.foreign_keys
   where name = 'fk_order_header_customer'
   and parent_object_id = object_id('order_header'))
alter table order_header
  drop constraint fk_order_header_customer
go

-- Drop table if exists:

if exists 
  (select * from sys.tables 
   where name = 'customer')
drop table customer
go

-- Create customer table:

create table customer
( customer_key           int not null identity(1,1)
, customer_id            varchar(10) not null
, account_number         int
, customer_type_key      int
, name                   varchar(100) not null
, gender                 char(1)
, date_of_birth          datetime
, occupation_key         int
, household_income_key   int
, date_registered        datetime
, customer_status_key    int
, subscriber_class_key   int
, subscriber_band_key    int
, permission_key         int
, source_system_code     tinyint not null
, create_timestamp       datetime not null
, update_timestamp       datetime not null
, constraint pk_customer 
  primary key clustered (customer_key)
  on nds_fg6
, constraint fk_customer_occupation
  foreign key (occupation_key)
  references occupation(occupation_key)
, constraint fk_customer_household_income
  foreign key (household_income_key)
  references household_income(household_income_key)
, constraint fk_customer_customer_status
  foreign key (customer_status_key)
  references customer_status(customer_status_key)
, constraint fk_customer_subscriber_class
  foreign key (subscriber_class_key)
  references subscriber_class(subscriber_class_key)
, constraint fk_customer_subscriber_band
  foreign key (subscriber_band_key)
  references subscriber_band(subscriber_band_key)
, constraint fk_customer_permission
  foreign key (permission_key)
  references permission(permission_key)
) on nds_fg2
go

-- Establish FK from other tables:

if exists
  (select * from sys.tables
   where name = 'address_junction')
alter table address_junction
  add constraint fk_address_junction_customer
  foreign key (customer_key)
  references customer(customer_key)
go

if exists
  (select * from sys.tables
   where name = 'phone_number_junction')
alter table phone_number_junction
  add constraint fk_phone_number_junction_customer
  foreign key (customer_key)
  references customer(customer_key)
go

if exists
  (select * from sys.tables
   where name = 'email_address_junction')
alter table email_address_junction
  add constraint fk_email_address_junction_customer
  foreign key (customer_key)
  references customer(customer_key)
go

if exists
  (select * from sys.tables
   where name = 'interest_junction')
alter table interest_junction
  add constraint fk_interest_junction_customer
  foreign key (customer_key)
  references customer(customer_key)
go

if exists
  (select * from sys.tables
   where name = 'subscription_sales')
alter table subscription_sales
  add constraint fk_subscription_sales_customer
  foreign key (customer_key)
  references customer(customer_key)
go

if exists
  (select * from sys.tables
   where name = 'communication_subscription')
alter table communication_subscription
  add constraint fk_communication_subscription_customer
  foreign key (customer_key)
  references customer(customer_key)
go

if exists
  (select * from sys.tables
   where name = 'campaign_result')
alter table campaign_result
  add constraint fk_campaign_result_customer
  foreign key (customer_key)
  references customer(customer_key)
go

if exists
  (select * from sys.tables
   where name = 'channel_junction')
alter table channel_junction
  add constraint fk_channel_junction_customer
  foreign key (customer_key)
  references customer(customer_key)
go

if exists
  (select * from sys.tables
   where name = 'order_header')
alter table order_header
  add constraint fk_order_header_customer
  foreign key (customer_key)
  references customer(customer_key)
go

-- Build indexes:

if exists
  (select * from sys.indexes 
   where name = 'customer_customer_id' 
   and object_id = object_id('customer'))
drop index customer.customer_customer_id
go

create unique index customer_customer_id
  on customer(customer_id)
  on nds_fg6
go

-- communication_subscription

use NDS
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'communication_subscription')
drop table communication_subscription
go

-- Create the table:

create table communication_subscription
( customer_key              int      not null 
, communication_key         int      not null
, channel_key               int      not null
, subscription_start_date   int
, subscription_end_date     int
, subscription_status_key   int
, source_system_code        tinyint  not null
, create_timestamp          datetime not null
, update_timestamp          datetime not null
, constraint pk_communication_subscription
  primary key clustered (customer_key, communication_key, channel_key)
  on nds_fg6
, constraint fk_communication_subscription_customer
  foreign key (customer_key)
  references customer(customer_key)
, constraint fk_communication_subscription_communication
  foreign key (communication_key)
  references communication(communication_key)
, constraint fk_communication_subscription_channel
  foreign key (channel_key)
  references channel(channel_key)
, constraint fk_communication_subscription_subscription_status
  foreign key (subscription_status_key)
  references subscription_status(subscription_status_key)
) on nds_fg4
go

-- campaign_result

use NDS
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'campaign_result')
drop table campaign_result
go

-- Create the table:

create table campaign_result
( campaign_key            int not null 
, customer_key            int not null
, communication_key       int not null
, channel_key             int not null
, send_date               datetime
, delivery_status_key     int not null
, sent                    tinyint
, delivered               tinyint
, bounced                 tinyint
, opened                  tinyint
, clicked_through         tinyint
, complaint               tinyint
, spam_verdict            tinyint
, trap_hit                tinyint
, source_system_code      tinyint  not null
, create_timestamp        datetime not null
, update_timestamp        datetime not null
, constraint pk_campaign_result
  primary key clustered (customer_key, communication_key, channel_key)
  on nds_fg6
, constraint fk_campaign_result_campaign
  foreign key (campaign_key)
  references campaign(campaign_key)
, constraint fk_campaign_result_customer
  foreign key (customer_key)
  references customer(customer_key)
, constraint fk_campaign_result_communication
  foreign key (communication_key)
  references communication(communication_key)
, constraint fk_campaign_result_channel
  foreign key (channel_key)
  references channel(channel_key)
, constraint fk_campaign_result_delivery_status
  foreign key (delivery_status_key)
  references delivery_status(delivery_status_key)
) on nds_fg4
go

-- supplier_performance

use NDS
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'supplier_performance')
drop table supplier_performance
go

-- Create the table:

create table supplier_performance
( week_number               int      not null
, supplier_key              int      not null
, product_key               int      not null
, start_date                datetime 
, ordered_quantity          int
, unit_cost                 money
, ordered_value             money
, returns_quantity          int
, returns_value             money
, rejects_quantity          int
, rejects_value             money
, total_spend               money
, title_availability        decimal (9,2)
, format_availability       decimal (9,2)
, stock_outage              decimal (9,2)
, average_lead_time         smallint
, source_system_code        tinyint not null
, create_timestamp          datetime not null
, update_timestamp          datetime not null
, constraint pk_supplier_performance
  primary key clustered (week_number, supplier_key, product_key)
  on nds_fg6
) on nds_fg5
go

-- Build indexes:

if exists
  (select * from sys.indexes
   where name = 'supplier_key'
   and object_id = object_id('supplier_performance'))
drop index supplier_performance.supplier_key
go

create unique index supplier_key
  on supplier_performance(supplier_key)
  on nds_fg6
go

if exists
  (select * from sys.indexes
   where name = 'product_key'
   and object_id = object_id('supplier_performance'))
drop index supplier_performance.product_key
go

create unique index product_key
  on supplier_performance(product_key)
  on nds_fg6
go

-- subscription_sales

use NDS
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'subscription_sales')
drop table subscription_sales
go

-- Create the table:

create table subscription_sales
( snapshot_date             datetime
, customer_key              int      not null
, package_key               int      not null
, format_key                int      not null
, store_key                 int      not null
, subscription_start_date   datetime
, subscription_end_date     datetime
, lead_key                  int      not null
, subscription_id           int      not null
, subscription_revenue      money
, single_titles_revenue     money    
, monthly_revenue           money
, music_quantity            int
, music_unit_cost           money
, monthly_music_cost        money
, film_quantity             int
, film_unit_cost            money
, monthly_film_cost         money
, book_quantity             int
, book_unit_cost            money
, monthly_book_cost         money
, monthly_indirect_cost     money
, monthly_cost              money
, monthly_margin            money
, annual_revenue            money
, annual_cost               money
, annual_profit             money
, subscriber_profitability  decimal(9,2)
, subscribe_timestamp       datetime
, unsubscribe_timestamp     datetime
, source_system_code        tinyint not null
, create_timestamp          datetime not null
, update_timestamp          datetime not null
, constraint pk_subscription_sales
  primary key clustered (snapshot_date, customer_key, package_key)
  on nds_fg6
, constraint fk_subscription_sales_customer
  foreign key (customer_key)
  references customer(customer_key)
, constraint fk_subscription_sales_package
  foreign key (package_key)
  references package(package_key)
, constraint fk_subscription_sales_format
  foreign key (format_key)
  references format(format_key)
, constraint fk_subscription_sales_store
  foreign key (store_key)
  references store(store_key)
, constraint fk_subscription_sales_lead
  foreign key (lead_key)
  references lead(lead_key)
) on [primary]
go

-- Build indexes

if exists
  (select * from sys.indexes
   where name = 'customer_key'
   and object_id = object_id('subscription_sales'))
drop index subscription_sales.customer_key
go

create unique index customer_key
  on subscription_sales(customer_key)
  on nds_fg6
go

if exists
  (select * from sys.indexes
   where name = 'package_key'
   and object_id = object_id('subscription_sales'))
drop index subscription_sales.package_key
go

create unique index package_key
  on subscription_sales(package_key)
  on nds_fg6
go

-- order_header

use NDS
go

-- Remove FK if exists:

if exists
  (select * from sys.foreign_keys
   where name = 'fk_order_item_order_header'
   and parent_object_id = object_id('order_item'))
alter table order_item
  drop constraint fk_order_item_order_header
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'order_header')
drop table order_header
go

-- Create the table:

create table order_header
( order_key             int not null identity(1,1)
, order_id              int not null
, sales_date            datetime
, customer_key          int
, store_key             int
, currency_key          int
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_order_header
  primary key clustered (order_key)
  on nds_fg6
, constraint fk_order_header_customer
  foreign key (customer_key)
  references customer(customer_key)
, constraint fk_order_header_store
  foreign key (store_key)
  references store(store_key)
) on [primary]
go

-- Create FK:

if exists
  (select * from sys.tables
   where name = 'order_item')
alter table order_item
  add constraint fk_order_item_order_header
  foreign key (order_key)
  references order_header(order_key)
go

-- Build indexes:

if exists
  (select * from sys.indexes
   where name = 'order_header_order_id'
   and object_id = object_id('order_header'))
drop index order_header.order_header_order_id
go

create unique index order_header_order_id
  on order_header(order_id)
  on nds_fg6
go

if exists
  (select * from sys.indexes
   where name = 'order_header_sales_date'
   and object_id = object_id('order_header'))
drop index order_header.order_header_sales_date
go

create index order_header_sales_date
  on order_header(sales_date)
  on nds_fg6
go

if exists
  (select * from sys.indexes
   where name = 'order_header_customer_key'
   and object_id = object_id('order_header'))
drop index order_header.order_header_customer_key
go

create index order_header_customer_key
  on order_header(customer_key)
  on nds_fg6
go

if exists
  (select * from sys.indexes
   where name = 'order_header_store_key'
   and object_id = object_id('order_header'))
drop index order_header.order_header_store_key
go

create index order_header_store_key
  on order_header(store_key)
  on nds_fg6
go

-- order_item

use NDS
go

-- Drop the table:

if exists 
  (select * from sys.tables 
   where name = 'order_item')
drop table order_item
go

-- Create the table:

create table order_item
( order_key             int not null
, line_number           int not null
, product_key           int not null
, quantity              decimal (9,2)
, unit_price            smallmoney
, unit_cost             smallmoney
, sales_value           money
, sales_cost            money
, margin                money
, currency_key          int
, currency_rate         smallmoney
, unit_price_usd        smallmoney
, unit_cost_usd         smallmoney
, sales_value_usd       money
, sales_cost_usd        money
, margin_usd            money
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_order_item
  primary key clustered (order_key, line_number)
  on nds_fg6
, constraint fk_order_item_order_header
  foreign key (order_key)
  references order_header(order_key)
, constraint fk_order_item_product
  foreign key (product_key)
  references product(product_key)
) on [primary]
go

-- address_junction

use NDS
go

-- Drop the table if exists:

if exists 
  (select * from sys.tables 
   where name = 'address_junction')
drop table address_junction
go

-- Create the table:

create table address_junction
( address_junction_key  int not null identity(1,1)
, customer_key          int not null
, address_key           int not null
, address_type_key      int
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_address_junction
  primary key clustered (address_junction_key)
  on nds_fg3
, constraint fk_address_junction_customer
  foreign key (customer_key)
  references customer(customer_key)
, constraint fk_address_junction_address
  foreign key (address_key)
  references address(address_key)
, constraint fk_address_junction_address_type
  foreign key (address_type_key)
  references address_type(address_type_key)
) on nds_fg3
go

-- Build indexes:

if exists
  (select * from sys.indexes
   where name = 'address_junction_customer_key_address_key'
   and object_id = object_id('address_junction'))
drop index address_junction.address_junction_customer_key_address_key
go

create unique index address_junction_customer_key_address_key
  on address_junction(customer_key, address_key)
  on nds_fg6
go

-- phone_number_junction

use NDS
go

if exists 
  (select * from sys.tables 
   where name = 'phone_number_junction')
drop table phone_number_junction
go

create table phone_number_junction
( phone_number_junction_key  int not null identity(1,1)
, customer_key               int not null
, phone_number_key           int not null
, phone_number_type_key      int
, source_system_code         tinyint not null
, create_timestamp           datetime not null
, update_timestamp           datetime not null
, constraint pk_phone_number_junction
  primary key clustered (phone_number_junction_key)
  on nds_fg6
, constraint fk_phone_number_junction_customer
  foreign key (customer_key)
  references customer(customer_key)
, constraint fk_phone_number_junction_phone_number
  foreign key (phone_number_key)
  references phone_number(phone_number_key)
, constraint fk_phone_number_junction_phone_number_type
  foreign key (phone_number_type_key)
  references phone_number_type(phone_number_type_key)
) on nds_fg2
go

if exists
  (select * from sys.indexes
   where name = 'customer_phone_number'
   and object_id = object_id('phone_number_junction'))
drop index phone_number_junction.customer_phone_number
go

create unique index customer_phone_number
  on phone_number_junction(customer_key, phone_number_key)
  on nds_fg6
go

-- email_address_junction

use NDS
go

-- Drop the table if exists:

if exists 
  (select * from sys.tables 
   where name = 'email_address_junction')
drop table email_address_junction
go

-- Create the table:

create table email_address_junction
( email_address_junction_key  int not null identity(1,1)
, customer_key                int not null
, email_address_key           int not null
, email_address_type_key      int
, source_system_code          tinyint not null
, create_timestamp            datetime not null
, update_timestamp            datetime not null
, constraint pk_email_address_junction
  primary key clustered (email_address_junction_key)
  on nds_fg6
, constraint fk_email_address_junction_customer
  foreign key (customer_key)
  references customer(customer_key)
, constraint fk_email_address_junction_email_address
  foreign key (email_address_key)
  references email_address(email_address_key)
, constraint fk_email_address_junction_email_address_type
  foreign key (email_address_type_key)
  references email_address_type(email_address_type_key)
) on nds_fg2
go

-- Build indexes:

if exists
  (select * from sys.indexes
   where name = 'email_address_junction_customer_key_email_address_key'
   and object_id = object_id('email_address_junction'))
drop index email_address_junction.email_address_junction_customer_key_email_address_key
go

create unique index email_address_junction_customer_key_email_address_key
  on email_address_junction(customer_key, email_address_key)
  on nds_fg6
go

-- interest_junction

use NDS
go

if exists 
  (select * from sys.tables 
   where name = 'interest_junction')
drop table interest_junction
go

create table interest_junction
( interest_junction_key int not null identity(1,1)
, customer_key          int not null
, interest_key          int not null
, interest_type_key     int 
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_interest_junction 
  primary key clustered (interest_junction_key)
  on nds_fg6
, constraint fk_interest_junction_customer
  foreign key (customer_key)
  references customer(customer_key)
, constraint fk_interest_junction_interest
  foreign key (interest_key)
  references interest(interest_key)
) on nds_fg2
go

-- channel_junction

use NDS
go

-- Drop the table if exists:

if exists 
  (select * from sys.tables 
   where name = 'channel_junction')
drop table channel_junction
go

-- Create the table:

create table channel_junction
( channel_junction_key  int not null identity(1,1)
, customer_key          int not null
, channel_key           int not null
, channel_type_key      int
, source_system_code    tinyint not null
, create_timestamp      datetime not null
, update_timestamp      datetime not null
, constraint pk_channel_junction
  primary key clustered (channel_junction_key)
  on nds_fg6
, constraint fk_channel_junction_customer
  foreign key (customer_key)
  references customer(customer_key)
, constraint fk_channel_junction_channel
  foreign key (channel_key)
  references channel(channel_key)
) on nds_fg2
go


