--Day08

--ex00
-- Session #1
begin;
    update pizzeria set rating = 5 where name = 'Pizza Hut';

    select * from pizzeria where name = 'Pizza Hut';
commit;--использовать в первой сессии после отработки session #2 в другом окне
-- Session #2 Before Commit (делается в другом окне)
select * from pizzeria where name = 'Pizza Hut'; -- Rating 4.6
-- After Commit in Session #1
select * from pizzeria where name = 'Pizza Hut'; -- Rating 5

--ex01
--если установлен
show transaction isolation level;
--если не установлен
set transaction isolation level read committed;
-- Session #1
begin;
    select * from pizzeria where name = 'Pizza Hut';

    update pizzeria set rating = 4 where name = 'Pizza Hut';
commit;
-- Session #2
begin;
    select * from pizzeria where name = 'Pizza Hut';

    update pizzeria set rating = 3.6 where name = 'Pizza Hut';
commit;

--ex02
SHOW TRANSACTION ISOLATION LEVEL;
-- Session #1
begin isolation level repeatable read;
	select * from pizzeria where name = 'Pizza Hut';

    update pizzeria set rating = 4 where name = 'Pizza Hut';
commit;
-- Session #2
begin isolation level repeatable read;
    select * from pizzeria where name = 'Pizza Hut';

    update pizzeria set rating = 3.6 where name = 'Pizza Hut';
commit;

--ex03
--Session #1
begin;
select * from pizzeria where name = 'Pizza Hut'; -- 3.6
--Session #2 before commit
begin;
    update pizzeria set rating = 3.0 where name = 'Pizza Hut';
commit;
--Session #1 after commit
select * from pizzeria where name = 'Pizza Hut';
commit;

--ex04
--Session #1
begin isolation level serializable;
select * from pizzeria where name = 'Pizza Hut'; -- 3.0
--Session #2
begin;
    update pizzeria set rating = 5 where name = 'Pizza Hut';
commit;
--Session #1
select * from pizzeria where name = 'Pizza Hut';
commit;

--ex05
--Session #1
begin;
select sum(rating) from pizzeria;
--Session #2
begin;
    update pizzeria set rating = 1 where name = 'Pizza Hut';
commit;
--Session #1
select sum(rating) from pizzeria;
commit;

--ex06
--Session #1
begin isolation level repeatable read;
select sum(rating) from pizzeria; 
--Session #2
begin;
update pizzeria set rating = 5 where name = 'pizza hut';
commit;
--Session #1
select sum(rating) from pizzeria; -- сумма не изменилась без commit из session #2
commit;

--ex07
--Session #1
begin;
update pizzeria set rating = 5 where id = 1; -- блокирует pizza hut
--session #2
begin;
update pizzeria set rating = 5 where id = 2; -- блокирует dominos
--session #1
update pizzeria set rating = 5 where id = 2; -- ждет сессию №2
--session #2
update pizzeria set rating = 5 where id = 1; -- ждет сессию №1 (дедлок)
-- PostgreSQL автоматически откатит одну из транзакций.