**Query #1**
-- How many unique nodes are there on the Data Bank system?

    select COUNT(DISTINCT customer_nodes.node_id) from data_bank.customer_nodes;

| count |
| ----- |
| 5     |

---
**Query #2**
-- What is the number of nodes per region?

    select r.region_name, count(distinct cn.node_id)
    from data_bank.customer_nodes cn join data_bank.regions r
    	on cn.region_id = r.region_id
    group by r.region_name
    order by r.region_name;

| region_name | count |
| ----------- | ----- |
| Africa      | 5     |
| America     | 5     |
| Asia        | 5     |
| Australia   | 5     |
| Europe      | 5     |

---
**Query #3**
-- How many customers are allocated to each region?

    select r.region_name, count(distinct cn.customer_id)
    from data_bank.customer_nodes cn join data_bank.regions r
    	on cn.region_id = r.region_id
    group by r.region_name
    order by r.region_name;

| region_name | count |
| ----------- | ----- |
| Africa      | 102   |
| America     | 105   |
| Asia        | 95    |
| Australia   | 110   |
| Europe      | 88    |

---
**Query #4**
-- How many days on average are customers reallocated to a different node?

    with node_diff as (
    select customer_id, end_date - start_date as diff, node_id
    from data_bank.customer_nodes cn 
    where end_date != '9999-12-31'
    group by customer_id, node_id, end_date, start_date
    ),
    sum_diff as (
    select customer_id, node_id, SUM(diff) AS sum_diff
    from node_diff
    group by customer_id, node_id 
    )
    
    select 
      ROUND(AVG(sum_diff),2) AS avg_reallocation_days
    from sum_diff;

| avg_reallocation_days |
| --------------------- |
| 23.57                 |

---
**Query #5**
-- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

    with node_diff as (
    select customer_id, region_id, end_date - start_date as diff, node_id
    from data_bank.customer_nodes cn 
    where end_date != '9999-12-31'
    group by customer_id, node_id, end_date, start_date, region_id
    ),
    sum_diff as (
    select customer_id, node_id, region_id, SUM(diff) AS sum_diff
    from node_diff
    group by customer_id, node_id, region_id
    )
    
    select region_id,
      PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY sum_diff) as median, 
      PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY sum_diff) as percentile_80,
      PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY sum_diff) as percentile_95th
    from sum_diff
    Group by region_id
    Order by region_id;

| region_id | median | percentile_80     | percentile_95th   |
| --------- | ------ | ----------------- | ----------------- |
| 1         | 21     | 34                | 51                |
| 2         | 22     | 34                | 53.69999999999999 |
| 3         | 22     | 35                | 54                |
| 4         | 22     | 34.60000000000002 | 52                |
| 5         | 23     | 34                | 51.39999999999998 |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/2GtQz4wZtuNNu7zXH5HtV4/3)