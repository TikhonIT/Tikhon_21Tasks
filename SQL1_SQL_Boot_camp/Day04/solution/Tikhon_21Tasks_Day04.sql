--Day04
--ex00
CREATE VIEW v_persons_female AS
SELECT *
FROM person
WHERE gender = 'female';

SELECT *
FROM v_persons_female;

CREATE VIEW v_persons_male AS
SELECT *
FROM person
WHERE gender = 'male';

SELECT * FROM v_persons_male;
--ex01
SELECT name FROM v_persons_female
UNION ALL
SELECT name FROM v_persons_male
ORDER BY name;
--ex02
CREATE VIEW v_generated_dates AS
SELECT generated_date::DATE
FROM generate_series('2022-01-01', '2022-01-31', INTERVAL '1 day') AS generated_date
ORDER BY generated_date;

SELECT *
FROM v_generated_dates;
--ex03
SELECT generated_date AS missing_date
FROM v_generated_dates
LEFT JOIN person_visits ON generated_date = visit_date
WHERE visit_date IS NULL
ORDER BY missing_date;
--ex04
CREATE VIEW v_symmetric_union AS
(
    (SELECT person_id FROM person_visits WHERE visit_date = '2022-01-02')
    EXCEPT
    (SELECT person_id FROM person_visits WHERE visit_date = '2022-01-06')
)
UNION
(
    (SELECT person_id FROM person_visits WHERE visit_date = '2022-01-06')
    EXCEPT
    (SELECT person_id FROM person_visits WHERE visit_date = '2022-01-02')
)
ORDER BY person_id;

SELECT *
FROM v_symmetric_union;
--ex05
CREATE VIEW v_price_with_discount AS
SELECT p.name, m.pizza_name, m.price, ROUND(m.price * 0.9) AS discount_price
FROM person_order po
JOIN person p ON po.person_id = p.id
JOIN menu m ON po.menu_id = m.id
ORDER BY p.name, m.pizza_name;

SELECT *
FROM v_price_with_discount;
--ex06
CREATE MATERIALIZED VIEW mv_dmitriy_visits_and_eats AS
SELECT pz.name AS pizzeria_name
FROM person_visits pv
JOIN person p ON pv.person_id = p.id
JOIN pizzeria pz ON pv.pizzeria_id = pz.id
WHERE p.name = 'Dmitriy'
  AND pv.visit_date = '2022-01-08'
  AND EXISTS (
    SELECT 1
    FROM menu m
    WHERE m.pizzeria_id = pz.id
      AND m.price < 800
  );

SELECT *
FROM mv_dmitriy_visits_and_eats;
--ex07
INSERT INTO person_visits (id, person_id, pizzeria_id, visit_date)
VALUES (20, 9, 3, '2022-01-08');

REFRESH MATERIALIZED VIEW mv_dmitriy_visits_and_eats;
--ex08
DROP VIEW v_persons_female;
DROP VIEW v_persons_male;
DROP VIEW v_generated_dates;
DROP VIEW v_symmetric_union;
DROP VIEW v_price_with_discount;
DROP MATERIALIZED VIEW mv_dmitriy_visits_and_eats;
