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
---------------------------------------------------------------------

-- What are the standard ingredients for each pizza?

with temp as (
select 
	unnest(
  		string_to_array(toppings, ', ')
	) as topping
from pizza_runner.pizza_recipes
)


select topping, count(topping) as freq
from temp
group by topping
order by freq desc;

-- What was the most commonly added extra?

with temp as (
select 
	unnest(
  		string_to_array(extras, ', ')
	) as extra
from pizza_runner.cust_orders
)

select extra, count(extra) as _times
from temp
where extra != 'N'
group by extra
order by _times desc
limit 1;

-- What was the most common exclusion?

with temp as (
select 
	unnest(
  		string_to_array(exclusions, ', ')
	) as exclusion
from pizza_runner.cust_orders
)

select exclusion, count(exclusion) as _times
from temp
where exclusion != 'N'
group by exclusion
order by _times desc
limit 1;

-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

with full_order_split as (
select 
		c.order_id, 
		c.customer_id, 
        pn.pizza_name, 
        -- c.exclusions, 
        -- c.extras, 
        c.order_time, 
        unnest(string_to_array(c.exclusions, ', ')) as exclusion,
        unnest(string_to_array(c.extras, ', ')) as extra,
        ROW_NUMBER() OVER(ORDER BY c.order_id) as order_pizza_id
from pizza_runner.cust_orders c join pizza_runner.pizza_names pn
	on c.pizza_id = pn.pizza_id
order by c.order_id
), 
full_order_str as (
select 
		fo.order_id, 
		fo.customer_id, 
        fo.order_time,
        fo.pizza_name,
        string_agg(exc.topping_name, ', ' ) as excl,
        string_agg(extr.topping_name, ', ' ) as extr
from full_order_split fo left join pizza_runner.pizza_toppings exc
	on CAST(fo.exclusion as INTEGER) = exc.topping_id
    left join pizza_runner.pizza_toppings extr on CAST(fo.extra as INTEGER) = extr.topping_id
group by fo.order_pizza_id, fo.pizza_name, fo.order_id, fo.customer_id, fo.order_time
)

select 
		order_id, 
		customer_id, 
        order_time,
        concat(pizza_name,
               CASE WHEN excl is not null THEN ' - Exclude ' || excl ELSE '' END,
               CASE WHEN extr is not null THEN ' - Extra ' || extr ELSE '' END) as ordered_pizza
from full_order_str
order by order_id;


-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

-- filter delivered
with filtered as (
select c.*, pr.toppings
from pizza_runner.cust_orders c join pizza_runner.pizza_recipes pr on
		c.pizza_id = pr.pizza_id
where order_id in (select order_id from pizza_runner.run_orders
                   where cancellation = 'N')
),
unioned as (
select unnest(string_to_array(exclusions, ', ')) as topping
  from filtered
  where exclusions != '0'
union all
select unnest(string_to_array(extras, ', ')) as topping
  from filtered
  where extras != '0'
union all
select unnest(string_to_array(toppings, ', ')) as topping
  from filtered
)

select pt.topping_name, count(topping) as freq
from unioned join pizza_runner.pizza_toppings pt 
	on cast(unioned.topping as integer) = pt.topping_id
group by topping, pt.topping_name
order by freq desc;