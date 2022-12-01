/*
------------------------------------
		Case Study Questions		
------------------------------------

	B. Data Analysis Questions

-- How many customers has Foodie-Fi ever had?
-- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
-- What is the number and percentage of customer plans after their initial free trial?
-- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
-- How many customers have upgraded to an annual plan in 2020?
-- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
-- Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
-- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

*/

-- How many customers has Foodie-Fi ever had?

select count(distinct customer_id) as total_ever
from foodie_fi.subscriptions;

-- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

-- кол-во триальных подписок по месяцам

select extract(month from start_date) as month_order, count(plan_id)
from foodie_fi.subscriptions
where plan_id = 0
group by month_order
order by month_order;

-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT p.plan_name, COUNT(s.plan_id) AS total_plans
FROM foodie_fi.plans p JOIN foodie_fi.subscriptions s 
		ON s.plan_id = p.plan_id
WHERE EXTRACT(YEAR FROM s.start_date) > 2020
GROUP BY p.plan_name
ORDER BY total_plans DESC;

-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

select count(distinct customer_id) as total_curned, 
	round(
      (count(distinct customer_id) / 
      (select count(distinct customer_id) 
       from foodie_fi.subscriptions)::decimal) * 100, 
      1) as percent_of_total
from foodie_fi.subscriptions
where plan_id = 4;

-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

with temp as (
select customer_id, plan_id as curr,
	LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) as next_plan
from foodie_fi.subscriptions)

select count(distinct customer_id) as total_trail_churned,
	ceil((count(distinct customer_id) / (select count(distinct customer_id) 
       from foodie_fi.subscriptions)::decimal) * 100) as ceil_perc_of_total
from temp
where curr = 0 and next_plan = 4;

-- What is the number and percentage of customer plans after their initial free trial?

select count(distinct t.customer_id) as total_continued,
	ceil((count(distinct t.customer_id) / (select count(distinct customer_id) 
       from foodie_fi.subscriptions)::decimal) * 100) as ceil_perc_of_total
from (
  select customer_id, plan_id as curr,
		LEAD(plan_id) 
  			OVER(PARTITION BY customer_id ORDER BY start_date) as next_plan
	from foodie_fi.subscriptions
  ) t
where curr = 0 and next_plan != 4;

-- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

with temp as (
select customer_id, plan_id
from foodie_fi.subscriptions
where 
      (
        (plan_id = 1 OR plan_id = 2) AND 
        abs(start_date - '2020-12-31'::DATE) <= 30
	  )
     OR ( plan_id = 3 AND abs(start_date - '2020-12-31'::DATE) <= 365)
     OR ( plan_id = 0 AND abs(start_date - '2020-12-31'::DATE) <= 7)
     OR plan_id = 4
order by customer_id
)

select plan_id, count(distinct customer_id) as customers, 
	round((count(distinct customer_id) / (select sum(count(*)) over() 
       from temp)::decimal) * 100, 1) as perc_of_total
from temp
group by plan_id;

-- How many customers have upgraded to an annual plan in 2020?

select count(distinct customer_id)
from foodie_fi.subscriptions
where plan_id = 3 and extract(year from start_date) = 2020;

-- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

with t1 as (
select customer_id, start_date
from foodie_fi.subscriptions
where plan_id = 0
),
t2 as (
select customer_id, start_date as annual_date
from foodie_fi.subscriptions
where plan_id = 3
)

select ceil(avg(abs(t1.start_date - t2.annual_date))) as avg_pro_upgrade
from t2 join t1 on t1.customer_id=t2.customer_id;

-- Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH temp AS(
    	SELECT
      		s.customer_id,
      		s.plan_id,
      		(WIDTH_BUCKET((s.start_date-(SELECT MIN(start_date) FROM foodie_fi.subscriptions WHERE customer_id = s.customer_id)),0,360,12) - 1) AS bucket
    	FROM foodie_fi.subscriptions s
    	WHERE s.plan_id = 3
)
    
SELECT CASE
		WHEN bucket = 0
        THEN bucket * 30 || '-' || (bucket+1)*30 || ' days'
        ELSE
            (bucket * 30)+1 || '-' || (bucket+1)*30 || ' days'
    	END AS period,
        COUNT(DISTINCT customer_id) AS customers
FROM temp
GROUP BY bucket, period
ORDER BY bucket;

-- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

with t as (
select customer_id, plan_id, start_date,
	LAST_VALUE(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) as next_plan,
  	LAST_VALUE(start_date) OVER(PARTITION BY customer_id ORDER BY start_date ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) as next_start
from foodie_fi.subscriptions
)

select count(customer_id)
from t
where plan_id = 2 and next_plan = 1 and extract(year from next_start) = 2020;

