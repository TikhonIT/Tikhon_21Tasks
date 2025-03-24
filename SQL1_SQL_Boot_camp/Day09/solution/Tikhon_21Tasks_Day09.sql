--Day09
--ex00
CREATE TABLE person_audit (
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    type_event char(1) DEFAULT 'I' NOT NULL,
    row_id bigint NOT NULL,
    name varchar,
    age integer,
    gender varchar,
    address varchar,
    CONSTRAINT ch_type_event CHECK (type_event IN ('I', 'U', 'D'))
);

CREATE OR REPLACE FUNCTION fnc_trg_person_insert_audit() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO person_audit (row_id, name, age, gender, address)
    VALUES (NEW.id, NEW.name, NEW.age, NEW.gender, NEW.address);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_insert_audit
AFTER INSERT ON person
FOR EACH ROW
EXECUTE FUNCTION fnc_trg_person_insert_audit();

--ex01
CREATE OR REPLACE FUNCTION fnc_trg_person_update_audit() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO person_audit (row_id, name, age, gender, address, type_event)
    VALUES (OLD.id, OLD.name, OLD.age, OLD.gender, OLD.address, 'U');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_update_audit
AFTER UPDATE ON person
FOR EACH ROW
EXECUTE FUNCTION fnc_trg_person_update_audit();

--ex02
CREATE OR REPLACE FUNCTION fnc_trg_person_delete_audit() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO person_audit (row_id, name, age, gender, address, type_event)
    VALUES (OLD.id, OLD.name, OLD.age, OLD.gender, OLD.address, 'D');
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_delete_audit
AFTER DELETE ON person
FOR EACH ROW
EXECUTE FUNCTION fnc_trg_person_delete_audit();

--ex03
DROP TRIGGER IF EXISTS trg_person_insert_audit ON person;
DROP TRIGGER IF EXISTS trg_person_update_audit ON person;
DROP TRIGGER IF EXISTS trg_person_delete_audit ON person;
DROP FUNCTION IF EXISTS fnc_trg_person_insert_audit();
DROP FUNCTION IF EXISTS fnc_trg_person_update_audit();
DROP FUNCTION IF EXISTS fnc_trg_person_delete_audit();
TRUNCATE TABLE person_audit;

CREATE OR REPLACE FUNCTION fnc_trg_person_audit() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO person_audit (row_id, name, age, gender, address, type_event)
        VALUES (NEW.id, NEW.name, NEW.age, NEW.gender, NEW.address, 'I');
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO person_audit (row_id, name, age, gender, address, type_event)
        VALUES (OLD.id, OLD.name, OLD.age, OLD.gender, OLD.address, 'U');
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO person_audit (row_id, name, age, gender, address, type_event)
        VALUES (OLD.id, OLD.name, OLD.age, OLD.gender, OLD.address, 'D');
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_audit
AFTER INSERT OR UPDATE OR DELETE ON person
FOR EACH ROW
EXECUTE FUNCTION fnc_trg_person_audit();

--ex04
CREATE FUNCTION fnc_persons_female()
RETURNS TABLE (id bigint, name varchar, age integer, gender varchar, address varchar) AS $$
    SELECT id, name, age, gender, address FROM person WHERE gender = 'female';
$$ LANGUAGE SQL;

CREATE FUNCTION fnc_persons_male()
RETURNS TABLE (id bigint, name varchar, age integer, gender varchar, address varchar) AS $$
    SELECT id, name, age, gender, address FROM person WHERE gender = 'male';
$$ LANGUAGE SQL;

--ex05
DROP FUNCTION IF EXISTS fnc_persons_female();
DROP FUNCTION IF EXISTS fnc_persons_male();

CREATE FUNCTION fnc_persons(pgender varchar DEFAULT 'female')
RETURNS TABLE (id bigint, name varchar, age integer, gender varchar, address varchar) AS $$
    SELECT id, name, age, gender, address FROM person WHERE gender = pgender;
$$ LANGUAGE SQL;

--ex06
CREATE OR REPLACE FUNCTION fnc_person_visits_and_eats_on_date(
    pperson varchar DEFAULT 'Dmitriy',
    pprice numeric DEFAULT 500,
    pdate date DEFAULT '2022-01-08'
)
RETURNS TABLE (pizzeria_name varchar) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT pz.name::varchar
    FROM person_visits pv
    JOIN person p ON p.id = pv.person_id
    JOIN menu m ON m.pizzeria_id = pv.pizzeria_id
    JOIN pizzeria pz ON pz.id = pv.pizzeria_id
    WHERE p.name = pperson
    AND pv.visit_date = pdate
    AND m.price < pprice;
END;
$$ LANGUAGE plpgsql;

--ex07
CREATE FUNCTION func_minimum(VARIADIC arr numeric[])
RETURNS numeric AS $$
    SELECT MIN(a) FROM unnest(arr) AS a;
$$ LANGUAGE SQL;

--ex08
CREATE OR REPLACE FUNCTION fnc_fibonacci(pstop integer DEFAULT 10)
RETURNS TABLE (fibonacci_number integer) AS $$
    WITH RECURSIVE fib(a, b) AS (
        SELECT 0, 1
        UNION ALL
        SELECT b, a + b FROM fib WHERE a < pstop
    )
    SELECT a FROM fib WHERE a < pstop;
$$ LANGUAGE SQL;