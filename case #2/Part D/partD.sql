------------------------
-----DATA CLEANING------
------------------------

--SQL functions: Create temp table, CASE WHEN, TRIM, ALTER TABLE, ALTER data type, filtering using '%'

--TABLE: customer_orders

SELECT order_id, customer_id, pizza_id, 
CASE
	WHEN exclusions IS null OR exclusions LIKE 'null' OR exclusions LIKE '' THEN '0'
	ELSE exclusions
	END AS exclusions,
CASE
	WHEN extras IS NULL or extras LIKE 'null' or extras LIKE '' THEN '0'
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
	WHEN cancellation IS NULL or cancellation LIKE 'null' OR cancellation LIKE '' THEN 'N'
	ELSE cancellation
	END AS cancellation
INTO pizza_runner.run_orders
FROM pizza_runner.runner_orders;

-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

select sum(case pizza_id when 1 then 12 else 10 end) as total_revenue
from pizza_runner.cust_orders c join pizza_runner.run_orders r
	on c.order_id = r.order_id
where cancellation = 'N';

-- What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra

with temp as (
  select unnest(string_to_array(extras, ',')) as toppings
from pizza_runner.cust_orders c join pizza_runner.run_orders r
	on c.order_id = r.order_id
where cancellation = 'N' and extras != '0'
)

select sum(case pizza_id when 1 then 12 else 10 end) + (select count(toppings) from temp) as total_revenue
from pizza_runner.cust_orders c join pizza_runner.run_orders r
	on c.order_id = r.order_id
where cancellation = 'N';

-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

DROP TABLE IF EXISTS customer_ratings;

    CREATE TABLE customer_ratings (
      "order_id" INTEGER,
      "rating" INTEGER,
      "comment" VARCHAR(150),
      "rating_time" TIMESTAMP
    );

INSERT INTO customer_ratings
      ("order_id", "rating", "comment", "rating_time")
    VALUES
      ('1', '4', 'A little late but very polite runner!', '2020-01-01 18:57:54'),
      ('2', '5', NULL, '2020-01-01 22:01:32'),
      ('3', '5','Excellent!', '2020-01-04 01:11:09'),
      ('4', '2', 'Late and didnt even told me good afternoon', '2020-01-04 14:37:14'),
      ('5', '5', NULL, '2020-01-08 21:59:44'),
      ('7', '5', 'Please promote this guy!', '2020-01-08 21:58:22'),
      ('8', '5', NULL, '2020-01-12 13:20:01'),
      ('10', '5', 'Perfect!', '2020-01-11 21:22:57');


-- Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas

select 
		c.customer_id,
        c.order_id,
        r.runner_id,
        cr.rating,
        c.order_time,
        r.pickup_time,
        to_char(extract(epoch from (to_timestamp(r.pickup_time, 'YYYY-MM-DD hh24:mi:ss') - c.order_time)) / 60, '999.99') as prep_time,
        r.duration,
        ROUND((cast(r.distance as decimal)/cast(r.duration as decimal) * 60), 2) as avg_speed,
        count(c.order_id) as total_pizzas
from pizza_runner.cust_orders c join pizza_runner.run_orders r
	on c.order_id = r.order_id and cancellation = 'N'
    join customer_ratings cr on c.order_id = cr.order_id
group by 
		c.customer_id,
        c.order_id,
        r.runner_id,
        cr.rating,
        c.order_time,
        r.pickup_time, 
        r.duration, r.distance
order by c.order_id;

-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?


select sum(case pizza_id when 1 then 12 else 10 end) - (select sum(0.3 * cast(distance as decimal)) as fee
from pizza_runner.run_orders
where cancellation = 'N') as total_revenue_with_fees
from pizza_runner.cust_orders c join pizza_runner.run_orders r
	on c.order_id = r.order_id
where cancellation = 'N';


