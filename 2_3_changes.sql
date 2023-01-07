--Все фримы переезжают из USA в Dubai
UPDATE prog_products.firms SET city_id = (SELECT city_id from prog_products.cities WHERE city = 'Dubai')
WHERE city_id IN (SELECT cities.city_id FROM prog_products.cities INNER JOIN prog_products.countries USING(country_id) WHERE country = 'USA');

--Проверим
SELECT *  FROM (prog_products.firms INNER JOIN prog_products.cities USING(city_id)) INNER JOIN prog_products.countries USING (country_id)
ORDER BY firm_id;

--Поднять цену на лицензию на 10 процентов на все продукты, которые были выпущены до 2019 года (включительно)
UPDATE prog_products.licenses SET price_of_license = price_of_license * 1.1 WHERE product_id IN 
(SELECT product_id FROM prog_products.programming_products WHERE date_produced < '2020-01-01');

--Проверим
SELECT  product_id, license_id, price_of_license, name, date_produced FROM (prog_products.licenses INNER JOIN prog_products.programming_products USING(product_id))
ORDER BY date_produced;

--Неправильный вариант удаления программных продуктов фирмы Broadcom Inc
--Сработает ограничения целостности
DELETE FROM prog_products.programming_products WHERE firm_id = (SELECT firm_id FROM prog_products.firms WHERE name = 'Broadcom Inc');

--Теперь удалим правильно: удалим все лицензии и инсталляции этого продукта
DELETE FROM prog_products.installations WHERE license_id IN (SELECT license_id FROM prog_products.licenses WHERE product_id IN
															(SELECT product_id FROM prog_products.programming_products
															 WHERE firm_id = (SELECT firm_id FROM prog_products.firms WHERE name = 'Broadcom Inc')));
DELETE FROM prog_products.licenses WHERE product_id IN (SELECT product_id FROM prog_products.programming_products
														WHERE firm_id = (SELECT firm_id FROM prog_products.firms WHERE name = 'Broadcom Inc'));
DELETE FROM prog_products.programming_products WHERE firm_id = (SELECT firm_id FROM prog_products.firms WHERE name = 'Broadcom Inc');							

--Проверим
SELECT product_id, programming_products.name, firm_id, firms.name FROM prog_products.programming_products INNER JOIN prog_products.firms USING(firm_id)
ORDER by product_id;

--Все пользователи-мужчины из Москвы сегодня деинсталлировали все свои программыне продукты
UPDATE prog_products.installations SET deinstallation_date = current_date WHERE user_id IN
(SELECT user_id FROM prog_products.users WHERE gender = 'M' and city_id = (SELECT city_id FROM prog_products.cities WHERE city = 'Moscow'));

--Проверим
SELECT user_id, surname, name, gender, installation_id, deinstallation_date FROM prog_products.users INNER JOIN prog_products.installations USING(user_id)
WHERE city_id = (SELECT city_id FROM prog_products.cities WHERE city = 'Moscow');
															 