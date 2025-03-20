--Day03
--ex00
SELECT m.pizza_name, m.price, pz.name AS pizzeria_name, pv.visit_date
FROM person p
JOIN person_visits pv ON p.id = pv.person_id
JOIN pizzeria pz ON pv.pizzeria_id = pz.id
JOIN menu m ON pz.id = m.pizzeria_id
WHERE p.name = 'Kate' AND m.price BETWEEN 800 AND 1000
ORDER BY m.pizza_name, m.price, pz.name;
--ex01
SELECT m.id AS menu_id
FROM menu m
LEFT JOIN person_order po ON m.id = po.menu_id
WHERE po.menu_id IS NULL
ORDER BY menu_id;
--ex02
SELECT m.pizza_name, m.price, pz.name AS pizzeria_name
FROM menu m
JOIN pizzeria pz ON m.pizzeria_id = pz.id
LEFT JOIN person_order po ON m.id = po.menu_id
WHERE po.id IS NULL
ORDER BY m.pizza_name, m.price;
--ex03
WITH gender_counts AS (
    SELECT 
        pv.pizzeria_id,
        SUM(CASE WHEN p.gender = 'female' THEN 1 ELSE 0 END) AS female,
        SUM(CASE WHEN p.gender = 'male' THEN 1 ELSE 0 END) AS male
    FROM person_visits pv
    JOIN person p ON pv.person_id = p.id
    GROUP BY pv.pizzeria_id
)
SELECT 
    pz.name AS pizzeria_name
FROM gender_counts gc
JOIN pizzeria pz ON gc.pizzeria_id = pz.id
WHERE gc.female > gc.male
UNION ALL
SELECT 
    pz.name
FROM gender_counts gc
JOIN pizzeria pz ON gc.pizzeria_id = pz.id
WHERE gc.male > gc.female
ORDER BY pizzeria_name;
--ex04
WITH pizzeria_genders AS (
    SELECT 
        pz.name AS pizzeria_name,
        COUNT(DISTINCT p.gender) AS gender_count,
        MAX(p.gender) AS only_gender
    FROM pizzeria pz
    JOIN menu m ON pz.id = m.pizzeria_id
    JOIN person_order po ON m.id = po.menu_id
    JOIN person p ON po.person_id = p.id
    GROUP BY pz.name
    HAVING COUNT(DISTINCT p.gender) = 1
)
SELECT pizzeria_name
FROM pizzeria_genders
WHERE only_gender = 'female'
UNION
SELECT pizzeria_name
FROM pizzeria_genders
WHERE only_gender = 'male'
ORDER BY pizzeria_name;
--ex05
SELECT pz.name AS pizzeria_name
FROM person_visits pv
JOIN person p ON pv.person_id = p.id
JOIN pizzeria pz ON pv.pizzeria_id = pz.id
WHERE p.name = 'Andrey'
EXCEPT
SELECT pz.name
FROM person_order po
JOIN person p ON po.person_id = p.id
JOIN menu m ON po.menu_id = m.id
JOIN pizzeria pz ON m.pizzeria_id = pz.id
WHERE p.name = 'Andrey'
ORDER BY 1;
--ex06
SELECT m1.pizza_name, p1.name AS pizzeria_name_1, p2.name AS pizzeria_name_2, m1.price
FROM menu m1
JOIN menu m2 ON m1.pizza_name = m2.pizza_name AND m1.price = m2.price AND m1.pizzeria_id < m2.pizzeria_id
JOIN pizzeria p1 ON m1.pizzeria_id = p1.id
JOIN pizzeria p2 ON m2.pizzeria_id = p2.id
ORDER BY m1.pizza_name;
--ex07
INSERT INTO menu (id, pizzeria_id, pizza_name, price)
VALUES (19, 2, 'greek pizza', 800);
--ex08
INSERT INTO menu (id, pizzeria_id, pizza_name, price)
VALUES (
    (SELECT MAX(id) + 1 FROM menu),
    (SELECT id FROM pizzeria WHERE name = 'Dominos'),
    'sicilian pizza',
    900
);
--ex09
INSERT INTO person_visits (id, person_id, pizzeria_id, visit_date)
VALUES 
    (
        (SELECT MAX(id) + 1 FROM person_visits),
        (SELECT id FROM person WHERE name = 'Denis'),
        (SELECT id FROM pizzeria WHERE name = 'Dominos'),
        '2022-02-24'
    ),
    (
        (SELECT MAX(id) + 2 FROM person_visits),
        (SELECT id FROM person WHERE name = 'Irina'),
        (SELECT id FROM pizzeria WHERE name = 'Dominos'),
        '2022-02-24'
    );
--ex10
INSERT INTO person_order (id, person_id, menu_id, order_date)
VALUES
    (
        (SELECT MAX(id) + 1 FROM person_order),
        (SELECT id FROM person WHERE name = 'Denis'),
        (SELECT id FROM menu WHERE pizza_name = 'sicilian pizza' AND pizzeria_id = 2),
        '2022-02-24'
    ),
    (
        (SELECT MAX(id) + 2 FROM person_order),
        (SELECT id FROM person WHERE name = 'Irina'),
        (SELECT id FROM menu WHERE pizza_name = 'sicilian pizza' AND pizzeria_id = 2),
        '2022-02-24'
    );
--ex11
UPDATE menu
SET price = price * 0.9
WHERE pizza_name = 'greek pizza' AND pizzeria_id = (SELECT id FROM pizzeria WHERE name = 'Dominos');
--ex12
INSERT INTO person_order (id, person_id, menu_id, order_date)
SELECT
    (SELECT MAX(id) FROM person_order) + ROW_NUMBER() OVER (ORDER BY p.id) AS id,
    p.id,
    (SELECT id FROM menu WHERE pizza_name = 'greek pizza' AND pizzeria_id = 2),
    '2022-02-25'
FROM person p;
--ex13
DELETE FROM person_order
WHERE order_date = '2022-02-25'
  AND menu_id = (
      SELECT id 
      FROM menu 
      WHERE pizza_name = 'greek pizza'
        AND pizzeria_id = (SELECT id FROM pizzeria WHERE name = 'Dominos')
  );
DELETE FROM menu
WHERE pizza_name = 'greek pizza'
  AND pizzeria_id = (SELECT id FROM pizzeria WHERE name = 'Dominos');