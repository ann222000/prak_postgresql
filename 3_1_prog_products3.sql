begin;
DROP SCHEMA IF EXISTS prog_products3 CASCADE;
CREATE SCHEMA prog_products3;

set search_path to prog_products3;

CREATE TABLE users (
	user_id SERIAL PRIMARY KEY,
	user_information jsonb NOT NULL,
	characteristic text,
	installation_count integer CHECK(installation_count >= 0),
	users_products text[]
);

CREATE TABLE programming_products (
    product_id SERIAL PRIMARY KEY,
    product_name text NOT NULL,
    product_class text
);

CREATE TABLE installations (
    installation_id SERIAL PRIMARY KEY,
    installation_updating_dates timestamp[], 
    product_id integer NOT NULL REFERENCES programming_products ON DELETE CASCADE,
    operating_system text,
	--license_key text,
	price_for_license numeric(8,2) CHECK(price_for_license >= 0),
	user_id integer NOT NULL REFERENCES users ON DELETE CASCADE
);

COPY programming_products
    FROM '/home/anna/Desktop/prak5/products.txt' WITH (FORMAT TEXT, delimiter '|');

COPY users
    FROM '/home/anna/Desktop/prak5/users.txt' WITH (FORMAT TEXT, delimiter '|');

COPY installations
    FROM '/home/anna/Desktop/prak5/installations.txt' WITH (FORMAT TEXT, delimiter '|');
	
commit;

-- set auto-commit ON
analyze;

--Select * from prog_products3.users Limit 100;
--SELECT count(*) from installations;
--SELECT count(*) from users;