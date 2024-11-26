CREATE TABLE test_users (
    id serial PRIMARY KEY,
    full_name varchar(255) NOT NULL,
    username varchar(255) NOT NULL,
    email varchar(255) UNIQUE NOT NULL,
    password varchar(255) NOT NULL,
    phone_number varchar(255) NOT NULL,
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

--test_users tábla adatai*********************************************************************************

INSERT INTO test_users (full_name, username, email, password, phone_number, created_at, updated_at)
	SELECT
		left(md5(random()::varchar), 15),
		left(md5(random()::varchar), 10),
		--left(md5(CAST(generate_series AS varchar)), 8),
		'user' || generate_series || '@' || 'domain.com',
		left(md5(random()::varchar), 10),
		--left(md5(random()::varchar), 10),
		'+36' || regexp_replace(CAST (random() AS text),'^0\.(\d{2})(\d{3})(\d{4}).*$','-\1-\2-\3'),
		to_timestamp(1673478000 + generate_series * 5600),
		to_timestamp(1673478000 + generate_series * 5600)
	FROM generate_series(1, 12500);

--*********************************************************************************************************************************************************

CREATE TABLE test_addresses (
	id serial,
	user_id int REFERENCES test_users (id) NOT NULL,
	address_type varchar(20) NOT NULL,
	country_code varchar(10) NOT NULL,
	region_id int NOT NULL,
	city varchar(255) NOT NULL,
	zip_code varchar(10) NOT NULL,
	street_name varchar(255) NOT NULL,
	house_number int NOT NULL,
	created_at timestamp DEFAULT current_timestamp NOT NULL,
    PRIMARY KEY (id, region_id)
) PARTITION by list (region_id);

CREATE TABLE budapest PARTITION OF test_addresses for values in (1);
CREATE TABLE pest PARTITION OF test_addresses for values in (2);
CREATE TABLE kozep_dunantul PARTITION OF test_addresses for values in (3);
CREATE TABLE nyugat_dunantul PARTITION OF test_addresses for values in (4);
CREATE TABLE del_dunantul PARTITION OF test_addresses for values in (5);
CREATE TABLE eszak_magyarorszag PARTITION OF test_addresses for values in (6);
CREATE TABLE eszak_alfold PARTITION OF test_addresses for values in (7);
CREATE TABLE del_alfold PARTITION OF test_addresses for values in (8);

--test_addresses tábla adatai*********************************************************************************

INSERT INTO test_addresses (user_id, address_type, country_code, region_id, city, zip_code, street_name, house_number, created_at)
	SELECT
		generate_series,
		CASE
			WHEN random() <= 0.6 THEN 'számlázási'
			ELSE 'szállítási'			
		END,
		CASE
			WHEN random() <=1 THEN 'HU'
		END,
		CASE
			WHEN random() <= 0.2 THEN 1
			WHEN random() <= 0.3 THEN 2
			WHEN random() <= 0.4 THEN 3
			WHEN random() <= 0.5 THEN 4
			WHEN random() <= 0.6 THEN 5
			WHEN random() <= 0.7 THEN 6
			WHEN random() <= 0.9 THEN 7
		ELSE 8					
		END,
		left(md5(random()::varchar), 20),
		left(md5(random()::varchar), 10),
		left(md5(random()::varchar), 20),
		random() * 1000,
		to_timestamp(1673478000 + generate_series * 5600)
	FROM generate_series(1, 12000);


--*********************************************************************************************************************************************************

CREATE TABLE test_categories (
	id serial PRIMARY KEY,
	name varchar(255) UNIQUE NOT NULL,
	parent_id int,
	created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);
	
--test_categories adatai*********************************************************************************

INSERT INTO test_categories (name, parent_id, created_at, updated_at)
	SELECT
		left(md5(random()::varchar), 20),
		random () * 1000,
		to_timestamp(1673478000 + generate_series * 5600),
		to_timestamp(1673478000 + generate_series * 5600)
	FROM generate_series(1, 13000);

--*********************************************************************************************************************************************************

CREATE TABLE test_products (
    id serial PRIMARY KEY,
    sku int NOT NULL,
    name varchar(255) NOT NULL,
    description varchar(255),
	product_type varchar(255) NOT NULL,
	UNIQUE (sku, product_type),
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);
	
--test_products tábla adatai*********************************************************************************

INSERT INTO test_products (sku, name, description, product_type, created_at, updated_at)
	SELECT
		generate_series,
		CASE
			WHEN random() <= 0.01 THEN 'Szállítási költség'
			ELSE left(md5(random()::varchar), 50)
		END,
		CASE 
			WHEN random() <= 0.01 THEN 'Személyes átvétel'
			WHEN random() <= 0.03 THEN 'GLS házhozszállítás - átutalás/bankkártya'
			WHEN random() <= 0.04 THEN 'GLS házhozszállítás - utánvét'
			WHEN random() <= 0.05 THEN 'GLS házhozszállítás - átutalás/bankkártya'
			WHEN random() <= 0.05 THEN 'Magyar Posta házhozszállítás - átutalás/bankkártya'
			WHEN random() <= 0.06 THEN 'Magyar Posta házhozszállítás - utánvét'
			ELSE left(md5(random()::varchar), 50)
		END,		
		CASE 
			WHEN random() <= 0.1 THEN 'Szolgáltatás'
			ELSE 'Termék'
		END,
		to_timestamp(1673478000 + generate_series * 5600),
		to_timestamp(1673478000 + generate_series * 5600)
	FROM generate_series(1, 13000);


--*********************************************************************************************************************************************************
	
CREATE TABLE test_product_categories (
	id serial PRIMARY KEY,
	category_id int REFERENCES test_categories (id) NOT NULL,
	product_id int REFERENCES test_products (id) NOT NULL,
	UNIQUE (category_id, product_id),
	created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

--test_product_categories tábla adatai*********************************************************************************

INSERT INTO test_product_categories (category_id, product_id, created_at, updated_at)
	SELECT
		generate_series,
		generate_series,
		to_timestamp(1673478000 + generate_series * 5600),
		to_timestamp(1673478000 + generate_series * 5600)
	FROM generate_series(1, 13000);
		
--*********************************************************************************************************************************************************

CREATE TABLE test_product_stock (
	id serial PRIMARY KEY,
	product_id int REFERENCES test_products (id) NOT NULL,
	quantity int NOT NULL CONSTRAINT positive_quantity CHECK (quantity >= 0),
	UNIQUE (product_id, quantity),
	created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

--test_product_stock tábla adatai*********************************************************************************

INSERT INTO test_product_stock (product_id, quantity, created_at, updated_at)
	SELECT
		generate_series,
		random() * 100,
		to_timestamp(1673478000 + generate_series * 5600),
		to_timestamp(1675810800 + generate_series * 5370)
	FROM generate_series(1, 13000);
	
--*********************************************************************************************************************************************************	
	
CREATE TABLE test_product_price_changes (
	id serial PRIMARY KEY,
	product_id int REFERENCES test_products (id) NOT NULL,
	from_date date NOT NULL,
	price decimal (10, 2) NOT NULL CONSTRAINT positive_product_price_changes CHECK (price >= 0),
	created_at timestamp DEFAULT current_timestamp NOT NULL,
	price_actualisation_time timestamp
);


--test_product_price tábla adatai*********************************************************************************

INSERT INTO test_product_price_changes (product_id, from_date, price, created_at, price_actualisation_time)
	SELECT
		generate_series,
		to_timestamp(1673478000 + generate_series * 5600),
		random() * 10000,
		to_timestamp(1673478000 + generate_series * 5600),
		to_timestamp(1673478000 + generate_series * 5600)
	FROM generate_series(1, 13000);
		
--*********************************************************************************************************************************************************

CREATE TABLE test_attributes (
   id serial PRIMARY KEY,
   name varchar(255) UNIQUE NOT NULL,
   created_at timestamp DEFAULT current_timestamp NOT NULL,
   updated_at timestamp DEFAULT current_timestamp NOT NULL
);

--test_attributes tábla adatai*********************************************************************************

INSERT INTO test_attributes (name, created_at, updated_at)
	SELECT
		left(md5(random()::varchar), 15),
		to_timestamp(1673478000 + generate_series * 5600),
		to_timestamp(1673478000 + generate_series * 5600)
	FROM generate_series(1, 13000);

--*********************************************************************************************************************************************************

CREATE TABLE test_attr_values (
    id serial PRIMARY KEY,
    val varchar(255) UNIQUE NOT NULL,
    attr_id int REFERENCES test_attributes (id) NOT NULL,
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

--test_attr_values tábla adatai*********************************************************************************

INSERT INTO test_attr_values (attr_id, val, created_at, updated_at)
	SELECT
		generate_series,
		left(md5(random()::varchar), 15),
		to_timestamp(1673478000 + generate_series * 5600),
		to_timestamp(1673478000 + generate_series * 5600)
	FROM generate_series(1, 13000);

--*********************************************************************************************************************************************************

CREATE TABLE test_product_attr_values (
    id serial PRIMARY KEY,
    attr_values_id int REFERENCES test_attr_values (id) NOT NULL,
    product_id int REFERENCES test_products (id) NOT NULL,
    UNIQUE (attr_values_id, product_id),
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

--test_product_attr_values tábla adatai*********************************************************************************

insert  into test_product_attr_values (attr_values_id, product_id, created_at, updated_at)
	SELECT
		generate_series,
		generate_series,
		to_timestamp(1673478000 + generate_series * 5600),
		to_timestamp(1673478000 + generate_series * 5600)
	FROM generate_series(1, 13000);

--*********************************************************************************************************************************************************

CREATE TABLE test_payment_types (
	id serial PRIMARY KEY,
	name varchar(255) UNIQUE NOT NULL,
	created_at timestamp DEFAULT current_timestamp NOT NULL,
	updated_at timestamp DEFAULT current_timestamp NOT NULL
);

--test_payment_types tábla adatai*********************************************************************************

INSERT INTO test_payment_types (name, created_at, updated_at)
	SELECT
		CASE 
			WHEN random() = 0.01 THEN 'készpénz'
			WHEN random() = 0.02 THEN 'bankkártya'
			WHEN random() = 0.03 THEN 'utánvét'
			WHEN random() = 0.04 THEN 'átutalás'
			ELSE left(md5(random()::varchar), 20)
		END,
		to_timestamp(1673478000 + generate_series * 5600),
		to_timestamp(1673478000 + generate_series * 5600)
	FROM generate_series(1, 50);


--*********************************************************************************************************************************************************

CREATE TABLE test_order_header (
	id serial PRIMARY KEY,
	user_id int REFERENCES test_users (id) NOT NULL,
	payment_type_id int REFERENCES test_payment_types (id) NOT NULL,
	payment_status boolean NOT NULL DEFAULT 'false',
	created_at timestamp DEFAULT current_timestamp NOT NULL,
	updated_at timestamp DEFAULT current_timestamp NOT NULL
);

--test_order_header tábla adatai*********************************************************************************

INSERT INTO test_order_header (user_id, payment_type_id, payment_status, created_at, updated_at )
	SELECT
		generate_series,
		(49 * random())::int +1 r_num,
		CASE 
			WHEN random() <= 0.4 THEN TRUE
			ELSE FALSE
		END,
		to_timestamp(1691100000 + generate_series * 3840),
		to_timestamp(1691100000 + generate_series * 3840)
	FROM generate_series(1, 12000);


--*********************************************************************************************************************************************************

CREATE TABLE test_order_items (
	id serial PRIMARY KEY,
	order_header_id int REFERENCES test_order_header (id) NOT NULL,
	product_id int REFERENCES test_products (id) NOT NULL,
	quantity int NOT NULL CONSTRAINT positive_ordered_quantity CHECK (quantity > 0) NOT NULL,
	UNIQUE (order_header_id, product_id),
	created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

--test_order_items tábla adatai*********************************************************************************

INSERT INTO test_order_items (order_header_id, product_id, quantity, created_at, updated_at)
	SELECT
		generate_series,
		generate_series,
		random() * 100 + 1,
		to_timestamp(1691100000 + generate_series * 3840),
		to_timestamp(1691100000 + generate_series * 3840)
	FROM generate_series(1, 12000);

--*********************************************************************************************************************************************************

CREATE TABLE test_invoice (
	id serial PRIMARY KEY,
	order_header_id int REFERENCES test_order_header (id) NOT NULL,
	UNIQUE (order_header_id), 
	total int NOT NULL CONSTRAINT positive_total_invoice CHECK (total >= 0),
	created_at timestamp DEFAULT current_timestamp NOT NULL
);

--test_invoice tábla adatai*********************************************************************************

INSERT INTO test_invoice (order_header_id, total, created_at)
	SELECT
		generate_series,
		random() * 100000,
		to_timestamp(1691272800 + generate_series * 3820)
	FROM generate_series(1, 10000);	






