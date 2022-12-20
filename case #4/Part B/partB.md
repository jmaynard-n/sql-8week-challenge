**Query #1**

    select distinct txn_type,
    	COUNT(txn_type) OVER(PARTITION BY txn_type) as ucount,
        COUNT(txn_type) OVER() as total
    from data_bank.customer_transactions;

| txn_type   | ucount | total |
| ---------- | ------ | ----- |
| purchase   | 1617   | 5868  |
| deposit    | 2671   | 5868  |
| withdrawal | 1580   | 5868  |

---
**Query #2**

    with tmp as (
    select 
    	AVG(txn_amount) OVER(PARTITION BY customer_id) as amounts,
        COUNT(txn_type) OVER(PARTITION BY customer_id) as hist_count
    from data_bank.customer_transactions
    where txn_type = 'deposit'
      )
    
    select round(avg(amounts), 2) as avg_amount, floor(avg(hist_count)) as avg_count
    from tmp;

| avg_amount | avg_count |
| ---------- | --------- |
| 508.86     | 6         |

---
**Query #3**

    with tmp as (
    select customer_id, extract(MONTH from txn_date) as month_of_year,
    	sum(case when txn_type = 'deposit' then 1 else 0 end) as deposit_cnt,
        sum(case when txn_type = 'purchase' then 1 else 0 end) as purchase_cnt,
        sum(case when txn_type = 'withdrawal' then 1 else 0 end) as wthdraw_cnt
    from data_bank.customer_transactions
    group by customer_id, month_of_year
      )
      
    select month_of_year, count(customer_id)
    from tmp
    where deposit_cnt >= 2 and (purchase_cnt = 1 or wthdraw_cnt = 1)
    group by month_of_year
    order by month_of_year;

| month_of_year | count |
| ------------- | ----- |
| 1             | 115   |
| 2             | 108   |
| 3             | 113   |
| 4             | 50    |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/2GtQz4wZtuNNu7zXH5HtV4/91)