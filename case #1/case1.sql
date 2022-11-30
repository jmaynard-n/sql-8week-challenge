/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

/* 
   --------
   SOLUTION
   --------
*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, sum(m.price)
FROM dannys_diner.sales s join dannys_diner.menu m 
	on s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT s.customer_id, count(distinct s.order_date)
FROM dannys_diner.sales s 
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 3. What was the first item from the menu purchased by each customer?
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

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name, count(m.product_id) as purchased
FROM dannys_diner.sales s join dannys_diner.menu m 
	on s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY purchased DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

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


-- 6. Which item was purchased first by the customer after they became a member?

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

-- 7. Which item was purchased just before the customer became a member?

/* !!!!! LAG AND LEAD WINDOW FUNCTIONS !!!! */

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

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT distinct s.customer_id, 
	SUM(m.price) OVER(PARTITION BY s.customer_id) as total_spent,
    COUNT(s.product_id) OVER(PARTITION BY s.customer_id) as total_items
FROM dannys_diner.sales s join dannys_diner.members mem 
	on s.customer_id = mem.customer_id  
	join dannys_diner.menu m on s.product_id = m.product_id
WHERE s.order_date < mem.join_date
ORDER BY s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

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

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT distinct s.customer_id, 
	SUM(m.price * 10 * 2) OVER(PARTITION BY s.customer_id) as points
FROM dannys_diner.sales s join dannys_diner.members mem 
	on s.customer_id = mem.customer_id  
	join dannys_diner.menu m on s.product_id = m.product_id
WHERE -- first week after joining
	s.order_date >= mem.join_date AND 
    s.order_date - mem.join_date + 1 <= 7
ORDER BY s.customer_id;

-- bonus question #1
-- Join all the things.

SELECT s.customer_id, s.order_date, m.product_name, m.price,
	CASE WHEN s.order_date >= mem.join_date THEN 'Y'
    ELSE 'N'
    END as member
FROM dannys_diner.sales s full join dannys_diner.members mem 
	on s.customer_id = mem.customer_id  
	join dannys_diner.menu m on s.product_id = m.product_id
ORDER BY s.customer_id, s.order_date;

-- bonus question #2
-- Rank all the things
--  NOT COMPLETED
-- SELECT s.customer_id, s.order_date, m.product_name, m.price,
-- 	CASE WHEN s.order_date >= mem.join_date THEN 'Y'
--     ELSE 'N'
--     END as member,
--     DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date)
--     as ranking
-- FROM dannys_diner.sales s full join dannys_diner.members mem 
-- 	on s.customer_id = mem.customer_id  
-- 	join dannys_diner.menu m on s.product_id = m.product_id
-- ORDER BY s.customer_id, s.order_date;