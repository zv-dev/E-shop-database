CREATE TABLE users (
    id serial PRIMARY KEY,
    full_name varchar(255) NOT NULL,
    username varchar(255) NOT NULL,
    email varchar(255) UNIQUE NOT NULL,
    password varchar(255) NOT NULL,
    phone_number varchar(255) NOT NULL,
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

CREATE TABLE addresses (
    id serial,
    user_id int REFERENCES users (id) NOT NULL,
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

CREATE TABLE budapest PARTITION OF addresses FOR VALUES IN (1);
CREATE TABLE pest PARTITION OF addresses FOR VALUES IN (2);
CREATE TABLE kozep_dunantul PARTITION OF addresses FOR VALUES IN (3);
CREATE TABLE nyugat_dunantul PARTITION OF addresses FOR VALUES IN (4);
CREATE TABLE del_dunantul PARTITION OF addresses FOR VALUES IN (5);
CREATE TABLE eszak_magyarorszag PARTITION OF addresses FOR VALUES IN (6);
CREATE TABLE eszak_alfold PARTITION OF addresses FOR VALUES IN (7);
CREATE TABLE del_alfold PARTITION OF addresses FOR VALUES IN (8);

CREATE TABLE categories (
    id serial PRIMARY KEY,
    name varchar(255) UNIQUE NOT NULL,
    parent_id int,
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

CREATE TABLE products (
    id serial PRIMARY KEY,
    sku int NOT NULL,
    name varchar(255) NOT NULL,
    description varchar(255),
    product_type varchar(255) NOT NULL,
    UNIQUE (sku, product_type),
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

CREATE TABLE product_categories (
    id serial PRIMARY KEY,
    category_id int REFERENCES categories (id) NOT NULL,
    product_id int REFERENCES products (id) NOT NULL,
    UNIQUE (category_id, product_id),
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

CREATE TABLE product_stock (
    id serial PRIMARY KEY,
    product_id int REFERENCES products (id) NOT NULL,
    quantity int NOT NULL CONSTRAINT positive_quantity CHECK (quantity >= 0),
    UNIQUE (product_id, quantity),
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

CREATE TABLE product_price_changes(
    id serial PRIMARY KEY,
    product_id int REFERENCES products (id) NOT NULL,
    from_date date NOT NULL,
    price decimal (10, 2) NOT NULL CONSTRAINT positive_product_price_changes CHECK (price >= 0),
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    price_actualisation_time timestamp
);

CREATE TABLE attributes (
    id serial PRIMARY KEY,
    name varchar(255) UNIQUE NOT NULL,
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

CREATE TABLE attr_values (
    id serial PRIMARY KEY,
    val varchar(255) UNIQUE NOT NULL,
    attr_id int REFERENCES attributes (id) NOT NULL,
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

CREATE TABLE product_attr_values (
    id serial PRIMARY KEY,
    attr_values_id int REFERENCES attr_values (id) NOT NULL,
    product_id int REFERENCES products (id) NOT NULL,
    UNIQUE (attr_values_id, product_id),
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

CREATE TABLE payment_types (
    id serial PRIMARY KEY,
    name varchar(255) UNIQUE NOT NULL,
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

CREATE TABLE order_header (
    id serial PRIMARY KEY,
    user_id int REFERENCES users (id) NOT NULL,
    payment_type_id int REFERENCES payment_types (id) NOT NULL,
    payment_status boolean NOT NULL DEFAULT 'false',
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

CREATE TABLE order_items (
    id serial PRIMARY KEY,
    order_header_id int REFERENCES order_header (id) NOT NULL,
    product_id int REFERENCES products (id) NOT NULL,
    quantity int NOT NULL CONSTRAINT positive_ordered_quantity CHECK (quantity > 0) NOT NULL,
    UNIQUE (order_header_id, product_id),
    created_at timestamp DEFAULT current_timestamp NOT NULL,
    updated_at timestamp DEFAULT current_timestamp NOT NULL
);

CREATE TABLE invoice (
    id serial PRIMARY KEY,
    order_header_id int REFERENCES order_header (id) NOT NULL,
    UNIQUE (order_header_id), 
    total decimal(10, 2) NOT NULL CONSTRAINT positive_total_invoice CHECK (total >= 0),
    created_at timestamp DEFAULT current_timestamp NOT NULL
);