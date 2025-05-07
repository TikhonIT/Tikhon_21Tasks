--Day00

--ex00
select name, age
from person
where address = 'Kazan';

--ex01
select name, age
from person
where gender = 'female' and address = 'Kazan'
order by name;

--ex02
select name, rating
from pizzeria
where rating >= 3.5 and rating <= 5
order by rating;

select name, rating
from pizzeria
where rating between 3.5 and 5
order by rating;

--ex03
select distinct id
from person_visits
where visit_date between '2022-01-06' and '2022-01-09' or pizzeria_id = 2
order by id desc;

--ex04
select concat(name, ' (age:', age, ''',gender:''', gender, ''',address:''', address, ''')')
from person
order by 1;

--ex05
select (select name from person where id = po.person_id) as name
from person_order po
where po.menu_id IN(13, 14, 18) and order_date = '2022-01-07';

--ex06
select 
    (select name from person where id = po.person_id) as name,
    (select name from person where id = po.person_id) = 'Denis' as check_name
from person_order po
where po.menu_id IN(13, 14, 18) and order_date = '2022-01-07';

--ex07
select 
    id, 
    name,
    case
        when age between 10 and 20 then 'interval #1'
        when age > 20 and age < 24 then 'interval #2'
        else 'interval #3'
    end as interval_info
from person
order by interval_info;

--ex08
select *
from person_order
where id % 2 = 0
order by id;

--ex09
select 
    (select name from person where id = pv.person_id) as person_name,
    (select name from pizzeria where id = pv.pizzeria_id) as pizzeria_name
from (select person_id, pizzeria_id from person_visits where visit_date between '2022-01-07' and '2022-01-09') as pv
order by 1, 2 desc