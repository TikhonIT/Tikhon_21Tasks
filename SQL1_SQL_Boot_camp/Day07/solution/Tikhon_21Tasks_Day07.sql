--Day07

--ex00
select person_id, count(*) as count_of_visits
from person_visits
group by person_id
order by 2 desc, 1;

--ex01
with visits_count as(
    select person_id, count(*) as count_of_visits
    from person_visits
    group by person_id
    order by 2 desc, 1
    limit 4
)
select p.name, vc.count_of_visits
from person p
join visits_count vc on p.id = vc.person_id
order by 2 desc, 1;

--ex02
(select pi.name, count(*) as count, 'order' as action_type
from pizzeria pi
join menu m on pi.id = m.pizzeria_id
join person_order po on po.menu_id = m.id
group by pi.name
order by 2 desc
limit 3)
union all
(select pi.name, count(*) as count, 'visit' as action_type
from pizzeria pi
join person_visits pv on pv.pizzeria_id = pi.id
group by pi.name
order by 2 desc
limit 3)
order by 3, 2 desc;

--ex03
with sum_counts as(
(select pi.name, count(*) as count, 'order' as action_type
from pizzeria pi
join menu m on pi.id = m.pizzeria_id
join person_order po on po.menu_id = m.id
group by pi.name
order by 2 desc
limit 3)
union all
(select pi.name, count(*) as count, 'visit' as action_type
from pizzeria pi
join person_visits pv on pv.pizzeria_id = pi.id
group by pi.name
order by 2 desc
limit 3)
order by 3, 2 desc
)
select name, sum(count) as sum_count
from sum_counts
group by name
order by 2 desc;

--ex04
with visits_count as(
    select person_id, count(*) as count_of_visits
    from person_visits
    group by person_id
    having count(*) > 3
    order by 2 desc, 1
)
select p.name, vc.count_of_visits
from person p
join visits_count vc on p.id = vc.person_id
order by 2 desc, 1;

--ex05
select distinct p.name
from person p
join person_visits pv on p.id = pv.person_id
order by 1;

--ex06
select pi.name, count(*) as count_of_orders, round(avg(m.price), 2) as average_price, max(m.price) as max_price, min(m.price) as min_price
from person_order po
join menu m on m.id = po.menu_id
join pizzeria pi on pi.id = m.pizzeria_id
group by pi.name
order by 1;

--ex07
select round(avg(rating), 4) as avg_rating
from pizzeria;

--ex08
select p.address, pi.name, count(*) as count_of_orders
from person p
join person_order po on p.id = po.person_id
join menu m on m.id = po.menu_id
join pizzeria pi on pi.id = m.pizzeria_id
group by p.address, pi.name
order by 1, 2;

--ex09
select 
    address, 
    round(max(age) - min(age) / max(age)::numeric, 2) as formula, 
    round(avg(age), 2) as average,
    case
        when round(max(age) - min(age) / max(age)::numeric, 2) > round(avg(age), 2) then 'true'
        else 'false'
    end as comparison    
from person
group by address
order by 1;