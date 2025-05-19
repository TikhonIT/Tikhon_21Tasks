--Team01

--ex00
with cte_currency as(
    select 
        id, 
        name, 
        rate_to_usd, 
        row_number() over(partition by id order by updated desc) as rn
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
    name desc,
    lastname,
    type;
	
--ex01
insert into currency values (100, 'eur', 0.85, '2022-01-01 13:29');
insert into currency values (100, 'eur', 0.79, '2022-01-08 13:29');

with crn_tmp as (
    select
        crn.id,
        crn.rate_to_usd,
        crn.name,
        lag(crn.updated) over(partition by crn.id order by crn.updated) prev_date,
        lead(crn.updated) over(partition by crn.id order by crn.updated) next_date,
        crn.updated cur_date
    from currency crn
    ),
    crn as (
   select
        id,
        rate_to_usd,
        name,
        coalesce(prev_date, '1000-01-01') start_date,
        cur_date end_date
    from crn_tmp
    where prev_date is null
    union all
    select
        id,
        rate_to_usd,
        name,
        cur_date start_date,
        coalesce(next_date, '3000-01-01') end_date
    from crn_tmp
    )
select
    coalesce(us.name, 'not defined') name,
    coalesce(us.lastname, 'not defined') lastname,
    coalesce(crn.name, 'not defined') currency_name,
    crn.rate_to_usd * bl.money currency_in_usd
from balance bl
join crn
    on bl.currency_id = crn.id
    and bl.updated > crn.start_date
    and bl.updated <= crn.end_date
left outer join "user" us
    on us.id = bl.user_id
order by 1 desc, 2, 3;