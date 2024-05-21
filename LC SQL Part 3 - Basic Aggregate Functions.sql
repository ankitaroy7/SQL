
--LeetCode Questions: Basic Aggregate Functions

------Q1. Not Boring Movies [Easy]
 
select *
from Cinema
where mod(id, 2) != 0
and description not in ('boring')
order by rating desc

------Q2. Average Selling Price [Easy]

with cte1 as 
(select p.*, u.units, p.price * u.units as price1
from Prices p
left join UnitsSold u
on p.start_date <= u.purchase_date and p.end_date >= u.purchase_date and p.product_id = u.product_id)

,cte2 as
(select product_id, round((total_price/total_units),2) as average_price from (
select product_id, sum(price1) as total_price, coalesce(sum(units),0) as total_units
from cte1
group by product_id) a)

select product_id, coalesce(average_price, 0) as average_price
from cte2

------Q3. Project Employees I [Easy]

select p.project_id, round(avg(experience_years),2) as average_years
from Project p
left join Employee e
on p.employee_id = e.employee_id
group by project_id

------Q4. Percentage of Users Attended a Contest [Easy]

select contest_id, round(percentage,2) as percentage from
(select contest_id, count(*)*100/(select count(distinct user_id)from Users) as percentage
from Register
group by contest_id) a
order by percentage desc, contest_id

------Q5. Queries Quality and Percentage [Easy]

with cte1 as
(select query_name, round(avg(ratio),2) as quality, count(*) as total_count from
(select *, (rating/position) as ratio
from Queries) a
group by query_name)

select c.query_name, c.quality, round((coalesce(b.ratinglessthan3,0)*100/c.total_count),2) as poor_query_percentage from
((select query_name, count(*) as ratinglessthan3
from Queries
where rating < 3
group by query_name) b
right join cte1 c
on c.query_name = b.query_name)
where c.query_name is not null


------Q6. Monthly Transactions I [Medium]
--Imp. Joining null to null--
with cte1 as
(select month, country, state, count(state) as cnt, sum(amount) as trx_amt from
(select *, left(trans_date, 7) as month from Transactions) a
group by month, country, state)

,cte2 as
(select month, country, coalesce(sum(case when state = 'approved' then cnt end),0) as approved_count
,coalesce(sum(case when state != 'declined' then trx_amt end),0) as approved_total_amount
from cte1
group by month, country)



select b.month, b.country, b.trans_count, c.approved_count , b.trans_total_amount, c.approved_total_amount from (
(select month, country, sum(cnt) as trans_count, sum(trx_amt) as trans_total_amount
from cte1
group by month, country) b
left join cte2 c
on b.month = c.month and (b.country = c.country or (b.country is null and c.country is null)))

------Q7. Immediate Food Delivery II [Medium]

with cte1 as
(select d.*, a.first_order
from Delivery d
inner join 
(select customer_id, min(order_date) as first_order
from Delivery
group by customer_id) a
on d.customer_id = a.customer_id)

,cte2 as
(select *, (case when order_date = customer_pref_delivery_date then 'immediate' else 'scheduled' end) as delivery_type
from cte1) 

select round(((select count(*) from cte2 where order_date = first_order and delivery_type = 'immediate')*100/(select count(*) from cte2 where order_date = first_order)),2) as immediate_percentage

------Q8. Game Play Analysis IV [Medium]

with cte1 as
(select *
,rank() over(partition by player_id order by event_date) as date_order
from Activity)

,cte2 as
(select player_id, event_date, date_add(event_date, interval 1 day) as next_event_date , date_order
from cte1
where date_order = 1)

,cte3 as
(select count(*) as req_num  from (
select a.*, b.next_event_date from 
((select *
from cte1
where date_order = 2) a
left join cte2 b
on a.player_id = b.player_id) 
where a.event_date = b.next_event_date) sq)

select round((select req_num from cte3)/(select count(distinct player_id) from Activity),2) as fraction
