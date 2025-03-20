--Day06
--ex00
create table person_discounts(
    id bigint primary key,
    person_id bigint not null ,
    pizzeria_id bigint not null,
    discount numeric,
    constraint fk_person_discounts_person_id foreign key(person_id) references person(id),
    constraint fk_person_discounts_pizzeria_id foreign key(pizzeria_id) references pizzeria(id)
);

--ex01
insert into person_discounts(id, person_id, pizzeria_id, discount)
select
    row_number() over() as id,
    po.person_id,
    m.pizzeria_id,
    case
        when count(*) = 1 then 10.5  
        when count(*) = 2 then 22 
        else 30
    end as discount
from person_order po
join menu m on po.menu_id = m.id
group by po.person_id, m.pizzeria_id;

--ex02
select p.name, m.pizza_name, m.price, (m.price * (1 - pd.discount / 100)) as discount_price, pz.name as pizzeria_name
from person p
join person_order po on po.person_id = p.id
join menu m on po.menu_id = m.id
join pizzeria pz on m.pizzeria_id = pz.id
join person_discounts pd on pd.person_id = p.id and pd.pizzeria_id = pz.id
order by p.name, m.pizza_name;

--ex03
create unique index idx_person_discounts_unique on person_discounts(person_id, pizzeria_id);
--план работы индекса
set enable_seqscan = false;
EXPLAIN ANALYZE
SELECT * FROM person_discounts WHERE person_id = 1 AND pizzeria_id = 1;
/*Index Scan using idx_person_discounts_unique on person_discounts  (cost=0.14..8.15 rows=1 width=56) (actual time=0.182..0.186 rows=1 loops=1)
  Index Cond: ((person_id = 1) AND (pizzeria_id = 1))
Planning Time: 0.203 ms
Execution Time: 0.223 ms*/

--ex04
alter table person_discounts
add constraint ch_nn_person_id check(person_id is not null),
add constraint ch_nn_pizzeria_id check(pizzeria_id is not null),
add constraint ch_nn_discount check(discount is not null),
alter column discount set default 0,
add constraint ch_range_discount check(discount between 0 and 100);

--ex05
comment on table person_discounts is 'Таблица персональных скидок для отдельных лиц в определенных пиццериях.';
comment on column person_discounts.id is 'Первичный ключ записи о скидке.';
comment on column person_discounts.person_id is 'Столбец указывает на человека, получающего скидку.';
comment on column person_discounts.pizzeria_id is 'Столбец указывает на пиццерию, где действует скидка.';
comment on column person_discounts.discount is 'Диапазон скидки составляет от 0 до 100.';

--ex06
create sequence seq_person_discounts;

select SETVAL('seq_person_discounts', (select MAX(id) + 1 from person_discounts));

alter table person_discounts 
alter column id set default nextval('seq_person_discounts');