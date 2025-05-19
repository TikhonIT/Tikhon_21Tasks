--Team00

create table roads (
	point1 bpchar(1) null,
	point2 bpchar(1) null,
	cost int4 null
);

insert into roads (point1, point2, cost)
values
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
with recursive paths as (
    select 
        point2::text as last_road,
        array['a', point2::text] as tour,
        cost as total_cost,
        1 as depth
    from roads
    where point1 = 'a'
    union all
    select 
        r.point2::text as last_road,
        p.tour || r.point2::text as tour,
        p.total_cost + r.cost as total_cost,
        p.depth + 1 as depth
    from paths p
    join roads r on p.last_road = r.point1::text
    where not r.point2::text = any(p.tour)
    and depth < 3
),
complete_tours as (
    select 
        total_cost + (select cost from roads where point1::text = last_road and point2 = 'a') as total_cost,
        array_to_string(tour || array['a'], ',') as tour
    from paths
    where depth = 3
)
select total_cost, '{' || tour || '}' as tour
from complete_tours
where total_cost = (select min(total_cost) from complete_tours)
order by total_cost, tour;
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
            point2 = 'a' and
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
        total_cost, tour;

--ex01
--var1
with recursive paths as (
    select 
        point2::text as last_road,
        array['a', point2::text] as tour,
        cost as total_cost,
        1 as depth
    from roads
    where point1 = 'a'
    union all
    select 
        r.point2::text as last_road,
        p.tour || r.point2::text as tour,
        p.total_cost + r.cost as total_cost,
        p.depth + 1 as depth
    from paths p
    join roads r on p.last_road = r.point1::text
    where not r.point2::text = any(p.tour)
    and depth < 3
),
complete_tours as (
    select 
        total_cost + (select cost from roads where point1::text = last_road and point2 = 'a') as total_cost,
        array_to_string(tour || array['a'], ',') as tour
    from paths
    where depth = 3
),
min_max as (
    select min(total_cost) as min_cost, max(total_cost) as max_cost
    from complete_tours
)
select total_cost, '{' || tour || '}' as tour
from complete_tours, min_max
where total_cost = min_cost or total_cost = max_cost
order by total_cost, tour;
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
            point2 = 'a' and
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
        total_cost, tour;