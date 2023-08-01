--Danny's Dinner A Resurant's Data Study 

--Q-1 : What is the total amount each customer spent at the restaurant?

SELECT customer_id,
       Sum(price) AS Total_Amount_Spent
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY customer_id;

--Q-2 : How many days has each customer visited the restaurant?

SELECT sales.customer_id, 
       Count(DISTINCT(sales.order_date)) AS Days_Visited
FROM dannys_diner.sales
GROUP BY sales.customer_id ;


--Q-3 : What was the first item(s) from the menu purchased by each customer?
--Use Of Window Function

With Ordered_sales AS (
SELECT sales.customer_id,
       rank() OVER(
        PARTITION BY sales.customer_id
        ORDER BY sales.order_date
       ) AS order_rank ,
       sales.order_date,
       menu.product_name
From dannys_diner.sales
JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
)
SELECT  DISTINCT customer_id, product_name , order_date
FROM Ordered_sales
WHERE order_rank = 1
;

-- Q4 : What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
  menu.product_name,
  Count(Sales.*) As total_purchases
From dannys_diner.menu
Inner Join dannys_diner.sales
ON menu.product_id = sales.product_id
Group By product_name
Limit 1;

-- Q5 : Which item(s) was the most popular for each customer?

WITH customer_item_cte AS (
SELECT
  sales.customer_id,
  menu.product_name,
  COUNT(sales.*) as Frequent_Item_Purchase,
  DENSE_RANK() Over(
         PARTITION BY sales.customer_id
         ORDER BY COUNT(sales.*) DESC
  ) AS item_rank
FROM dannys_diner.menu
INNER JOIN dannys_diner.sales
ON menu.product_id = sales.product_id
GROUP BY sales.customer_id ,menu.product_name
)
SELECT 
  customer_id,
  product_name,
  Frequent_Item_Purchase
FROM customer_item_cte
WHERE item_rank =1
;





