--addresses tábla indexelése************************************************************************************************

--1. city indexelése
--lekérdezés index nélkül
EXPLAIN SELECT city FROM addresses WHERE address_type LIKE 'szállítási' AND user_id=1;
-- indexelés
CREATE INDEX idx_addresses_city ON addresses USING btree(city);
--lekérdezés indexelés után
EXPLAIN SELECT city FROM addresses WHERE address_type LIKE 'szállítási' AND user_id=1;

--2. region_id indexelése
--lekérdezés index nélkül
EXPLAIN SELECT * FROM addresses WHERE address_type LIKE 'szállítási' AND region_id=1;
-- indexelés
CREATE INDEX idx_addresses_region_id ON addresses USING btree(region_id);
--lekérdezés indexelés után
EXPLAIN SELECT * FROM addresses WHERE address_type LIKE 'szállítási' AND region_id=1;

--attr_values tábla indexelése************************************************************************************************

--lekérdezés index nélkül
EXPLAIN SELECT val FROM attr_values WHERE attr_id=3;
--indexelés
CREATE INDEX idx_attr_values_attr_id ON attr_values USING btree(attr_id);
--lekérdezés indexelés után
EXPLAIN SELECT val FROM attr_values WHERE attr_id=3;

--order_header tábla indexelése************************************************************************************************

--1. user_id indexelése
--lekérdezés index nélkül
EXPLAIN SELECT order_header.id FROM order_header WHERE user_id=5;
--indexelés
CREATE INDEX idx_order_header_user_id ON order_header USING btree(user_id);
--lekérdezés indexelés után
EXPLAIN SELECT order_header.id FROM order_header WHERE user_id=5;

--2. payment_type_id indexelése
--lekérdezés index nélkül
EXPLAIN SELECT order_header.id FROM order_header WHERE payment_type_id=1;
--indexelés
CREATE INDEX idx_order_header_payment_type_id ON order_header USING btree(payment_type_id);
--lekérdezés indexelés után
EXPLAIN SELECT order_header.id FROM order_header WHERE payment_type_id=1;

--products tábla indexelése************************************************************************************************

--1. products.name indexelése
--lekérdezés index nélkül
EXPLAIN SELECT sku FROM products WHERE name LIKE 'QED';
--indexelés
CREATE INDEX idx_products_name ON products USING btree(name);
--lekérdezés indexelés után
EXPLAIN SELECT sku FROM products WHERE name LIKE 'QED';

--product_price_changes tábla indexelése************************************************************************************************
EXPLAIN SELECT product_id, from_date FROM product_price_changes WHERE price = 3500 AND price_actualisation_time BETWEEN '20240101' AND '20241031';
--indexelés
CREATE INDEX idx_product_price_changes_price ON product_price_changes USING btree(price);
--lekérdezés indexelés után
EXPLAIN SELECT product_id, from_date FROM product_price_changes WHERE price = 3500 AND price_actualisation_time BETWEEN '20240101' AND '20241031';
