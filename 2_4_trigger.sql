set search_path to prog_products;
--Триггер срабатывают перед удалением строк таблицы programming_products, удаляет строки соответствующие этому
--продукту в других таблицах и не позволяет удалить системное ПО

DROP TRIGGER IF EXISTS delete_product_wherever on programming_products;

CREATE OR REPLACE FUNCTION delete_product_wherever() RETURNS trigger AS $delete_product_wherever$
    BEGIN
	    IF OLD.product_class = 'system software' THEN
                RAISE NOTICE 'You can not delete this product!'
				USING HINT = 'Check correcteness of product name!';
				RETURN NULL;
        END IF;
	    DELETE FROM installations WHERE license_id IN (SELECT license_id FROM licenses WHERE product_id = OLD.product_id);
        DELETE FROM licenses WHERE product_id = OLD.product_id;
        RETURN OLD;
    END;
$delete_product_wherever$ LANGUAGE plpgsql;

CREATE TRIGGER delete_product_wherever BEFORE DELETE ON programming_products
     FOR EACH ROW EXECUTE FUNCTION delete_product_wherever();

-- проверка триггера: Изменение данных для сохранения целостности

set search_path to prog_products;

DELETE FROM programming_products WHERE firm_id = (SELECT firm_id FROM firms WHERE name = 'Broadcom Inc');
SELECT product_id, programming_products.name AS product, firms.name AS firm, installation_id FROM programming_products
FULL OUTER JOIN licenses USING(product_id) FULL OUTER JOIN installations USING(license_id)
FULL OUTER JOIN firms USING(firm_id) ORDER BY product_id;

--проверка триггера: Проверка транзакций
--START TRANSACTION;
DELETE FROM programming_products;
SELECT * FROM programming_products LEFT OUTER JOIN licenses USING(product_id) LEFT OUTER JOIN installations USING(license_id);
--COMMIT;