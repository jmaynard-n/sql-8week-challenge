**Query #1**

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
    	WHEN cancellation IS NULL or cancellation LIKE 'null' THEN 'N'
    	ELSE cancellation
    	END AS cancellation
    INTO pizza_runner.run_orders
    FROM pizza_runner.runner_orders;

There are no results to be displayed.

---
**Query #3**
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

    select (registration_date - '2021-01-01' + 1) / 7 as weeks_from_start, count(runner_id)
    from pizza_runner.runners
    group by weeks_from_start;

| weeks_from_start | count |
| ---------------- | ----- |
| 0                | 2     |
| 2                | 1     |
| 1                | 1     |

---
**Query #4**
-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

    select r.runner_id,
    	to_char(avg(extract(epoch from (to_timestamp(r.pickup_time, 'YYYY-MM-DD hh24:mi:ss') - c.order_time)) / 60), '9999.99') as diff
    from pizza_runner.run_orders r 
    		join pizza_runner.cust_orders c
            on r.order_id = c.order_id
    where r.pickup_time is not null
    group by r.runner_id
    order by r.runner_id;

| runner_id | diff     |
| --------- | -------- |
| 1         |    15.68 |
| 2         |    23.72 |
| 3         |    10.47 |

---
**Query #5**
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

| pizzas_in_order | avg_prep_time |
| --------------- | ------------- |
| 3               |    29.28      |
| 2               |    18.38      |
| 1               |    12.36      |

---
**Query #6**
-- What was the average distance travelled for each customer?

    SELECT c.customer_id, to_char(AVG(cast(r.distance as float)), '9999.99') AS avg_distance
    FROM pizza_runner.cust_orders c
    JOIN pizza_runner.run_orders r
      ON c.order_id = r.order_id
    WHERE r.duration is not null
    GROUP BY c.customer_id;

| customer_id | avg_distance |
| ----------- | ------------ |
| 101         |    20.00     |
| 103         |    23.40     |
| 104         |    10.00     |
| 105         |    25.00     |
| 102         |    16.73     |

---
**Query #7**
-- What was the difference between the longest and shortest delivery times for all orders?

    SELECT MAX(duration::NUMERIC) - MIN(duration::NUMERIC) AS delivery_time_difference
    FROM pizza_runner.run_orders
    where duration is not null;

| delivery_time_difference |
| ------------------------ |
| 30                       |

---
**Query #8**
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

| runner_id | customer_id | order_id | pizzas_in_order | distance | duration_hr         | avg_speed |
| --------- | ----------- | -------- | --------------- | -------- | ------------------- | --------- |
| 1         | 101         | 1        | 1               | 20       | 0.5333333333333333  | 37.50     |
| 1         | 101         | 2        | 1               | 20       | 0.45                | 44.44     |
| 1         | 102         | 3        | 2               | 13.4     | 0.3333333333333333  | 40.20     |
| 1         | 104         | 10       | 2               | 10       | 0.16666666666666666 | 60.00     |
| 2         | 102         | 8        | 1               | 23.4     | 0.25                | 93.60     |
| 2         | 103         | 4        | 3               | 23.4     | 0.6666666666666666  | 35.10     |
| 2         | 105         | 7        | 1               | 25       | 0.4166666666666667  | 60.00     |
| 3         | 104         | 5        | 1               | 10       | 0.25                | 40.00     |

---
**Query #9**
-- What is the successful delivery percentage for each runner?

    SELECT 
      runner_id, 
      ROUND(100 * SUM(
        CASE WHEN distance is null THEN 0
        ELSE 1 END) / COUNT(*), 0) AS success_perc
    FROM pizza_runner.run_orders 
    GROUP BY runner_id
    ORDER BY runner_id;

| runner_id | success_perc |
| --------- | ------------ |
| 1         | 100          |
| 2         | 75           |
| 3         | 50           |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/1016)