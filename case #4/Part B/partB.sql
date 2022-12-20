-- What is the unique count and total amount for each transaction type?

select distinct txn_type,
	COUNT(txn_type) OVER(PARTITION BY txn_type) as ucount,
    COUNT(txn_type) OVER() as total
from data_bank.customer_transactions;

-- What is the average total historical deposit counts and amounts for all customers?

with tmp as (
select 
	AVG(txn_amount) OVER(PARTITION BY customer_id) as amounts,
    COUNT(txn_type) OVER(PARTITION BY customer_id) as hist_count
from data_bank.customer_transactions
where txn_type = 'deposit'
  )

select round(avg(amounts), 2) as avg_amount, floor(avg(hist_count)) as avg_count
from tmp;

-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

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

-- What is the closing balance for each customer at the end of the month?



-- What is the percentage of customers who increase their closing balance by more than 5%?


