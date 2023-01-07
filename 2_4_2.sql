--READ UNCOMMITTED
--потерянные изменения
set search_path to prog_products;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;  
SELECT * FROM licenses WHERE  product_id=7;								
										
UPDATE licenses set price_of_license = price_of_license + 500 where product_id=7;					
--На этой команде зависнет, чтобы не допустить потерянных изменений

ROLLBACK;				
SELECT * FROM licenses WHERE  product_id=7;	
 

--грязные чтения
set search_path to prog_products;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;


SELECT * FROM licenses WHERE  product_id=17;

COMMIT;

SELECT * FROM licenses WHERE  product_id=17;


--READ COMMITED
--грязные чтения
set search_path to prog_products;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;  

SELECT * FROM licenses WHERE  product_id=7;

COMMIT;

SELECT * FROM licenses WHERE  product_id=7;


--неповторяющиеся чтения
set search_path to prog_products;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;                                     
SELECT * FROM licenses WHERE product_id=20;

SELECT * FROM licenses WHERE product_id=20;

COMMIT;

 

--REPEATABLE READ
--неповторяющиеся чтения  
set search_path to prog_products;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM licenses WHERE product_id=7;	

SELECT * FROM licenses WHERE  product_id=7;

COMMIT;


--фантомы
set search_path to prog_products;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
--UPDATE licenses SET price_of_license = price_of_license +200 WHERE price_of_license > 500;
INSERT INTO licenses (price_of_license, product_id, license_key)
VALUES
    (230, 2, 'WEA65'),
	(700, 3, 'YBb67'),
	(900, 8, 'UYD87'),
	(1400, 12, 'PIH85'),
	(1100, 14, 'POR87');

COMMIT;


--SERIALIZABLE
--фантомы 
set search_path to prog_products;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
INSERT INTO licenses (price_of_license, product_id, license_key)
VALUES
    (230, 2, 'WEA65'),
	(700, 3, 'YBb67'),
	(900, 8, 'UYD87'),
	(1400, 12, 'PIH85'),
	(1100, 14, 'POR87');
	

COMMIT;
