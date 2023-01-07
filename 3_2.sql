--Создать пользователя test и выдать ему доступ к базе данных.
CREATE USER test;

GRANT USAGE ON SCHEMA prog_products3 TO test;
GRANT ALL ON DATABASE prog_products3 to test; 

--Выдать права SELECT UPDATE INSERT
GRANT SELECT, UPDATE, INSERT ON prog_products3.programming_products to test;
GRANT SELECT (installation_id, operating_system, product_id, installation_updating_dates), UPDATE(installation_updating_dates) ON prog_products3.installations to test;
GRANT SELECT ON prog_products3.users to test;

--Представления
CREATE OR REPLACE VIEW children AS
	SELECT * FROM prog_products3.users
	WHERE CAST (users.user_information->>'age' AS INTEGER) <= 18;
	 
CREATE OR REPLACE VIEW applications AS 
	SELECT * FROM prog_products3.programming_products 
    WHERE product_class = 'application';
	 
CREATE OR REPLACE VIEW Android_products AS 
	SELECT product_id, operating_system, product_name, product_class FROM prog_products3.installations INNER JOIN prog_products3.programming_products USING (product_id)
     WHERE operating_system = 'Android'

--Присвоить новому пользователю право доступа (SELECT) к одному из представлений
GRANT SELECT ON Android_products to test;

--Создать стандартную роль уровня базы данных, присвоить ей право доступа (UPDATE на некоторые столбцы) к одному из представлений
CREATE ROLE children_management;
GRANT UPDATE(user_information) ON children to children_management;
GRANT SELECT(user_information) ON children to children_management;

--Назначить новому пользователю созданную роль.
CREATE USER manager;
GRANT children_management TO manager;

--Выполнить от имени нового пользователя некоторые выборки из таблиц и представлений.
SET ROLE test;
SELECT count(*) FROM Android_products WHERE product_class = 'programming_tool';
SELECT * FROM prog_products3.users;
SELECT * From prog_products3.installations; -- ошибка нет доступа

SET ROLE manager;
SELECT * FROM prog_products3.users 
	WHERE CAST(users.user_information->>'age' AS INTEGER) <= 14; -- error
SELECT * FROM children
	WHERE CAST(user_information->>'age' AS INTEGER) <= 14; --  эта же информация через представление
	
--Выполнить от имени нового пользователя операторы изменения таблиц с ограниченными правами доступа. 
SET ROLE test;
DELETE FROM prog_products3.programming_products WHERE product_class = 'system_software'; --error
INSERT INTO prog_products3.programming_products VALUES
(501, 'Subway Surf', 'applictaion');
UPDATE prog_products3.installations SET operating_system = 'IpadOS' WHERE operating_system = 'IpodOS' --error


-- удаляем роли(пользователей): удаляем все права, чтобы стереть пользователя/роль
SET ROLE postgres;
DROP ROLE IF EXISTS manager;

REASSIGN OWNED BY children_management TO postgres;
REVOKE ALL ON ALL TABLES IN SCHEMA prog_products3 FROM children_management;
REVOKE ALL ON DATABASE prog_products3 FROM children_management;
REVOKE ALL ON TABLE children FROM children_management;
DROP ROLE IF EXISTS children_management;


REASSIGN OWNED BY test TO postgres;
REVOKE ALL ON ALL TABLES IN SCHEMA prog_products3 FROM test;
REVOKE ALL ON SCHEMA prog_products3 FROM test;
REVOKE ALL ON DATABASE prog_products3 FROM test;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM test;
DROP ROLE IF EXISTS test;