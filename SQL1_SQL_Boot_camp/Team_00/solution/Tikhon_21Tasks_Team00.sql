--Team00
CREATE TABLE roads (
	point1 bpchar(1) NULL,
	point2 bpchar(1) NULL,
	cost int4 NULL
);

INSERT INTO roads (point1, point2, cost)
VALUES
    ('a', 'b', 10),
    ('b', 'a', 10),
    ('a', 'c', 15),
    ('c', 'a', 15),
    ('a', 'd', 20),
    ('d', 'a', 20),
    ('b', 'c', 35),
    ('c', 'b', 35),
    ('b', 'd', 25),
    ('d', 'b', 25),
    ('c', 'd', 30),
    ('d', 'c', 30);

--ex00
--var1
WITH RECURSIVE paths AS (
    SELECT 
        point2::text AS last_road,
        ARRAY['a', point2::text] AS tour,
        cost AS total_cost,
        1 AS depth
    FROM roads
    WHERE point1 = 'a'
    UNION ALL
    SELECT 
        r.point2::text AS last_road,
        p.tour || r.point2::text AS tour,
        p.total_cost + r.cost AS total_cost,
        p.depth + 1 AS depth
    FROM paths p
    JOIN roads r ON p.last_road = r.point1::text
    WHERE NOT r.point2::text = ANY(p.tour)
    AND depth < 3
),
complete_tours AS (
    SELECT 
        total_cost + (SELECT cost FROM roads WHERE point1::text = last_road AND point2 = 'a') AS total_cost,
        array_to_string(tour || ARRAY['a'], ',') AS tour
    FROM paths
    WHERE depth = 3
)
SELECT total_cost, '{' || tour || '}' as tour
FROM complete_tours
WHERE total_cost = (SELECT MIN(total_cost) FROM complete_tours)
ORDER BY total_cost, tour;
--var2
with 
    recursive tmp_tour(point1, point2, cost, is_cycle, path) 
    as (
        select 
            point1, 
            point2, 
            cost, 
            false is_cycle, 
            array[point1]||point2 path
        from 
            roads 
        where 
            point1 = 'a'
        union 
        select 
            r.point1, 
            r.point2, 
            tt.cost+r.cost cost, 
            (r.point2)= any(path), 
            path||r.point2
        from 
            tmp_tour tt, 
            roads r
        where 
            r.point1 = tt.point2 
            and not is_cycle
    ), 
    -- количество пунктов назначения
    point_cnt as(
        select 
            count(distinct point1) cnt
        from 
            roads   
    ),
    --выбираем только те туры, которые проходят по всем городам и вычисляем минимальную стоимость 
    tmp_tour_costs as(
        select 
            path, 
            cost, 
            min(cost) over() min_cost
        from 
            tmp_tour tt, 
            point_cnt pc 
        where
            point2 = 'a' AND
            cardinality(tt.path) = pc.cnt+1
    )
    --выбираем только туры с минимальной стоимостью
    select  
        ttc.cost total_cost, 
        concat(ttc.path) tour
    from 
        tmp_tour_costs ttc
    where 
        ttc.cost = min_cost
    order by 
        total_cost, tour

--ex01
--var1
WITH RECURSIVE paths AS (
    SELECT 
        point2::text AS last_road,
        ARRAY['a', point2::text] AS tour,
        cost AS total_cost,
        1 AS depth
    FROM roads
    WHERE point1 = 'a'
    UNION ALL
    SELECT 
        r.point2::text AS last_road,
        p.tour || r.point2::text AS tour,
        p.total_cost + r.cost AS total_cost,
        p.depth + 1 AS depth
    FROM paths p
    JOIN roads r ON p.last_road = r.point1::text
    WHERE NOT r.point2::text = ANY(p.tour)
    AND depth < 3
),
complete_tours AS (
    SELECT 
        total_cost + (SELECT cost FROM roads WHERE point1::text = last_road AND point2 = 'a') AS total_cost,
        array_to_string(tour || ARRAY['a'], ',') AS tour
    FROM paths
    WHERE depth = 3
),
min_max AS (
    SELECT MIN(total_cost) as min_cost, MAX(total_cost) as max_cost
    FROM complete_tours
)
SELECT total_cost, '{' || tour || '}' as tour
FROM complete_tours, min_max
WHERE total_cost = min_cost OR total_cost = max_cost
ORDER BY total_cost, tour;
--var2
with 
    recursive tmp_tour(point1, point2, cost, is_cycle, path) 
    as (
        select 
            point1, 
            point2, 
            cost, 
            false is_cycle, 
            array[point1]||point2 path
        from 
            roads 
        where 
            point1 = 'a'
        union 
        select 
            r.point1, 
            r.point2, 
            tt.cost+r.cost cost, 
            (r.point2)= any(path), 
            path||r.point2
        from 
            tmp_tour tt, 
            roads r
        where 
            r.point1 = tt.point2 
            and not is_cycle
    ), 
    -- количество пунктов назначения
    point_cnt as(
        select 
            count(distinct point1) cnt
        from 
            roads   
    ),
    --выбираем только те туры, которые проходят по всем городам и вычисляем минимальную и максимальную стоимости
    tmp_tour_costs as(
        select 
            path, 
            cost, 
            min(cost) over() min_cost,
            max(cost) over() max_cost
        from 
            tmp_tour tt, 
            point_cnt pc 
        where
            point2 = 'a' AND
            cardinality(tt.path) = pc.cnt+1
    )
    --выбираем только туры с минимальной и максимальной стоимостями
    select  
        ttc.cost total_cost, 
        concat(ttc.path) tour
    from 
        tmp_tour_costs ttc
    where 
        ttc.cost in(min_cost, max_cost)
    order by 
        total_cost, tour