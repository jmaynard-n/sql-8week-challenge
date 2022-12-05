    SELECT s.customer_id, p.plan_name, p.price, s.start_date
    FROM foodie_fi.subscriptions s
    JOIN foodie_fi.plans p ON p.plan_id = s.plan_id
    WHERE customer_id IN (1,2,11,19,24,31,48,62)
    ORDER BY s.customer_id, s.start_date;

| customer_id | plan_name     | price  | start_date               |
| ----------- | ------------- | ------ | ------------------------ |
| 1           | trial         | 0.00   | 2020-08-01T00:00:00.000Z |
| 1           | basic monthly | 9.90   | 2020-08-08T00:00:00.000Z |
| 2           | trial         | 0.00   | 2020-09-20T00:00:00.000Z |
| 2           | pro annual    | 199.00 | 2020-09-27T00:00:00.000Z |
| 11          | trial         | 0.00   | 2020-11-19T00:00:00.000Z |
| 11          | churn         |        | 2020-11-26T00:00:00.000Z |
| 19          | trial         | 0.00   | 2020-06-22T00:00:00.000Z |
| 19          | pro monthly   | 19.90  | 2020-06-29T00:00:00.000Z |
| 19          | pro annual    | 199.00 | 2020-08-29T00:00:00.000Z |
| 24          | trial         | 0.00   | 2020-11-10T00:00:00.000Z |
| 24          | pro monthly   | 19.90  | 2020-11-17T00:00:00.000Z |
| 24          | pro annual    | 199.00 | 2021-04-17T00:00:00.000Z |
| 31          | trial         | 0.00   | 2020-06-22T00:00:00.000Z |
| 31          | pro monthly   | 19.90  | 2020-06-29T00:00:00.000Z |
| 31          | pro annual    | 199.00 | 2020-11-29T00:00:00.000Z |
| 48          | trial         | 0.00   | 2020-01-11T00:00:00.000Z |
| 48          | basic monthly | 9.90   | 2020-01-18T00:00:00.000Z |
| 48          | churn         |        | 2020-06-01T00:00:00.000Z |
| 62          | trial         | 0.00   | 2020-10-12T00:00:00.000Z |
| 62          | basic monthly | 9.90   | 2020-10-19T00:00:00.000Z |
| 62          | pro monthly   | 19.90  | 2021-01-02T00:00:00.000Z |
| 62          | churn         |        | 2021-02-23T00:00:00.000Z |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/rHJhRrXy5hbVBNJ6F6b9gJ/16)

---

# Customer Journeys

**Customer 1**
Started on trial on Aug 1st, 2020
➞
After 7 days of trail downgraded it to basic monthly

**Customer 2**
Started on trial on Sept 20th, 2020
➞
After 7 days of trail upgraded it to pro annual

**Customer 11**
Started on trial on Nov 19th, 2020
➞
After 7 days of trail cancelled their subscription

**Customer 19**
Started on trial on Jun 22nd, 2020
➞
After 7 days of trail automatically continued to pro monthly
➞
After 2 month upgraded to pro annual

**Customer 24**
Started on trial on Nov 11th, 2020
➞
After 7 days of trail automatically continued to pro monthly
➞
After 5 month upgraded to pro annual

**Customer 31**
Started on trial on Jun 22nd, 2020
➞
After 7 days of trail automatically continued to pro monthly
➞
After 5 month upgraded to pro annual

**Customer 48**
Started on trial on Jan 11th, 2020
➞
After 7 days of trail downgraded to basic monthly
➞
After 5 month cancelled their subscription

**Customer 62**
Started on trial on Oct 12th, 2020
➞
After 7 days of trail downgraded to basic monthly
➞
After 3 month upgraded to pro monthly
➞
After 1 month cancelled their subscription