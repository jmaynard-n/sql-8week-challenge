**Query #1**
1. What is the total amount each customer spent at the restaurant?

    SELECT s.customer_id, sum(m.price)
    FROM dannys_diner.sales s join dannys_diner.menu m 
    	on s.product_id = m.product_id
    GROUP BY s.customer_id
    ORDER BY s.customer_id;

| customer_id | sum |
| ----------- | --- |
| A           | 76  |
| B           | 74  |
| C           | 36  |

---
**Query #2**
2. How many days has each customer visited the restaurant?

    SELECT s.customer_id, count(distinct s.order_date)
    FROM dannys_diner.sales s 
    GROUP BY s.customer_id
    ORDER BY s.customer_id;

| customer_id | count |
| ----------- | ----- |
| A           | 4     |
| B           | 6     |
| C           | 2     |

---
**Query #3**
3. What was the first item from the menu purchased by each customer?

    WITH temp AS (
      SELECT s.customer_id, m.product_name, s.order_date,
      	ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date ASC) 
        AS RowN
      FROM dannys_diner.sales s join dannys_diner.menu m 
    	on s.product_id = m.product_id
     )
     
     SELECT customer_id, product_name
     FROM temp
     WHERE RowN = 1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| B           | curry        |
| C           | ramen        |

---
**Query #4**
4. What is the most purchased item on the menu and how many times was it purchased by all customers?

    SELECT m.product_name, count(m.product_id) as purchased
    FROM dannys_diner.sales s join dannys_diner.menu m 
    	on s.product_id = m.product_id
    GROUP BY m.product_name
    ORDER BY purchased DESC
    LIMIT 1;

| product_name | purchased |
| ------------ | --------- |
| ramen        | 8         |

---
**Query #5**
5. Which item was the most popular for each customer?

    SELECT t.customer_id, t.product_name
    FROM (
    	SELECT s.customer_id, m.product_name,
    		ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY count(m.product_id) DESC) AS RowN
    	FROM dannys_diner.sales s join dannys_diner.menu m 
    		on s.product_id = m.product_id
    	GROUP BY m.product_name, s.customer_id
    	) t
    WHERE RowN = 1
    ORDER BY t.customer_id;

| customer_id | product_name |
| ----------- | ------------ |
| A           | ramen        |
| B           | curry        |
| C           | ramen        |

---
**Query #6**
6. Which item was purchased first by the customer after they became a member?

    SELECT t.customer_id, t.product_name
    FROM (
    	SELECT s.customer_id, m.product_name, 
    		ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date ASC) 	AS RowN
    	FROM dannys_diner.sales s join dannys_diner.members mem 
    		on s.customer_id = mem.customer_id  
    		join dannys_diner.menu m on s.product_id = m.product_id
    	WHERE s.order_date >= mem.join_date
    	  ) t
    WHERE RowN = 1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| B           | sushi        |

---
**Query #7**
7. Which item was purchased just before the customer became a member?

    SELECT t.customer_id, t.product_name
    FROM (
    	SELECT s.customer_id, m.product_name,
    		ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) 	AS RowN
    	FROM dannys_diner.sales s join dannys_diner.members mem 
    		on s.customer_id = mem.customer_id  
    		join dannys_diner.menu m on s.product_id = m.product_id
    	WHERE s.order_date < mem.join_date
    	  ) t
    WHERE RowN = 1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| B           | sushi        |

---
**Query #8**
8. What is the total items and amount spent for each member before they became a member?

    SELECT distinct s.customer_id, 
    	SUM(m.price) OVER(PARTITION BY s.customer_id) as total_spent,
        COUNT(s.product_id) OVER(PARTITION BY s.customer_id) as total_items
    FROM dannys_diner.sales s join dannys_diner.members mem 
    	on s.customer_id = mem.customer_id  
    	join dannys_diner.menu m on s.product_id = m.product_id
    WHERE s.order_date < mem.join_date
    ORDER BY s.customer_id;

| customer_id | total_spent | total_items |
| ----------- | ----------- | ----------- |
| A           | 25          | 2           |
| B           | 40          | 3           |

---
**Query #9**
9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

    SELECT distinct s.customer_id,
    	SUM(CASE 
            WHEN m.product_name = 'sushi' THEN m.price * 20
            ELSE m.price * 10 
            END) OVER(PARTITION BY s.customer_id) as points
    FROM dannys_diner.sales s join dannys_diner.members mem 
    	on s.customer_id = mem.customer_id  
    	join dannys_diner.menu m on s.product_id = m.product_id
    WHERE s.order_date >= mem.join_date
    ORDER BY s.customer_id;

| customer_id | points |
| ----------- | ------ |
| A           | 510    |
| B           | 440    |

---
**Query #10**
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

    SELECT distinct s.customer_id, 
    	SUM(m.price * 10 * 2) OVER(PARTITION BY s.customer_id) as points
    FROM dannys_diner.sales s join dannys_diner.members mem 
    	on s.customer_id = mem.customer_id  
    	join dannys_diner.menu m on s.product_id = m.product_id
    WHERE 
    	s.order_date >= mem.join_date AND 
        s.order_date - mem.join_date + 1 <= 7
    ORDER BY s.customer_id;

| customer_id | points |
| ----------- | ------ |
| A           | 1020   |
| B           | 200    |

---
**Query #11**
Bonus #1. Join all the things and create a table with columns: customer_id, order_date, product_name, price, is they a member of loyalty program. Order by date and customers

    SELECT s.customer_id, s.order_date, m.product_name, m.price,
    	CASE WHEN s.order_date >= mem.join_date THEN 'Y'
        ELSE 'N'
        END as member
    FROM dannys_diner.sales s full join dannys_diner.members mem 
    	on s.customer_id = mem.customer_id  
    	join dannys_diner.menu m on s.product_id = m.product_id
    ORDER BY s.customer_id, s.order_date;

| customer_id | order_date               | product_name | price | member |
| ----------- | ------------------------ | ------------ | ----- | ------ |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N      |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y      |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N      |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N      |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y      |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y      |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y      |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N      |

---