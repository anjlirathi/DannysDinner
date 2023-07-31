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