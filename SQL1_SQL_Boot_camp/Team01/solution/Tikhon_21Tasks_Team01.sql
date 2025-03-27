--Team01
--ex00
with cte_currency as(
    select 
        id, 
        name, 
        rate_to_usd, 
        row_number() over(partition by id order by updated DESC) as rn
    from currency
)
select 
    coalesce(u.name, 'not defined') as name, 
    coalesce(u.lastname, 'not defined') as lastname, 
    b.type, 
    sum(b.money) as volume, 
    coalesce(c.name, 'not defined') as currency_name,
    coalesce(c.rate_to_usd, 1) as last_rate_to_usd,
    sum(b.money) * coalesce(c.rate_to_usd, 1) as total_volume_in_usd
from balance b
left join "user" u on u.id = b.user_id
left join cte_currency c on c.id = b.currency_id and c.rn = 1
group by
    coalesce(u.name, 'not defined'),
    coalesce(u.lastname, 'not defined'),
    b.type,
    coalesce(c.name, 'not defined'),
    coalesce(c.rate_to_usd, 1)
order by
    name DESC,
    lastname,
    type;
	
--ex01
insert into currency values (100, 'EUR', 0.85, '2022-01-01 13:29');
insert into currency values (100, 'EUR', 0.79, '2022-01-08 13:29');

select 
    coalesce(u.name, 'not defined') as name,
    coalesce(u.lastname, 'not defined') as lastname,
    c.name as currency_name,
    (b.money * coalesce(rate.rate_to_usd, 1)) as currency_in_usd
from balance b
join currency c on b.currency_id = c.id
left join "user" u on b.user_id = u.id
cross join lateral(
    select rate_to_usd
    from(
            (select c1.rate_to_usd       
             from currency c1
             where c1.id = b.currency_id and c1.updated <= b.updated
             order by c1.updated desc
             limit 1)
            union all
            (select c2.rate_to_usd
             from currency c2
             where c2.id = b.currency_id and c2.updated > b.updated
             order by c2.updated asc
             limit 1)
    ) as sub
    limit 1
) as rate
group by
    coalesce(u.name, 'not defined'),
    coalesce(u.lastname, 'not defined'),
    c.name,
    (b.money * coalesce(rate.rate_to_usd, 1))
order by 
    name DESC,
    lastname,
    currency_name;