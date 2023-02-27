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

SELECT p.product_name,i.inventory_level
FROM products AS p
INNER JOIN inventory AS i
ON i.product_id = p.product_id
WHERE i.inventory_date = (SELECT MAX(inventory_date) FROM inventory)

-- Approach 3

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
