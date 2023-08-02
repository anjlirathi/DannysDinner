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

-- Q6 : Which item was purchased first by the customer after they became a member and what date was it? (including the date they joined)

WITH members_sales_cte AS(
SELECT 
  sales.customer_id,
  sales.order_date,
  menu.product_name,
  RANK () OVER (
          PARTITION BY sales.customer_id
          ORDER BY sales.order_date
        ) AS order_rank
FROM dannys_diner.sales 
INNER JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
INNER JOIN dannys_diner.members
ON sales.customer_id = members.customer_id
WHERE 
  sales.order_date >= members.join_date::DATE 
)
SELECT 
  customer_id,
  product_name,
  order_date
FROM members_sales_cte
WHERE order_rank =1;

--Q7 : Which menu item(s) was purchased just before the customer became a member and when?

WITH member_item_cte AS (
SELECT
  sales.customer_id,
  sales.order_date,
  menu.product_name,
  RANK() OVER (
        PARTITION BY sales.customer_id
        ORDER BY sales.order_date DESC --just before date
  ) AS order_rank
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
INNER JOIN dannys_diner.members
ON sales.customer_id = members.customer_id
WHERE 
  sales.order_date < members.join_date::DATE 
)
SELECT 
  customer_id,
  product_name,
  order_date
FROM member_item_cte
WHERE order_rank = 1;

--Q8 : What is the number of unique menu items and total amount spent for each member before they became a member?

SELECT 
  sales.customer_id,
  COUNT(DISTINCT menu.product_id) AS unique_menu_items,
  SUM (menu.price) AS total_spent
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
INNER JOIN dannys_diner.members
ON sales.customer_id = members.customer_id
WHERE 
  sales.order_date < members.join_date::DATE 
GROUP BY sales.customer_id
;


-- Q9 : If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT 
  sales.customer_id,
  SUM (
    CASE 
      WHEN menu.product_name = 'sushi' THEN 2*10*menu.price
      ELSE 10*menu.price
    END
    ) AS points
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY points DESC
;

--Q10 : In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT 
  sales.customer_id,
  SUM (
    CASE 
      WHEN menu.product_name != 'sushi' THEN 2*10*menu.price
      WHEN sales.order_date BETWEEN (members.join_date::DATE+6) AND (members.join_date::DATE) THEN 2*10*menu.price
      ELSE NULL
    END
  ) AS Points
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
INNER JOIN dannys_diner.members
ON sales.customer_id = members.customer_id
WHERE 
  sales.order_date BETWEEN (members.join_date::DATE+6) AND (members.join_date::DATE)
GROUP BY sales.customer_id
ORDER BY Points
;






