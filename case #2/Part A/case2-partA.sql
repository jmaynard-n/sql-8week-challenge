-- PART A

-- Schema SQL Query SQL ResultsEdit on DB Fiddle

-- Case Study Part A: Pizza Metrics
---------------------------------------------------------------------
-- How many pizzas were ordered?
-- How many unique customer orders were made?
-- How many successful orders were delivered by each runner?
-- How many of each type of pizza was delivered?
-- How many Vegetarian and Meatlovers were ordered by each customer?
-- What was the maximum number of pizzas delivered in a single order?
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- How many pizzas were delivered that had both exclusions and extras?
-- What was the total volume of pizzas ordered for each hour of the day?
-- What was the volume of orders for each day of the week?
---------------------------------------------------------------------

-- 1. How many pizzas were ordered?

select count(*)
from pizza_runner.customer_orders;

-- 2. How many unique customer orders were made?

select count(distinct order_id)
from pizza_runner.customer_orders;

-- 3. How many successful orders were delivered by each runner?

-- clean runner order table, cancellations column
-- replace all miscellaneous values to 'N' which states for 'Not cancelled' 
-- since "cancellation" is VARCHAR(23) it's values should be strings

update pizza_runner.runner_orders
set cancellation = replace(cancellation, 'null', 'N');

update pizza_runner.runner_orders
set cancellation = COALESCE(cancellation, 'N');

update pizza_runner.runner_orders
set cancellation = COALESCE(NULLIF(cancellation,''), 'N');

select count(*)
from pizza_runner.runner_orders
where cancellation = 'N';

-- this question also could be answered using values from duration column since there are distinct null values where order was not delivered

-- 4. How many of each type of pizza was delivered?

select c.pizza_id, count(c.pizza_id)
from pizza_runner.customer_orders c join pizza_runner.runner_orders r 
	on c.order_id = r.order_id
where r.cancellation = 'N'
group by c.pizza_id;

-- How many Vegetarian and Meatlovers were ordered by each customer?

select c.customer_id, c.pizza_id, count(c.pizza_id)
from pizza_runner.customer_orders c
group by c.customer_id, c.pizza_id
order by c.customer_id;

-- What was the maximum number of pizzas delivered in a single order?

select max(t.amount) 
from (
	select count(c.pizza_id) as amount
	from pizza_runner.customer_orders c 
  			join pizza_runner.runner_orders r 
			on c.order_id = r.order_id
	where r.cancellation = 'N'
	group by c.order_id
) t;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

-- clean customer orders table, exclusions and extras column
-- replace all miscellaneous values to 'N' which states for 'No changes' 
-- since "cancellation" is VARCHAR(4) it's values should be strings

update pizza_runner.customer_orders
set exclusions = replace(exclusions, 'null', 'N'),
	extras = replace(extras, 'null', 'N');

update pizza_runner.customer_orders
set exclusions = COALESCE(exclusions, 'N'),
	extras = COALESCE(extras, 'N');

update pizza_runner.customer_orders
set exclusions = COALESCE(NULLIF(exclusions,''), 'N'),
	extras = COALESCE(NULLIF(extras,''), 'N');

select c.customer_id,
	   sum(case 
             when exclusions = 'N' and extras = 'N' then 1 
             else 0 end) as no_changes,
       sum(case 
             when exclusions != 'N' or extras != 'N' then 1 
             else 0 end) as has_changes
from pizza_runner.customer_orders c 
  		join pizza_runner.runner_orders r 
		on c.order_id = r.order_id
where r.cancellation = 'N'
group by c.customer_id
order by c.customer_id;

-- How many pizzas were delivered that had both exclusions and extras?

select 
       sum(case 
             when exclusions != 'N' and extras != 'N' then 1 
             else 0 end) as has_changes
from pizza_runner.customer_orders c 
  		join pizza_runner.runner_orders r 
		on c.order_id = r.order_id
where r.cancellation = 'N';

-- What was the total volume of pizzas ordered for each hour of the day?

select extract(hour from c.order_time) as order_hour, count(pizza_id) as count_pizza_ordered
from pizza_runner.customer_orders c 
group by order_hour
order by order_hour;

-- What was the volume of orders for each day of the week?

first variant
select extract(dow from c.order_time) as day_of_week, count(pizza_id) as count_pizza_ordered
from pizza_runner.customer_orders c 
group by day_of_week;

-- second variant
select to_char(c.order_time, 'Day') as day_of_week, count(pizza_id) as count_pizza_ordered
from pizza_runner.customer_orders c 
group by day_of_week;