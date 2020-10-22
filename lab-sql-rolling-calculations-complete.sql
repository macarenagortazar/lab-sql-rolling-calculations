-- Lab | SQL Rolling calculations

-- In this lab, you will be using the Sakila database of movie rentals.
use sakila;

-- Instructions

-- 1. Get number of monthly active customers.

-- > Step 1: Getting the user activity

create or replace view customer_activity as (
select customer_id, convert(rental_date, date) as Activity_date,
date_format(convert(rental_date,date), '%m') as Activity_Month,
date_format(convert(rental_date,date), '%Y') as Activity_year
from sakila.rental);
select * from customer_activity;

-- > Step 2: Getting the active users per month

create or replace view monthly_active as(
select count(distinct customer_id) as Active_customers, Activity_year, Activity_Month
from customer_activity
group by Activity_year, Activity_Month
order by Activity_year, Activity_Month);
select *from montly_active;


-- 2. Active users in the previous month.
with cte_activity as (
select Active_customers, lag(Active_customers,1) over (partition by Activity_year) as active_last_month, Activity_year, Activity_Month
from monthly_active
)
select*from cte_activity
where active_last_month is not null;


-- 3. Percentage change in the number of active customers.
with cte_activity as (
select Active_customers, lag(Active_customers,1) over (partition by Activity_year) as active_last_month, (Active_customers-lag(Active_customers,1) over (partition by Activity_year))/Active_customers*100 as percentage_change, Activity_year, Activity_Month
from monthly_active
)
select*from cte_activity
where active_last_month is not null;

-- 4. Retained customers every month.

with distinct_customers as (
  select distinct customer_id , Activity_Month, Activity_year
  from customer_activity
)
select count(distinct d1.customer_id) as Retained_customers, d1.Activity_Month, d1.Activity_year
from distinct_customers d1
join distinct_customers d2 on d1.customer_id = d2.customer_id
and d1.Activity_month = d2.Activity_month + 1
group by d1.Activity_month, d1.Activity_year
order by d1.Activity_year, d1.Activity_month;

