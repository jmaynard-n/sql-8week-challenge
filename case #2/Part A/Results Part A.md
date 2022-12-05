**Query #1**
-- 1. How many pizzas were ordered?

    select count(*)
    from pizza_runner.customer_orders;

| count |
| ----- |
| 14    |

---
**Query #2**
-- 2. How many unique customer orders were made?

    select count(distinct order_id)
    from pizza_runner.customer_orders;

| count |
| ----- |
| 10    |

---
-- 3. How many successful orders were delivered by each runner?

-- clean runner order table, cancellations column
-- replace all miscellaneous values to 'N' which states for 'Not cancelled' 
-- since "cancellation" is VARCHAR(23) it's values should be strings
**Query #3**

    update pizza_runner.runner_orders
    set cancellation = replace(cancellation, 'null', 'N');

There are no results to be displayed.

---
**Query #4**

    update pizza_runner.runner_orders
    set cancellation = COALESCE(cancellation, 'N');

There are no results to be displayed.

---
**Query #5**

    update pizza_runner.runner_orders
    set cancellation = COALESCE(NULLIF(cancellation,''), 'N');

There are no results to be displayed.

---
**Query #6**
-- How many successful orders were delivered by each runner?

    select count(*)
    from pizza_runner.runner_orders
    where cancellation = 'N';

| count |
| ----- |
| 8     |

---
**Query #7**
-- 4. How many of each type of pizza was delivered?

    select c.pizza_id, count(c.pizza_id)
    from pizza_runner.customer_orders c join pizza_runner.runner_orders r 
    	on c.order_id = r.order_id
    where r.cancellation = 'N'
    group by c.pizza_id;

| pizza_id | count |
| -------- | ----- |
| 1        | 9     |
| 2        | 3     |

---
**Query #8**
-- How many Vegetarian and Meatlovers were ordered by each customer?

    select c.customer_id, c.pizza_id, count(c.pizza_id)
    from pizza_runner.customer_orders c
    group by c.customer_id, c.pizza_id
    order by c.customer_id;

| customer_id | pizza_id | count |
| ----------- | -------- | ----- |
| 101         | 2        | 1     |
| 101         | 1        | 2     |
| 102         | 2        | 1     |
| 102         | 1        | 2     |
| 103         | 2        | 1     |
| 103         | 1        | 3     |
| 104         | 1        | 3     |
| 105         | 2        | 1     |

---
**Query #9**
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

| max |
| --- |
| 3   |

---
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

-- clean customer orders table, exclusions and extras columns
-- replace all miscellaneous values to 'N' which states for 'No changes' 
-- since "cancellation" is VARCHAR(4) it's values should be strings

**Query #10**

    update pizza_runner.customer_orders
    set exclusions = replace(exclusions, 'null', 'N'),
    	extras = replace(extras, 'null', 'N');

There are no results to be displayed.

---
**Query #11**

    update pizza_runner.customer_orders
    set exclusions = COALESCE(exclusions, 'N'),
    	extras = COALESCE(extras, 'N');

There are no results to be displayed.

---
**Query #12**

    update pizza_runner.customer_orders
    set exclusions = COALESCE(NULLIF(exclusions,''), 'N'),
    	extras = COALESCE(NULLIF(extras,''), 'N');

There are no results to be displayed.

---
**Query #13**
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

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

| customer_id | no_changes | has_changes |
| ----------- | ---------- | ----------- |
| 101         | 2          | 0           |
| 102         | 3          | 0           |
| 103         | 0          | 3           |
| 104         | 1          | 2           |
| 105         | 0          | 1           |

---
**Query #14**
-- How many pizzas were delivered that had both exclusions and extras?

    select 
           sum(case 
                 when exclusions != 'N' and extras != 'N' then 1 
                 else 0 end) as has_changes
    from pizza_runner.customer_orders c 
      		join pizza_runner.runner_orders r 
    		on c.order_id = r.order_id
    where r.cancellation = 'N';

| has_changes |
| ----------- |
| 1           |

---
**Query #15**
-- What was the total volume of pizzas ordered for each hour of the day?

    select extract(hour from c.order_time) as order_hour, count(pizza_id) as count_pizza_ordered
    from pizza_runner.customer_orders c 
    group by order_hour
    order by order_hour;

| order_hour | count_pizza_ordered |
| ---------- | ------------------- |
| 11         | 1                   |
| 13         | 3                   |
| 18         | 3                   |
| 19         | 1                   |
| 21         | 3                   |
| 23         | 3                   |

---
**Query #16**
-- What was the volume of orders for each day of the week?

-- first variant 
    select extract(dow from c.order_time) as day_of_week, count(pizza_id) as count_pizza_ordered
    from pizza_runner.customer_orders c 
    group by day_of_week;

| day_of_week | count_pizza_ordered |
| ----------- | ------------------- |
| 3           | 5                   |
| 4           | 3                   |
| 6           | 5                   |
| 5           | 1                   |

---
**Query #17**
-- What was the volume of orders for each day of the week?

-- second variant 
    select to_char(c.order_time, 'Day') as day_of_week, count(pizza_id) as count_pizza_ordered
    from pizza_runner.customer_orders c 
    group by day_of_week;

| day_of_week | count_pizza_ordered |
| ----------- | ------------------- |
| Saturday    | 5                   |
| Thursday    | 3                   |
| Friday      | 1                   |
| Wednesday   | 5                   |

---
