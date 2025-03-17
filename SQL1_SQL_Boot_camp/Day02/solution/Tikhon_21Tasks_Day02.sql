--Day02
--ex00
SELECT pz.name, pz.rating
FROM pizzeria pz
LEFT JOIN person_visits pv ON pz.id = pv.pizzeria_id
WHERE pv.pizzeria_id IS NULL;
--ex01
SELECT missing_date::date
FROM generate_series('2022-01-01'::date, '2022-01-10'::date, '1 day') AS missing_date
LEFT JOIN person_visits pv
ON pv.visit_date = missing_date
AND pv.person_id IN (1, 2)
WHERE pv.id IS NULL
ORDER BY missing_date;
--ex02
SELECT COALESCE(p.name, '-') AS person_name, pv.visit_date, COALESCE(pz.name, '-') AS pizzeria_name
FROM person p
FULL JOIN person_visits pv ON p.id = pv.person_id AND pv.visit_date BETWEEN '2022-01-01' AND '2022-01-03'
FULL JOIN pizzeria pz ON pv.pizzeria_id = pz.id
ORDER BY person_name, visit_date, pizzeria_name;
--ex03
WITH date_range AS (
    SELECT generate_series('2022-01-01'::date, '2022-01-10'::date, '1 day')::date AS visit_date
)
SELECT dr.visit_date AS missing_date
FROM date_range dr
LEFT JOIN person_visits pv
    ON dr.visit_date = pv.visit_date
    AND pv.person_id IN (1, 2)
WHERE pv.visit_date IS NULL
ORDER BY dr.visit_date;
--ex04
SELECT m.pizza_name, pz.name AS pizzeria_name, m.price
FROM menu m
JOIN pizzeria pz ON m.pizzeria_id = pz.id
WHERE m.pizza_name IN ('mushroom pizza', 'pepperoni pizza')
ORDER BY pizza_name, pizzeria_name;
--ex05
SELECT name
FROM person
WHERE gender = 'female' AND age > 25
ORDER BY name;
--ex06
SELECT m.pizza_name, pz.name AS pizzeria_name
FROM person_order po
JOIN menu m ON po.menu_id = m.id
JOIN pizzeria pz ON m.pizzeria_id = pz.id
JOIN person p ON po.person_id = p.id
WHERE p.name IN ('Denis', 'Anna')
ORDER BY pizza_name, pizzeria_name;
--ex07
SELECT pz.name
FROM person_visits pv
JOIN pizzeria pz ON pv.pizzeria_id = pz.id
WHERE pv.visit_date = '2022-01-08'
AND pv.person_id = (SELECT id FROM person WHERE name = 'Dmitriy')
AND EXISTS (
    SELECT 1 FROM menu m
    WHERE m.pizzeria_id = pz.id AND m.price < 800
);
--ex08
SELECT DISTINCT p.name
FROM person p
JOIN person_order po ON p.id = po.person_id
JOIN menu m ON po.menu_id = m.id
WHERE p.gender = 'male'
AND p.address IN ('Moscow', 'Samara')
AND m.pizza_name IN ('pepperoni pizza', 'mushroom pizza')
ORDER BY p.name DESC;
--ex09
SELECT p.name
FROM person p
JOIN person_order po ON p.id = po.person_id
JOIN menu m ON po.menu_id = m.id
WHERE p.gender = 'female' AND m.pizza_name = 'pepperoni pizza'
INTERSECT
SELECT p.name
FROM person p
JOIN person_order po ON p.id = po.person_id
JOIN menu m ON po.menu_id = m.id
WHERE p.gender = 'female' AND m.pizza_name = 'cheese pizza'
ORDER BY name;
--ex10
SELECT p1.name AS person_name1, p2.name AS person_name2, p1.address AS common_address
FROM person p1
JOIN person p2 ON p1.address = p2.address AND p1.id > p2.id
ORDER BY person_name1, person_name2, common_address;
