--adott termék aktuális vagy adott időpontban érvényes árát adja vissza***************************************************************************************************************************************
--bemenő paraméter: productId, orderDate default now()
--visszatérési érték: decimal
--megvalósítás: A product_price_changes táblában szűrjük azokat a sorokat, ahol az árváltozás már életbe lépett (price_actualisation_time mező értéke <= mint a paraméterként megadott orderDate értéke) és ahol a paraméterként megadott productId megegyezik a táblában szereplő product_id-vel.
--A kigyűjtött sorokat from_date szerint csökkenő sorrenbe helyezve visszaadja a legelső árat.

CREATE OR REPLACE FUNCTION get_product_price(productId int, orderDate timestamp DEFAULT now()) RETURNS decimal AS $$
DECLARE PriceOfOrderedProduct decimal;
BEGIN
    SELECT INTO PriceOfOrderedProduct price
    FROM product_price_changes
    WHERE price_actualisation_time <= orderDate AND product_id=productId
    ORDER BY from_date DESC
    LIMIT 1;
    RETURN PriceOfOrderedProduct;
END;
$$ LANGUAGE plpgsql;

-- a  get_product_price() függvény meghívása
SELECT * FROM get_product_price (15);

--adott rendelés értéke***************************************************************************************************************************************
--bemenő paraméter: orderNumber
--viszatérési érték: decimal
--megvalósítás: Az order_items táblán végighaladva kigyűjtjük azon sorok product_id, quantity mezők értékeit, ahol az order_header_id mező értéke megegyezik a bemenő paraméterként megadott orderNumber értékével. 
--A kigyűjtött sorokon végighaladva kiszámoljuk a sorösszegeket (get_product_price függvény segítségével), majd ezeket összeadva megkapjuk a rendelés értékét.

CREATE OR REPLACE FUNCTION get_order_total_amount(orderNumber int) RETURNS decimal AS $$
DECLARE sumPrice decimal := 0;
DECLARE row record;
BEGIN
    FOR row IN
        SELECT product_id, quantity FROM order_items WHERE order_items.order_header_id = orderNumber
    LOOP
        sumPrice :=  sumPrice + row.quantity * (SELECT * FROM get_product_price (row.product_id, (SELECT created_at FROM order_header WHERE order_header.id = orderNumber)));
    END LOOP;
    RETURN sumPrice;
END;
$$ LANGUAGE plpgsql;

-- a  get_order_total_amount() függvény meghívása
SELECT get_order_total_amount(8);

--adott rendelésen szereplő tételek sorértéke***************************************************************************************************************************************
--bemenő paraméter: orderNumber
--visszatérési érték: tábla, mezői: productId, lineTotalAmount
--megvalósítás: Az order_items táblát összekapcsoljuk az order_header táblával és szűrjük azokat a sorokat, ahol a bemenő paraméterként megadott orderNumber értéke megegyezik az order_items tábla order_header_id mező értékével.
--A függvény visszaadja a bemenő paraméterként megadott rendelésen szereplő termékek azonosítóját, illetve sorösszegét (a sorösszeget a get_product_price függvény segítségével számoljuk)

CREATE OR REPLACE FUNCTION get_line_total_amount(orderNumber int) RETURNS TABLE (productId int, lineTotalAmount decimal)AS $$
BEGIN
    FOR productId, lineTotalAmount IN
        SELECT product_id, (quantity*(SELECT * FROM get_product_price(product_id, order_header.created_at)))
        FROM order_items LEFT JOIN order_header ON order_header.id=order_items.order_header_id
        WHERE order_items.order_header_id=orderNumber
    LOOP
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- a  get_line_total_amount() függvény meghívása
SELECT * FROM get_line_total_amount(8);

--legjobban fogyó könyvek(adott időszakban)***************************************************************************************************************************************
--bemenő paraméter: hit, fromDate, toDate
--visszatérési érték: tábla, mezői: prodId, prodName, prodQuantity
--megvalósítás: Az order_items táblát összekapcsoljuk a products, illetve order_header táblákkal és szűrjük azokat a sorokat, ahol a products táblában szereplő product_type mező értéke 'Termék', és ahol az order_header tábla created_at mező értéke beleesik a bemenő paraméterként megadott fromDate és toDate közötti időintervallumba.
--Az így kapott sorokat csoportosítjuk termék azonosító (order_items.product_id) és terméknév (products.name) szerint, majd csökkenő sorrendbe rendezzük összmennyiség alapján (SUM(quantity))
--A függvény viszaadja azon termékek adatait (termék azonosító, név, vásárolt összmennyiség), melyből a legtöbbet vásároltak adott időszak alatt. 
--Annyi találatot ad vissza, amekkora értéket adtunk a hit bementő paraméternek. Holtverseny megengedett.

CREATE OR REPLACE FUNCTION best_selling_products(hit int, fromDate date, toDate date) RETURNS TABLE (prodId int, prodName varchar, prodQuantity int) AS $$
BEGIN
    FOR prodId, prodName, prodQuantity IN
        SELECT order_items.product_id, products.name, SUM(quantity)
        FROM order_items 
        LEFT JOIN products ON order_items.product_id=products.id
        LEFT JOIN order_header ON order_items.order_header_id=order_header.id
        WHERE product_type='Termék' AND order_header.created_at BETWEEN fromDate AND toDate
        GROUP BY order_items.product_id, products.name
        ORDER BY SUM(quantity) DESC
        FETCH FIRST hit ROWS WITH TIES
    LOOP
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- a  best_selling_products() függvény meghívása
SELECT * FROM best_selling_products(5, '20240101', '20241010');

--legaktívabb vásárlók(legtöbb rendelést küldő vásárlók adott időszakban)***************************************************************************************************************************************
--bemenő paraméter: hit, fromDate, toDate
--visszatérési érték: tábla, mezői: userId, fullName, emailAddress, quantityOfOrders
--megvalósítás: Az order_header táblát összekapcsoljuk a users táblával és szűrjük azokat a sorokat, ahol az order_header tábla created_at mező értéke beleesik a bemenő paraméterként megadott fromDate és toDate közötti időintervallumba.
--Az így kapott sorokon végighaladva megszámoljuk, hányszor szerepelnek az egyes felhasználók (COUNT(user_id)) - ennyi rendelést adtak le - , a sorokat csoportosítjuk user_id, full_name és email cím alapján és csökkenő sorrendbe rendezzük COUNT(user_id) szerint. 
--A függvény visszaadja azon felhasználók adatait (felhasználó azonosító, teljesnév, email cím, elküldött rendelések mennyisége), akik a legtöbb rendelést küldték adott időszak alatt.
--Annyi találatot ad vissza, amekkora értéket adtunk a hit bementő paraméternek. Holtverseny megengedett.

CREATE OR REPLACE FUNCTION most_purchasing_customer(hit int, fromDate date, toDate date) RETURNS TABLE (userId int, fullName varchar, emailAddress varchar, quantityOfOrders int) AS $$
BEGIN
    FOR userId, fullName, emailAddress, quantityOfOrders IN
        SELECT user_id, full_name, email, COUNT(user_id)
        FROM order_header 
        LEFT JOIN users ON user_id=users.id
        WHERE order_header.created_at BETWEEN fromDate AND toDate
        GROUP BY user_id, full_name, email
        ORDER BY COUNT(user_id) DESC
        FETCH FIRST hit ROWS WITH TIES
    LOOP
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- a  most_purchasing_customer() függvény meghívása
SELECT * FROM most_purchasing_customer(5, '20240101', '20241010');

--a legnagyobb értékben rendeléseket leadó vásárlók(adott időszakban)***************************************************************************************************************************************
--bemenő paraméter: hit, fromDate, toDate
--visszatérési érték: tábla, mezői: userId, fullName, emailAddress, orderTotalAmount
--megvalósítás: A megvalósításhoz két lekérdezés szükséges. Az egyikben kigyűjtjük az egyes rendelésekhez tartozó adatokat (rendelésszám, felhasználó azonosító, teljesnév, email cím, adott rendelés összege), majd a másik lekérdezésben az így kapott eredménytáblán végighaladva összeadjuk az azonos user_id-vel rendelkező rendelések értékeit.
--lépések: 
--1.A FROM után következő főtáblát lekérdezéssel előállítjuk. Ebben a lekérdezésben összekapcsoljuk az order_items táblát a products, order_header, illetve users táblákkal és szűrjük azokat a sorokat,
-- ahol az order_header tábla created_at mező értéke beleesik a bemenő paraméterként megadott fromDate és toDate közötti időintervallumba. Ez a lekérdezés visszaadja az egyes rendelési tételekhez tartozó rendelésszámot, felhasználó azonosítót, a felhasználó teljes nevét, email címét,
-- illetve az egyes rendelések összértékét (a get_order_total_amount függvény segítségével). Az így kapott sorokat csoportosítjuk az egyes rendelési tételekhez tartozó rendelésszámok, felhasználó azonosító, teljes név és email cím szerint, majd felhasználó azonosító és rendelésszám szerint csökkenő sorrendbe rakjuk.
--2. Az 1. pontban kapott eredménytábla lesz a külső lekérdezés főtáblája. Az eredménytábla sorain végighaladva csoportosítjuk a sorokat felhasználó azonosító, teljesnév, email cím szerint és csökkenő sorrenbe rendezzük az azonos felhasználó által küldött rendelések összértéke alapján.
--A függvény visszaadja azon felhasználók adatait (felhasználó azonosító, teljesnév, email cím, elküldött rendelések összértéke), akik a legnagyobb értékben küldtek rendeléseket (rendelések összértéke alapján.)
--Annyi találatot ad vissza, amekkora értéket adtunk a hit bementő paraméternek. Holtverseny megengedett.
 
CREATE OR REPLACE FUNCTION customers_ordering_the_highest_value(hit int, fromDate date, toDate date) RETURNS TABLE (userId int, fullName varchar, emailAddress varchar, orderTotalAmount decimal) AS $$
BEGIN
    FOR userId, fullName, emailAddress, orderTotalAmount IN
        SELECT user_id, full_name, email, SUM(order_total_value)
        FROM (
             SELECT order_items.order_header_id, user_id, full_name, email, (SELECT * FROM get_order_total_amount(order_items.order_header_id)) AS order_total_value
             FROM order_items LEFT JOIN products ON order_items.product_id=products.id 
             LEFT JOIN order_header ON order_items.order_header_id=order_header.id 
             LEFT JOIN users ON order_header.user_id=users.id 
             WHERE order_header.created_at between fromDate AND toDate
             GROUP BY order_items.order_header_id, user_id, full_name, email
             ORDER BY user_id, order_header_id
             )
        GROUP BY user_id, full_name, email
        ORDER BY SUM(order_total_value) DESC
        FETCH FIRST hit ROWS WITH TIES
    LOOP
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- a  customers_ordering_the_highest_value() függvény meghívása
SELECT * FROM customers_ordering_the_highest_value(2, '20240101', '20241010');

--a legdrágább termék/termékek***************************************************************************************************************************************
--bemenő paraméter: nincs
--visszatérési érték: tábla, mezői: prodId, prodName, prodPrice
--megvalósítás: A products táblában szűrjük azokat a sorokat, ahol a product_type mező értéke 'Termék'. A lekérdezés eredménye visszaadja a termék id-t, nevet, illetve a termék árat (a termék árat a get_product_price függvény segítségével). 
--A megkapott eredménysorokat ár szerint csökkenő sorrendbe rendezzük és a függvény az így kapott sorokból az első(ke)t adja vissza. Holtverseny megengedett.

CREATE OR REPLACE FUNCTION most_expensive_product() RETURNS TABLE (prodId int, prodName varchar, prodPrice decimal) AS $$
BEGIN
    FOR prodId, prodName, prodPrice in
        SELECT id, products.name, (SELECT * FROM get_product_price(products.id)) as price
        FROM products
        WHERE product_type LIKE 'Termék' 
        ORDER BY price DESC
        FETCH FIRST 1 ROWS WITH TIES
    LOOP
        RETURN NEXT;
    END LOOP;	
END;
$$ LANGUAGE plpgsql;

-- a  most_expensive_product() függvény meghívása
SELECT * FROM most_expensive_product();

--adott rendelés értéke, fizetési státusz, fizetési mód***************************************************************************************************************************************
--bemenő paraméter: orderNumber
--visszatérési érték: paymentType, paymentStatus, orderTotalAmount
--megvalósítás: Az order_items táblát összekapcsoljuk az order_header, illetve products táblákkal és szűrjük azokat a sorokat, ahol a bemenő paraméterként megadott orderNumber megegyezik az order_items tábla order_header_id mező értékével.
--A függvény visszaadja a bemenő paraméterként megadott rendelés értékét, fizetési státuszát, illetve fizetési módját (a rendelés értékét a get_order_total_amount függvény segítségével)

CREATE OR REPLACE FUNCTION order_total_value_with_payment_status_payment_type(orderNumber int) RETURNS TABLE (paymentType int, paymentStatus boolean, orderTotalAmount decimal) AS $$
BEGIN
    FOR paymentType, paymentStatus, orderTotalAmount IN
        SELECT payment_type_id, payment_status, (SELECT * FROM get_order_total_amount(order_items.order_header_id)) AS total_order_value
        FROM order_items LEFT JOIN order_header ON order_items.order_header_id=order_header.id
        LEFT JOIN products ON order_items.product_id=products.id
        WHERE order_items.order_header_id=orderNumber
        GROUP BY order_items.order_header_id, payment_type_id, payment_status
    LOOP
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- az order_total_value_with_payment_status_payment_type() függvény meghívása
SELECT * FROM order_total_value_with_payment_status_payment_type(1);

--adott rendelés fizetési státusza***************************************************************************************************************************************
--bemenő paraméter: orderNumber
--visszatérési érték: boolean
--megvalósítás: Végig megyünk az order_header táblán és szűrjük azokat a sorokat, ahol a bemenő paraméterként megadott orderNumber megegyezik az order_header tábla id mező értékével. A lekérdezés eredménye az adott rendelés payment_status-a.

CREATE OR REPLACE FUNCTION order_payment_status(orderNumber int) RETURNS boolean AS $$
DECLARE paymentStatus boolean;
BEGIN
    SELECT INTO paymentStatus payment_status
    FROM order_header
    WHERE id=orderNumber;
    RETURN paymentStatus;
END;
$$ LANGUAGE plpgsql;

-- az order_payment_status_() függvény meghívása
SELECT * FROM order_payment_status(15);

--adott rendelés fizetési módja***************************************************************************************************************************************
--bemenő paraméter: orderNumber
--visszatérési érték: skalár szám
--megvalósítás: Végig megyünk az order_header táblán és szűrjük azokat a sorokat, ahol a bemenő paraméterként megadott orderNumber megegyezik az order_header tábla id mező értékével. A lekérdezés eredménye az adott rendelés payment_type_id-je.

CREATE OR REPLACE FUNCTION order_payment_type(orderNumber int) RETURNS int AS $$
DECLARE paymentType int;
BEGIN
    SELECT INTO paymentType payment_type_id
    FROM order_header
    WHERE id=orderNumber;
    RETURN paymentType;
END;
$$ LANGUAGE plpgsql;

-- az order_payment_type() függvény meghívása
SELECT * FROM order_payment_type(10);

--adott rendelés rendelési tételei***************************************************************************************************************************************
--bemenő paraméter: orderNumber
--visszatérési érték: tábla, mezői: prodId, prodName, prodDescription, prodPrice, orderedQuantity, lineTotal
--megvalósítás: Az order_items táblát összekapcsoljuk a products, illetve az order_header táblával és szűrjök azokat a sorokat, ahol a bemenő paraméterként megadott orderNumber megegyezik az order_items tábla order_header_id mező értékével.
--A függvény visszaadja az adott rendelésen szereplő termék azonosítókat, terméknevet, árat, rendelt mennyiséget és sorösszeget (az árat, illetve a sorösszeget a get_product_price függvény meghívásának segítségével).

CREATE OR REPLACE FUNCTION order_details(orderNumber int) RETURNS TABLE (prodId int, prodName varchar, prodDescription varchar, prodPrice decimal, orderedQuantity int, lineTotal decimal) AS $$
BEGIN
    FOR prodId, prodName, prodDescription, prodPrice, orderedQuantity, lineTotal IN
        SELECT products.id, products.name, description, (SELECT * FROM get_product_price(product_id, order_header.created_at)), quantity, quantity*(SELECT * FROM get_product_price(product_id, order_header.created_at)) AS total
        FROM order_items
        LEFT JOIN products on order_items.product_id=products.id
        LEFT JOIN order_header on order_header.id=order_items.order_header_id
        WHERE order_items.order_header_id=orderNumber
    LOOP
        RETURN NEXT;
    END LOOP;	
END;
$$ LANGUAGE plpgsql;

-- az order_details() függvény meghívása
SELECT * FROM order_details(17);

--adott termék raktárkészlete***************************************************************************************************************************************
--bemenő paraméter: productid
--visszatérési érték: skalár szám
--megvalósítás: A product_stock táblán végighaladva szűrjük azokat a sorokat, ahol a product_stock tábla product_id értéke megegyezik a bemenő paraméterként megadott productid értékével és visszaadja a termékmennyiséget.

CREATE OR REPLACE FUNCTION product_stock(productid int) RETURNS int AS $$
DECLARE stockQuantity int;
BEGIN
    SELECT INTO stockQuantity quantity
    FROM product_stock
    WHERE product_stock.product_id=productid;
    RETURN stockQuantity;
END;
$$ LANGUAGE plpgsql;

-- az product_stock() függvény meghívása
SELECT * FROM product_stock(8);

--adott rendelésen szereplő termékek készlete(visszaadja a rendelésszámot, termék azonosítót, készletet)***************************************************************************************************************************************
--bemenő paraméter: orderNumber
--visszatérési érték: tábla, mezői: prodId, prodStockQuantity
--megvalósítás: A order_items tábla sorait összelkapcsoljuk a products és a product_stock táblákkal szűrve azokat a sorokat, ahol a products táblában szereplő product_type mező éréke 'Termék' és szerepel a paraméterként megadott orderNumber.
--A függvény visszaadja az adott rendelésen szereplő  termékek készletét.

CREATE OR REPLACE FUNCTION stock_of_products_included_in_the_order(orderNumber int) RETURNS TABLE (prodId int, prodStockQuantity int) AS $$
BEGIN
    FOR prodId, prodStockQuantity IN
        SELECT order_items.product_id, product_stock.quantity 
        FROM order_items LEFT JOIN products ON order_items.product_id=products.id 
        LEFT JOIN product_stock ON order_items.product_id=product_stock.product_id
        WHERE products.product_type LIKE 'Termék' AND order_items.order_header_id=orderNumber
    LOOP
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- az stock_of_products_included_in_the_order() függvény meghívása
SELECT * FROM stock_of_products_included_in_the_order(8);

-- Kategória fa lekérdezés recursive function-nal a levéltől indulva a gyökérig***************************************************************************************************************************************
--bemenő paraméter: categId
--visszatérési érték: tábla, mezői: id, name
--megvalósítás: A bemenő paraméterként megadott categId alapján lekérdezi az adott kategória sort és a függvény önmagát meghívja mindaddig, amíg az adott elem parent id-je null értéket nem vesz fel.
--Ezt követően lekérdezi a gyökér elemet is.

CREATE OR REPLACE FUNCTION get_product_category_path(categId int) RETURNS TABLE (id int, name varchar) AS $$
BEGIN
    RETURN QUERY
    SELECT (get_product_category_path(a.parent_id)).* FROM categories a where a.id=categId and a.parent_id IS NOT NULL;

    RETURN QUERY
    SELECT b.id, b.name from categories b where b.id=categId;	
END;
$$ LANGUAGE plpgsql;

-- az get_product_category_path() függvény meghívása
SELECT * FROM get_product_category_path(10);