--Day01
--ex00
SELECT id AS object_id, pizza_name AS object_name
FROM menu
UNION
SELECT id, name
FROM person
ORDER BY object_id, object_name;
--ex01
SELECT object_name
FROM (
    SELECT name AS object_name, 1 AS sort
    FROM person
    UNION ALL
    SELECT pizza_name AS object_name, 2 AS sort
    FROM menu
) AS combdata
ORDER BY sort, object_name;
--ex02
SELECT DISTINCT pizza_name
FROM menu
ORDER BY pizza_name DESC;
--ex03
SELECT order_date AS action_date, person_id
FROM person_order
INTERSECT
SELECT visit_date AS action_date, person_id
FROM person_visits
ORDER BY action_date, person_id DESC;
--ex04
SELECT person_id
FROM person_order
WHERE order_date = '2022-01-07'
EXCEPT ALL
SELECT person_id
FROM person_visits
WHERE visit_date = '2022-01-07';
--ex05
SELECT person.id, person.name, person.age AS age, person.gender AS gender, person.address AS address, 
pizzeria.id, pizzeria.name, pizzeria.rating AS rating
FROM person
CROSS JOIN pizzeria
ORDER BY person.id, pizzeria.id;
--ex06
SELECT 
    action_date,
    p.name AS person_name
FROM (
    SELECT order_date AS action_date, person_id
    FROM person_order
    INTERSECT
    SELECT visit_date AS action_date, person_id
    FROM person_visits
) AS combined
JOIN person p ON combined.person_id = p.id
ORDER BY action_date, person_name DESC;
--ex07
SELECT po.order_date AS order_date, p.name || ' (age:' || p.age || ')' AS person_information
FROM person_order po
JOIN person p ON po.person_id = p.id
ORDER BY order_date, person_information;
--ex08
SELECT order_date, name || ' (age:' || age || ')' AS person_information
FROM (SELECT person_id AS id, order_date FROM person_order) AS po
NATURAL JOIN person
ORDER BY order_date, person_information;
--ex09
--1-й вариант
SELECT name AS pizzeria_name
FROM pizzeria
WHERE id NOT IN (
    SELECT pizzeria_id
    FROM person_visits
);
--2-й вариант
SELECT name AS pizzeria_name
FROM pizzeria p
WHERE NOT EXISTS (
    SELECT 1
    FROM person_visits pv
    WHERE pv.pizzeria_id = p.id
);
--3-й вариант
SELECT pz.name AS pizzeria_name
FROM pizzeria pz 
LEFT JOIN person_visits pv ON pz.id = pv.pizzeria_id
WHERE pv.pizzeria_id IS NULL;
--ex10
SELECT p.name AS person_name, m.pizza_name, pz.name AS pizzeria_name
FROM person_order po
JOIN person p ON po.person_id = p.id
JOIN menu m ON po.menu_id = m.id
JOIN pizzeria pz ON m.pizzeria_id = pz.id
ORDER BY person_name, pizza_name, pizzeria_name;