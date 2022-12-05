-- Case Study Part B: Runner and Customer Experience
---------------------------------------------------------------------
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- What was the average distance travelled for each customer?
-- What was the difference between the longest and shortest delivery times for all orders?
-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- What is the successful delivery percentage for each runner?
-- ---------------------------------------------------------------------

------------------------
-----DATA CLEANING------
------------------------

--SQL functions: Create temp table, CASE WHEN, TRIM, ALTER TABLE, ALTER data type, filtering using '%'

--TABLE: customer_orders

SELECT order_id, customer_id, pizza_id, 
CASE
	WHEN exclusions IS null OR exclusions LIKE 'null' THEN 'N'
	ELSE exclusions
	END AS exclusions,
CASE
	WHEN extras IS NULL or extras LIKE 'null' THEN 'N'
	ELSE extras
	END AS extras,
	order_time
INTO pizza_runner.cust_orders
FROM pizza_runner.customer_orders;

--TABLE: runner_orders

--pickup_time - remove nulls and replace with ' '
--distance - remove km and nulls
--duration - remove minutes and nulls
--cancellation - remove NULL and null and replace with ' ' 

SELECT order_id, runner_id,  
CASE
	WHEN pickup_time LIKE 'null' THEN null 
	ELSE pickup_time
	END AS pickup_time,
CASE
	WHEN distance LIKE 'null' THEN null
	WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	ELSE distance
	END AS distance,
CASE
	WHEN duration LIKE 'null' THEN null
	WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	ELSE duration
	END AS duration,
CASE
	WHEN cancellation IS NULL or cancellation LIKE 'null' THEN 'N'
	ELSE cancellation
	END AS cancellation
INTO pizza_runner.run_orders
FROM pizza_runner.runner_orders;
---------------------------------------------------------------------

-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

select (registration_date - '2021-01-01' + 1) / 7 as weeks_from_start, count(runner_id)
from pizza_runner.runners
group by weeks_from_start;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

select r.runner_id,
	to_char(avg(extract(epoch from (to_timestamp(r.pickup_time, 'YYYY-MM-DD hh24:mi:ss') - c.order_time)) / 60), '9999.99') as diff
from pizza_runner.run_orders r 
		join pizza_runner.cust_orders c
        on r.order_id = c.order_id
where r.pickup_time is not null
group by r.runner_id
order by r.runner_id;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?


with temp as(
select c.order_id, count(c.order_id) as pizzas_in_order, c.order_time, r.pickup_time,
	avg(extract(epoch from (to_timestamp(r.pickup_time, 'YYYY-MM-DD hh24:mi:ss') - c.order_time)) / 60) as prep_time
from pizza_runner.run_orders r 
		join pizza_runner.cust_orders c
        on r.order_id = c.order_id
where r.pickup_time != 'N'
group by c.order_id, c.order_time, r.pickup_time
)

select pizzas_in_order, to_char(avg(prep_time), '9999.99') as avg_prep_time
from temp
group by pizzas_in_order;

-- What was the average distance travelled for each customer?

SELECT c.customer_id, to_char(AVG(cast(r.distance as float)), '9999.99') AS avg_distance
FROM pizza_runner.cust_orders c
JOIN pizza_runner.run_orders r
  ON c.order_id = r.order_id
WHERE r.duration is not null
GROUP BY c.customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?

SELECT MAX(duration::NUMERIC) - MIN(duration::NUMERIC) AS delivery_time_difference
FROM pizza_runner.run_orders
where duration is not null;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?

select 
  r.runner_id, 
  c.customer_id, 
  c.order_id, 
  count(c.order_id) AS pizzas_in_order, 
  r.distance, 
  (cast(r.duration as float)/ 60) AS duration_hr , 
  ROUND((cast(r.distance as decimal)/cast(r.duration as decimal) * 60), 2) AS avg_speed
from pizza_runner.run_orders r JOIN pizza_runner.cust_orders c
  ON r.order_id = c.order_id
where distance is not null
group by r.runner_id, c.customer_id, c.order_id, r.distance, r.duration
order by r.runner_id;

-- What is the successful delivery percentage for each runner?

SELECT 
  runner_id, 
  ROUND(100 * SUM(
    CASE WHEN distance is null THEN 0
    ELSE 1 END) / COUNT(*), 0) AS success_perc
FROM pizza_runner.run_orders 
GROUP BY runner_id
ORDER BY runner_id;
