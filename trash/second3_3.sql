CREATE USER test;

GRANT USAGE ON SCHEMA prog_products3 TO test;
GRANT ALL ON DATABASE prog_products3 to test;
GRANT USAGE ON FUNCTION old_users TO test;


CREATE OR REPLACE FUNCTION old_users() RETURNS TABLE(user_id integer, user_information_f json, installation_count integer, users_products text[]) AS $$
	BEGIN
	BEGIN
	SET ROLE test;
	RETURN QUERY SELECT * FROM prog_products3.users WHERE CAST(user_information->>'age' AS INTEGER) >= 50 ORDER BY user_id;
	EXCEPTION
        WHEN SQLSTATE '42501' THEN -- insufficient_privilege
            begin
            raise notice 'Not enough priveleges!';
            end;
    END;
	END;
$$
LANGUAGE plpgsql;


SELECT * FROM old_users();

SET ROLE postgres;
DROP FUNCTION old_users();