--LeetCode Questions: Sorting and Grouping

------Q1. Number of Unique Subjects Taught by Each Teacher [Easy]

select teacher_id, count(distinct subject_id) as cnt
from Teacher
group by teacher_id;

------Q2. User Activity for the Past 30 Days I

select * from (
select activity_date as day, count(distinct user_id) as active_users
from Activity
where activity_type in ('open_session','end_session','scroll_down', 'send_message')
group by activity_date) a
where active_users != 0 and day <= '2019-07-27' and day > '2019-06-27'
order by day

/*date_sub('2019-07-27, interval 29 day) can be used instead of hard-coding date!*/

select activity_date as day, count(distinct user_id) as active_users
from Activity
where  activity_date >= date_sub('2019-07-27', interval 29 day) and activity_date <= '2019-07-27'
group by activity_date


------Q3. Product Sales Analysis III [Medium]
--LC Question description incorrect

--Solution as per LC
with cte1 as
(select product_id, year as first_year, quantity, price from
(select *, rank() over(partition by product_id order by year) as rn
from Sales) a
where rn = 1)

select c.* 
from cte1 c
inner join Product p
on c.product_id = p.product_id

--2nd Solution

with cte1 as
(select *, quantity*price as price1
from sales)

, cte2 as
(select *, rank() over(partition by product_id order by year) as rn  from
(select product_id, year, sum(quantity) as quantity, sum(price1)/sum(quantity) as price
from cte1
group by product_id, year)a)

select p.product_id, b.first_year, b.quantity, b.price from 
product p
inner join
(select product_id, year as first_year, quantity, round(price,0) as price from cte2 where rn = 1) b
on p.product_id = b.product_id

------Q4. Classes More Than 5 Students [Easy]

select class
from Courses
group by class
having count(distinct student) >= 5

------Q5. Find Followers Count [Easy]

select user_id, count(distinct follower_id) as followers_count
from Followers
group by user_id

------Q6. Biggest Single Number [Easy]

select max(num) as num from ---------NOTE: using max(num) instead order by num desc limit 1 will give num while latter won't return null
(select num
from MyNumbers
group by num 
having count(*) = 1) a

------Q7. Customers Who Bought All Products [Medium]

select customer_id from
(select customer_id, count(distinct product_key) as cnt
from Customer
group by customer_id) a
where cnt = (select count(*) from Product)

