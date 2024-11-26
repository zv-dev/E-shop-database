--számla adatok legenerálása********************************************************************************************************************************************************

--bemeneti paraméter: orderNumber
--kimeneti paraméter: nincs
--megvalósítás: A rendelés adatai alapján adott feltételek teljesülése mellett legenerálja a számla tábla sorait.
--1. megvizsgálja, hogy a bemenő paraméterként megadott orderNumber létezik e az order_header táblában. Ha nem, exception-t dob.
--2. ha létezik, akkor lekérdezi, hogy a bemenő paraméterként megadott orderNumber létezik e már az invoice táblában. Ha igen, exception-t dob. 
--3. Ha nem, akkor tovább fut az eljárás és lekérdezi a product_stock táblából a rendelésen szereplő azon termékek készletmennyiségét, ahol a product_type mező értéke 'Termék'. Ha a rendelésen szereplő termékek közül legalább az egyikből többet rendeltek, mint a rendelkezésre álló készletmennyiség, exception-t dob.
--4. Ha nem, tovább fut és lekérdezi a rendelés payment_status értékét. Ha bankkártyával vagy utalással fizet és a payment_status értéke false, exception-t dob. 
--5. Ha nem, tovább fut az eljárás és lekérdezi a rendelés összegét a get_order_total_amount függvény segítségével. 
--6. Az orderNumber, totalAmount értékek beszúrásra kerülnek az invoice tábla order_header_id, total mezőibe. 
--7. Ha sikeres volt az adatbeszúrás, kiírásra kerül a 'számlaadatok sikeresen beszúrva' szöveg, ha nem, exception-t dob és a tárolt eljárás futása leáll.
--hívása: call generate_invoice()

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
CREATE OR REPLACE PROCEDURE generate_invoice(orderNumber int) AS $$
DECLARE orderIsInvoiced int;
DECLARE stockOfProduct int;
DECLARE notPaidOrder int;
DECLARE cardPaymentId constant int := 2;
DECLARE bankTransferPaymentId constant int := 4;
DECLARE totalAmount int;
BEGIN
		SELECT INTO orderNumber order_header.id 
		FROM order_header
		WHERE order_header.id=orderNumber;

		IF NOT FOUND THEN
			RAISE EXCEPTION 'Nincs ilyen rendelés!';
		END IF;

		SELECT INTO orderIsInvoiced invoice.order_header_id 
		FROM invoice
		WHERE invoice.order_header_id=orderNumber;

		IF FOUND THEN
			RAISE EXCEPTION 'A rendelés már ki van számlázva!';
		END IF;

		SELECT INTO stockOfProduct product_stock.quantity
		FROM order_items LEFT JOIN products ON order_items.product_id=products.id 
		LEFT JOIN product_stock ON order_items.product_id=product_stock.product_id
		WHERE products.product_type LIKE 'Termék' AND order_items.order_header_id=orderNumber AND order_items.quantity > product_stock.quantity LIMIT 1;

		IF FOUND THEN
			RAISE EXCEPTION 'Nincs elegendő készletmennyiség!';
		END IF;

		SELECT INTO notPaidOrder order_header.id
		FROM order_header
		WHERE (payment_type_id=cardPaymentId OR payment_type_id=bankTransferPaymentId) AND payment_status IS FALSE AND order_header.id=orderNumber;

		IF FOUND THEN
			RAISE EXCEPTION 'Nincs kifizetve! %', notPaidOrder;
		END IF;

		SELECT INTO totalAmount * FROM get_order_total_amount (orderNumber);
	

		INSERT INTO invoice(order_header_id, total) VALUES (orderNumber, totalAmount);
		
		IF FOUND THEN
			RAISE NOTICE 'számlaadatok sikeresen beszúrva';
		ELSE
			RAISE EXCEPTION 'számlaadatok beszúrása sikertelen';
		END IF;
END;
$$ LANGUAGE plpgsql;
COMMIT;

-- az generate_invoice() tárolt eljárás meghívása
CALL generate_invoice(15);


--Termékár érvénybe lépése a price_actualisation_time mező értékének frissítésével *******************************************************************************************************************************************************************************************
--bemeneti paraméter: nincs
--kimeneti paraméter: nincs
--megvalósítás: Az árváltozás táblában megkeresi azokat a sorokat, ahol érvényesíteni kell az árváltozást és ezeken a sorokon végiglépkedve a price_actualisation_time mező értékét az aktuális dátumra állítja be jelezve, hogy az árváltozás életbe lépett.
--hívása manuálisan: call actualize_product_price()
--hívása időzítve: pg_cron kiterjesztés használatának segítségével, rendszeres időközönként meghívva futtatva.

CREATE OR REPLACE PROCEDURE actualize_product_price() AS $$ --actualize_product_price
DECLARE productId int;
DECLARE productPrice decimal;
BEGIN
	FOR productId, productPrice IN
		SELECT product_id, price
		FROM product_price_changes
		WHERE from_date >= current_date
	LOOP
		UPDATE product_price_changes SET price_actualisation_time = now() WHERE product_id = productId and from_date = current_date;
		RAISE NOTICE 'Termék azonosító % : , Termék ár %', productId, productPrice;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

CALL actualize_product_price()