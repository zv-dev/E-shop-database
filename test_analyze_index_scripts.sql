--legjobban fogyó könyvek***************************************************************************************************************************************

SELECT test_order_items.product_id, test_products.name, SUM(quantity)
FROM test_order_items 
LEFT JOIN test_products ON test_order_items.product_id=test_products.id
LEFT JOIN test_order_header ON test_order_items.order_header_id=test_order_header.id
WHERE product_type='Termék' 
GROUP BY test_order_items.product_id, test_products.name
ORDER BY SUM(quantity) DESC
FETCH FIRST 100 ROWS WITH TIES;

EXPLAIN (ANALYZE,buffers) SELECT test_order_items.product_id, test_products.name, SUM(quantity)
FROM test_order_items 
LEFT JOIN test_products ON test_order_items.product_id=test_products.id
LEFT JOIN test_order_header ON test_order_items.order_header_id=test_order_header.id
WHERE product_type='Termék' 
GROUP BY test_order_items.product_id, test_products.name
ORDER BY SUM(quantity) DESC
FETCH FIRST 100 ROWS WITH TIES;

--------------------------------------------------------------Query Plan-----------------------------------------------------------------------------------------

/*Limit  (cost=1365.19..1365.44 rows=100 width=44) (actual time=11.597..11.622 rows=169 loops=1)
  Buffers: shared hit=306
  ->  Sort  (cost=1365.19..1392.09 rows=10759 width=44) (actual time=11.595..11.609 rows=170 loops=1)
        Sort Key: (sum(test_order_items.quantity)) DESC
        Sort Method: quicksort  Memory: 1056kB
        Buffers: shared hit=306
        ->  HashAggregate  (cost=846.40..953.99 rows=10759 width=44) (actual time=9.076..10.169 rows=10762 loops=1)
              Group Key: test_order_items.product_id, test_products.name
              Batches: 1  Memory Usage: 1425kB
              Buffers: shared hit=306
              ->  Hash Join  (cost=525.20..765.71 rows=10759 width=40) (actual time=4.586..6.920 rows=10762 loops=1)
                    Hash Cond: (test_order_items.product_id = test_products.id)
                    Buffers: shared hit=306
                    ->  Seq Scan on test_order_items  (cost=0.00..209.00 rows=12000 width=12) (actual time=0.006..0.521 rows=12000 loops=1)
                          Buffers: shared hit=89
                    ->  Hash  (cost=379.50..379.50 rows=11656 width=36) (actual time=4.561..4.561 rows=11656 loops=1)
                          Buckets: 16384  Batches: 1  Memory Usage: 947kB
                          Buffers: shared hit=217
                          ->  Seq Scan on test_products  (cost=0.00..379.50 rows=11656 width=36) (actual time=0.008..2.338 rows=11656 loops=1)
                                Filter: ((product_type)::text = 'Termék'::text)
                                Rows Removed by Filter: 1344
                                Buffers: shared hit=217
Planning:
  Buffers: shared hit=91
Planning Time: 0.635 ms
Execution Time: 11.824 ms*/


--Táblák indexelése**************************************************************************************************************************************************

--addresses tábla indexelése************************************************************************************************

--1. city indexelése
--lekérdezés index nélkül Append
EXPLAIN SELECT city FROM test_addresses WHERE address_type LIKE 'szállítási';
-- indexelés
CREATE INDEX idx_test_addresses_city ON test_addresses USING btree(city);
--lekérdezés indexelés után
EXPLAIN SELECT city FROM test_addresses WHERE address_type LIKE 'szállítási';

--2. region_id indexelése
--lekérdezés index nélkül
EXPLAIN SELECT * FROM test_addresses WHERE address_type like 'szállítási' AND region_id=1;
-- indexelés
CREATE INDEX idx_test_addresses_region_id ON test_addresses USING btree(region_id);
--lekérdezés indexelés után
EXPLAIN SELECT * FROM test_addresses WHERE address_type LIKE 'szállítási' AND region_id=1;

--attr_values tábla indexelése************************************************************************************************

--lekérdezés index nélkül
EXPLAIN SELECT val FROM test_attr_values WHERE attr_id=3;
--indexelés
CREATE INDEX idx_test_attr_values_attr_id ON test_attr_values USING btree(attr_id);
--lekérdezés indexelés után
EXPLAIN SELECT val FROM test_attr_values WHERE attr_id=3;

--order_header tábla indexelése************************************************************************************************

--1. user_id indexelése
--lekérdezés index nélkür
EXPLAIN SELECT test_order_header.id FROM test_order_header WHERE user_id=617;
--indexelés
CREATE INDEX idx_test_order_header_user_id ON test_order_header USING btree(user_id);
--lekérdezés indexelés után
EXPLAIN SELECT test_order_header.id FROM test_order_header WHERE user_id=617;

--2. payment_type_id indexelése
--lekérdezés index nélkül
EXPLAIN SELECT test_order_header.id FROM test_order_header WHERE payment_type_id=1;
--indexelés
CREATE INDEX idx_test_order_header_payment_type_id ON test_order_header USING btree(payment_type_id);
--lekérdezés indexelés után
EXPLAIN SELECT test_order_header.id FROM test_order_header WHERE payment_type_id=1;

--products tábla indexelése************************************************************************************************
SELECT * FROM test_product_price_changes;
--lekérdezés index nélkül
EXPLAIN SELECT sku FROM test_products WHERE name LIKE 'Szállítási költség';
--indexelés
CREATE INDEX idx_test_products_name ON test_products USING btree(name);
--lekérdezés indexelés után
EXPLAIN ANALYZE SELECT sku FROM test_products WHERE name LIKE 'Szállítási költség';

--product_price_changes tábla indexelése************************************************************************************************
EXPLAIN SELECT product_id, from_date FROM test_product_price_changes WHERE price = 185 AND price_actualisation_time BETWEEN '20230101' AND '20231031';
--indexelés
CREATE INDEX idx_test_product_price_changes_price ON test_product_price_changes USING btree(price);
--lekérdezés indexelés után
EXPLAIN SELECT product_id, from_date FROM test_product_price_changes WHERE price = 185 AND price_actualisation_time BETWEEN '20230101' AND '20231031';

--------------------------------------------------------------Query Plan indexelés után-----------------------------------------------------------------------------------------

EXPLAIN (ANALYZE,buffers) SELECT test_order_items.product_id, test_products.name, SUM(quantity)
FROM test_order_items 
LEFT JOIN test_products ON test_order_items.product_id=test_products.id
LEFT JOIN test_order_header ON test_order_items.order_header_id=test_order_header.id
WHERE product_type='Termék' 
GROUP BY test_order_items.product_id, test_products.name
ORDER BY SUM(quantity) DESC
FETCH FIRST 100 ROWS WITH TIES;

/*Limit  (cost=1365.19..1365.44 rows=100 width=44) (actual time=8.813..8.836 rows=169 loops=1)
  Buffers: shared hit=306
  ->  Sort  (cost=1365.19..1392.09 rows=10759 width=44) (actual time=8.812..8.825 rows=170 loops=1)
        Sort Key: (sum(test_order_items.quantity)) DESC
        Sort Method: quicksort  Memory: 1056kB
        Buffers: shared hit=306
        ->  HashAggregate  (cost=846.40..953.99 rows=10759 width=44) (actual time=6.594..7.532 rows=10762 loops=1)
              Group Key: test_order_items.product_id, test_products.name
              Batches: 1  Memory Usage: 1425kB
              Buffers: shared hit=306
              ->  Hash Join  (cost=525.20..765.71 rows=10759 width=40) (actual time=2.160..4.267 rows=10762 loops=1)
                    Hash Cond: (test_order_items.product_id = test_products.id)
                    Buffers: shared hit=306
                    ->  Seq Scan on test_order_items  (cost=0.00..209.00 rows=12000 width=12) (actual time=0.004..0.449 rows=12000 loops=1)
                          Buffers: shared hit=89
                    ->  Hash  (cost=379.50..379.50 rows=11656 width=36) (actual time=2.147..2.147 rows=11656 loops=1)
                          Buckets: 16384  Batches: 1  Memory Usage: 947kB
                          Buffers: shared hit=217
                          ->  Seq Scan on test_products  (cost=0.00..379.50 rows=11656 width=36) (actual time=0.003..1.085 rows=11656 loops=1)
                                Filter: ((product_type)::text = 'Termék'::text)
                                Rows Removed by Filter: 1344
                                Buffers: shared hit=217
Planning:
  Buffers: shared hit=9
Planning Time: 0.151 ms
Execution Time: 8.936 ms*/