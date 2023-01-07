SET enable_seqscan TO on;
--array
DROP INDEX IF EXISTS prog_products3.study_products;

EXPLAIN ANALYZE SELECT * FROM prog_products3.users WHERE ARRAY['School', 'University'] <@ users_products ORDER BY user_id;
"Gather  (cost=1000.00..65712.63 rows=403 width=435) (actual time=2.996..771.832 rows=370 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on users  (cost=0.00..64672.33 rows=168 width=435) (actual time=11.459..738.889 rows=123 loops=3)"
"        Filter: ('{School,University}'::text[] <@ users_products)"
"        Rows Removed by Filter: 333210"
"Planning Time: 7.471 ms"
"Execution Time: 771.934 ms"


CREATE INDEX study_products ON prog_products3.users USING GIN(users_products);
--Query returned successfully in 7 secs 490 msec.

EXPLAIN ANALYZE SELECT * FROM prog_products3.users WHERE ARRAY['School', 'University'] <@ users_products ORDER BY user_id;
"Bitmap Heap Scan on users  (cost=59.12..1573.00 rows=403 width=435) (actual time=1.392..1.624 rows=370 loops=1)"
"  Recheck Cond: ('{School,University}'::text[] <@ users_products)"
"  Heap Blocks: exact=370"
"  ->  Bitmap Index Scan on study_products  (cost=0.00..59.02 rows=403 width=0) (actual time=1.358..1.358 rows=370 loops=1)"
"        Index Cond: (users_products @> '{School,University}'::text[])"
"Planning Time: 0.525 ms"
"Execution Time: 1.844 ms"

EXPLAIN ANALYZE SELECT * FROM prog_products3.users where user_id=100;

--Full text and several tables index gin for full text
EXPLAIN ANALYZE SELECT * FROM prog_products3.installations LEFT JOIN prog_products3.users using(user_id) 
WHERE  to_tsvector('russian', characteristic) @@ to_tsquery('Лучший') and operating_system = 'Ubuntu';
"Gather  (cost=275775.16..512435.09 rows=107788 width=520) (actual time=6997.111..7174.336 rows=111072 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Hash Join  (cost=274775.16..500656.29 rows=44912 width=520) (actual time=6965.848..7082.585 rows=37024 loops=3)"
"        Hash Cond: (installations.user_id = users.user_id)"
"        ->  Parallel Seq Scan on installations  (cost=0.00..208883.80 rows=460317 width=89) (actual time=0.794..1320.502 rows=370221 loops=3)"
"              Filter: (operating_system = 'Ubuntu'::text)"
"              Rows Removed by Filter: 2963112"
"        ->  Parallel Hash  (cost=271964.00..271964.00 rows=40653 width=435) (actual time=5528.427..5528.428 rows=33293 loops=3)"
"              Buckets: 16384  Batches: 16  Memory Usage: 2848kB"
"              ->  Parallel Seq Scan on users  (cost=0.00..271964.00 rows=40653 width=435) (actual time=230.157..5493.353 rows=33293 loops=3)"
"                    Filter: (characteristic @@ to_tsquery('Лучший'::text))"
"                    Rows Removed by Filter: 300040"
"Planning Time: 0.679 ms"
"JIT:"
"  Functions: 42"
"  Options: Inlining true, Optimization true, Expressions true, Deforming true"
"  Timing: Generation 7.879 ms, Inlining 136.795 ms, Optimization 354.046 ms, Emission 195.131 ms, Total 693.851 ms"
"Execution Time: 7183.484 ms" 5337.016

DROP INDEX IF EXISTS prog_products3.best_users;
DROP INDEX IF EXISTS prog_products3.os; 

CREATE INDEX best_users ON prog_products3.users USING GIN(to_tsvector('russian', characteristic));
CREATE INDEX os ON prog_products3.installations USING HASH(operating_system);
--Query returned successfully in 37 min 33 secs.

EXPLAIN ANALYZE SELECT * FROM prog_products3.installations LEFT JOIN prog_products3.users using(user_id) 
WHERE  to_tsvector('russian', characteristic) @@ to_tsquery('Лучший') and operating_system = 'Ubuntu';
"Gather  (cost=17416.75..228054.55 rows=5517 width=536) (actual time=1115.197..1241.916 rows=111072 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Hash Join  (cost=16416.75..226502.85 rows=2299 width=536) (actual time=1080.342..1156.414 rows=37024 loops=3)"
"        Hash Cond: (installations.user_id = users.user_id)"
"        ->  Parallel Seq Scan on installations  (cost=0.00..208879.33 rows=459722 width=89) (actual time=0.045..484.850 rows=370221 loops=3)"
"              Filter: (operating_system = 'Ubuntu'::text)"
"              Rows Removed by Filter: 2963112"
"        ->  Parallel Hash  (cost=16390.71..16390.71 rows=2083 width=451) (actual time=515.673..515.674 rows=33293 loops=3)"
"              Buckets: 8192 (originally 8192)  Batches: 16 (originally 1)  Memory Usage: 2880kB"
"              ->  Parallel Bitmap Heap Scan on users  (cost=135.00..16390.71 rows=2083 width=451) (actual time=17.908..481.104 rows=33293 loops=3)"
"                    Recheck Cond: (to_tsvector('russian'::regconfig, characteristic) @@ to_tsquery('Лучший'::text))"
"                    Heap Blocks: exact=18492"
"                    ->  Bitmap Index Scan on best_users  (cost=0.00..133.75 rows=5000 width=0) (actual time=25.468..25.468 rows=99880 loops=1)"
"                          Index Cond: (to_tsvector('russian'::regconfig, characteristic) @@ to_tsquery('Лучший'::text))"
"Planning Time: 3.775 ms"
"JIT:"
"  Functions: 48"
"  Options: Inlining false, Optimization false, Expressions true, Deforming true"
"  Timing: Generation 4.545 ms, Inlining 0.000 ms, Optimization 2.389 ms, Emission 27.304 ms, Total 34.237 ms"
"Execution Time: 1246.574 ms"


--Json
EXPLAIN ANALYZE SELECT * FROM prog_products3.users
WHERE (user_information?&array['surname', 'name', 'age']) and CAST(user_information->>'age' AS INTEGER) > 18 and CAST(user_information->>'name' AS text) = 'Andrew';
"Seq Scan on users  (cost=10000000000.00..10000088916.00 rows=1 width=451) (actual time=270.355..270.355 rows=0 loops=1)"
"  Filter: ((user_information ?& '{surname,name,age}'::text[]) AND ((user_information ->> 'name'::text) = 'Andrew'::text) AND (((user_information ->> 'age'::text))::integer > 18))"
"  Rows Removed by Filter: 1000000"
"Planning Time: 0.104 ms"
"JIT:"
"  Functions: 2"
"  Options: Inlining true, Optimization true, Expressions true, Deforming true"
"  Timing: Generation 0.284 ms, Inlining 12.838 ms, Optimization 37.146 ms, Emission 9.081 ms, Total 59.350 ms"
"Execution Time: 270.681 ms"

"Gather  (cost=1000.00..73874.43 rows=1 width=451) (actual time=131.477..134.378 rows=0 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on users  (cost=0.00..72874.33 rows=1 width=451) (actual time=111.773..111.773 rows=0 loops=3)"
"        Filter: ((user_information ?& '{surname,name,age}'::text[]) AND ((user_information ->> 'name'::text) = 'Andrew'::text) AND (((user_information ->> 'age'::text))::integer > 18))"
"        Rows Removed by Filter: 333333"
"Planning Time: 0.071 ms"
"Execution Time: 134.394 ms"

DROP INDEX IF EXISTS prog_products3.user_info;

CREATE INDEX user_info ON prog_products3.users using GIN(user_information);

EXPLAIN ANALYZE SELECT * FROM prog_products3.users JOIN prog_products3.installations USING(user_id)
WHERE CAST(user_information->>'age' AS INTEGER) > 18;
"Bitmap Heap Scan on users  (cost=52.75..443.39 rows=1 width=451) (actual time=0.048..0.049 rows=0 loops=1)"
"  Recheck Cond: (user_information ?& '{surname,name,age}'::text[])"
"  Filter: (((user_information ->> 'name'::text) = 'Andrew'::text) AND (((user_information ->> 'age'::text))::integer > 18))"
"  ->  Bitmap Index Scan on user_info  (cost=0.00..52.75 rows=100 width=0) (actual time=0.047..0.047 rows=0 loops=1)"
"        Index Cond: (user_information ?& '{surname,name,age}'::text[])"
"Planning Time: 0.189 ms"
"Execution Time: 0.063 ms"

--Simple several columns
EXPLAIN ANALYZE SELECT * FROM prog_products3.installations WHERE operating_system = 'Windows' and product_id = 100 ORDER BY installation_id;
"Gather Merge  (cost=220339.96..220549.04 rows=1792 width=89) (actual time=310.530..313.546 rows=2218 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Sort  (cost=219339.94..219342.18 rows=896 width=89) (actual time=289.281..289.312 rows=739 loops=3)"
"        Sort Key: installation_id"
"        Sort Method: quicksort  Memory: 162kB"
"        Worker 0:  Sort Method: quicksort  Memory: 163kB"
"        Worker 1:  Sort Method: quicksort  Memory: 142kB"
"        ->  Parallel Seq Scan on installations  (cost=0.00..219296.00 rows=896 width=89) (actual time=3.080..288.975 rows=739 loops=3)"
"              Filter: ((operating_system = 'Windows'::text) AND (product_id = 100))"
"              Rows Removed by Filter: 3332594"
"Planning Time: 0.088 ms"
"JIT:"
"  Functions: 6"
"  Options: Inlining false, Optimization false, Expressions true, Deforming true"
"  Timing: Generation 0.793 ms, Inlining 0.000 ms, Optimization 0.861 ms, Emission 6.693 ms, Total 8.347 ms"
"Execution Time: 313.877 ms"

DROP INDEX IF EXISTS prog_products3.product_windows;

CREATE INDEX product_windows ON prog_products3.installations (operating_system, product_id);

EXPLAIN ANALYZE SELECT * FROM prog_products3.installations WHERE operating_system = 'Windows' and product_id = 100 ORDER BY installation_id;
"Sort  (cost=7977.81..7983.18 rows=2150 width=89) (actual time=1.907..1.989 rows=2218 loops=1)"
"  Sort Key: installation_id"
"  Sort Method: quicksort  Memory: 490kB"
"  ->  Bitmap Heap Scan on installations  (cost=30.47..7858.80 rows=2150 width=89) (actual time=0.438..1.758 rows=2218 loops=1)"
"        Recheck Cond: ((operating_system = 'Windows'::text) AND (product_id = 100))"
"        Heap Blocks: exact=2201"
"        ->  Bitmap Index Scan on product_windows  (cost=0.00..29.93 rows=2150 width=0) (actual time=0.206..0.206 rows=2218 loops=1)"
"              Index Cond: ((operating_system = 'Windows'::text) AND (product_id = 100))"
"Planning Time: 0.179 ms"
"Execution Time: 2.049 ms"


-- PARTITIONING
DROP TABLE IF EXISTS prog_products3.installations_parted CASCADE; 
CREATE TABLE IF NOT EXISTS prog_products3.installations_parted (
    installation_id SERIAL,
    installation_updating_dates timestamp[], 
    product_id integer NOT NULL REFERENCES prog_products3.programming_products ON DELETE CASCADE,
    operating_system text,
	price_for_license numeric(8,2) CHECK(price_for_license >= 0),
	user_id integer NOT NULL REFERENCES prog_products3.users ON DELETE CASCADE,
	PRIMARY KEY(installation_id, price_for_license)
) PARTITION BY RANGE (price_for_license);


CREATE TABLE IF NOT EXISTS prog_products3.installations_parted1
	PARTITION OF prog_products3.installations_parted FOR VALUES FROM (100) TO (300);

CREATE TABLE IF NOT EXISTS prog_products3.users_parted2
	PARTITION OF prog_products3.installations_parted FOR VALUES FROM (300) TO (500);

CREATE TABLE IF NOT EXISTS prog_products3.installations_parted3
	PARTITION OF prog_products3.installations_parted FOR VALUES FROM (500) TO (700);

CREATE TABLE IF NOT EXISTS prog_products3.installations_parted4
	PARTITION OF prog_products3.installations_parted FOR VALUES FROM (700) TO (900);

CREATE TABLE IF NOT EXISTS prog_products3.installations_parted5
	PARTITION OF prog_products3.installations_parted FOR VALUES FROM (900) TO (1101);

INSERT INTO prog_products3.installations_parted
	SELECT * FROM prog_products3.installations;
--Query returned successfully in 3 min 10 secs.

EXPLAIN ANALYZE SELECT * FROM prog_products3.installations WHERE price_for_license >= 900;
"Seq Scan on installations  (cost=0.00..281796.00 rows=2046261 width=89) (actual time=54.436..2038.840 rows=1998573 loops=1)"
"  Filter: (price_for_license >= '900'::numeric)"
"  Rows Removed by Filter: 8001427"
"Planning Time: 0.119 ms"
"JIT:"
"  Functions: 2"
"  Options: Inlining false, Optimization false, Expressions true, Deforming true"
"  Timing: Generation 10.044 ms, Inlining 0.000 ms, Optimization 14.040 ms, Emission 37.672 ms, Total 61.757 ms"
"Execution Time: 2100.062 ms"


EXPLAIN ANALYZE SELECT * FROM prog_products3.installations_parted WHERE price_for_license >= 900;
"Seq Scan on users_parted5 installations_parted  (cost=0.00..56236.88 rows=1998350 width=90) (actual time=0.018..296.715 rows=1998573 loops=1)"
"  Filter: (price_for_license >= '900'::numeric)"
"Planning Time: 1.988 ms"
"Execution Time: 343.064 ms"

--Partioning installations
DROP TABLE prog_products3.installations1;
DROP TABLE prog_products3.installations2;
DROP TABLE prog_products3.installations3;
DROP TABLE prog_products3.installations4;
DROP TABLE prog_products3.installations5;

CREATE TABLE prog_products3.installations1 (CHECK (price_for_license BETWEEN 100 AND  299)) INHERITS (prog_products3.installations);
CREATE TABLE prog_products3.installations2 (CHECK (price_for_license BETWEEN 300 AND  499)) INHERITS (prog_products3.installations);
CREATE TABLE prog_products3.installations3 (CHECK (price_for_license BETWEEN 500 AND  699)) INHERITS (prog_products3.installations);
CREATE TABLE prog_products3.installations4 (CHECK (price_for_license BETWEEN 700 AND  899)) INHERITS (prog_products3.installations);
CREATE TABLE prog_products3.installations5 (CHECK (price_for_license BETWEEN 900 AND  1100)) INHERITS (prog_products3.installations);

EXPLAIN ANALYZE SELECT * FROM prog_products3.installations WHERE price_for_license >= 900;
"Append  (cost=10000000000.00..20000292047.08 rows=2046491 width=89) (actual time=111.814..1158.329 rows=1998573 loops=1)"
"  ->  Seq Scan on installations installations_1  (cost=10000000000.00..10000281796.00 rows=2046261 width=89) (actual time=111.813..1065.764 rows=1998573 loops=1)"
"        Filter: (price_for_license >= '900'::numeric)"
"        Rows Removed by Filter: 8001427"
"  ->  Seq Scan on installations5 installations_2  (cost=10000000000.00..10000000018.62 rows=230 width=90) (actual time=0.009..0.009 rows=0 loops=1)"
"        Filter: (price_for_license >= '900'::numeric)"
"Planning Time: 0.168 ms"
"JIT:"
"  Functions: 4"
"  Options: Inlining true, Optimization true, Expressions true, Deforming true"
"  Timing: Generation 0.411 ms, Inlining 40.107 ms, Optimization 39.926 ms, Emission 24.451 ms, Total 104.895 ms"
"Execution Time: 1204.823 ms"


--Materialized view
CREATE MATERIALIZED VIEW installations_Windows AS SELECT * FROM prog_products3.installations WHERE operating_system in ('Windows', 'Ubuntu', 'Fedora', 'Manjaro');

DROP MATERIALIZED VIEW installations_windows;

explain analyze SELECT * FROM installations_Windows WHERE operating_system = 'Windows';
explain analyze SELECT * FROM prog_products3.installations WHERE operating_system = 'Windows';


509
1014