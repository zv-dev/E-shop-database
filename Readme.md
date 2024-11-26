# Online Könyvesbolt Adatbázis Rendszer (PostgreSQL)
## Az adatrendszer ismertetése

- A rendszerben a termékek (könyvek), vásárlók, rendelések és számlák adatait kezeljük. Nem kezelünk beszerzéseket, nincsen raktárak közötti készletmozgatás, nincs helyesbítő/jóváíró számla, szállítólevél készítés. Nem kezelünk engedményeket.
- A rendeléseken szereplő termékek a megrendelés pillanatában érvényes aktuális áron kerülnek kiszámlázásra.
- A rendeléseket külön számlázzuk (1 rendelés = 1 számla), részteljesítésre nincs lehetőség. A rendelések számlázásakor - a teljesíthetőség ellenőrzése után – a rendelésen szereplő termékek készletmennyiségét a rendelésen szereplő mennyiséggel csökkentjük.

## Ügyviteli funkciók

- Felhasználókezelés: 
    - Regisztrált felhasználók adatainak rögzítése, hozzájuk tartozó címek rögzítése.
- Kategória rögzítés: 
    - Termékkategóriák rögzítése.
- Termékkezelés:
    - Termékek rögzítése, terméktípus meghatározása.
- Termék tulajdonságok: 
    - Termékekhez rendelhető tulajdonságok rögzítése.
- Tulajdonság értékek:
    - Adott termék tulajdonsághoz rendelt értékek rögzítése.
- Készletkezelés: 
    - Termék aktuális készletmennyiségének tárolása, készlet frissítése számlázást követően.
    - Termékmennyiség >=0 megszorítás.
- Árváltozás: 
    - A termékek árváltozásának nyomon követése, új ár rögzítése adott termékhez, megadott dátumtól.
    - Termék ár >=0 megszorítás.
- Fizetési módok: 
    - Fizetési módok rögzítése.
- Rendelés: 
    - Adott vevőhöz tartozó rendelések rögzítése.
    - Rendelt termék mennyiség > 0 megszorítás.
- Számlázás: 
    - Adott feltételek teljesülése esetén a rendelésből számla generálása. Egy számlán egy rendelés szerepelhet.
- Statisztikák/riportok: 
    - Statisztikák/riportok generálása.
 
## Szükséges egyedek kialakítása

(jelölés: **TÁBLA** (**kulcs**, leíró, _kapcsolathordozó_))
(táblázat jelölések: PK (elsődleges kulcs), FK (külső kulcs) a hivatkozott szülőtáblával, U (egyedi))

### USERS: felhasználók törzse
**USERS** {**id**, full_name, username, **email**, password, phone_number, created_at, updated_at}
Az **email** cím **egyedi**, nem szerepelhet többször ua. az email cím az adatbázisban. Egy felhasználónak több címe is lehet, ADDRESSES → USERS

| mező | adattípus | szerep | korlátozás |
| ------ | ------ | ------ | ------ |
| id | serial(4) | PK Generált |  |
| full_name | varchar(255) | Kötelező |  |
| username |  varchar(255) | Kötelező |  |
| email |  varchar(255) | U, Kötelező |  |
| password | varchar(255) | Kötelező |  |
| phone_number | varchar(255) | Kötelező |  |
| created_at | timestamp | kötelező, alapért: current_timestamp |  |
| updated_at | timestamp | kötelező, alapért: current_timestamp |  |

### ADDRESSES: felhasználók címei
**ADDRESSES** {**id**, _user_id_, address_type, country_code, **region_id**, city, zip_code, street_name, house_number, created_at}
A felhasználók **kétféle cím**mel rendelkezhetnek – address_type értékei: _Számlázási_ v. _Szállítási_, **egy felhasználónak több számlázási/szállítási cím**e is lehet. A rögzített címeket **nem lehet felülírni**, címváltozás esetén **új cím**et szükséges felvinni. A címeket régió szerint particionáljuk.

| mező | adattípus | szerep | korlátozás |
| ------ | ------ | ------ | ------ |
| id | serial(4) | PK része, Generált |  |
| user_id | int(4) | Kötelező, FK (users) |  |
| address_type |  varchar(20) | Kötelező |  |
| country_code |  varchar(10) | Kötelező |  |
| region_id | int(4) | PK része, Kötelező |  |
| city | varchar(255) | Kötelező |  |
| zip_code | varchar(10) | Kötelező |  |
| street_name | varchar(255) | Kötelező |  |
| house_number | int(4) | Kötelező |  |
| created_at | timestamp | kötelező, alapért: current_timestamp |  |

### PRODUCTS: termékek
**PRODUCTS** {**id**, **sku**, name, description, **product_type**, created_at, updated_at}
A products táblában tároljuk a **termékek általános tulajdonságai**t, pl. cikkszám, név, leírás. Kétféle terméktípus létezik – product_type értékei _Termék_ vagy _Szolgáltatás_ -, melyet a termék felvitelekor szükséges megadni. 

| mező | adattípus | szerep | korlátozás |
| ------ | ------ | ------ | ------ |
| id | serial(4) | PK Generált |  |
| sku | int(4) | U, Kötelező |  |
| name |  varchar(255) | Kötelező |  |
| description |  varchar(255) |  |  |
| product_type | varchar(255) | U, Kötelező |  |
| created_at | timestamp | kötelező, alapért: current_timestamp |  |
| updated_at | timestamp | kötelező, alapért: current_timestamp |  |

### CATEGORIES: termék kategóriák
**CATEGORIES** {**id**, **name**, parent_id, created_at, updated_at}
**Rekurzív** módon vannak letárolva a kategóriák. **Bármilyen mélységű** lehet a kategória (hurok vizsgálat)
Egy kategória több termékhez is kapcsolódhat és egy terméket több kategóriába is besorolhatunk. **CATEGORIES : PRODUCTS = N:M**, ezért **szükség van kapcsolótáblára.**

| mező | adattípus | szerep | korlátozás |
| ------ | ------ | ------ | ------ |
| id | serial(4) | PK Generált |  |
| name |  varchar(255) | U, Kötelező |  |
| parent_id | int(4) |  |  |
| created_at | timestamp | kötelező, alapért: current_timestamp |  |
| updated_at | timestamp | kötelező, alapért: current_timestamp |  |

### PRODUCT_CATEGORIES: termékek és kategóriák kapcsolótáblája
**PRODUCT_CATEGORIES** {**id, _category_id_, _product_id_**, created_at, updated_at}
Ebben a táblában **rendeljük össze a termékeket a lehetséges kategóriákkal**. PRODUCT_CATEGORIES → CATEGORIES és PRODUCT_CATEGORIES →PRODUCTS

| mező | adattípus | szerep | korlátozás |
| ------ | ------ | ------ | ------ |
| id | serial(4) | PK Generált |  |
| category_id |  int(4) | U, Kötelező, FK (categories) |  |
| product_id |  int(4) | U, Kötelező, FK (products) |  |
| created_at | timestamp | kötelező, alapért: current_timestamp |  |
| updated_at | timestamp | kötelező, alapért: current_timestamp |  |

### PRODUCT_STOCK: termékkészlet
**PRODUCT_STOCK** {**id**, **_product_id_**, quantity, created_at, updated_at}
A termékkészlet tábla mindig az adott termék aktuális készletét tárolja. A PRODUCT_STOCK → PRODUCTS. A termék készletmennyiség >= 0

mező | adattípus | szerep | korlátozás |
| ------ | ------ | ------ | ------ |
id | serail(4) | PK generált |  |
product_id | int(4) | FK (products) kötelező |  |
from_date | date | kötelező |  |
price | decimal(10, 2) | kötelező | price >= 0 |  |
created_at | timestamp | kötelező, alapért: current_timestamp |  |
price_actualisation_time | timestamp |  |

### PRODUCT_PRICE_CHANGES: termék árváltozás
**PRODUCT_PRICE_CHANGES** {**id**, _product_id_, from_date, price, created_at, price_actualisation_time}
Ebben a táblában **tároljuk a termékek árait, árváltozásait**. A rendeléseken szereplő termékek a **rendelés elküldésekor érvényes ár**át ebből a táblából nyerjük ki. A **from_date** mezőben adjuk meg, hogy **mikortól érvényes** az új ár, a **created_at** mező tárolja az **új ár felvitelének az idejét**, a **price_actualisation_time** mezőben tároljuk azt a dátumot, amikor az **új rögzített ár érvényesítésre kerül**. A PRODUCT_PRICE_CHANGES → PRODUCTS. A **termék ár >=0**

mező | adattípus | szerep | korlátozás |
| ------ | ------ | ------ | ------ |
id | serail(4) | PK generált |  | 
product_id | int(4) | FK (products) kötelező |  | 
from_date | date | kötelező |  | 
price | decimal (10, 2) | kötelező | price >= 0 |
created_at | timestamp | kötelező, alapért: current_timestamp |  | 
price_actualisation_time | timestamp |  |  | 

### ATTRIBUTES: attribútumok
ATTRIBUTES {**id**, **name**, created_at, updated_at}
Az attribútum táblában tároljuk a **termékekhez rendelhető tulajdonságokat**, pl. 1. típus, 2. kiadó, 3. szerző stb.

mező | adattípus | szerep | korlátozás |
| ------ | ------ | ------ | ------ |
id | serial(4) | PK, generált |  | 
name | varchar(255) | U, kötelező |  | 
created_at | timestamp | kötelező, alapért: current_timestamp |  |
updated_at | timestamp | kötelező, alapért: current_timestamp |  |

### ATTR_VALUES: attribútum értékek
**ATTR_VALUES**: {**id**, **val**, _attr_id_, created_at, updated_at}
Az attr_values tábla tartalmazza az **attribútumokhoz kapcsolódó értékeket** (egy attribútumhoz több érték is tartozhat). ATTRIBUTES : ATTR_VALUES = 1 : N, ezért ATTR_VALUES → ATTRIBUTES

mező | adattípus | szerep | korlátozás |
| ------ | ------ | ------ | ------ |
id | serial(4) | PK, generált |  | 
val | int(4) | U, kötelező |  | 
attr_id | int(4) | FK (attributes), kötelező |  | 
created_at | timestamp | kötelező, alapért: current_timestamp |  | 
updated_at | timestamp | kötelező, alapért: current_timestamp |  |

### PRODUCT_ATTR_VALUES: termék attribútum érték
**PRODUCT_ATTR_VALUES** {**id, _attr_values_id_, _product_id_**, created_at, updated_at}
A product_attr_values tábla a **kapcsolótábla a products és az attr_values táblák között**. PRODUCT_ATTR_VALUES → ATTR_VALUES és PRODUCT_ATTR_VALUES → PRODUCTS

mező | adattípus | szerep | korlátozás |
| ------ | ------ | ------ | ------ |
id | serial(4) | PK része, generált |  | 
attr_values_id | int(4) | U, kötelező, FK (attr_values) |  | 
product_id | int(4) | U, kötelező, FK (products) |  | 
created_at | timestamp | kötelező, alapért: current_timestamp |  | 
updated_at | timestamp | kötelező, alapért: current_timestamp |  | 

### PAYMENT_TYPES: fizetési módok
**PAYMENT_TYPES** {**id, name**, created_at, updated_at}
A payment_types táblában tároljuk a lehetséges **fizetési módok**at. 

mező | adattípus | szerep | korlátozás |
| ------ | ------ | ------ | ------ |
id | serial(4) | PK, generált |  | 
name | varchar(255) | U, kötelező |  | 
created_at | timestamp | kötelező, alapért: current_timestamp |  | 
updated_at | timestamp | kötelező, alapért: current_timestamp |  | 

### ORDER_HEADER: rendelésfej
**ORDER_HEADER** {**id**, _user_id_, _payment_type_id_, payment_status, created_at, updated_at}
Az order_header táblában **tároljuk a rendelésszámot (id), felhasználó azonosítót, fizetési módot, fizetési státuszt**. A **fizetési státusz boolean** típusú. Egy rendelés egy user-hez tartozhat. Az ORDER_HEADER → USERS és ORDER_HEADER →PAYMENT_TYPES

mező | adattípus | szerep | korlátozás |
| ------ | ------ | ------ | ------ |
id | serial(4) | PK, generált |  | 
user_id | int(4) | FK (users), kötelező |  | 
payment_type_id | int(4) | FK (payment_tpes), kötelező |  | 
payment_status | boolean | kötelező, alapért: false |  | 
created_at | timestamp | kötelező, alapért: current_timestamp |  | 
updated_at | timestamp | kötelező, alapért: current_timestamp |  | 

### ORDER_ITEMS: rendelés tételek
**ORDER_ITEMS** {**id**, **_order_header_id_, _product_id_**, quantity, created_at, updated_at}
Az order_items táblában tároljuk az adott rendeléshez tartozó tételeket. **Egy termék csak egy sorban szerepelhet**, a **rendelt mennyiség**nek **nullánál nagyobb**nak kell lennie. Az ORDER_HEADER : ORDER_ITEMS 1:N kapcsolatban vannak, így ORDER_ITEMS → ORDER_HEADER. Az ORDER_ITEMS → PRODUCTS

mező | adattípus | szerep | korlátozás |
| ------ | ------ | ------ | ------ |
id | serial(4) | PK, generált |  | 
order_header_id | int(4) | U, kötelező, FK (order_header) |  |
product_id | int(4) | U, kötelező, FK (products) |  |
quantity | quantity(4) | kötelező | quantity > 0 |  |
created_at | timestamp | kötelező, alapért: current_timestamp |  | 
updated_at | timestamp | kötelező, alapért: current_timestamp |  | 

### INVOICE: számla
**INVOICE** {**id, _order_header_id_**, total, created_at}
Az invoice táblában tároljuk a számlaszámot (id), rendelésszámot, számla végösszegét. A **rendeléseket egyesével számlázzuk**, így az INVOICE : ORDER_HEADER 1:1 kapcsolatban vannak. INVOICE  → ORDER_HEADER.

mező | adattípus | szerep | korlátozás |
| ------ | ------ | ------ | ------ |
id | serial(4) | PK, generált |  | 
order_header_id | int(4) | U, FK (order_header) |  | 
total | decimal(10, 2) |  | total >= 0 |  |
created_at | timestamp | kötelező, alapért: current_timestamp |  | 

## Egyed-kapcsolat diagram

![ Alt Text](/images/egyed_kapcsolat.png)

## Fogalmak

- Az adatbázisban szereplő táblák elsődleges kulcsa a saját, autoincrementált id-je, a természetes kulcsot/összetett természetes kulcsokat egyedinek állítjuk be.
- A created_at, updated_at mezők minden táblában, ahol szerepelnek default current_timestamp not null értéket kapnak.
- Az árak, összegek nettó árak.
- A termék, valamint a cím típusa egy szöveges besorolás. 
- A számlán tároljuk az adott rendelés végösszegét, ami a rendeléskor leadott termékárak alapján számítódik a product_price_changes tábla alapján.
- A rendelés akkor teljesíthető, ha a rendelésen szereplő termékekből van készlet 
    - és utalásos/bankkártyás fizetés esetén, ha a payment_status igaz értéket vesz fel.
- Amennyiben egy rendelés teljesíthető, akkor a generate_invoice() tárolt eljárás meghívásával automatikusan generálódnak a számla adatok.
- A számla alapja mindig 1 rendelés.
- Egy rendelésnek csak 1 user-e lehet
- A normálforma megtartása érdekében csak a product_price_changes táblában tároljuk a termék árakat. A product_price_changes táblában tárolt ár mezőből nyerjük ki a rendelés létrehozásakor érvényes árat a product_price_changes tábla price_actualisation_time mezőjének és az order_header tábla created_at mező értékének vizsgálata alapján. 
- A termékár érvénybe lépéséről az actualize_product_price() tárolt eljárás gondoskodik, ami hívható manuálisan a „call actualize_product_price()”-al, vagy időzítetten a pg_cron kiterjesztés használatának segítségével.

## Kapcsolati ábra

![ Alt Text](/images/e_shop-diagram.png)

## Megvalósítás

- alapszkriptek (create_e_shop.sql, insert_e_shop.sql): 
    - a táblák létrehozását tartalmazza az elsődleges, egyedi, illetve külső kulcsokkal
    - tartalmazza az adott mezőre vonatkozó megszorításokat
    - táblák adatokkal történő feltöltése (INSERT utasítás)
- lekérdezések (e_shop_scripts.sql)
- triggerek (triggers_e_shop.sql)
    - táblaszintű extra megszorítások
- tárolt eljárások (procedures_e_shop.sql)
    - számlaadatok legenerálása a rendelésekből adott feltételek teljesülése esetén
    - Termékár érvénybe lépése a product_price_changes tábla price_actualisation_time mező értékének frissítésével
- funkciók (functions_e_shop.sql)
    - hasznos lekérdezések függvényhívásokkal
- indexelés (index_e_shop.sql)
    - táblák indexelése a gyorsabb futás elérésének érdekében
- teszt adatbázis alapszkriptek (create_test.sql)
    - a táblák létrehozását tartalmazza az elsődleges, egyedi, illetve külső kulcsokkal
    - tartalmazza az adott mezőre vonatkozó megszorításokat
    - táblák adatokkal történő feltöltése (INSERT utasítás)
- test adatbázis indexelése és analizálása (test_analyze_index.sql)




