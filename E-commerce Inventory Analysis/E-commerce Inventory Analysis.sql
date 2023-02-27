--Setting up the DB
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



-- Question 1 : What are the top 5 products with the highest inventory levels on the most recent inventory date?

-- Approach 1

SELECT p.product_name,
(SELECT inventory_level FROM inventory WHERE product_id = p.product_id ORDER BY inventory_date DESC LIMIT 1) AS inventory_level
FROM products AS p
ORDER BY inventory_level DESC

-- Approach 2

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

-- Approach 3

SELECT p.product_name,i.inventory_level
FROM products AS p
INNER JOIN inventory AS i
ON i.product_id = p.product_id
WHERE i.inventory_date = (SELECT MAX(inventory_date) FROM inventory)

-- Question 2 : What is the total inventory level for each product category on the most recent inventory date?

-- Approach 1
SELECT p.product_category, SUM(i.inventory_level)
FROM products AS p
INNER JOIN inventory AS i
ON i.product_id = p.product_id
WHERE i.inventory_date = (SELECT MAX(inventory_date) FROM inventory)
GROUP BY product_category

-- Approach 2

SELECT p.product_category,
SUM((SELECT inventory_level FROM inventory WHERE product_id = p.product_id ORDER BY inventory_date DESC LIMIT 1)) AS total_inventory_level
FROM products AS p
GROUP BY product_category
ORDER BY 2 DESC

-- Approach 3

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

-- Question 3 : What is the average inventory level for each product category for the month of January 2022?

--Approach 1
SELECT p.product_category,round(avg(i.inventory_level),2) AS avg_inventory_level
FROM products AS p
INNER JOIN inventory AS i
ON p.product_id = i.product_id
WHERE EXTRACT(YEAR FROM i.inventory_date)= 2022 AND
EXTRACT(MONTH FROM inventory_date)= 01
GROUP BY p.product_category

--Approach 2
SELECT p.product_category,round(avg(i.inventory_level),2) AS avg_inventory_level
FROM products AS p
INNER JOIN inventory AS i
ON p.product_id = i.product_id
WHERE i.inventory_date >= '2022-01-01' AND inventory_date < '2022-02-01'
GROUP BY p.product_category

-- Approach 3

SELECT p.product_category, ROUND(AVG(i.inventory_level), 2) AS avg_inventory_level
FROM products AS p, inventory AS i
WHERE p.product_id = i.product_id
AND i.inventory_date BETWEEN '2022-01-01' AND '2022-01-31'
GROUP BY p.product_category

-- Question 4. Which products had a decrease in inventory level from the previous inventory date to the current inventory date?

--Approach 1
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

-- Approach 2
SELECT  p.product_name, inv_1.inventory_date, inv_1.inventory_level - inv_2.inventory_level AS inventory_diff
FROM inventory AS inv_1
JOIN inventory inv_2 ON inv_1.product_id = inv_2.product_id 
         AND inv_1.inventory_date = inv_2.inventory_date + INTERVAL '1 day'
JOIN products p ON inv_1.product_id = p.product_id
WHERE inv_1.inventory_level < inv_2.inventory_level;

-- Approach 3

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

-- Question 5. What is the overall trend in inventory levels for each product category over the month of January 2022?

--Approach 1

SELECT p.product_category,i.inventory_date , round(avg(i.inventory_level),2) AS avg_inventory_level
FROM products AS p
INNER JOIN inventory AS i
ON p.product_id = i.product_id
WHERE EXTRACT(YEAR FROM i.inventory_date)= 2022 AND
EXTRACT(MONTH FROM inventory_date)= 01
GROUP BY p.product_category, i.inventory_date
ORDER BY p.product_category, i.inventory_date

--Approach 2

SELECT p.product_category, i.inventory_date,round(avg(i.inventory_level),2) AS avg_inventory_level
FROM products AS p
INNER JOIN inventory AS i
ON p.product_id = i.product_id
WHERE i.inventory_date >= '2022-01-01' AND inventory_date < '2022-02-01'
GROUP BY p.product_category, i.inventory_date
ORDER BY p.product_category, i.inventory_date

--Approach 3
SELECT p.product_category,i.inventory_date, ROUND(AVG(i.inventory_level), 2) AS avg_inventory_level
FROM products AS p, inventory AS i
WHERE p.product_id = i.product_id
AND i.inventory_date BETWEEN '2022-01-01' AND '2022-01-31'
GROUP BY p.product_category, i.inventory_date
ORDER BY p.product_category, i.inventory_date