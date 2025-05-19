--Day09

--ex00
create table person_audit (
    created timestamp with time zone default current_timestamp not null,
    type_event char(1) default 'i' not null,
    row_id bigint not null,
    name varchar,
    age integer,
    gender varchar,
    address varchar,
    constraint ch_type_event check (type_event in ('i', 'u', 'd'))
);

create or replace function fnc_trg_person_insert_audit() returns trigger as $$
begin
    insert into person_audit (row_id, name, age, gender, address)
    values (new.id, new.name, new.age, new.gender, new.address);
    return new;
end;
$$ language plpgsql;

create trigger trg_person_insert_audit
after insert on person
for each row
execute function fnc_trg_person_insert_audit();

--ex01
create or replace function fnc_trg_person_update_audit() returns trigger as $$
begin
    insert into person_audit (row_id, name, age, gender, address, type_event)
    values (old.id, old.name, old.age, old.gender, old.address, 'u');
    return new;
end;
$$ language plpgsql;

create trigger trg_person_update_audit
after update on person
for each row
execute function fnc_trg_person_update_audit();

--ex02
create or replace function fnc_trg_person_delete_audit() returns trigger as $$
begin
    insert into person_audit (row_id, name, age, gender, address, type_event)
    values (old.id, old.name, old.age, old.gender, old.address, 'd');
    return old;
end;
$$ language plpgsql;

create trigger trg_person_delete_audit
after delete on person
for each row
execute function fnc_trg_person_delete_audit();

--ex03
drop trigger if exists trg_person_insert_audit on person;
drop trigger if exists trg_person_update_audit on person;
drop trigger if exists trg_person_delete_audit on person;
drop function if exists fnc_trg_person_insert_audit();
drop function if exists fnc_trg_person_update_audit();
drop function if exists fnc_trg_person_delete_audit();
truncate table person_audit;

create or replace function fnc_trg_person_audit() returns trigger as $$
begin
    if (tg_op = 'insert') then
        insert into person_audit (row_id, name, age, gender, address, type_event)
        values (new.id, new.name, new.age, new.gender, new.address, 'i');
        return new;
    elsif (tg_op = 'update') then
        insert into person_audit (row_id, name, age, gender, address, type_event)
        values (old.id, old.name, old.age, old.gender, old.address, 'u');
        return new;
    elsif (tg_op = 'delete') then
        insert into person_audit (row_id, name, age, gender, address, type_event)
        values (old.id, old.name, old.age, old.gender, old.address, 'd');
        return old;
    end if;
end;
$$ language plpgsql;

create trigger trg_person_audit
after insert or update or delete on person
for each row
execute function fnc_trg_person_audit();

--ex04
create function fnc_persons_female()
returns table (id bigint, name varchar, age integer, gender varchar, address varchar) as $$
    select id, name, age, gender, address from person where gender = 'female';
$$ language sql;

create function fnc_persons_male()
returns table (id bigint, name varchar, age integer, gender varchar, address varchar) as $$
    select id, name, age, gender, address from person where gender = 'male';
$$ language sql;

--ex05
drop function if exists fnc_persons_female();
drop function if exists fnc_persons_male();

create function fnc_persons(pgender varchar default 'female')
returns table (id bigint, name varchar, age integer, gender varchar, address varchar) as $$
    select id, name, age, gender, address from person where gender = pgender;
$$ language sql;

--ex06
create or replace function fnc_person_visits_and_eats_on_date(
    pperson varchar default 'dmitriy',
    pprice numeric default 500,
    pdate date default '2022-01-08'
)
returns table (pizzeria_name varchar) as $$
begin
    return query
    select distinct pz.name::varchar
    from person_visits pv
    join person p on p.id = pv.person_id
    join menu m on m.pizzeria_id = pv.pizzeria_id
    join pizzeria pz on pz.id = pv.pizzeria_id
    where p.name = pperson
    and pv.visit_date = pdate
    and m.price < pprice;
end;
$$ language plpgsql;

--ex07
create function func_minimum(variadic arr numeric[])
returns numeric as $$
    select min(a) from unnest(arr) as a;
$$ language sql;

--ex08
create or replace function fnc_fibonacci(pstop integer default 10)
returns table (fibonacci_number integer) as $$
    with recursive fib(a, b) as (
        select 0, 1
        union all
        select b, a + b from fib where a < pstop
    )
    select a from fib where a < pstop;
$$ language sql;