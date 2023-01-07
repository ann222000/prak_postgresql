--Все продукты произведенные в России, отсортированные по product_id 
SELECT * FROM prog_products.programming_products WHERE firm_id IN (SELECT firm_id from prog_products.firms WHERE city_id IN
(SELECT city_id FROM prog_products.cities WHERE country_id = (SELECT country_id from prog_products.countries WHERE country = 'Russia')))
ORDER BY product_id;


--Статистика по пользователям: их города, продукты, которыми они пользуются и фирмы, которые произвели данные продукты 
SELECT user_id, surname, users.name, city, programming_products.name, firms.name as firm FROM prog_products.users LEFT OUTER JOIN prog_products.cities USING(city_id)
LEFT OUTER JOIN prog_products.installations USING(user_id) LEFT OUTER JOIN prog_products.licenses USING(license_id) 
LEFT OUTER JOIN prog_products.programming_products USING(product_id) LEFT OUTER JOIN prog_products.firms USING(firm_id) ORDER BY user_id;
				
--Сколько пользователей пользуются ОС Windows
SELECT count(DISTINCT users.user_id) FROM prog_products.users INNER JOIN prog_products.installations USING(user_id)
                                     INNER JOIN prog_products.platforms USING(platform_id) 
									 WHERE operating_system = 'Windows';


--Все фирмы и их текущее местоположение
SELECT firm_id, name, city, country FROM prog_products.firms LEFT OUTER JOIN prog_products.cities USING (city_id) LEFT OUTER JOIN prog_products.countries
USING (country_id) ORDER BY firm_id;