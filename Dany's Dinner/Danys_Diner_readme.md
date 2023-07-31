# SQL_Projects

# 🍜 Case Study #1: Danny's Diner

## Solution

View the complete syntax.

***

### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT s.customer_id, SUM(price) AS total_sales
FROM dbo.sales AS s
JOIN dbo.menu AS m
   ON s.product_id = m.product_id
GROUP BY customer_id; 
````

#### Steps:

- To calculate the total sales from each customer, we'll use the **SUM** function combined with **GROUP BY**.
- We can merge the ```sales``` and ```menu``` tables by using **JOIN**, matching them through the shared attributes of ```customer_id``` and ```price```.



#### Answer:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***

### 2. How many days has each customer visited the restaurant?

````sql
SELECT customer_id, COUNT(DISTINCT(order_date)) AS visit_count
FROM dbo.sales
GROUP BY customer_id;
````

#### Steps:
- To determine the ```visit_count``` for each customer, we'll use the **COUNT** function with **DISTINCT** on the ```order_date``` column. This ensures that we avoid counting the same day multiple times if a customer visited the restaurant more than once on that particular day.
- By using **DISTINCT**, we only consider unique dates for each customer, providing an accurate count of their visits.

#### Answer:
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
WITH ordered_sales_cte AS
(
   SELECT customer_id, order_date, product_name,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date) AS rank
   FROM dbo.sales AS s
   JOIN dbo.menu AS m
      ON s.product_id = m.product_id
)

SELECT customer_id, product_name
FROM ordered_sales_cte
WHERE rank = 1
GROUP BY customer_id, product_name;
````

#### Steps:

- Create a  CTE ```order_sales_cte``` and use **DENSE_RANK** to add a new column ```rank``` based on ```order_date```.
- Since ```order_date``` lacks timestamps, use **DENSE_RANK** to avoid assigning different ranks to orders placed on the same day.
- **GROUP BY** all columns to display only records with ```rank = 1```, showing the first order made by each customer without considering the order sequence on the same day.

#### Answer:
| customer_id | product_name | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- Customer A's first orders are curry and sushi.
- Customer B's first order is curry.
- Customer C's first order is ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT TOP 1 (COUNT(s.product_id)) AS most_purchased, product_name
FROM dbo.sales AS s
JOIN dbo.menu AS m
   ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY most_purchased DESC;
````

#### Steps:
Sure, here it is:

- **COUNT** the number of ```product_id``` and **ORDER BY** the count in descending order to find the ```most_purchased``` items.
- Use **TOP 1** to filter and display the highest number of purchased item.

#### Answer:
| most_purchased | product_name | 
| ----------- | ----------- |
| 8       | ramen |


- The most purchased item on the menu is ramen, which has been ordered 8 times.

***

### 5. Which item was the most popular for each customer?

````sql
WITH fav_item_cte AS
(
   SELECT s.customer_id, m.product_name, COUNT(m.product_id) AS order_count,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY COUNT(s.customer_id) DESC) AS rank
   FROM dbo.menu AS m
   JOIN dbo.sales AS s
      ON m.product_id = s.product_id
   GROUP BY s.customer_id, m.product_name
)

SELECT customer_id, product_name, order_count
FROM fav_item_cte 
WHERE rank = 1;
````

#### Steps:
- Create a CTE (Common Table Expression) named ```fav_item_cte``` and use **DENSE_RANK** to assign a ```rank``` to each product based on its ```order_count``` in descending order for each customer.
- Retrieve results showing only the products where the ```rank``` is equal to 1, representing the most popular product for each customer.

#### Answer:
| customer_id | product_name | order_count |
| ----------- | ---------- |------------  |
| A           | ramen        |  3   |
| B           | sushi        |  2   |
| B           | curry        |  2   |
| B           | ramen        |  2   |
| C           | ramen        |  3   |

- Based on the analysis, both Customer A and Customer C's favorite item is ramen.
- On the other hand, Customer B seems to enjoy all items on the menu

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
WITH member_sales_cte AS 
(
   SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date) AS rank
   FROM sales AS s
   JOIN members AS m
      ON s.customer_id = m.customer_id
   WHERE s.order_date >= m.join_date
)

SELECT s.customer_id, s.order_date, m2.product_name 
FROM member_sales_cte AS s
JOIN menu AS m2
   ON s.product_id = m2.product_id
WHERE rank = 1;
````

#### Steps:
- Let's create a temporary table called ```member_sales_cte``` using a window function. We'll partition it by ascending ```order_date``` and then filter the results to include only records on or after the ```join_date``` for each customer.
- After that, we'll further filter the table to show only the first item purchased by each customer, where ```rank = 1```.

#### Answer:
| customer_id | order_date  | product_name |
| ----------- | ---------- |----------  |
| A           | 2021-01-07 | curry        |
| B           | 2021-01-11 | sushi        |

- Based on the analysis from the ```member_sales_cte``` table, we found that Customer A's first order as a member was curry.
- Similarly, Customer B's first order as a member was sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
WITH prior_member_purchased_cte AS 
(
   SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
         DENSE_RANK() OVER(PARTITION BY s.customer_id
         ORDER BY s.order_date DESC) AS rank
   FROM sales AS s
   JOIN members AS m
      ON s.customer_id = m.customer_id
   WHERE s.order_date < m.join_date
)

SELECT s.customer_id, s.order_date, m2.product_name 
FROM prior_member_purchased_cte AS s
JOIN menu AS m2
   ON s.product_id = m2.product_id
WHERE rank = 1;
````

#### Steps:
- To find out the last ```order_date``` before a customer becomes a member, we created the ```prior_member_purchased_cte``` table. We used a **Windows function** with partitioning by ```customer_id``` and ordering by descending ```order_date``` to create a new column ```rank``` that represents the sequence of orders for each customer.
- Then, we filtered the table to include only the ```order_date``` that occurred before the corresponding customer's ```join_date```. This gives us the last purchase date before the customer became a member.

#### Answer:
| customer_id | order_date  | product_name |
| ----------- | ---------- |----------  |
| A           | 2021-01-01 |  sushi        |
| A           | 2021-01-01 |  curry        |
| B           | 2021-01-04 |  sushi        |

- Customer A's last orders before becoming a member were sushi and curry.
- As for Customer B, it was sushi. That must have been some really good sushi!

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
SELECT s.customer_id, COUNT(DISTINCT s.product_id) AS unique_menu_item, 
   SUM(mm.price) AS total_sales
FROM sales AS s
JOIN members AS m
   ON s.customer_id = m.customer_id
JOIN menu AS mm
   ON s.product_id = mm.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;

````

#### Steps:
- Filter the `order_date` before `join_date` and then perform a **COUNT DISTINCT** on `product_id` and **SUM** the `total spent` before becoming a member.- Filter ```order_date``` before ```join_date``` and perform a **COUNT** **DISTINCT** on ```product_id``` and **SUM** the ```total spent``` before becoming member.

#### Answer:
| customer_id | unique_menu_item | total_sales |
| ----------- | ---------- |----------  |
| A           | 2 |  25       |
| B           | 2 |  40       |

Before becoming members,
- Customer A spent $ 25 on 2 items.
- Customer B spent $40 on 2 items.

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

````sql
WITH price_points AS
(
   SELECT *, 
      CASE
         WHEN product_id = 1 THEN price * 20
         ELSE price * 10
      END AS points
   FROM menu
)

SELECT s.customer_id, SUM(p.points) AS total_points
FROM price_points_cte AS p
JOIN sales AS s
   ON p.product_id = s.product_id
GROUP BY s.customer_id
````

#### Steps:
- To calculate the total points earned by each customer before becoming a member, we'll use the following breakdown:
	- Each $1 spent = 10 points.
	- For sushi (product_id 1), each $1 spent = 20 points.

- We'll use the CASE WHEN statement to create conditional statements for calculating points:
	- If product_id = 1, then every $1 price is multiplied by 20 points.
	- For all other product_id values that are not 1, each $1 is multiplied by 10 points.

- Then, we'll use the SUM function to calculate the total points earned, which we'll name as ```price_points```.

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 860 |
| B           | 940 |
| C           | 360 |

- Total points for Customer A is 860.
- Total points for Customer B is 940.
- Total points for Customer C is 360.

***

### 10. 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

````sql
WITH dates_cte AS 
(
   SELECT *, 
      DATEADD(DAY, 6, join_date) AS valid_date, 
      EOMONTH('2021-01-31') AS last_date
   FROM members AS m
)

SELECT d.customer_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price,
   SUM(CASE
      WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
      WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
      ELSE 10 * m.price
      END) AS points
FROM dates_cte AS d
JOIN sales AS s
   ON d.customer_id = s.customer_id
JOIN menu AS m
   ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY d.customer_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price
````

#### Steps:
To calculate the points for each customer based on the different time periods, we'll use the following assumptions:

- On Day -X to Day 1 (customer becomes a member on Day 1 ```join_date```), each $1 spent is 10 points and for sushi, each $1 spent is 20 points.
- On Day 1 ```join_date``` to Day 7 ```valid_date```, each $1 spent for all items is 20 points.
- On Day 8 to ```last_day``` of Jan 2021, each $1 spent is 10 points, and for sushi, it's 2x points (20 points per $1).

We'll create a ```dates_cte``` to find out the customer's ```valid_date``` (which is 6 days after ```join_date``` and inclusive of ```join_date```) and ```last_day``` of Jan 2021 (which is ‘2021–01–31’). Then, we'll calculate the points accordingly based on the defined assumptions.

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 1370 |
| B           | 820 |

- Total points for Customer A is 1,370.
- Total points for Customer B is 820.

***

## BONUS QUESTIONS

### Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

````sql
SELECT s.customer_id, s.order_date, m.product_name, m.price,
   CASE
      WHEN mm.join_date > s.order_date THEN 'N'
      WHEN mm.join_date <= s.order_date THEN 'Y'
      ELSE 'N'
      END AS member
FROM sales AS s
LEFT JOIN menu AS m
   ON s.product_id = m.product_id
LEFT JOIN members AS mm
   ON s.customer_id = mm.customer_id;
 ````
 
#### Answer: 
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | -------------| ----- | ------ |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

***

### Rank All The Things - Danny also requires further information about the ```ranking``` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ```ranking``` values for the records when customers are not yet part of the loyalty program.

````sql
WITH summary_cte AS 
(
   SELECT s.customer_id, s.order_date, m.product_name, m.price,
      CASE
      WHEN mm.join_date > s.order_date THEN 'N'
      WHEN mm.join_date <= s.order_date THEN 'Y'
      ELSE 'N' END AS member
   FROM sales AS s
   LEFT JOIN menu AS m
      ON s.product_id = m.product_id
   LEFT JOIN members AS mm
      ON s.customer_id = mm.customer_id
)

SELECT *, CASE
   WHEN member = 'N' then NULL
   ELSE
      RANK () OVER(PARTITION BY customer_id, member
      ORDER BY order_date) END AS ranking
FROM summary_cte;
````

#### Answer: 
| customer_id | order_date | product_name | price | member | ranking | 
| ----------- | ---------- | -------------| ----- | ------ |-------- |
| A           | 2021-01-01 | sushi        | 10    | N      | NULL
| A           | 2021-01-01 | curry        | 15    | N      | NULL
| A           | 2021-01-07 | curry        | 15    | Y      | 1
| A           | 2021-01-10 | ramen        | 12    | Y      | 2
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| B           | 2021-01-01 | curry        | 15    | N      | NULL
| B           | 2021-01-02 | curry        | 15    | N      | NULL
| B           | 2021-01-04 | sushi        | 10    | N      | NULL
| B           | 2021-01-11 | sushi        | 10    | Y      | 1
| B           | 2021-01-16 | ramen        | 12    | Y      | 2
| B           | 2021-02-01 | ramen        | 12    | Y      | 3
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-07 | ramen        | 12    | N      | NULL


***


