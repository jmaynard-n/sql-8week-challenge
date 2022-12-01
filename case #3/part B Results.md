### How many customers has Foodie-Fi ever had? 

**Query #1**

    select count(distinct customer_id) as total_ever
    from foodie_fi.subscriptions;

| total_ever |
| ---------- |
| 1000       |

---
### What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

**Query #2**

    select extract(month from start_date) as month_order, count(plan_id)
    from foodie_fi.subscriptions
    where plan_id = 0
    group by month_order
    order by month_order;

| month_order | count |
| ----------- | ----- |
| 1           | 88    |
| 2           | 68    |
| 3           | 94    |
| 4           | 81    |
| 5           | 88    |
| 6           | 79    |
| 7           | 89    |
| 8           | 88    |
| 9           | 87    |
| 10          | 79    |
| 11          | 75    |
| 12          | 84    |

---
### What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

**Query #3**

    SELECT p.plan_name, COUNT(s.plan_id) AS total_plans
    FROM foodie_fi.plans p JOIN foodie_fi.subscriptions s 
    		ON s.plan_id = p.plan_id
    WHERE EXTRACT(YEAR FROM s.start_date) > 2020
    GROUP BY p.plan_name
    ORDER BY total_plans DESC;

| plan_name     | total_plans |
| ------------- | ----------- |
| churn         | 71          |
| pro annual    | 63          |
| pro monthly   | 60          |
| basic monthly | 8           |

---
### What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

**Query #4**

    select count(distinct customer_id) as total_curned, 
    	round(
          (count(distinct customer_id) / 
          (select count(distinct customer_id) 
           from foodie_fi.subscriptions)::decimal) * 100, 
          1) as percent_of_total
    from foodie_fi.subscriptions
    where plan_id = 4;

| total_curned | percent_of_total |
| ------------ | ---------------- |
| 307          | 30.7             |

---
### How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

**Query #5**

    with temp as (
    select customer_id, plan_id as curr,
    	LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) as next_plan
    from foodie_fi.subscriptions)
    
    select count(distinct customer_id) as total_trail_churned,
    	ceil((count(distinct customer_id) / (select count(distinct customer_id) 
           from foodie_fi.subscriptions)::decimal) * 100) as ceil_perc_of_total
    from temp
    where curr = 0 and next_plan = 4;

| total_trail_churned | ceil_perc_of_total |
| ------------------- | ------------------ |
| 92                  | 10                 |

---
### What is the number and percentage of customer plans after their initial free trial?

**Query #6**

    select count(distinct t.customer_id) as total_continued,
    	ceil((count(distinct t.customer_id) / (select count(distinct customer_id) 
           from foodie_fi.subscriptions)::decimal) * 100) as ceil_perc_of_total
    from (
      select customer_id, plan_id as curr,
    		LEAD(plan_id) 
      			OVER(PARTITION BY customer_id ORDER BY start_date) as next_plan
    	from foodie_fi.subscriptions
      ) t
    where curr = 0 and next_plan != 4;

| total_continued | ceil_perc_of_total |
| --------------- | ------------------ |
| 908             | 91                 |

---
### What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

**Query #7**

    with temp as (
    select customer_id, plan_id
    from foodie_fi.subscriptions
    where 
          (
            (plan_id = 1 OR plan_id = 2) AND 
            abs(start_date - '2020-12-31'::DATE) <= 30
    	  )
         OR ( plan_id = 3 AND abs(start_date - '2020-12-31'::DATE) <= 365)
         OR ( plan_id = 0 AND abs(start_date - '2020-12-31'::DATE) <= 7)
         OR plan_id = 4
    order by customer_id
    )
    
    select plan_id, count(distinct customer_id) as customers, 
    	round((count(distinct customer_id) / (select sum(count(*)) over() 
           from temp)::decimal) * 100, 1) as perc_of_total
    from temp
    group by plan_id;

| plan_id | customers | perc_of_total |
| ------- | --------- | ------------- |
| 0       | 19        | 2.7           |
| 1       | 51        | 7.2           |
| 2       | 74        | 10.4          |
| 3       | 258       | 36.4          |
| 4       | 307       | 43.3          |

---
### How many customers have upgraded to an annual plan in 2020?

**Query #8**

    select count(distinct customer_id)
    from foodie_fi.subscriptions
    where plan_id = 3 and extract(year from start_date) = 2020;

| count |
| ----- |
| 195   |

---
### How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

**Query #9**

    with t1 as (
    select customer_id, start_date
    from foodie_fi.subscriptions
    where plan_id = 0
    ),
    t2 as (
    select customer_id, start_date as annual_date
    from foodie_fi.subscriptions
    where plan_id = 3
    )
    
    select ceil(avg(abs(t1.start_date - t2.annual_date))) as avg_pro_upgrade
    from t2 join t1 on t1.customer_id=t2.customer_id;

| avg_pro_upgrade |
| --------------- |
| 105             |

---
### Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

**Query #10**

    WITH temp AS(
        	SELECT
          		s.customer_id,
          		s.plan_id,
          		(WIDTH_BUCKET((s.start_date-(SELECT MIN(start_date) FROM foodie_fi.subscriptions WHERE customer_id = s.customer_id)),0,360,12) - 1) AS bucket
        	FROM foodie_fi.subscriptions s
        	WHERE s.plan_id = 3
    )
        
    SELECT CASE
    		WHEN bucket = 0
            THEN bucket * 30 || '-' || (bucket+1)*30 || ' days'
            ELSE
                (bucket * 30)+1 || '-' || (bucket+1)*30 || ' days'
        	END AS period,
            COUNT(DISTINCT customer_id) AS customers
    FROM temp
    GROUP BY bucket, period
    ORDER BY bucket;

| period       | customers |
| ------------ | --------- |
| 0-30 days    | 48        |
| 31-60 days   | 25        |
| 61-90 days   | 33        |
| 91-120 days  | 35        |
| 121-150 days | 43        |
| 151-180 days | 35        |
| 181-210 days | 27        |
| 211-240 days | 4         |
| 241-270 days | 5         |
| 271-300 days | 1         |
| 301-330 days | 1         |
| 331-360 days | 1         |

---
### How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

**Query #11**

    with t as (
    select customer_id, plan_id, start_date,
    	LAST_VALUE(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) as next_plan,
      	LAST_VALUE(start_date) OVER(PARTITION BY customer_id ORDER BY start_date ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) as next_start
    from foodie_fi.subscriptions
    )
    
    select count(customer_id)
    from t
    where plan_id = 2 and next_plan = 1 and extract(year from next_start) = 2020;

| count |
| ----- |
| 0     |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/rHJhRrXy5hbVBNJ6F6b9gJ/16)
