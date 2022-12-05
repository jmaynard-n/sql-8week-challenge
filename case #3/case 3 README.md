# Case Study #3 - Foodie-Fi
:mag_right: [Check out case study #3 challange page](https://8weeksqlchallenge.com/case-study-3/)

# Table of contents
- [Case Description](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/case%203%20README.md#description)
- [Case Study Questions](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/case%203%20README.md#case-study-questions)
  - [Part A. Customer Journey](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/case%203%20README.md#part-a---customer-journey)
  - [Part B. Data Analysis Questions](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/case%203%20README.md#part-b---data-analysis-questions)
  - [Part C. Challenge Payment Question](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/case%203%20README.md#part-c---challenge-payment-question)
  - [Part D. Outside The Box Questions](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/case%203%20README.md#part-d---outside-the-box-questions)
- [Techiniques used in my solution](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/case%203%20README.md#techiniques-used-in-my-solution)
- [My solutions for each part](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/case%203%20README.md#my-solutions)
- [ER Diagram](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/case%203%20README.md#er-diagram)
- [Tables](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/case%203%20README.md#tables)

## Description 
![Case 3 Cover](https://8weeksqlchallenge.com/images/case-study-designs/3.png) 
> Subscription based businesses are super popular and Danny realised that there was a large gap in the market - he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows!
> Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!
> Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.

## Case Study Questions

### Part A - Customer Journey
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

[go to solution](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/partA%20Results.md)

### Part B - Data Analysis Questions
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

[go to solution](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/part%20B%20Results.md)

### Part C - Challenge Payment Question
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
once a customer churns they will no longer make payments

### Part D - Outside The Box Questions
1. How would you calculate the rate of growth for Foodie-Fi?
2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?

[go to solution](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/partD.md) 

## Techiniques used in my solution
- joins, where, group by, order by
- windowing functions
- cte

## My solutions
Part | Solution | Link to online DB |
--- | --- | --- |
A | [go](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/partA%20Results.md) | [view](https://www.db-fiddle.com/f/rHJhRrXy5hbVBNJ6F6b9gJ/16) |
B | [go](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/part%20B%20Results.md) | [view](https://www.db-fiddle.com/f/rHJhRrXy5hbVBNJ6F6b9gJ/16) |
C | --- | --- |
D | [go](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/partD.md) | no need |

## ER diagram 
![image](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/ER_case3.png)

## Tables 
![image](https://github.com/jmaynard-n/sql-8week-challenge/blob/main/case%20%233/tables%20case3.png)
