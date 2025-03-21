--Day08
--ex00
-- Session #1
BEGIN;
UPDATE pizzeria SET rating = 5 WHERE name = 'Pizza Hut';
SELECT * FROM pizzeria WHERE name = 'Pizza Hut'; -- rating 5
COMMIT;--использовать в первой сессии после отработки session #2 в другом окне
-- Session #2 Before Commit (делается в другом окне)
SELECT * FROM pizzeria WHERE name = 'Pizza Hut'; -- Rating 4.6
-- After Commit in Session #1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut'; -- Rating 5

--ex01
--если установлен
SHOW TRANSACTION ISOLATION LEVEL;
--если не установлен
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Session #1
BEGIN;
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
UPDATE pizzeria SET rating = 4 WHERE name = 'Pizza Hut';
COMMIT;
-- Session #2
BEGIN;
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
UPDATE pizzeria SET rating = 3.6 WHERE name = 'Pizza Hut';
COMMIT;

--ex02
SHOW TRANSACTION ISOLATION LEVEL;
-- Session #1
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
UPDATE pizzeria SET rating = 4 WHERE name = 'Pizza Hut';
COMMIT;
-- Session #2
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
UPDATE pizzeria SET rating = 3.6 WHERE name = 'Pizza Hut';
COMMIT;

--ex03
--Session #1
BEGIN;
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut'; -- 3.6
--Session #2 before commit
BEGIN;
UPDATE pizzeria SET rating = 3.0 WHERE name = 'Pizza Hut';
COMMIT;
--Session #1 after commit
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut'; -- 3.0
COMMIT;

--ex04
--Session #1
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut'; -- 3.0
--Session #2
BEGIN;
UPDATE pizzeria SET rating = 5 WHERE name = 'Pizza Hut';
COMMIT;
--Session #1
SELECT rating FROM pizzeria WHERE name = 'Pizza Hut'; -- 3.0 нет изменений без commit из Session #2
COMMIT;

--ex05
--Session #1
BEGIN;
SELECT SUM(rating) FROM pizzeria;
--Session #2
BEGIN;
UPDATE pizzeria SET rating = 1 WHERE name = 'Pizza Hut';
COMMIT;
--Session #1
SELECT SUM(rating) FROM pizzeria; -- Сумма изменилась при commit из Session #2
COMMIT;

--ex06
--Session #1
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT SUM(rating) FROM pizzeria; 
--Session #2
BEGIN;
UPDATE pizzeria SET rating = 5 WHERE name = 'Pizza Hut';
COMMIT;
--Session #1
SELECT SUM(rating) FROM pizzeria; -- Сумма не изменилась без commit из Session #2
COMMIT;

--ex07
--Session #1
BEGIN;
UPDATE pizzeria SET rating = 5 WHERE id = 1; -- Блокирует Pizza Hut
--Session #2
BEGIN;
UPDATE pizzeria SET rating = 5 WHERE id = 2; -- Блокирует Dominos
--Session #1
UPDATE pizzeria SET rating = 5 WHERE id = 2; -- Ждет Сессию №2
--Session #2
UPDATE pizzeria SET rating = 5 WHERE id = 1; -- Ждет Сессию №1 (дедлок)
-- PostgreSQL автоматически откатит одну из транзакций.