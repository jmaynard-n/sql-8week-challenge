
**Query #1**

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

There are no results to be displayed.

---
**Query #2**

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

There are no results to be displayed.

---

-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees? 

**Query #3**

    select sum(case pizza_id when 1 then 12 else 10 end) as total_revenue
    from pizza_runner.cust_orders c join pizza_runner.run_orders r
    	on c.order_id = r.order_id
    where cancellation = 'N';

| total_revenue |
| ------------- |
| 138           |

---
-- What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra

**Query #4**

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

| total_revenue |
| ------------- |
| 142           |

---
-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

**Query #5**

    DROP TABLE IF EXISTS customer_ratings;

There are no results to be displayed.

---
-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

**Query #6**

    CREATE TABLE customer_ratings (
          "order_id" INTEGER,
          "rating" INTEGER,
          "comment" VARCHAR(150),
          "rating_time" TIMESTAMP
        );

There are no results to be displayed.

---
**Query #7**

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

There are no results to be displayed.

---
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

**Query #8**

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

| customer_id | order_id | runner_id | rating | order_time               | pickup_time         | prep_time | duration | avg_speed | total_pizzas |
| ----------- | -------- | --------- | ------ | ------------------------ | ------------------- | --------- | -------- | --------- | ------------ |
| 101         | 1        | 1         | 4      | 2020-01-01T18:05:02.000Z | 2020-01-01 18:15:34 |   10.53   | 32       | 37.50     | 1            |
| 101         | 2        | 1         | 5      | 2020-01-01T19:00:52.000Z | 2020-01-01 19:10:54 |   10.03   | 27       | 44.44     | 1            |
| 102         | 3        | 1         | 5      | 2020-01-02T23:51:23.000Z | 2020-01-03 00:12:37 |   21.23   | 20       | 40.20     | 2            |
| 103         | 4        | 2         | 2      | 2020-01-04T13:23:46.000Z | 2020-01-04 13:53:03 |   29.28   | 40       | 35.10     | 3            |
| 104         | 5        | 3         | 5      | 2020-01-08T21:00:29.000Z | 2020-01-08 21:10:57 |   10.47   | 15       | 40.00     | 1            |
| 105         | 7        | 2         | 5      | 2020-01-08T21:20:29.000Z | 2020-01-08 21:30:45 |   10.27   | 25       | 60.00     | 1            |
| 102         | 8        | 2         | 5      | 2020-01-09T23:54:33.000Z | 2020-01-10 00:15:02 |   20.48   | 15       | 93.60     | 1            |
| 104         | 10       | 1         | 5      | 2020-01-11T18:34:49.000Z | 2020-01-11 18:50:20 |   15.52   | 10       | 60.00     | 2            |

---
-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

**Query #9**

    select sum(case pizza_id when 1 then 12 else 10 end) - (select sum(0.3 * cast(distance as decimal)) as fee
    from pizza_runner.run_orders
    where cancellation = 'N') as total_revenue_with_fees
    from pizza_runner.cust_orders c join pizza_runner.run_orders r
    	on c.order_id = r.order_id
    where cancellation = 'N';

| total_revenue_with_fees |
| ----------------------- |
| 94.44                   |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/1016)