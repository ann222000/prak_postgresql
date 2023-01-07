DROP SCHEMA IF EXISTS prog_products CASCADE;
CREATE SCHEMA prog_products;

DROP TYPE IF EXISTS gender_type;
CREATE TYPE gender_type AS ENUM ('F', 'M');
DROP TYPE IF EXISTS user_type_type; 
CREATE TYPE user_type_type AS ENUM('Legal entity', 'Natural person');
DROP TYPE IF EXISTS prog_products.product_class_type;
CREATE TYPE prog_products.product_class_type AS ENUM ('system software', 'programming toolkit', 'application programms');
DROP TYPE IF EXISTS installation_type_type;
CREATE TYPE installation_type_type AS ENUM ('manually', 'silent intallation', 'automatic', 'remote', 'pure', 'direct');

CREATE TABLE prog_products.countries (
    country_id SERIAL PRIMARY KEY,
    country text NOT NULL
);

CREATE TABLE prog_products.cities (
    city_id SERIAL PRIMARY KEY,
    city text NOT NULL,
    country_id integer NOT NULL REFERENCES prog_products.countries
);

CREATE TABLE prog_products.firms (
    firm_id SERIAL PRIMARY KEY,
    name text NOT NULL,
    ammount_of_workers integer CHECK(ammount_of_workers >= 1 AND ammount_of_workers <=1000000),
	city_id integer REFERENCES prog_products.cities
);

CREATE TABLE prog_products.type_of_usage (
	type_id SERIAL PRIMARY KEY,
	user_type user_type_type NOT NULL,
	aim_of_usage text
);

CREATE TABLE prog_products.programming_products (
    product_id SERIAL PRIMARY KEY,
    name text NOT NULL,
    firm_id integer NOT NULL REFERENCES prog_products.firms,
    date_produced date CHECK(date_produced <= current_date),
    product_class prog_products.product_class_type NOT NULL
);

CREATE TABLE prog_products.users (
	user_id SERIAL PRIMARY KEY,
	surname text NOT NULL,
	name text NOT NULL,
	gender gender_type,
	city_id integer REFERENCES prog_products.cities,
	type_id integer REFERENCES prog_products.type_of_usage
);

CREATE TABLE prog_products.platforms (
    platform_id SERIAL PRIMARY KEY,
    operating_system text NOT NULL,
	OS_version varchar(10)
);

	
CREATE TABLE prog_products.licenses (
    license_id SERIAL PRIMARY KEY,
    price_of_license numeric(8,2) CHECK(price_of_license >= 0),
    product_id integer NOT NULL REFERENCES prog_products.programming_products,
	license_key text NOT NULL
);

CREATE TABLE prog_products.installations (
    installation_id SERIAL PRIMARY KEY,
	installation_type installation_type_type NOT NULL,
	installation_date date NOT NULL CHECK(installation_date <= current_date),
	deinstallation_date date CHECK(deinstallation_date <= current_date),
	license_id integer NOT NULL CONSTRAINT license_const REFERENCES prog_products.licenses,
	price_for_help_with_installation numeric(8,2) CHECK(price_for_help_with_installation > 0),
	user_id integer NOT NULL REFERENCES prog_products.users,
	platform_id integer NOT NULL REFERENCES prog_products.platforms
);

INSERT INTO prog_products.countries (country)
VALUES
    ('Russia'),
	('France'),
	('Italy'),
	('UAE'),
	('Turkey'),
	('Spain'),
	('Georgia'),
	('Egypt'),
	('Ukraine'),
	('USA');

INSERT INTO prog_products.cities (city, country_id)
VALUES
    ('Moscow', 1),
	('Rostov-on-Don', 1),
	('Tula', 1),
	('Paris', 2),
	('Rome', 3),
	('Venice', 3),
	('Dubai', 4),
	('Abu-Dhabi', 4),
	('Ankara', 5),
	('Antalya', 5),
	('Belek', 5),
	('Barcelona', 6),
	('Madrid', 6),
	('Lion', 6),
	('Tbilisi', 7),
	('Batumi', 7),
	('Hurgada', 8),
	('Kyiv', 9),
	('Odessa', 9),
	('Washington', 10),
	('California', 10);

INSERT INTO prog_products.firms (name, ammount_of_workers, city_id)
VALUES
    ('IBM', 1000, 3),
	('Aplle', 10027, 7),
	('Amazon', 20000, 12),
	('Walmart', 30000, 15),
	('Alphabet', 1000, 1),
	('Samsung Group', 1600, 20),
	('Meta Platforms', 1800, 19),
	('Cisco System', 1980, 17),
	('Oracle Corporation', 2900, 8),
	('Broadcom Inc', 2100, 9),
	('SAP', 107000, 12),
	('Accenture', 710000, 15),
	('Salesforce', 73500, 13),
	('Adobe', 26000, 19),
	('Intuit', 14200, 20),
	('Capgemini', 340700, 4),
	('VMware', 37500, 21),
	('Uber Technologies Inc', 29300, 1),
	('Shopify', 10000, 10),
	('Zoom Video Communication', 6787, 11),
	('Synopsys', 16000, 12),
	('Atlassian', 8813, 16);
	
INSERT INTO prog_products.type_of_usage (user_type, aim_of_usage)
VALUES
    ('Legal entity', 'money manegement'),
	('Legal entity', 'planning'),
	('Legal entity', 'office communication'),
	('Legal entity', 'information keeping'),
	('Natural person', 'entertainment'),
	('Natural person', 'work'),
	('Natural person', 'watching films'),
	('Natural person', 'listenning music'),
	('Natural person', 'reading'),
	('Natural person', 'searching information');

INSERT INTO prog_products.platforms (operating_system, OS_version)
VALUES
    ('Windows', '10.1'),
	('Ubuntu', '20.0.4'),
	('Ubuntu', '16.0.3'),
	('Fedora', '11.5'),
	('Windows', '7.1'),
	('macOS', '3.2'),
	('IOS', '16.0.2'),
	('IOS', '16.0.0'),
	('IpadOS', '15.7'),
	('Android', '11.9'),
	('Manjaro', '12.4'),
	('Manjaro', '11.6');

INSERT INTO prog_products.users (surname, name, gender, city_id, type_id)
VALUES
    ('Биктимиров', 'Михаил', 'M', 5, 2),
    ('Гнилозуб-Волобуев', 'Никита', 'M', 8, 3),
    ('Давыденко', 'Георгий', 'M', 7, 4),
    ('Егоров', 'Илья', 'M', 9, 5),
    ('Ильичев', 'Дмитрий', 'M', 1, 7),
    ('Казанцева', 'Варвара', 'F', 12, 6),
    ('Карпов', 'Андрей', 'M', 13, 1),
    ('Капранов', 'Степан', 'M', 14, 2),
    ('Конев', 'Артем', 'M', 15, 10),
	('Майоров', 'Егор', 'M', 17, 9),
	('Рычкова', 'Любовь', 'F', 20, 8),
	('Рябыкин', 'Владислав', 'M', 16, 2),
	('Сорокин', 'Даниил', 'M', 3, 1),
	('Шабанов', 'Валентин', 'M', 7, 6),
	('Водяный', 'Андрей', 'M', 11, 7),
	('Зелинский', 'Андрей', 'M', 1, 8),
	('Кочармин', 'Михаил', 'M', 1, 9),
	('Хачатрян', 'Микаэл', 'M', 2, 3),
	('Атабеков', 'Ибрагим', 'M', 3, 10),
	('Бедрин', 'Павел', 'M', 4, 4),
	('Болотин', 'Константин', 'M', 13, 8),
	('Борина', 'Ирина', 'F', 19, 7),
	('Милиенков', 'Антон', 'M', 20, 6),
	('Русанов', 'Антон', 'M', 5, 2);
	



INSERT INTO prog_products.programming_products (name, firm_id, date_produced, product_class)
VALUES
    ('TCL Dev Kit', 8, '2020-06-05', 'programming toolkit'),
	('GTK+', 10, '2018-03-09', 'programming toolkit'),
	('Perl Dev Kit', 12, '2015-04-23', 'programming toolkit'),
	('Arabica', 13, '2017-12-09', 'programming toolkit'),
	('Mobile Robot Programming Toolkit', 19, '2016-07-18', 'programming toolkit'),
	('Aesop', 20, '2017-04-24', 'programming toolkit'),
	('Amulet', 7, '2021-09-08', 'programming toolkit'),
	('VScode', 21, '2019-07-12', 'programming toolkit'),
	('Cypress', 18, '2020-08-17', 'programming toolkit'),
	('Git', 20, '2012-09-15', 'programming toolkit'),
	('Docker', 15, '2018-11-11', 'programming toolkit'),
	('Subway surf', 12, '2013-10-12', 'application programms'),
	('Clash of clans', 14, '2012-11-17', 'application programms'),
	('Geometric Dash', 16, '2014-10-25', 'application programms'),
	('Google Translator', 20, '2013-02-12', 'application programms'),
	('VK', 7, '2010-03-14', 'application programms'),
	('MT', 4, '2015-01-19', 'application programms'),
	('Zenly', 2, '2019-02-16', 'application programms'),
	('Thunar', 9, '2017-09-14','system software'),
	('Wondows', 10, '2006-11-28', 'application programms'),
	('Xbox system software', 11, '2010-06-16', 'system software');

INSERT INTO prog_products.licenses (price_of_license, product_id, license_key)
VALUES
    (2300, 20, 'AAA65'),
	(100, 8, 'AAb67'),
	(200, 9, 'ASD87'),
	(300, 6, 'JJH85'),
	(400, 7, 'AER87'),
	(439, 10, 'KJH99'),
	(298, 12, 'KJY87'),
	(312.23, 13, 'LOI97'),
	(458.9, 14, 'PP74'),
	(512.19, 1, 'AAQ54'),
	(516.15, 2, 'NBV66'),
	(633.98, 3, 'POK89'),
	(782.17, 4, 'WQE45'),
	(987, 5, 'KMN72'),
	(1002.19, 11, 'KKL98'),
	(112.5, 15, 'PPL11'),
	(114.67, 16, 'BVC65'),
	(283.17, 17, 'LDS34'),
	(345.78, 19, 'TRE14'),
	(429.72, 18, 'RTG86');
	
INSERT INTO prog_products.installations (installation_type, installation_date, deinstallation_date, license_id, price_for_help_with_installation, user_id, platform_id)
VALUES
    ('manually', '2020-12-18', NULL, 2, 76.5, 1, 1),
	('silent intallation', '2020-11-11', NULL, 4, 23.3, 3, 3),
	('automatic', '2019-12-09', NULL, 6, 24, 5, 6),
	('remote', '2021-10-19', NULL, 8, 25.7, 7, 9),
	('pure', '2021-09-13', NULL, 10, 58.9, 9, 11),
	('direct', '2022-06-17', NULL, 12, 13.7, 11, 2),
	('manually', '2022-07-28', NULL, 14, 15.2, 13, 4),
	('silent intallation', '2019-08-12', NULL, 16, 16.11, 15, 5),
	('automatic', '2019-03-12', NULL, 18, 100, 17, 7),
	('remote', '2017-09-23', NULL, 20, 12.3, 19, 8),
	('pure', '2022-03-14', NULL, 1, 18.9, 21, 10),
	('direct', '2022-02-23', NULL, 3, 19.6, 20, 1),
	('manually', '2022-09-28', NULL, 5, 15.7, 18, 7),
	('silent intallation', '2022-05-17', NULL, 7, 9.99, 16, 3),
	('automatic', '2021-03-19', NULL, 9, 19.99, 14, 9),
	('remote', '2021-09-28', NULL, 11, 29.99, 12, 5),
	('pure', '2022-03-30', NULL, 13, 29, 10, 4),
	('direct', '2021-08-30', NULL, 15, 37, 8, 8),
	('manually', '2022-08-30', NULL, 17, 15.55, 6, 7),
	('silent intallation', '2022-09-15', NULL, 19, 13.14, 4, 5);
	
	
	


CREATE TABLE prog_products.installation_license (
    installation_id integer NOT NULL REFERENCES prog_products.installations ON DELETE CASCADE,
    license_id integer NOT NULL REFERENCES prog_products.licenses ON DELETE RESTRICT,
    PRIMARY KEY (installation_id, license_id)

);

INSERT INTO prog_products.installation_license (installation_id, license_id)
SELECT installation_id, license_id FROM prog_products.installations;

ALTER TABLE prog_products.installations DROP CONSTRAINT license_const;

--ALTER TABLE IF EXISTS prog_products.installations
--DROP COLUMN IF EXISTS license_id;

-- CREATE OR REPLACE FUNCTION several_licenses() RETURNS trigger AS $several_licenses$
--     BEGIN
--         IF 
--                 NEW.category <> 'оборудование для добычи' 
--             and 
--                 NEW.category <> 'транспорт'
--             THEN
--                 RAISE EXCEPTION 'wrong category!';
--         END IF;
--         RETURN NEW;
--     END;
-- $several_licenses$ LANGUAGE plpgsql;

-- DROP TRIGGER IF EXISTS several_licenses on prog_products.installations;

-- CREATE TRIGGER prog_products.installations
--     INSTEAD OF INSERT OR UPDATE ON prog_products.installations
--     FOR EACH ROW EXECUTE FUNCTION several_licenses();

CREATE or REPLACE VIEW prog_products.installations AS
    SELECT installation_id, installation_type, installation_date, deinstallation_date , prog_products.installation_license.license_id,
    price_for_help_with_installation,
   user_id, platform_id  FROM prog_products.installations INNER JOIN prog_products.installation_license USING(installation_id);
 
-- CREATE RULE "_RETURN" AS ON SELECT TO prog_products.installations
--   DO INSTEAD SELECT installation_id, installation_type, installation_date, deinstallation_date , prog_products.installation_license.license_id,
--   price_for_help_with_installation,
--   user_id, platform_id from prog_products.installations 
--   INNER JOIN prog_products.installation_license  USING(installation_id);

-- SELECT * from prog_products.installations;

--создаем триггер что при обращение к колонки лицензий в таблице инсталляций вместо этого будет обращение к этой колонке новой таблицы

