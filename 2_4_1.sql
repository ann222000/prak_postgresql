--Установить в обоих сеансах уровень изоляции READ UNCOMMITTED. Выполнить
--сценарии проверки наличия аномалий потерянных изменений и грязных чтений.

--READ UNCOMMITTED, в postgresql совпадаетс READ COMMITTED
--потерянные изменения (не допускается)
set search_path to prog_products;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
                                          
UPDATE licenses set price_of_license = price_of_license + 600 where product_id=7;
                                                        
COMMIT; 

--грязные чтения(невозможно в postgresql)
set search_path to prog_products;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
                                          
UPDATE licenses SET price_of_license = price_of_license * 1.1 WHERE product_id=17;

ROLLBACK;

SELECT * FROM licenses WHERE  product_id=17;



--Установить в обоих сеансах уровень изоляции READ COMMITTED. Выполнить
--сценарии проверки наличия аномалий грязных чтений и неповторяющихся чтений


--READ COMMITED
--грязные чтения(невозможно)
set search_path to prog_products;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
                                          
UPDATE licenses SET price_of_license = price_of_license + 100 WHERE product_id=7;

ROLLBACK;
                                                                
SELECT * FROM licenses WHERE  product_id=7;


--неповторяющиеся чтения(возможны)
set search_path to prog_products;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION; 

UPDATE licenses SET price_of_license = price_of_license - 500 where product_id=20;                                                 
COMMIT;

 --Установить в обоих сеансах уровень изоляции REPEATABLE READ. Выполнить
--сценарии проверки наличия аномалий неповторяющихся чтений и фантомов.


--REPEATABLE READ
--неповторяющиеся чтения  
set search_path to prog_products;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;                                     

UPDATE licenses SET price_of_license = 500 where product_id=7;
                                                       
COMMIT;                                              
                                        
--фантомы 
set search_path to prog_products;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM licenses WHERE price_of_license > 500;

SELECT * FROM licenses WHERE price_of_license > 500;
                                                        
COMMIT;
SELECT * FROM licenses WHERE price_of_license > 500;


--Установить в обоих сеансах уровень изоляции SERIALIZABLE. Выполнить сценарий
--проверки наличия фантомов.


--В postgresql фантомное чтение недопустимо и в REPEATABLE READ, и в SERIALIZABLE
--SERIALIZABLE
--фантомы
set search_path to prog_products;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT * FROM licenses WHERE price_of_license > 500;

SELECT * FROM licenses WHERE price_of_license > 500;
                                                        
COMMIT;
SELECT * FROM licenses WHERE price_of_license > 500;
