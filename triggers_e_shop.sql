--Készletmennyiség csökkentése számlázás után********************************************************************************************************************************************************

CREATE OR REPLACE FUNCTION decrease_product_stock_quantity_after_invoicing()
RETURNS TRIGGER AS $$
DECLARE productId int;
DECLARE orderedQuantity int;
BEGIN
    FOR productId, orderedQuantity IN
        SELECT products.id, quantity
        FROM order_items LEFT JOIN products on order_items.product_id=products.id
        WHERE products.product_type LIKE 'Termék' AND order_items.order_header_id=NEW.order_header_id
    LOOP
        UPDATE product_stock SET quantity = quantity - orderedQuantity WHERE product_stock.product_id = productId;
    END LOOP;
    RETURN NEW;
    RAISE NOTICE 'Termék azonosító % : , Termék mennyiség %', productId, orderedQuantity;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER insert_invoice_trigger
AFTER INSERT ON invoice
FOR EACH ROW
EXECUTE FUNCTION decrease_product_stock_quantity_after_invoicing();

--updated_at mezők módosítása ********************************************************************************************************************************************************

CREATE OR REPLACE FUNCTION refresh_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

DO
$$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT *
           FROM information_schema.tables
           where table_schema = 'public'
                 and table_name NOT IN ('budapest', 'pest', 'kozep_dunantul', 'nyugat_dunantul', 'del_dunantul', 'eszak_magyarorszag', 'eszak_alfold', 'del_alfold', 'addresses', 'invoice', 'product_price_changes')
  LOOP
    RAISE NOTICE 'CREATE TRIGGER FOR: %', r.table_name::text;

    EXECUTE 'CREATE TRIGGER trg_refresh_updated_at
      BEFORE UPDATE
      on ' || r.table_name || ' FOR EACH ROW
    EXECUTE PROCEDURE refresh_updated_at();';
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Address táblában nem lehet update-elni a sorokat, csak újat beszúrni *******************************************************************************************************************************************************************************************

CREATE OR REPLACE FUNCTION do_not_update_addresses()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'address tábla sorai nem módosíthatóak';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER do_not_update_addresses
AFTER UPDATE ON addresses
FOR EACH ROW
EXECUTE FUNCTION do_not_update_addresses();

--Invoice táblában nem lehet update-elni a sorokat, csak újat beszúrni *******************************************************************************************************************************************************************************************

CREATE OR REPLACE FUNCTION do_not_update_invoice()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'invoice tábla sorai nem módosíthatóak';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER do_not_update_invoice
AFTER UPDATE ON invoice
FOR EACH ROW
EXECUTE FUNCTION do_not_update_invoice();