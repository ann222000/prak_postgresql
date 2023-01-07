set search_path to prog_products;


CREATE OR REPLACE FUNCTION entity_checker() RETURNS trigger AS $entity_checker$
    BEGIN
        -- сумма юнитов меньше 
        IF 
                NEW.user_type <> 'Legal entity'
            and 
                NEW.user_type <> 'Natural person'
            THEN
                RAISE EXCEPTION 'Wrong type!';
        END IF;
        RETURN NEW;
    END;
$entity_checker$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS entity_checker on type_of_usage;

CREATE CONSTRAINT TRIGGER entity_checker 
    AFTER INSERT OR UPDATE ON type_of_usage
    FOR EACH ROW
    EXECUTE FUNCTION entity_checker();


-- проверка триггера:

set search_path to prog_products;

select * from type_of_usage;
insert into type_of_usage (user_type, aim_of_usage) values ('Legal entity', 'money earn');
select * from type_of_usage;


set search_path to prog_products;
begin;
insert into type_of_usage (user_type, aim_of_usage) values ('Animal', 'money earn');
select * from type_of_usage;
-- ничего нельзя будет сделать до rollback