# SQL_Projects

# E-commerce Inventory Analysis

## Solution

View the complete syntax [here](https://github.com/Temitope5/SQL_Projects/blob/main/E-commerce%20Inventory%20Analysis/E-commerce%20Inventory%20Analysis.sql)

***
## Database Set Up

## Table 1: products
````sql 
CREATE TABLE products (
product_id SERIAL PRIMARY KEY,
product_name VARCHAR(50),
product_category VARCHAR(20),
product_price NUMERIC(10,2)
);

INSERT INTO products (product_name, product_category, product_price)
VALUES ('Product A', 'Category 1', 19.99),
('Product B', 'Category 2', 29.99),
('Product C', 'Category 1', 39.99),
('Product D', 'Category 3', 49.99),
('Product E', 'Category 2', 59.99);

````

## Table 2: inventory

````sql
CREATE TABLE inventory (
  product_id INT,
  inventory_date DATE,
  inventory_level INT
);

INSERT INTO inventory (product_id, inventory_date, inventory_level)
VALUES (1, '2022-01-01', 100),
       (2, '2022-01-01', 200),
       (3, '2022-01-01', 150),
       (4, '2022-01-01', 75),
       (5, '2022-01-01', 250),
       (1, '2022-01-02', 80),
       (2, '2022-01-02', 180),
       (3, '2022-01-02', 100),
       (4, '2022-01-02', 60),
       (5, '2022-01-02', 220),
       (1, '2022-01-03', 50),
       (2, '2022-01-03', 150),
       (3, '2022-01-03', 75),
       (4, '2022-01-03', 80),
       (5, '2022-01-03', 200);
````

## Question 1. What are the top 5 products with the highest inventory levels on the most recent inventory date?

#### Approach 1

````sql 
SELECT p.product_name,
(SELECT inventory_level FROM inventory WHERE product_id = p.product_id ORDER BY inventory_date DESC LIMIT 1) AS inventory_level
FROM products AS p
ORDER BY inventory_level DESC; 
````

#### Explanation:
- This query retrieves the product_names and their latest inventory_levels from the products and inventory tables.
- It uses a subquery to find the maximum inventory_date for all products, 
- And then filters the inventory table to retrieve the inventory levels for the latest inventory_date. The results are sorted by inventory_level.

#### Approach 2:

````sql
SELECT p.product_name,i.inventory_level
FROM products AS p
INNER JOIN inventory AS i
ON i.product_id = p.product_id
WHERE i.inventory_date = (SELECT MAX(inventory_date) FROM inventor
````

#### Explanation:
- This query retrieves the latest inventory level for each product by joining the products and inventory tables on the product_id and inventory_date columns.
- It uses a subquery to find the latest inventory_date for each product, and then joins the inventory table again to retrieve the corresponding inventory_level for each product. The results are sorted in descending order by inventory_level.

#### Approach 3:
```` sql
SELECT p.product_name, i.inventory_level
FROM products AS p
INNER JOIN 
(
SELECT product_id, MAX(inventory_date) AS max_date
	FROM inventory
	GROUP BY product_id
) AS latest_inv
ON p.product_id =latest_inv.product_id
INNER JOIN inventory AS i
ON latest_inv.product_id=i.product_id
AND latest_inv.max_date= i.inventory_date
Order by i.inventory_level DESC
````

#### Explanation:
- This query retrieves the total inventory level for each product category based on the latest inventory data by joining the products and inventory tables using a subquery to filter the inventory table for the most recent inventory data for each product.
- The subquery selects the product_id and the maximum inventory_date for each product from the inventory table, grouping the results by product_id. 
- The latest inventory data for each product is then joined with the products table on the product_id column to retrieve the corresponding product_category.
- The results are then joined with the inventory table on the product_id and inventory_date columns to retrieve the inventory_level for the latest inventory data. The results are then summed using the SUM function and displayed as the total_inventory_level.
- The results are then grouped by product_category using the GROUP BY clause, and sorted in descending order by the total_inventory_level using the ORDER BY clause. 

### Result

|product_name|	inventory_level|
|-------------|-------------|
|Product E|	200|
|Product B	|150|
|Product D	|80|
|Product C	|75|
|Product A	|50|

- The top 5 inventory levels include
- Product E with an inventory level of 200
- Product E with an inventory level of 150
- Product E with an inventory level of 80
- Product E with an inventory level of 75
- Product E with an inventory level of 50

- This suggests you would need to stock up on Product A and Product B as quick as possible before customers starts complaining

## Question 2. What is the total inventory level for each product category on the most recent inventory date?

#### Approach 1

````sql
SELECT p.product_category, SUM(i.inventory_level)AS total_inventory_level
FROM products AS p
INNER JOIN inventory AS i
ON i.product_id = p.product_id
WHERE i.inventory_date = (SELECT MAX(inventory_date) FROM inventory)
GROUP BY product_category
````
#### Explanation:
- This query retrieves the total inventory level for each product category on the most recent inventory date by joining the products and inventory tables on the product_id column. 
- It uses a subquery to find the latest inventory date and then filters the inventory table to retrieve the inventory levels for that date. The results are then grouped by product category, and the total inventory level for each category is calculated using the SUM function.


#### Approach 2

````sql
SELECT p.product_category,
SUM((SELECT inventory_level FROM inventory WHERE product_id = p.product_id ORDER BY inventory_date DESC LIMIT 1)) AS total_inventory_level
FROM products AS p
GROUP BY product_category
````
ORDER BY 2 DESC

#### Explanation:

- This query retrieves the total inventory level for each product category based on the latest inventory data by using a subquery in the SELECT clause to retrieve the latest inventory_level for each product from the inventory table. 
- The results are then grouped by product_category using the GROUP BY clause, and sorted in descending order by the total_inventory_level using the ORDER BY clause.

#### Approach 3

````sql 
SELECT p.product_category, sum(i.inventory_level) AS total_inventory_level
FROM products AS p
INNER JOIN 
(
SELECT product_id, MAX(inventory_date) AS max_date
	FROM inventory
	GROUP BY product_id
) AS latest_inv
ON p.product_id =latest_inv.product_id
INNER JOIN inventory AS i
ON latest_inv.product_id=i.product_id
AND latest_inv.max_date= i.inventory_date
GROUP BY p.product_category
ORDER BY 2 DESC
````

#### Explanation:

- This query retrieves the total inventory level for each product category based on the latest inventory data by joining the products and inventory tables using a subquery to filter the inventory table for the most recent inventory data for each product.
- The subquery selects the product_id and the maximum inventory_date for each product from the inventory table, grouping the results by product_id. 
- The latest inventory data for each product is then joined with the products table on the product_id column to retrieve the corresponding product_category.
- The results are then joined with the inventory table on the product_id and inventory_date columns to retrieve the inventory_level for the latest inventory data. The results are then summed using the SUM function and displayed as the total_inventory_level.
- The results are then grouped by product_category using the GROUP BY clause, and sorted in descending order by the total_inventory_level using the ORDER BY clause. 

#### Result

|product_category |	total_inventory_level|
|-------------|-------------|
|Category 1|	125|
|Category 2|	350|
|Category 3|	80|

- Product category 1 has a total stock level of 125
- Product category 2 has a total stock level of 350
- Product category 3 has a total stock level of 80


## Question 3 : What is the average inventory level for each product category for the month of January 2022?

#### Approach 1

````sql
SELECT p.product_category,round(avg(i.inventory_level),2) AS avg_inventory_level
FROM products AS p
INNER JOIN inventory AS i
ON p.product_id = i.product_id
WHERE EXTRACT(YEAR FROM i.inventory_date)= 2022 AND
EXTRACT(MONTH FROM inventory_date)= 01
GROUP BY p.product_category
````
#### Explanation:
- This approach uses the EXTRACT function to filter inventory data for January 2022, then joins the products and inventory tables using the product_id column.
-It then groups the results by product_category and calculates the average inventory level, rounded to 2 decimal places using the ROUND function.

#### Approach 2

````sql 
SELECT p.product_category,round(avg(i.inventory_level),2) AS avg_inventory_level
FROM products AS p
INNER JOIN inventory AS i
ON p.product_id = i.product_id
WHERE i.inventory_date >= '2022-01-01' AND inventory_date < '2022-02-01'
GROUP BY p.product_category
````
#### Explanation:
- This approach uses a subquery to identify the latest inventory date for each product_id, then joins the products and inventory tables on the latest inventory date and product_id columns. It then groups the results by product_category and calculates the sum of inventory levels.


#### Approach 3
````sql
SELECT p.product_category, ROUND(AVG(i.inventory_level), 2) AS avg_inventory_level
FROM products AS p, inventory AS i
WHERE p.product_id = i.product_id
AND i.inventory_date BETWEEN '2022-01-01' AND '2022-01-31'
GROUP BY p.product_category
````
#### Explanation:

- This approach uses the BETWEEN operator to filter inventory data for the month of January 2022, then joins the products and inventory tables using the product_id column. 
- It then groups the results by product_category and calculates the average inventory level, rounded to 2 decimal places using the ROUND function

#### Result

|product_category|	avg_inventory_level|
|-------------|-------------|
|Category |1|	92.5|
|Category |2|	200|
|Category |3|	71.67|

## Question 4. Which products had a decrease in inventory level from the previous inventory date to the current inventory date?

#### Approach 1

````sql
WITH cte AS 
(
SELECT
product_name,
curr.inventory_date,
curr.inventory_level - LAG(curr.inventory_level) OVER (PARTITION BY curr.product_id ORDER BY curr.inventory_date) AS inventory_diff
FROM inventory AS curr
INNER JOIN products as p
ON p.product_id = curr.product_id
)
SELECT * 
FROM cte
WHERE inventory_change IS NOT NULL
````

- This query calculates the difference in inventory levels between the current date and the previous date for each product in the inventory table.
- It then returns the product name, inventory date, and inventory difference for products that experienced a change in inventory level.

#### Approach 2

````sql
SELECT  p.product_name, inv_1.inventory_date, inv_1.inventory_level - inv_2.inventory_level AS inventory_diff
FROM inventory AS inv_1
JOIN inventory inv_2 ON inv_1.product_id = inv_2.product_id 
         AND inv_1.inventory_date = inv_2.inventory_date + INTERVAL '1 day'
JOIN products p ON inv_1.product_id = p.product_id
WHERE inv_1.inventory_level < inv_2.inventory_level;
````
#### Explanation:
- This SQL query retrieves the product name, inventory date, and inventory level difference between two consecutive days for each product in the inventory table where the inventory level decreased.
- It helps to identify the products with declining inventory levels on consecutive days, which can be useful for inventory management and supply chain optimization.

#### Approach 3

````sql
SELECT 
    
	p.product_name,
    curr.inventory_date, 
    curr.inventory_level - prev.inventory_level AS inventory_diff
FROM inventory AS curr
JOIN inventory AS prev 
    ON curr.product_id = prev.product_id 
    AND curr.inventory_date > prev.inventory_date 
    AND NOT EXISTS (
        SELECT 1 FROM inventory 
        WHERE product_id = curr.product_id 
        AND inventory_date > prev.inventory_date 
        AND inventory_date < curr.inventory_date
    )
JOIN products AS p
ON p.product_id =curr.product_id
WHERE curr.inventory_level < prev.inventory_level
ORDER BY curr.product_id, curr.inventory_date DESC;
````

#### Explanation:
- This SQL query identifies products whose inventory levels have decreased over two consecutive days. It returns the product name, inventory date, and inventory difference for each product that experienced a decrease in inventory level

#### Result
|	product_name	|	inventory_date	|	inventory_diff	|
|-------------|-------------|-------------|
|	Product A	|	03/01/2022	|	-30	|
|	Product A	|	02/01/2022	|	-20	|
|	Product B	|	03/01/2022	|	-30	|
|	Product B	|	02/01/2022	|	-20	|
|	Product C	|	03/01/2022	|	-25	|
|	Product C	|	02/01/2022	|	-50	|
|	Product D	|	02/01/2022	|	-15	|
|	Product E	|	03/01/2022	|	-20	|
|	Product E	|	02/01/2022	|	-30	|


## Question 5. What is the overall trend in inventory levels for each product category over the month of January 2022?

#### Approach 1

````sql
SELECT p.product_category,i.inventory_date , round(avg(i.inventory_level),2) AS avg_inventory_level
FROM products AS p
INNER JOIN inventory AS i
ON p.product_id = i.product_id
WHERE EXTRACT(YEAR FROM i.inventory_date)= 2022 AND
EXTRACT(MONTH FROM inventory_date)= 01
GROUP BY p.product_category, i.inventory_date
ORDER BY p.product_category, i.inventory_date
````
#### Explanation:
- This the query joins the products and inventory tables on the product_id. It filters the results to only include inventory levels from January 2022, then groups the data by product category and inventory date.

#### Approach 2

````sql
SELECT p.product_category, i.inventory_date,round(avg(i.inventory_level),2) AS avg_inventory_level
FROM products AS p
INNER JOIN inventory AS i
ON p.product_id = i.product_id
WHERE i.inventory_date >= '2022-01-01' AND inventory_date < '2022-02-01'
GROUP BY p.product_category, i.inventory_date
ORDER BY p.product_category, i.inventory_date
````
#### Explanation:

- This query joins the products and inventory tables using the product_id column.

- The WHERE clause filters the results to include only inventory levels recorded between January 1, 2022, and January 31, 2022. The GROUP BY clause groups the data by product category and inventory date, allowing the query to calculate the average inventory level for each product category on each inventory date in January 2022.

- Finally, the ORDER BY clause sorts the results by product category and inventory date, which makes it easier to analyze the data.

#### Approach 3

````sql
SELECT p.product_category,i.inventory_date, ROUND(AVG(i.inventory_level), 2) AS avg_inventory_level
FROM products AS p, inventory AS i
WHERE p.product_id = i.product_id
AND i.inventory_date BETWEEN '2022-01-01' AND '2022-01-31'
GROUP BY p.product_category, i.inventory_date
ORDER BY p.product_category, i.inventory_date
````

Explanation
- This query performs an inner join between the products and inventory tables on the product_id column.

- The WHERE clause filters the results to include only inventory levels recorded between January 1, 2022, and January 31, 2022. The GROUP BY clause groups the data by product category and inventory date, allowing the query to calculate the average inventory level for each product category on each inventory date in January 2022.

Finally, the ORDER BY clause sorts the results by product category and inventory date, which makes it easier to analyze the data.

#### Result 

|	product_category	|	inventory_date	|	avg_inventory_level	|
|-------------|-------------|-------------|
|	Category 1	|	01/01/2022	|	125	|
|	Category 1	|	02/01/2022	|	90	|
|	Category 1	|	03/01/2022	|	62.5	|
|	Category 2	|	01/01/2022	|	225	|
|	Category 2	|	02/01/2022	|	200	|
|	Category 2	|	03/01/2022	|	175	|
|	Category 3	|	01/01/2022	|	75	|
|	Category 3	|	02/01/2022	|	60	|
|	Category 3	|	03/01/2022	|	80	|
