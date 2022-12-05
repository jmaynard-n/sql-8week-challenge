-- What are the standard ingredients for each pizza?

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
-- What are the standard ingredients for each pizza?
**Query #3**

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

| topping | freq |
| ------- | ---- |
| 6       | 2    |
| 4       | 2    |
| 11      | 1    |
| 12      | 1    |
| 10      | 1    |
| 7       | 1    |
| 3       | 1    |
| 5       | 1    |
| 1       | 1    |
| 2       | 1    |
| 8       | 1    |
| 9       | 1    |

---
-- What was the most commonly added extra?
**Query #4**

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

| extra | _times |
| ----- | ------ |
| 0     | 10     |

---
-- What was the most common exclusion?
**Query #5**

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

| exclusion | _times |
| --------- | ------ |
| 0         | 9      |

---
-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
**Query #6**

    with full_order_split as (
    select 
    		c.order_id, 
    		c.customer_id, 
            pn.pizza_name, 
            
            
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

| order_id | customer_id | order_time               | ordered_pizza                                                   |
| -------- | ----------- | ------------------------ | --------------------------------------------------------------- |
| 1        | 101         | 2020-01-01T18:05:02.000Z | Meatlovers                                                      |
| 2        | 101         | 2020-01-01T19:00:52.000Z | Meatlovers                                                      |
| 3        | 102         | 2020-01-02T23:51:23.000Z | Meatlovers                                                      |
| 3        | 102         | 2020-01-02T23:51:23.000Z | Vegetarian                                                      |
| 4        | 103         | 2020-01-04T13:23:46.000Z | Meatlovers - Exclude Cheese                                     |
| 4        | 103         | 2020-01-04T13:23:46.000Z | Vegetarian - Exclude Cheese                                     |
| 4        | 103         | 2020-01-04T13:23:46.000Z | Meatlovers - Exclude Cheese                                     |
| 5        | 104         | 2020-01-08T21:00:29.000Z | Meatlovers - Extra Bacon                                        |
| 6        | 101         | 2020-01-08T21:03:13.000Z | Vegetarian                                                      |
| 7        | 105         | 2020-01-08T21:20:29.000Z | Vegetarian - Extra Bacon                                        |
| 8        | 102         | 2020-01-09T23:54:33.000Z | Meatlovers                                                      |
| 9        | 103         | 2020-01-10T11:22:59.000Z | Meatlovers - Exclude Cheese - Extra Bacon, Chicken              |
| 10       | 104         | 2020-01-11T18:34:49.000Z | Meatlovers                                                      |
| 10       | 104         | 2020-01-11T18:34:49.000Z | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |

---
-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

**Query #7**

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

| topping_name | freq |
| ------------ | ---- |
| Cheese       | 16   |
| Mushrooms    | 13   |
| Bacon        | 12   |
| BBQ Sauce    | 10   |
| Salami       | 9    |
| Chicken      | 9    |
| Beef         | 9    |
| Pepperoni    | 9    |
| Peppers      | 3    |
| Onions       | 3    |
| Tomatoes     | 3    |
| Tomato Sauce | 3    |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/1016)