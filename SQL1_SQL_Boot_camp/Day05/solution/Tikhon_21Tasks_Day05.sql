--Day05
SET enable_seqscan = off;

--ex00
CREATE INDEX idx_person_visits_person_id ON person_visits (person_id);
CREATE INDEX idx_person_visits_pizzeria_id ON person_visits (pizzeria_id);
CREATE INDEX idx_menu_pizzeria_id ON menu (pizzeria_id);
CREATE INDEX idx_person_order_person_id ON person_order (person_id);
CREATE INDEX idx_person_order_menu_id ON person_order (menu_id);

--ex01
SELECT m.pizza_name, pz.name AS pizzeria_name
FROM menu m
JOIN pizzeria pz ON m.pizzeria_id = pz.id;
-- План работы индекса
EXPLAIN ANALYZE
SELECT m.pizza_name, pz.name AS pizzeria_name
FROM menu m
JOIN pizzeria pz ON m.pizzeria_id = pz.id;
/*Merge Join  (cost=0.27..24.75 rows=18 width=64) (actual time=0.053..0.081 rows=18 loops=1)
  Merge Cond: (m.pizzeria_id = pz.id)
  ->  Index Only Scan using idx_menu_unique on menu m  (cost=0.14..12.41 rows=18 width=40) (actual time=0.034..0.048 rows=18 loops=1)
        Heap Fetches: 18
  ->  Index Scan using idx_1 on pizzeria pz  (cost=0.13..12.22 rows=6 width=40) (actual time=0.009..0.013 rows=6 loops=1)
Planning Time: 0.338 ms
Execution Time: 0.183 ms*/

--ex02
CREATE INDEX idx_person_name ON person (UPPER(name));
-- План работы индекса
EXPLAIN ANALYZE
SELECT * FROM person WHERE UPPER(name) = 'ANNA';
/*Index Scan using idx_person_name on person  (cost=0.14..8.15 rows=1 width=108) (actual time=0.055..0.059 rows=1 loops=1)
  Index Cond: (upper((name)::text) = 'ANNA'::text)
Planning Time: 0.181 ms
Execution Time: 0.155 ms*/

--ex03
CREATE INDEX idx_person_order_multi ON person_order (person_id, menu_id, order_date);
-- План работы индекса
EXPLAIN ANALYZE
SELECT person_id, menu_id, order_date
FROM person_order
WHERE person_id = 8 AND menu_id = 19;
/*Index Only Scan using idx_person_order_multi on person_order  (cost=0.14..8.16 rows=1 width=20) (actual time=0.028..0.029 rows=0 loops=1)
  Index Cond: ((person_id = 8) AND (menu_id = 19))
  Heap Fetches: 0
Planning Time: 0.210 ms
Execution Time: 0.065 ms*/

--ex04
CREATE UNIQUE INDEX idx_menu_unique ON menu (pizzeria_id, pizza_name);
-- План работы индекса
EXPLAIN ANALYZE
SELECT * FROM menu WHERE pizzeria_id = 1 AND pizza_name = 'cheese pizza';
/*Index Scan using idx_menu_unique on menu  (cost=0.14..8.16 rows=1 width=80) (actual time=0.040..0.079 rows=1 loops=1)
  Index Cond: ((pizzeria_id = 1) AND ((pizza_name)::text = 'cheese pizza'::text))
Planning Time: 0.167 ms
Execution Time: 0.115 ms*/

--ex05
CREATE UNIQUE INDEX idx_person_order_order_date ON person_order (person_id, menu_id)
WHERE order_date = '2022-01-01';
-- План работы индекса
EXPLAIN ANALYZE
SELECT person_id, menu_id FROM person_order
WHERE order_date = '2022-01-01';
/*Index Only Scan using idx_person_order_order_date on person_order  (cost=0.13..8.15 rows=1 width=16) (actual time=0.175..0.182 rows=5 loops=1)
  Heap Fetches: 5
Planning Time: 0.178 ms
Execution Time: 0.227 ms*/

--ex06
DROP INDEX IF EXISTS idx_1;
CREATE INDEX idx_1 ON pizzeria (id, rating);
-- План работы индекса
EXPLAIN ANALYZE
SELECT
    m.pizza_name AS pizza_name,
    max(pz.rating) OVER (PARTITION BY pz.rating ORDER BY pz.rating ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS k
FROM menu m
INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id
ORDER BY 1, 2;
/*Sort  (cost=25.86..25.91 rows=18 width=96) (actual time=0.216..0.220 rows=18 loops=1)
  Sort Key: m.pizza_name, (max(pz.rating) OVER (?))
  Sort Method: quicksort  Memory: 26kB
  ->  WindowAgg  (cost=25.13..25.49 rows=18 width=96) (actual time=0.143..0.175 rows=18 loops=1)
        ->  Sort  (cost=25.13..25.17 rows=18 width=64) (actual time=0.121..0.125 rows=18 loops=1)
              Sort Key: pz.rating
              Sort Method: quicksort  Memory: 26kB
              ->  Merge Join  (cost=0.27..24.75 rows=18 width=64) (actual time=0.073..0.097 rows=18 loops=1)
                    Merge Cond: (m.pizzeria_id = pz.id)
                    ->  Index Only Scan using idx_menu_unique on menu m  (cost=0.14..12.41 rows=18 width=40) (actual time=0.020..0.032 rows=18 loops=1)
                          Heap Fetches: 18
                    ->  Index Only Scan using idx_1 on pizzeria pz  (cost=0.13..12.22 rows=6 width=40) (actual time=0.045..0.048 rows=6 loops=1)
                          Heap Fetches: 6
Planning Time: 0.536 ms
Execution Time: 0.299 ms*/