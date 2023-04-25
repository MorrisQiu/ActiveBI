select 'order_header', COUNT(*) from order_header
union
select 'order_detail', COUNT(*) from order_detail
union 
select 'customer', COUNT(*) from customer
union
select 'product', COUNT(*) from product
union
select 'store', COUNT(*) from store