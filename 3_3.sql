CREATE OR REPLACE FUNCTION almost_adults(price_for_university_license integer DEFAULT 0) RETURNS integer[] AS $$
    DECLARE
	next_id integer = count(*) FROM prog_products3.installations;
    school_product_id integer; --= product_id FROM prog_products3.programming_products WHERE product_name = 'School';
    university_product_id integer; --= product_id FROM prog_products3.programming_products WHERE product_name = 'University';
	cursor_users CURSOR FOR SELECT user_id, user_information, users_products FROM prog_products3.users WHERE ARRAY['School'] <@ users_products and user_id < 10000;
	changed_users integer[];
	err_code text;
	msg_text text;
	exc_context text;
	BEGIN
	BEGIN
	school_product_id = product_id FROM prog_products3.programming_products WHERE product_name = 'School';
	university_product_id = product_id FROM prog_products3.programming_products WHERE product_name = 'University';
	FOR cur_row in cursor_users LOOP
	    IF CAST(cur_row.user_information->>'age' AS INTEGER) > 18 THEN
		    BEGIN
		    raise notice 'Adult with id % studies at school! He is too old for it!', cur_row.user_id; 
		    CONTINUE;
			END;
		END IF;
		IF CAST(cur_row.user_information->>'age' AS INTEGER) = 18 THEN
		    BEGIN
		    IF ARRAY['University'] <@ cur_row.users_products THEN
			    BEGIN
			    raise notice 'BAD user studies in university and at school!';
				END;
			END IF;
			next_id  = next_id + 1;
			INSERT INTO prog_products3.installations(installation_id, installation_updating_dates, product_id, price_for_license, user_id)
			VALUES
			    (next_id, ARRAY[current_date], university_product_id, price_for_university_license, cur_row.user_id);
			DELETE FROM prog_products3.installations WHERE user_id = cur_row.user_id AND product_id = university_product_id;
			changed_users = cur_row.user_id || changed_users;
		    -- insert into installations new one with university
			--delete old installation
			-- add user in list
			END;
		END IF;
	END LOOP;
	UPDATE prog_products3.users SET users_products = (ARRAY['University'] || array_remove(users_products, 'School')) WHERE (ARRAY['School'] <@ users_products and user_id < 10000)
	and CAST(user_information->>'age' AS INTEGER) = 18;
	RETURN changed_users;
	EXCEPTION
        WHEN OTHERS THEN 
		GET STACKED DIAGNOSTICS
    	err_code = RETURNED_SQLSTATE,
		msg_text = MESSAGE_TEXT,
    	exc_context = PG_CONTEXT;
   		RAISE NOTICE 'ERROR CODE: % MESSAGE TEXT: % CONTEXT: %', err_code, msg_text, exc_context;
		RETURN ARRAY[]::integer[];
	END;
	END;
$$
LANGUAGE plpgsql;


SELECT * from almost_adults();


--INSERT INTO prog_products3.programming_products VALUES(5101, 'School', 'application');