--LeetCode Questions: Part 2

------1. Replace Employee ID With The Unique Identifier [Easy]

select EmployeeUNI.unique_id as unique_id, Employees.name 
from Employees
left join EmployeeUNI
on Employees.id = EmployeeUNI.id;


------2. Product Sales Analysis I [Easy]

select p.product_name, s.year, s.price
from Sales s
left join Product p
on s.product_id = p.product_id

------3. Customer Who Visited but Did Not Make Any Transactions [Easy]

select v.customer_id, count(*) as count_no_trans
from Visits v
left join Transactions t
on v.visit_id = t.visit_id
where t.transaction_id is null
group by v.customer_id;

------4. Rising Temperature [Easy]

with prev_temp as (select *
, date_add(recordDate, INTERVAL 1 DAY) as nxt_date
from weather),


final_table as (select w.id, p.recordDate as prev_date, p.temperature as prev_temp, p.nxt_date as date, w.temperature as temp
from prev_temp p
inner join Weather w
on p.nxt_date = w.recordDate)

select id
from final_table
where temp > prev_temp


------5. Average Time of Process per Machine [Easy]

select machine_id, round((end_time - start_time)/no_of_processes, 3) as processing_time from
(select machine_id
, sum(case when activity_type = 'start' then timestamp end) as start_time
, sum(case when activity_type = 'end' then timestamp end) as end_time
, count(distinct process_id) as no_of_processes
from Activity
group by machine_id) a


------6. Employee Bonus [Easy]

select e.name, b.bonus
from Employee e
left join Bonus b
on e.empId = b.empId
where b.bonus < 1000 or b.bonus is null

------7. Students and Examinations [Easy]

with cte1 as
(select a.*, e.subject_name as subject_name1 from
((select * 
from Students
cross join Subjects) a
left join
Examinations e
on a.student_id = e.student_id and a.subject_name = e.subject_name))

select student_id,student_name, subject_name, count(subject_name1) as attended_exams
from cte1
group by student_id,student_name, subject_name
order by student_id, subject_name

------8. Managers with at Least 5 Direct Reports [Medium]

select manager_name as name from
(select e1.*, e2.name as manager_name 
from Employee e1
inner join Employee e2 
on e1.managerId = e2.id) a
group by managerId, manager_name
having count(a.id) >= 5

------9. Confirmation Rate [Medium]

with cte1 as
(select s.user_id, c.time_stamp, c.action
from Confirmations c
right join Signups s
on c.user_id = s.user_id)

,cte2 as
(select user_id, count(action) as total_requested_confirmation
from cte1
group by user_id)

,cte3 as
(select *, count(*) as total_no_of_confirmed from
cte1
where action = 'confirmed'
group by user_id)

,cte4 as
(select a.user_id, round((b.total_no_of_confirmed/a.total_requested_confirmation),2) as confirmation_rate
from cte2 a
left join cte3 b
on a.user_id = b.user_id)

select user_id, coalesce(confirmation_rate, 0) as confirmation_rate from cte4
order by confirmation_rate