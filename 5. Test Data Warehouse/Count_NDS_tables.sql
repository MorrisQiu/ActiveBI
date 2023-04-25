USE NDS;
GO

-- ETL NDS Customer
SELECT 'customer_status', COUNT(*) AS numrows FROM customer_status
UNION SELECT 'customer_type',COUNT(*) AS numrows FROM customer_type
UNION SELECT 'household_income',COUNT(*) AS numrows FROM household_income
UNION SELECT 'occupation',COUNT(*) AS numrows FROM occupation
UNION SELECT 'permission',COUNT(*) AS numrows FROM permission
UNION SELECT 'interest',COUNT(*) AS numrows FROM interest
UNION SELECT 'customer',COUNT(*) AS numrows FROM customer
UNION SELECT 'interest_junction', COUNT(*) AS numrows FROM interest_junction
UNION SELECT 'address_type',COUNT(*) AS numrows FROM address_type
UNION SELECT 'address_junction', COUNT(*) AS numrows FROM address_junction
UNION SELECT 'country',COUNT(*) AS numrows FROM country
UNION SELECT 'state',COUNT(*) AS numrows FROM state
UNION SELECT 'city',COUNT(*) AS numrows FROM city
UNION SELECT 'address',COUNT(*) AS address FROM address