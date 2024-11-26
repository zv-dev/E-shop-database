--Mekkora a rendelések értéke (rendelésenként)?*********************************************************************************

SELECT order_items.order_header_id, products.id, products.name, description, quantity, (SELECT * FROM get_product_price(product_id, order_header.created_at)) AS price, (quantity*(SELECT * FROM get_product_price(product_id, order_header.created_at))) AS total
INTO TEMPORARY list
FROM order_items LEFT JOIN products on order_items.product_id=products.id
LEFT JOIN order_header on order_header.id=order_items.order_header_id
ORDER BY order_items.order_header_id, products.id;

SELECT order_header_id AS order_number, SUM(total) AS total_amount
FROM list
GROUP BY order_header_id
ORDER BY order_header_id;

--Mik a rendelési tételek (rendelésenként csoportosítva)?*********************************************************************************

SELECT order_items.order_header_id, products.id, products.name, description, (SELECT * FROM get_product_price(product_id, order_header.created_at)) AS price, quantity, (quantity*(SELECT * FROM get_product_price(product_id, order_header.created_at))) AS total
FROM order_items LEFT JOIN products ON order_items.product_id=products.id
LEFT JOIN order_header on order_header.id=order_items.order_header_id
ORDER BY order_items.order_header_id, products.id;

--Melyik a legtöbbször választott fizetési mód?*********************************************************************************

SELECT payment_type_id, payment_types.name, Count(*) AS darab
FROM order_header LEFT JOIN payment_types ON order_header.payment_type_id=payment_types.id
GROUP BY payment_type_id, payment_types.name
ORDER BY darab DESC
FETCH FIRST 1 ROWS WITH TIES;

--Melyik termékből hány darab van készleten?*********************************************************************************
    
SELECT product_stock.product_id, sku, products.name, quantity AS elérhető_mennyiség
FROM product_stock LEFT JOIN products ON product_stock.product_id=products.id;

--Melyik terméknek mi a státusza (elérhető/nem elérhető)*********************************************************************************
SELECT product_stock.product_id, sku, products.name, quantity, 'elérhető' AS elérhetőség
FROM product_stock LEFT JOIN products ON product_stock.product_id=products.id
WHERE quantity>0
UNION
SELECT product_stock.product_id, sku, products.name, quantity, 'nem elérhető' AS elérhetőség
FROM product_stock LEFT JOIN products ON product_stock.product_id=products.id
WHERE quantity=0
ORDER BY product_id;

--Vásárlási előzmények vevőnként (ha érdekel az is, hogy ki nem vásárolt még)*********************************************************************************

SELECT order_header.created_at, user_id, full_name, order_header.id AS order_number, products.id AS product_id, products.name, (SELECT * FROM get_product_price(product_id, order_header.created_at)), quantity, (quantity*(SELECT * FROM get_product_price(product_id, order_header.created_at))) AS total
FROM users LEFT JOIN order_header ON users.id=order_header.user_id
LEFT JOIN order_items ON order_header.id=order_items.order_header_id
LEFT JOIN products ON order_items.product_id=products.id
ORDER BY users.id, order_number;

--Vásárlási előzmények vevőnként (ha csak az érdekel, aki már vásárolt)*********************************************************************************

SELECT order_header.created_at, user_id, full_name, order_header.id AS order_number, products.id AS product_id, products.name, (SELECT * FROM get_product_price(product_id, order_header.created_at)), quantity, (quantity*(SELECT * FROM get_product_price(product_id, order_header.created_at))) AS total
FROM users LEFT JOIN order_header ON users.id=order_header.user_id
LEFT JOIN order_items ON order_header.id=order_items.order_header_id
LEFT JOIN products ON order_items.product_id=products.id
WHERE users.id IN (SELECT user_id FROM order_header)
ORDER BY users.id, order_number;

--Melyik vásárló nem vett még semmit (nincs rendelése)*********************************************************************************

SELECT users.id, full_name AS name
FROM users
WHERE users.id NOT IN (SELECT user_id FROM order_header);

--Rendelések státusza*********************************************************************************

SELECT 'lezárt rendelések' AS rendelés_státusz, order_header.id AS rendelés_szám
FROM order_header
WHERE order_header.id IN (SELECT invoice.order_header_id FROM invoice)
UNION
SELECT 'nyitott rendelések' AS rendelés_státust, order_header.id AS rendelés_szám
FROM order_header
WHERE order_header.id NOT IN (SELECT invoice.order_header_id FROM invoice)
ORDER BY rendelés_szám;

--Melyik termék szerepel több kategóriában*********************************************************************************

SELECT product_id, COUNT(product_id) AS darab
FROM product_categories 
GROUP BY product_id
HAVING COUNT(product_id)>1;

--Melyik termék szerepel több kategóriában (kiírva a termék nevét, kategóriáját)*********************************************************************************

SELECT products.id, products.name || ':' || ' ' || categories.name AS termék_név_kategóriával
FROM products, categories, product_categories
WHERE products.id=product_categories.product_id AND categories.id=product_categories.category_id
AND products.id IN (
    SELECT product_id
    FROM product_categories LEFT JOIN products ON product_categories.product_id=products.id 
    GROUP BY product_id
    HAVING COUNT(product_id)>1
);

--Terméklista attribútumokkal*********************************************************************************

SELECT products.id, sku, products.name, (SELECT * FROM get_product_price(products.id)) AS price, attributes.name , attr_values.val
FROM products, product_attr_values, attr_values, attributes
WHERE products.id=product_attr_values.product_id AND product_attr_values.attr_values_id=attr_values.id AND attr_values.attr_id=attributes.id

-- Kategória fa lekérdezés cte-vel****************************************************************************

WITH RECURSIVE rec AS (
  SELECT categories.id, categories.name, categories.parent_id from categories where id=6
  UNION ALL
  SELECT categories.id, categories.name, categories.parent_id from rec, categories where categories.id = rec.parent_id)
SELECT id, name FROM rec ORDER BY id;
