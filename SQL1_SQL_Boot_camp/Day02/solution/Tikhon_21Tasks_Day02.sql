--Day02

--ex00
select pi.name, pi.rating
from pizzeria pi
left join person_visits pv on pi.id = pv.pizzeria_id
where pv.pizzeria_id is null;

--ex01
select outday::date
from generate_series('2022-01-01'::date, '2022-01-10'::date, '1 day') as outday
left join person_visits pv on pv.visit_date = outday and pv.person_id IN(1, 2)
where pv.id is null
order by 1;

--ex02
select coalesce(p.name, '-') as person_name, pv.visit_date, coalesce(pi.name, '-') as pizzeria_name
from person p
full join person_visits pv on p.id = pv.person_id and pv.visit_date between '2022-01-01' and '2022-01-03'
full join pizzeria pi on pi.id = pv.pizzeria_id
order by 1, 2, 3;

--ex03
with cte as(
    select generate_series('2022-01-01'::date, '2022-01-10'::date, '1 day') as outday
)
select cte.outday
from cte
left join person_visits pv on pv.visit_date = cte.outday and pv.person_id IN(1, 2)
where pv.id is null
order by 1;

--ex04
select m.pizza_name, pi.name as pizzeria_name, m.price
from menu m
join pizzeria pi on pi.id = m.pizzeria_id
where m.pizza_name IN('mushroom pizza', 'pepperoni pizza')
order by 1, 2;

--ex05
select name
from person
where gender = 'female' and age > 25
order by 1;

--ex06
select m.pizza_name, pi.name as pizzeria_name
from person_order po
join menu m on m.id = po.menu_id
join pizzeria pi on pi.id = m.pizzeria_id
join person p on p.id = po.person_id
where p.name IN('Denis', 'Anna')
order by 1, 2;

--ex07
select pi.name
from person_visits pv
join person p on p.id = pv.person_id
join pizzeria pi on pi.id = pv.pizzeria_id
join menu m on m.pizzeria_id = pi.id
where p.name = 'Dmitriy' and pv.visit_date = '2022-01-08' and m.price < 800;

--ex08
select distinct p.name
from person p
left join person_order po on p.id = po.person_id
left join menu m on po.menu_id = m.id
where p.address IN('Moscow', 'Samara') and p.gender = 'male' and m.pizza_name IN('mushroom pizza', 'pepperoni pizza')
order by 1 desc;

--ex09
select distinct p.name
from person p
left join person_order po on p.id = po.person_id
left join menu m on po.menu_id = m.id
where p.gender = 'female' and m.pizza_name IN('cheese pizza', 'pepperoni pizza')
order by 1;

--ex10
select p1.name as person_name1, p2.name as person_name2, p1.address as common_address
from person p1
join person p2 on p1.address = p2.address and p1.id > p2.id
order by 1, 2, 3;
