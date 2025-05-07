--Day01

--ex00
(select id as object_id, name as object_name
from person
union
select id, pizza_name
from menu)
order by 1, 2;

--ex01
select object_name
from ((select name as object_name
      from person
      order by 1)
      union all
      (select pizza_name
      from menu
      order by 1)) as o;

--ex02
select distinct pizza_name
from menu
order by pizza_name desc;

--ex03
(select order_date as action_date, person_id
from person_order
intersect
select visit_date, person_id
from person_visits)
order by 1, 2 desc;

--ex04
select person_id
from person_order
where order_date = '2022-01-07'
except all
select person_id
from person_visits
where visit_date = '2022-01-07';

--ex05
select p.id, p.name, p.age, p.gender, p.address, pi.id, pi.name, pi.rating
from person p
cross join pizzeria pi
order by 1, 6;

--ex06
(select po.order_date as action_date, p.name
from person_order po
join person p on p.id = po.person_id
intersect
select pv.visit_date, p.name
from person_visits pv
join person p on p.id = pv.person_id)
order by 1, 2 desc;

--ex07
select po.order_date as action_date, concat(p.name, ' (возраст:', p.age, ')') as person_information
from person_order po
join person p on p.id = po.person_id
order by 1, 2;

--ex08
select order_date, name || ' (возраст:' || age || ')' as person_information
from (select person_id as id, order_date from person_order) po
natural join person
order by 1, 2;

--ex09
select name as pizzeria_name
from pizzeria
where id not in(select pizzeria_id
                from person_visits);

select name as pizzeria_name
from pizzeria p
where not exists(select pv.pizzeria_id
                 from person_visits pv
                 where p.id = pv.pizzeria_id);

select p.name as pizzeria_name
from pizzeria p
left join person_visits pv on p.id = pv.pizzeria_id
where pv.pizzeria_id is null;

--ex10
select p.name as person_name, m.pizza_name, pi.name as pizzeria_name
from person_order po
join person p on po.person_id = p.id
join menu m on po.menu_id = m.id
join pizzeria pi on m.pizzeria_id = pi.id
order by 1, 2, 3;