IF EXISTS
  (SELECT * from sys.foreign_keys
   WHERE name = 'fk_customer_subscriber_class'
   AND parent_object_id = object_id('customer'))
ALTER TABLE customer
  DROP CONSTRAINT fk_customer_subscriber_class

TRUNCATE TABLE subscriber_class;

INSERT INTO subscriber_class (
	class_code,lower_limit,upper_limit,description,
	source_system_code,create_timestamp,update_timestamp)

VALUES ('A', 0.00, 59.99, 'class 60', 2, GETDATE(), GETDATE()),
	   ('B', 60.00, 99.99, 'class 100', 2, GETDATE(), GETDATE()),
	   ('C', 100.00, 199.99, 'class 200', 2, GETDATE(), GETDATE()),
	   ('D', 200.00, 500.00, 'class 200 +', 2, GETDATE(), GETDATE());

IF EXISTS
	(SELECT * FROM sys.tables
     WHERE name = 'customer')
ALTER TABLE customer
	ADD CONSTRAINT fk_customer_subcriiber_class 
	FOREIGN KEY (subscriber_class_key)
	REFERENCES subscriber_class(subscriber_class_key)


SELECT *
FROM subscriber_class