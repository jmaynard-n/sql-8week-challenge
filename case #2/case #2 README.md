# Case Study #2 - Pizza Runner
:mag_right: [Check out case study #2 challange page](https://8weeksqlchallenge.com/case-study-2/)

# Table of contents
- [Case Description](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/case%20%232%20README.md#description)
- [Case Study Questions](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/case%20%232%20README.md#case-study-questions)
  - [Part A. Pizza Metrics](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/case%20%232%20README.md#part-a---pizza-metrics)
  - [Part B. Runner and Customer Experience](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/case%20%232%20README.md#part-b---runner-and-customer-experience)
  - [Part C. Ingredient Optimisation](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/case%20%232%20README.md#part-c---ingredient-optimisation)
  - [Part D. Pricing and Ratings](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/case%20%232%20README.md#part-d---pricing-and-ratings)
- [Techiniques used in my solution](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/case%20%232%20README.md#techiniques-used-in-my-solution)
- [My solutions for each part](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/case%20%232%20README.md#my-solutions)
- [ER Diagram](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/case%20%232%20README.md#er-diagram)
- [Tables](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/case%20%232%20README.md#tables)

## Description 
![Case 2 Cover](https://8weeksqlchallenge.com/images/case-study-designs/2.png) 
> Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”
> Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more 
> genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

## Case Study Questions

### Part A - Pizza Metrics
1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?

[go to solution](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/Part%20A/Results%20Part%20A.md)

### Part B - Runner and Customer Experience
1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?

[go to solution](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/Part%20B/Results%20Part%20B.md)

### Part C - Ingredient Optimisation
1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

[go to solution](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/Part%20C/PartC%20Results.md)

### Part D - Pricing and Ratings
1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges 
for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras?
- Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
how would you design an additional table for this new dataset - generate a schema for this new table and insert 
your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
  - customer_id
  - order_id
  - runner_id
  - rating
  - order_time
  - pickup_time
  - Time between order and pickup
  - Delivery duration
  - Average speed
  - Total number of pizzas
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per
kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

[go to solution](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/Part%20D/Part%20D%20Results.md) 

## Techiniques used in my solution
- joins, where, group by, order by
- unnset, string_to_array
- complex string transformations
- casting
- data cleaning

## My solutions
Part | Solution | Link to online DB |
--- | --- | --- |
A | [go](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/Part%20A/Results%20Part%20A.md) | --- |
B | [go](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/Part%20B/Results%20Part%20B.md) | [view](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/1016) |
C | [go](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/Part%20C/PartC%20Results.md) | [view](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/1016) |
D | [go](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/Part%20D/Part%20D%20Results.md) | [view](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/1016) |

## ER diagram 
![image](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/ER%20Pizza%20runner.png)

## Tables 
![image](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%232/tables.png)
