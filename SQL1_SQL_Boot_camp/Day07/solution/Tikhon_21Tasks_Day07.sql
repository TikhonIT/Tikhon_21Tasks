--Day07
--ex00
select person_id, COUNT(*) as count_of_visits
from person_visits
group by person_id
order by count_of_visits desc, person_id;

--ex01
with visits_count as(
    select person_id, COUNT(*) as count_of_visits
    from person_visits
    group by person_id
    order by count_of_visits desc, person_id
    limit 4
)
select p.name, vc.count_of_visits
from visits_count vc
join person p on vc.person_id = p.id
order by count_of_visits desc, p.name;

--ex02
(
    SELECT pz.name, COUNT(*) AS count, 'order' AS action_type
    FROM person_order po
    JOIN menu m ON po.menu_id = m.id
    JOIN pizzeria pz ON m.pizzeria_id = pz.id
    GROUP BY pz.name
    ORDER BY count DESC
    LIMIT 3
)
UNION ALL
(
    SELECT pz.name, COUNT(*) AS count, 'visit' AS action_type
    FROM person_visits pv
    JOIN pizzeria pz ON pv.pizzeria_id = pz.id
    GROUP BY pz.name
    ORDER BY count DESC
    LIMIT 3
)
ORDER BY action_type, count DESC;

--ex03
with total as(
(
    SELECT pz.name, COUNT(*) AS count, 'order' AS action_type
    FROM person_order po
    JOIN menu m ON po.menu_id = m.id
    JOIN pizzeria pz ON m.pizzeria_id = pz.id
    GROUP BY pz.name
    ORDER BY count DESC
    LIMIT 3
)
UNION ALL
(
    SELECT pz.name, COUNT(*) AS count, 'visit' AS action_type
    FROM person_visits pv
    JOIN pizzeria pz ON pv.pizzeria_id = pz.id
    GROUP BY pz.name
    ORDER BY count DESC
    LIMIT 3
)
ORDER BY action_type, count DESC
)
select name, SUM(count) as total_count
from total
group by name
order by total_count desc;

--ex04
with visits_count as(
    select person_id, COUNT(*) as count_of_visits
    from person_visits
    group by person_id
    having COUNT(*) > 3
    order by count_of_visits desc, person_id
)
select p.name, vc.count_of_visits
from visits_count vc
join person p on vc.person_id = p.id
order by count_of_visits desc, p.name;

--ex05
with orders_count as(
    select person_id, COUNT(*) as count_of_orders
    from person_order
    group by person_id
    having COUNT(*) > 1
    order by count_of_orders desc, person_id
)
select p.name
from orders_count oc
join person p on oc.person_id = p.id
order by p.name;

--ex06
SELECT pz.name AS name, COUNT(*) AS count_of_orders, ROUND(AVG(m.price), 2) AS average_price, MAX(m.price) AS max_price, MIN(m.price) AS min_price
FROM person_order po
JOIN menu m ON po.menu_id = m.id
JOIN pizzeria pz ON m.pizzeria_id = pz.id
GROUP BY pz.name
ORDER BY pz.name;

--ex07
select ROUND(AVG(rating), 4) AS average_price
from pizzeria;

--ex08
SELECT p.address, pz.name AS name, COUNT(*) AS count_of_orders
FROM person_order po
JOIN person p ON po.person_id = p.id
JOIN menu m ON po.menu_id = m.id
JOIN pizzeria pz ON m.pizzeria_id = pz.id
GROUP BY p.address, pz.name
ORDER BY p.address, pz.name;

--ex09
SELECT address, ROUND((MAX(age) - (MIN(age)::numeric / MAX(age))), 2) AS formula, ROUND(AVG(age), 2) AS average_age,
    CASE 
        WHEN (MAX(age) - (MIN(age)::numeric / MAX(age))) > AVG(age) THEN 'True'
        ELSE 'False'
    END AS comparison
FROM person
GROUP BY address
ORDER BY address;