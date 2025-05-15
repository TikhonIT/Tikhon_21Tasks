--Day04

--ex00
create view v_persons_female as
select *
from person
where gender = 'female';

select *
from v_persons_female;

create view v_persons_male as
select *
from person
where gender = 'male';

select *
from v_persons_male;

--ex01
(select name
from v_persons_female
union
select name
from v_persons_male)
order by 1;

--ex02
create view v_generated_dates as
select generated_date::DATE
from generate_series('2022-01-01', '2022-12-31', interval '1 day') as generated_date
order by generated_date;

select *
from v_generated_dates;

--ex03
select vd.generated_date as missing_date
from v_generated_dates vd
left join person_visits pv on vd.generated_date = pv.visit_date
where pv.visit_date is null
order by 1;

--ex04
create view v_symmetric_union as
(select person_id from person_visits where visit_date = '2022-01-02'
 except
 select person_id from person_visits where visit_date = '2022-01-06')
union
(select person_id from person_visits where visit_date = '2022-01-06'
 except
 select person_id from person_visits where visit_date = '2022-01-02');
 
select *
from v_symmetric_union;

--ex05
create view v_price_with_discount as
select p.name, m.pizza_name, m.price, round(m.price * 0.9) as discount_price
from person p
join person_order po on p.id = po.person_id
join menu m on m.id = po.menu_id
order by 1, 2;

select *
from v_price_with_discount;

--ex06
create materialized view mv_dmitriy_visits_and_eats as
select pi.name as pizzeria_name
from pizzeria pi
join person_visits pv on pi.id = pv.pizzeria_id
join person p on p.id = pv.person_id
join menu m on pi.id = m.pizzeria_id
where p.name = 'Dmitriy' 
    and pv.visit_date = '2022-01-08'
    and m.price < 800;

select *
from mv_dmitriy_visits_and_eats;

--ex07
INSERT INTO person_visits (id, person_id, pizzeria_id, visit_date)
VALUES (20, 9, 3, '2022-01-08');

--ex08
drop view v_persons_female;
drop view v_persons_male;
drop view v_generated_dates;
drop view v_symmetric_union;
drop view v_price_with_discount;
drop materialized view mv_dmitriy_visits_and_eats;
