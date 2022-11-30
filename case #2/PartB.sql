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

/*-------------------
   USEFUL UPDATES
---------------------*/

-- clean runner order table, cancellations column
-- replace all miscellaneous values to 'N' which states for 'Not cancelled' 
-- since "cancellation" is VARCHAR(23) it's values should be strings

-- update pizza_runner.runner_orders
-- set cancellation = replace(cancellation, 'null', 'N');

-- update pizza_runner.runner_orders
-- set cancellation = COALESCE(cancellation, 'N');

-- update pizza_runner.runner_orders
-- set cancellation = COALESCE(NULLIF(cancellation,''), 'N');


-- clean customer orders table, exclusions and extras columns
-- replace all miscellaneous values to 'N' which states for 'No changes' 
-- since "cancellation" is VARCHAR(4) it's values should be strings

-- update pizza_runner.customer_orders
-- set exclusions = replace(exclusions, 'null', 'N'),
-- 	extras = replace(extras, 'null', 'N');

-- update pizza_runner.customer_orders
-- set exclusions = COALESCE(exclusions, 'N'),
-- 	extras = COALESCE(extras, 'N');

-- update pizza_runner.customer_orders
-- set exclusions = COALESCE(NULLIF(exclusions,''), 'N'),
-- 	extras = COALESCE(NULLIF(extras,''), 'N');

---------------------------------------------------------------------

-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

-- select (registration_date - '2021-01-01' + 1) / 7 as weeks_from_start, 					count(runner_id)
-- from pizza_runner.runners
-- group by weeks_from_start;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

update pizza_runner.runner_orders
set pickup_time = nullif(pickup_time, 'null');

select r.runner_id,
	to_char(avg(extract(epoch from (to_timestamp(r.pickup_time, 'YYYY-MM-DD hh24:mi:ss') - c.order_time)) / 60), '9999.99') as diff
from pizza_runner.runner_orders r 
		join pizza_runner.customer_orders c
        on r.order_id = c.order_id
where r.pickup_time is not null
group by r.runner_id
order by r.runner_id;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?



-- What was the average distance travelled for each customer?



-- What was the difference between the longest and shortest delivery times for all orders?
-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- What is the successful delivery percentage for each runner?

