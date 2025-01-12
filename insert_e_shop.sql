--user tábla adatai*********************************************************************************

INSERT INTO users (full_name, username, email, password, phone_number, created_at, updated_at)
    VALUES 
        ('Gipsz Jakab', 'gipszjakab', 'gipszjakab@gipszjakab.hu', MD5('passw'), '+361111111', '20230112', '20230112'),
        ('Gipsz János', 'gipszjanos', 'gipszjanos@gipszjanos.hu', MD5('passw18'), '+361111111', '20230415', '20230415'),
        ('Gipsz Jakabné', 'gipszjakabne', 'gipszjakabne@gipszjakabne.hu', MD5('passw'), '+361111111', '20230615', '20230615'),
        ('Nagy Éva', 'nagyeva', 'nagyeva@xy.hu', MD5('passw555'), '+3601111118', '20240205', '20240205'),
        ('Kiss Ágnes', 'kissagi', 'kissagi@xy.hu', MD5('passw555'), '+3619999999', '20240316', '20240316'),
        ('Gábor Dénes', 'gabordenes', 'gabordenes@zzz.com', MD5('00'), '+361256448', '20240715', '20240715'),	
        ('Kelemen Nóra', 'kelemennora', 'kelemennoras@zzz.com', MD5('5678'), '+361256448', '20240716', '20240716'),
        ('Kiss Virág', 'kissvirag', 'kissvirag@kissvirag.com', MD5('qwedsayx'), '+36701112222', '20240815', '20240815');

--addresses tábla adatai*********************************************************************************
 
INSERT INTO addresses (user_id, address_type, country_code, region_id, city, zip_code, street_name, house_number, created_at)
    VALUES
        (1, 'számlázási', 'HU', 1, 'Budapest', '1048', 'Erkel Gyula', 27, '20230112'),
        (1, 'szállítási', 'HU', 2, 'Vác', '2600', 'Alsó', 16, '20230112'),
        (2, 'számlázási', 'HU', 1, 'Budapest', '1048', 'Erkel Gyula', 27, '20230415'),
        (2, 'szállítási', 'HU', 2, 'Göd', '2132', 'Árpád', 2, '20230415'),
        (3, 'számlázási', 'HU', 2, 'Göd', '2131', 'Alagút', 15, '20230615'),
        (4, 'szállítási', 'HU', 1, 'Budapest', '1032', 'Gábor Áron', 42, '20240205'),
        (5, 'számlázási', 'HU', 2, 'Dunakeszi', '2120', 'Barátság', 6, '20240316'),
        (5, 'szállítási', 'HU', 1, 'Budapest', '1162', 'Wesselényi', 15, '20240316'),
        (6, 'számlázási', 'HU', 1, 'Budapest', '1115', 'Alkotás', 18, '20240715'),
        (7, 'számlázási', 'HU', 8, 'Szeged', '3530', 'Nagy Gábor', 42, '20240716'),
        (7, 'szállítási', 'HU', 7, 'Debrecen', '4031', 'Árvalányhaj', 2, '20240716'),
        (1, 'szállítási', 'HU', 1, 'Budapest', '1138', 'Dunavirág', 2, '20240802'),
        (8, 'számlázási', 'HU', 4, 'Szombathely', '9707', 'Bertalanffy Miklós', 8, '20240815'),
        (8, 'szállítási', 'HU', 4, 'Sopron', '9408', 'Csorga', 33, '20240815');

--attributes tábla adatai*********************************************************************************

INSERT INTO attributes (name, created_at, updated_at)
    VALUES
        ('típus', '20221231', '20221231'),
        ('kiadó', '20221231', '20221231'),
        ('szerző', '20221231', '20221231'),
        ('kiadás éve', '20221231', '20221231');

--attr_values tábla adatai*********************************************************************************

INSERT INTO attr_values (attr_id, val, created_at, updated_at)
    VALUES 
        (1, 'könyv', '20221231', '20221231'),
        (1, 'e-könyv', '20221231', '20221231'),
        (1, 'hangos könyv', '20221231', '20221231'),
        (2, 'Scolar kiadó', '20221231', '20221231'),
        (2, 'Pan Books', '20221231', '20221231'),
        (2, 'Új vénusz lap- és könyvkiadó', '20221231', '20221231'),
        (2, 'Taramix Kiadó', '20221231', '20221231'),
        (2, 'Fabian Kiadó', '20221231', '20221231'),
        (2, 'Typotex Elektronikus Kiadó', '20221231', '20221231'),
        (3, 'Richard Phillips Feynmann', '20221231', '20221231'),
        (3, 'Robert B. Leighton', '20221231', '20221231'),
        (3, 'Matthew Sands', '20221231', '20221231'),
        (3, 'Michio Kaku', '20221231', '20221231'),
        (3, 'Kovács Sándor', '20221231', '20221231'),
        (3, 'Douglas Adams', '20221231', '20221231'),
        (3, 'Vavyan Fable', '20221231', '20221231'),
        (3, 'Dr. Guta Gábor', '20221231', '20221231'),
        (3, 'Paul Davies', '20221231', '20221231');
    

--categories tábla adatai*********************************************************************************

INSERT INTO categories (name, parent_id, created_at, updated_at)
    VALUES
        ('Tudomány és Természet', NULL, '20221231', '20221231'),
        ('Irodalom', NULL, '20221231', '20221231'),
        ('Tankönyvek, segédkönyvek', NULL, '20221231', '20221231'),
        ('Számítástechnika, internet', NULL, '20221231', '20221231'),
        ('Ismeretterjesztő', 1, '20221231', '20221231'),
        ('Fizika', 5, '20221231', '20221231'),
        ('Matematika', 5, '20221231', '20221231'),
        ('Szórakoztató irodalom', 2, '20221231', '20221231'),
        ('Szépirodalom', 2, '20221231', '20221231'),
        ('Színmű', 2, '20221231', '20221231'),
        ('Főiskolai, egyetemi tankönyvek', 3, '20221231', '20221231'),
        ('Programozás, fejlesztés', 4, '20221231', '20221231'),
        ('Internet, hálózatok', 4, '20221231', '20221231'),
        ('Adatbázis-kezelés', 4, '20221231', '20221231');
        

-- products tábla adatai*********************************************************************************

INSERT INTO products (sku, name, description, product_type, created_at, updated_at)
    VALUES
        (1100, 'Szállítási költség', 'személyes átvétel', 'Szolgáltatás', '20221231', '20230101'),
        (1101, 'Szállítási költség', 'GLS házhozszállítás - átutalás/bankkártya', 'Szolgáltatás', '20221231', '20230101'),
        (1102, 'Szállítási költség', 'GLS házhozszállítás - utánvét', 'Szolgáltatás', '20221231', '20230101'),
        (1103, 'Szállítási költség', 'Magyar Posta házhozszállítás - átutalás/bankkártya', 'Szolgáltatás', '20221231', '20230101'),
        (1104, 'Szállítási költség', 'Magyar Posta házhozszállítás - utánvét', 'Szolgáltatás', '20221231', '20230101'),
        (1105, 'Hipertér', '', 'Termék', '20230125', '20240412'),
        (1106, 'Az emberiség jövője', '', 'Termék', '20230901', '20241002'),
        (1107, 'A megbundázott Világegyetem', 'Miért pont jó az Univerzum az életnek?','Termék', '20231231', '20240915'),
        (1108, 'Ponyvamesék', 'Puhakötés', 'Termék', '20240101', '20240101'),
        (1109, 'Kyra Eleison', '', 'Termék', '20240101', '20240801'),
        (1111, 'A Feynman - előadások fizikából II.', '', 'Termék', '20240228', '20240831'),
        (1110, 'Differenciaegyenletek', 'Matematika felsőfokon', 'Termék', '20240303', '20240612'),		
        (1112, 'QED', 'A megszilárdult fény', 'Termék', '20240331', '20240915'),
        (1113, 'Szoftverfejlesztés okosan Pythonnal', 'Agilis csapatok közös nyelve', 'Termék', '20240711', '20240711'),
        (1114, 'Dirk Gently holisztikus nyomozóirodája', 'no desc', 'Termék', '20240801', '20240920'),
        (1115, 'Galaxis útikalaúz stopposoknak', 'Dont panic!', 'Termék', '20240901', '20240901');	
                
--payment_type tábla adatai*********************************************************************************

INSERT INTO payment_types (name, created_at, updated_at)
    VALUES 
        ('készpénz', '20221231', '20221231'),
        ('bankkártya', '20221231', '20221231'),
        ('utánvét', '20221231', '20221231'),
        ('átutalás', '20221231', '20221231');

--product_attr_VALUES tábla adatai*********************************************************************************
    
insert  into product_attr_values (attr_values_id, product_id, created_at, updated_at)
    VALUES
        (1, 6, '20230125', '20230125'),
        (13, 6, '20230125', '20230125'),
        (2, 7, '20230901', '20230901'),
        (13, 7, '20230901', '20230901'),
        (1, 8, '20231231', '20231231'),
        (18, 8, '20231231', '20231231'),
        (1, 9, '20240101', '20240101'),
        (16, 9, '20240101', '20240101'),
        (8, 9, '20240101', '20240101'),
        (1, 10, '20240101', '20240101'),
        (16, 10, '20240101', '20240101'),
        (8, 10, '20240101', '20240101'),
        (1, 11, '20240228', '20240228'),
        (10, 11, '20240228', '20240228'),
        (11, 11, '20240228', '20240228'),
        (12, 11, '20240228', '20240228'),
        (9, 11, '20240228', '20240228'),
        (1, 12, '20240303', '20240303'),
        (17, 12, '20240303', '20240303'),
        (1, 13, '20240331', '20240331'),
        (10, 13, '20240331', '20240331'),
        (4, 13, '20240331', '20240331'),
        (1, 14, '20240711', '20240711'),
        (17, 14, '20240711', '20240711'),	
        (2, 15, '20240801', '20240801'),
        (15, 15, '20240801', '20240801'),
        (1, 16, '20240901', '20240901'),
        (15, 16, '20240901', '20240901');
        

--product_prices tábla adatai*********************************************************************************

INSERT INTO product_price_changes (product_id, from_date, price, created_at, price_actualisation_time)
    VALUES
        (1, '20230101', 0, '20221231', '20230101'),
        (2, '20230101', 1500, '20221231', '20230101'),
        (3, '20230101', 2000, '20221231', '20230101'),
        (4, '20230101', 1400, '20221231', '20230101'),
        (5, '20230101', 1900, '20221231', '20230101'),
        (6, '20230125', 6900, '20230125', '20230125'),
        (6, '20230826', 5890, '20230825', '20230826'),
        (7, '20230901', 3560, '20230901', '20230901'),
        (8, '20231231', 6000, '20231231', '20231231'),
        (9, '20240101', 3300, '20240101', '20240101'),
        (10, '20240101', 3250, '20240101', '20240101'),
        (6, '20240126', 6250, '20240125', '20240126'),
        (7, '20240211', 4100, '20240210', '20240211'),
        (11, '20240228', 9000, '20240228', '20240228'),
        (12, '20240303', 5500, '20240303', '20240303'),
        (13, '20240331', 3500, '20240331', '20240331'),
        (6, '20240412', 6750, '20240411', '20240412'),
        (12, '20240612', 6435, '20240611', '20240612'),
        (11, '20240615', 6500, '20240614', '20240615'),
        (8, '20240621', 7500, '20240620', '20240621'),
        (13, '20240630', 4000, '20240629', '20240630'),
        (14, '20240711', 4500, '20240711', '20240711'),
        (15, '20240801', 2500, '20240801', '20240801'),
        (10, '20240801', 4425, '20240731', '20240801'),
        (11, '20240831', 8075, '20240830', '20240831'),
        (16, '20240901', 5000, '20240901', '20240901'),
        (13, '20240915', 5000, '20240914', '20240915'),
        (8, '20240915', 8075, '20240910', '20240915'),
        (15, '20240920', 3500, '20240915', '20240920'),		
        (7, '20241002', 4430, '20241002', '20241002');

--product_categories tábla adatai*********************************************************************************

INSERT INTO product_categories (category_id, product_id, created_at, updated_at)
    VALUES
        (6, 6, '20230125', '20230125'),
        (6, 7, '20230901', '20230901'),
        (6, 8, '20231231', '20231231'),
        (8, 9, '20240101', '20240101'),
        (8, 10, '20240101', '20240101'),
        (6, 11, '20240228', '20240228'),
        (11, 11, '20240228', '20240228'),
        (7, 12, '20240303', '20240303'),
        (11, 12, '20240303', '20240303'),
        (6, 13, '20240331', '20240331'),
        (12, 14, '20240711', '20240711'),
        (11, 14, '20240711', '20240711'),
        (8, 15, '20240801', '20240801'),
        (8, 16, '20240901', '20240901');
            
--product stock tábla adatai*********************************************************************************

INSERT INTO product_stock (product_id, quantity, created_at, updated_at)
    VALUES		
        
        (6, 6, '20230212', '20230806'),
        (7, 7, '20231015', '20240421'),	
        (8, 10, '20240105', '20240105'),		
        (9, 12, '20240115', '20240115'),
        (10, 4, '20240115', '20241010'),	
        (11, 6, '20240302', '20241010'),
        (12, 0, '20240305', '20240708'),
        (13, 15, '20240402', '20241010'),
        (14, 0, '20240715', '20240715'),
        (15, 1, '20240803', '20241010'),
        (16, 10, '20240902', '20241010');
        
--order_details tábla adatai*********************************************************************************	
    
INSERT INTO order_header (user_id, payment_type_id, payment_status, created_at, updated_at)
    VALUES
        (5, 1, TRUE, '20230804', '20230804'),
        (3, 2, TRUE, '20240402', '20240402'),
        (6, 1, TRUE, '20240404', '20240404'),
        (2, 3, TRUE, '20240415', '20240415'),
        (3, 3, TRUE, '20240701', '20240701'),
        (1, 4, TRUE, '20240901', '20240901'),
        (1, 1, FALSE, '20240915', '20240915'),
        (5, 2, TRUE, '20240919', '20240919'),
        (1, 1, TRUE, '20241001', '20241001'),		
        (2, 2, TRUE, '20241003', '20241003'),
        (6, 2, TRUE, '20241003', '20241003'),
        (7, 2, TRUE, '20241005', '20241005'),
        (8, 1, FALSE, '20241009', '20241009'),	
        (6, 4, FALSE, '20241010', '20241010'),
        (8, 3, FALSE, '20241015', '20241015'),
        (7, 3, FALSE, '20241016', '20241016'),
        (6, 2, FALSE, '20241017', '20241017');
    

--order_items tábla adatai*********************************************************************************

INSERT INTO order_items (order_header_id, product_id, quantity, created_at, updated_at)
    VALUES
        (1, 6, 3, '20230804', '20230804'),
        (1, 1, 1, '20230804', '20230804'),
        (2, 11, 1, '20240402', '20240402'),
        (2, 12, 2, '20240402', '20240402'),
        (2, 2, 1, '20240402', '20240402'),
        (3, 13, 1, '20240404', '20240404'),
        (3, 1, 1, '20240404', '20240404'),
        (4, 7, 1, '20240415', '20240415'),
        (4, 11, 1, '20240415', '20240415'),
        (4, 12, 1, '20240415', '20240415'),
        (4, 5, 1, '20240415', '20240415'),
        (5, 12, 1, '20240701', '20240701'),
        (5, 11, 1, '20240701', '20240701'),
        (5, 13, 1, '20240701', '20240701'),
        (5, 5, 1, '20240701', '20240701'),
        (6, 11, 3, '20240901', '20240901'),
        (6, 4, 1, '20240901', '20240901'),
        (7, 13, 6, '20240915', '20240915'),
        (7, 1, 1, '20240915', '20240915'),
        (8, 10, 1, '20240919', '20240919'),
        (8, 11, 1, '20240919', '20240919'),
        (8, 16, 3, '20240919', '20240919'),
        (8, 4, 1, '20240919', '20240919'),
        (9, 16, 1, '20241001', '20241001'),
        (9, 13, 2, '20241001', '20241001'),
        (9, 1, 1, '20241001', '20241001'),
        (10, 15, 1, '20241003', '20241003'),
        (10, 10, 1, '20241003', '20241003'),
        (10, 11, 1, '20241003', '20241003'),
        (10, 2, 1, '20241003', '20241003'),
        (11, 13, 1, '20241003', '20241003'),
        (11, 15, 1, '20241003', '20241003'),
        (11, 7, 1, '20241003', '20241003'),
        (11, 4, 1, '20241003', '20241003'),
        (12, 10, 1, '20241005', '20241005'),
        (12, 11, 1, '20241005', '20241005'),
        (12, 16, 1, '20241005', '20241005'),
        (12, 13, 1, '20241005', '20241005'),
        (12, 15, 1, '20241005', '20241005'),
        (12, 4, 1, '20241005', '20241005'),
        (13, 7, 2, '20241009', '20241009'),
        (13, 1, 1, '20241009', '20241009'),
        (14, 16, 1, '20241010', '20241010'),
        (14, 15, 2, '20241010', '20241010'),
        (14, 2, 1, '20241010', '20241010'),
        (15, 9, 8, '20241015', '20241015'),
        (15, 3, 1, '20241015', '20241015'),
        (16, 12, 1, '20241016', '20241016'),
        (16, 5, 1, '20241016', '20241016'),
        (17, 10, 5, '20241017', '20241017'),
        (17, 5, 1, '20241017', '20241017');
            
--invoice tábla adatai*********************************************************************************

INSERT INTO invoice (order_header_id, total, created_at)
    VALUES
        (1, 20700, '20230806'),
        (2, 21500, '20240405'),
        (3, 3500, '20240410'),
        (4, 20500, '20240421'),
        (5, 18835, '20240708'),
        (6, 25625, '20240906'),
        (8, 28900, '20240922'),
        (9, 15000, '20241002'),
        (10, 17500, '20241006'),
        (11, 14330, '20241006'),
        (12, 27400, '20241010');
