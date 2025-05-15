--Day05
set enable_seqscan = off;

--ex00
create index idx_person_visits_person_id on person_visits(person_id);
create index idx_person_visits_pizzeria_id on person_visits(pizzeria_id);
create index ind_menu_pizzeria_id on menu(pizzeria_id);
create index idx_person_order_person_id on person_order(person_id);
create index idx_person_order_menu_id on person_order(menu_id);

--ex01
select m.pizza_name, pi.name as pizzeria_name
from menu m
join pizzeria pi on m.pizzeria_id = pi.id;
-- План работы индекса
explain analyze
select m.pizza_name, pi.name as pizzeria_name
from menu m
join pizzeria pi on m.pizzeria_id = pi.id;
/*QUERY PLAN                                                                                                                           |
-------------------------------------------------------------------------------------------------------------------------------------+
Merge Join  (cost=0.27..24.77 rows=19 width=42) (actual time=0.131..0.165 rows=19 loops=1)                                           |
  Merge Cond: (m.pizzeria_id = pi.id)                                                                                                |
  ->  Index Only Scan using idx_menu_unique on menu m  (cost=0.14..12.42 rows=19 width=40) (actual time=0.082..0.098 rows=19 loops=1)|
        Heap Fetches: 20                                                                                                             |
  ->  Index Scan using idx_1 on pizzeria pi  (cost=0.13..12.22 rows=6 width=18) (actual time=0.032..0.040 rows=6 loops=1)            |
Planning Time: 0.319 ms                                                                                                              |
Execution Time: 0.225 ms                                                                                                             |*/

--ex02
create index idx_person_name on person(upper(name));
-- План работы индекса
explain analyze
select *
from person
where upper(name) = 'PETER';
/*QUERY PLAN                                                                                                              |
------------------------------------------------------------------------------------------------------------------------+
Index Scan using idx_person_name on person  (cost=0.14..8.15 rows=1 width=108) (actual time=0.040..0.044 rows=1 loops=1)|
  Index Cond: (upper((name)::text) = 'PETER'::text)                                                                     |
Planning Time: 0.155 ms                                                                                                 |
Execution Time: 0.084 ms                                                                                                |*/

--ex03
create index idx_person_order_multi on person_order(person_id, menu_id, order_date);
-- План работы индекса
explain analyze
SELECT person_id, menu_id, order_date
FROM person_order
WHERE person_id = 8 AND menu_id = 19;
/*QUERY PLAN                                                                                                                               |
-----------------------------------------------------------------------------------------------------------------------------------------+
Index Only Scan using idx_person_order_multi on person_order  (cost=0.14..8.16 rows=1 width=20) (actual time=0.080..0.081 rows=0 loops=1)|
  Index Cond: ((person_id = 8) AND (menu_id = 19))                                                                                       |
  Heap Fetches: 0                                                                                                                        |
Planning Time: 0.279 ms                                                                                                                  |
Execution Time: 0.117 ms                                                                                                                 |*/

--ex04
create unique index idx_menu_unique on menu(pizzeria_id, pizza_name);
-- План работы индекса
explain analyze
select *
from menu
where pizzeria_id = 1 and pizza_name = 'cheese_pizza';
/*QUERY PLAN                                                                                                           |
---------------------------------------------------------------------------------------------------------------------+
Index Scan using idx_menu_unique on menu  (cost=0.14..8.16 rows=1 width=80) (actual time=0.064..0.065 rows=0 loops=1)|
  Index Cond: ((pizzeria_id = 1) AND ((pizza_name)::text = 'cheese_pizza'::text))                                    |
Planning Time: 0.174 ms                                                                                              |
Execution Time: 0.133 ms                                                                                             |*/

--ex05
create unique index idx_person_order_order_date on person_order (person_id, menu_id)
where order_date = '2022-01-01';
-- План работы индекса
explain analyze
select person_id, menu_id from person_order
where order_date = '2022-01-01';
/*QUERY PLAN                                                                                                                                    |
----------------------------------------------------------------------------------------------------------------------------------------------+
Index Only Scan using idx_person_order_order_date on person_order  (cost=0.13..8.15 rows=1 width=16) (actual time=0.239..0.244 rows=5 loops=1)|
  Heap Fetches: 5                                                                                                                             |
Planning Time: 0.144 ms                                                                                                                       |
Execution Time: 0.268 ms                                                                                                                      |*/

--ex06
drop index if exists idx_1;
create index idx_1 on pizzeria(id, rating);
-- План работы индекса
explain analyze
SELECT
    m.pizza_name AS pizza_name,
    max(rating) OVER (PARTITION BY rating ORDER BY rating ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS k
FROM  menu m
INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id
ORDER BY 1, 2;
/*QUERY PLAN                                                                                                                                             |
-------------------------------------------------------------------------------------------------------------------------------------------------------+
Sort  (cost=25.95..26.00 rows=19 width=71) (actual time=0.217..0.222 rows=19 loops=1)                                                                  |
  Sort Key: m.pizza_name, (max(pz.rating) OVER (?))                                                                                                    |
  Sort Method: quicksort  Memory: 26kB                                                                                                                 |
  ->  WindowAgg  (cost=25.17..25.55 rows=19 width=71) (actual time=0.141..0.174 rows=19 loops=1)                                                       |
        ->  Sort  (cost=25.17..25.22 rows=19 width=39) (actual time=0.114..0.118 rows=19 loops=1)                                                      |
              Sort Key: pz.rating                                                                                                                      |
              Sort Method: quicksort  Memory: 26kB                                                                                                     |
              ->  Merge Join  (cost=0.27..24.77 rows=19 width=39) (actual time=0.064..0.087 rows=19 loops=1)                                           |
                    Merge Cond: (m.pizzeria_id = pz.id)                                                                                                |
                    ->  Index Only Scan using idx_menu_unique on menu m  (cost=0.14..12.42 rows=19 width=40) (actual time=0.012..0.023 rows=19 loops=1)|
                          Heap Fetches: 19                                                                                                             |
                    ->  Index Only Scan using idx_1 on pizzeria pz  (cost=0.13..12.22 rows=6 width=15) (actual time=0.044..0.048 rows=6 loops=1)       |
                          Heap Fetches: 6                                                                                                              |
Planning Time: 0.578 ms                                                                                                                                |
Execution Time: 0.353 ms                                                                                                                               |*/