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

WITH crn_tmp AS (
    SELECT
        crn.id,
        crn.rate_to_usd,
        crn.name,
        LAG(crn.updated) OVER(PARTITION by crn.id ORDER by crn.updated) prev_date,
        LEAD(crn.updated) OVER(PARTITION by crn.id ORDER by crn.updated) next_date,
        crn.updated cur_date
    FROM currency crn
    ),
    crn AS (
   SELECT
        id,
        rate_to_usd,
        name,
        COALESCE(prev_date, '1000-01-01') start_date,
        cur_date end_date
    FROM crn_tmp
    WHERE prev_date IS NULL
    UNION ALL
    SELECT
        id,
        rate_to_usd,
        name,
        cur_date start_date,
        COALESCE(next_date, '3000-01-01') end_date
    FROM crn_tmp
    )
SELECT
    COALESCE(us.name, 'not defined') name,
    COALESCE(us.lastname, 'not defined') lastname,
    COALESCE(crn.name, 'not defined') currency_name,
    crn.rate_to_usd * bl.money currency_in_usd
FROM balance bl
JOIN crn
    ON bl.currency_id = crn.id
    AND bl.updated > crn.start_date
    AND bl.updated <= crn.end_date
LEFT OUTER JOIN "user" us
    ON us.id = bl.user_id
ORDER by 1 desc, 2, 3;