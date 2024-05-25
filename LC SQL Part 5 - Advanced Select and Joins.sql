--LeetCode Questions: Advanced Select and Joins

------Q1. The Number of Employees Which Report to Each Employee [Easy]

Select e1.reports_to as employee_id, e2.name, count(*) as reports_count, round(avg(e1.age),0) as average_age
from Employees e1
inner join Employees e2
on e1.reports_to = e2.employee_id
group by e1.reports_to, e2.name
having  count(*) >= 1
order by e1.reports_to

------Q2. Primary Department for Each Employee [Easy]

select a.*, e1.department_id from 
((select employee_id
from Employee
group by employee_id
having count(department_id) = 1) a
inner join Employee e1 
on a.employee_id = e1.employee_id)
union all
select b.*, e2.department_id from
((select employee_id
from Employee
group by employee_id
having count(department_id) > 1) b
inner join Employee e2
on (b.employee_id = e2.employee_id) and e2.primary_flag = 'Y')

------Q3. Triangle Judgement [Easy]

with cte1 as
(select *
,(case when x+y > z then 'Y' else 'N' end) as chk1
,(case when y+z > x then 'Y' else 'N' end) as chk2
,(case when z+x > y then 'Y' else 'N' end) as chk3
from Triangle)

select x, y, z
,(case when chk1 = 'Y' and chk2 = 'Y' and chk3 = 'Y' then 'Yes' else 'No' end) as triangle
 from cte1

 ------Q4. Consecutive Numbers [Medium]

 with cte1 as
(select a.*, l3.id as id3, l3.num as num3 from (
(select l1.id as id1, l1.num as num1, l2.id as id2, l2.num as num2
from Logs l1
inner join Logs l2 
on l1.id + 1  = l2.id) a
inner join
Logs l3
on a.id1 + 2 = l3.id))

select distinct * from
(select (case when num1 = num2 and num1 = num3 then num1 end) as ConsecutiveNums from cte1) b
where ConsecutiveNums is not null

------Q5. Product Price at a Given Date [Medium]

with cte1 as
(select *
from Products
where change_date <= '2019-08-16')

,cte2 as
(select product_id, new_price as price from
(select *
, rank() over(partition by product_id order by change_date desc) as rn
from cte1) a
where rn = 1
)

select distinct p.product_id, coalesce(c.price, 10) as price
from Products p left join cte2 c
on p.product_id = c.product_id

------Q6. Last Person to Fit in the Bus [Medium]

select person_name from(
select *
,sum(weight) over(order by turn) as sum1
from Queue) a
where sum1 <= 1000
order by sum1 desc
limit 1

------Q7. Count Salary Categories [Medium]

with cte1 as
(select *
,(case when income < 20000 then 'Low Salary' when income between 20000 and 50000 then 'Average Salary' else 'High Salary' end) as Category
from Accounts)

,cte2 as
(select Category, count(*) as accounts_count
from cte1
group by category)

, cte3 as
(select 'High Salary' as category
union all select 'Average Salary'
union all select 'Low Salary')

select c1.*, coalesce(c2.accounts_count,0) as accounts_count from cte3 c1
left join cte2 c2
on c1.Category = c2.Category

----------------
select 'Low Salary' as category, sum(income < 20000) AS accounts_count
from Accounts
union all 
select 'Average Salary' as category, sum(income BETWEEN 20000 AND 50000 ) as accounts_count
from Accounts
union all
select 'High Salary' as category, sum(income > 50000) as accounts_count
from Accounts;