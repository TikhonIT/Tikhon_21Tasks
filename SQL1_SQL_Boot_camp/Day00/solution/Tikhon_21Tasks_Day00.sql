--Day00
--ex00
select name, age
from person
where address = 'Kazan';
--ex01
select name, age
from person
where address = 'Kazan' and gender = 'female'
order by name;
--ex02
--1-й вариант
select name, rating
from pizzeria
where rating >= 3.5 and rating <= 5;
--2-й вариант
select name, rating
from pizzeria
where rating between 3.5 and 5;
--ex03
select distinct person_id
from person_visits
where visit_date between '2022-01-06' and '2022-01-09' or pizzeria_id = 2
order by person_id desc;
--ex04
select concat(name, ' (age:', age, ',gender:''', gender, ''',address:''', address, ''')') person_information
from person;
--ex05
SELECT 
    (SELECT name FROM person WHERE id = po.person_id) name
FROM person_order po
WHERE po.menu_id IN (13, 14, 18) 
  AND po.order_date = '2022-01-07';
--ex06
SELECT 
    (SELECT name FROM person WHERE id = po.person_id) AS name,
    (SELECT name FROM person WHERE id = po.person_id) = 'Denis' AS check_name
FROM person_order po
WHERE po.menu_id IN (13, 14, 18)
  AND po.order_date = '2022-01-07';
--ex07
SELECT 
    id,
    name,
    CASE 
        WHEN age BETWEEN 10 AND 20 THEN 'interval #1'
        WHEN age > 20 AND age < 24 THEN 'interval #2'
        ELSE 'interval #3'
    END AS interval_info
FROM person
ORDER BY interval_info;
--ex08
SELECT *
FROM person_order
WHERE id % 2 = 0
ORDER BY id;
--ex09
SELECT 
    (SELECT name FROM person WHERE id = pv.person_id) AS person_name,
    (SELECT name FROM pizzeria WHERE id = pv.pizzeria_id) AS pizzeria_name
FROM (SELECT * FROM person_visits 
      WHERE visit_date BETWEEN '2022-01-07' AND '2022-01-09') AS pv
ORDER BY person_name ASC, pizzeria_name DESC;