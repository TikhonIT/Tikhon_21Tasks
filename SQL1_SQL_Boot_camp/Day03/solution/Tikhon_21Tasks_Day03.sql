--Day03

--ex00
select m.pizza_name, m.price, pi.name as pizzeria_name, pv.visit_date
from person p
join person_visits pv on p.id = pv.person_id
join pizzeria pi on pi.id = pv.pizzeria_id
join menu m on pi.id = m.pizzeria_id
where p.name = 'Kate' and m.price between 800 and 1000
order by 1, 2, 3;

--ex01
select m.id
from menu m
left join person_order po on m.id = po.menu_id
where po.id is null
order by 1;

--ex02
select m.pizza_name, m.price, pi.name as pizzeria_name
from menu m
left join person_order po on m.id = po.menu_id
left join pizzeria pi on pi.id = m.pizzeria_id
where po.id is null
order by 1, 2;

--ex03
with gender_counts as(
    select
        pv.pizzeria_id,
        count(*) filter(where p.gender = 'female') as female,
        count(*) filter(where p.gender = 'male') as male
    from person_visits pv
    join person p on pv.person_id = p.id
    group by pv.pizzeria_id
)
select 
    pi.name as pizzeria_name
from gender_counts gc
join pizzeria pi on gc.pizzeria_id = pi.id
where gc.female != gc.male
order by 1;

--ex04
with pizzeria_genders as(
    select
        pi.name as pizzeria_name,
        count(distinct p.gender) as gender_count,
        max(p.gender) as only_gender
    from pizzeria pi
    join menu m on pi.id = m.pizzeria_id
    join person_order po on m.id = po.menu_id
    join person p on po.person_id = p.id
    group by pi.name 
    having count(distinct p.gender) = 1
)
(select pizzeria_name
from pizzeria_genders
where only_gender = 'female'
union
select pizzeria_name
from pizzeria_genders
where only_gender = 'male')
order by 1;

--ex05
(select pi.name as pizzeria_name
from person_visits pv
join person p on pv.person_id = p.id
join pizzeria pi on pv.pizzeria_id = pi.id
where p.name = 'Andrey'
except
select pi.name as pizzeria_name
from person_order po
join person p on po.person_id = p.id
join menu m on po.menu_id = m.id
join pizzeria pi on m.pizzeria_id = pi.id
where p.name = 'Andrey')
order by 1;

--ex06
select m1.pizza_name, p1.name as pizzeria_name_1, p2.name as pizzeria_name_2, m1.price
from menu m1
join menu m2 on m1.pizza_name = m2.pizza_name and m1.price = m2.price and m1.pizzeria_id < m2.pizzeria_id
join pizzeria p1 on m1.pizzeria_id = p1.id
join pizzeria p2 on m2.pizzeria_id = p2.id
order by 1;

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
update menu
set price = price * 0.9
where pizza_name = 'greek pizza' and pizzeria_id = (select id from pizzeria where name = 'Dominos');

--ex12
INSERT INTO person_order(id, person_id, menu_id, order_date)
SELECT
    (SELECT MAX(id) FROM person_order) + ROW_NUMBER() OVER(ORDER BY p.id) AS id,
    p.id,
    (SELECT id FROM menu WHERE pizza_name = 'greek pizza' AND pizzeria_id = 2),
    '2022-02-25'
FROM person p;

--ex13
delete from person_order
where order_date = '2022-02-25' and menu_id = (select id
                                               from menu
                                               where pizza_name = 'greek_pizza'
                                               and pizzeria_id = (select id from pizzeria where name = 'Dominos'));

delete from menu
where pizza_name = 'greek_pizza' and pizzeria_id = (select id from pizzeria where name = 'Dominos');