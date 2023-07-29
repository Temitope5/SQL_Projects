
/*

🍜 Case Study: Pizza Runner
 Stack: PostregreSQL


A. Pizza Metrics

1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?

 */
--Solution

-- Data Cleaning and Transformation
--A. Runner_orders Table: To clean the runner_orders table,I created a temporary table otherwise known as a temp_table to acheive this

CREATE TEMP TABLE runner_order_temp AS
   SELECT 
  order_id, 
  runner_id,
  CASE 
    WHEN pickup_time = 'null' THEN NULL
    ELSE pickup_time
  END AS pickup_time,
  CASE 
    WHEN distance = 'null' THEN NULL
    ELSE CAST(TRIM('km' FROM distance) AS NUMERIC)
  END AS distance,
  CASE 
    WHEN duration = 'null' THEN NULL
    ELSE CAST(
      CASE 
        WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
        WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
      	WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
        ELSE duration
      END AS NUMERIC
    )
  END AS duration,
  CASE 
    WHEN cancellation = 'null' THEN NULL
    WHEN cancellation = '' THEN NULL
    ELSE cancellation
  END AS cancellation
FROM pizza_runner.runner_orders;

-- B. Customer_orders Table: I created a temp_table for the customer_orders Table also

CREATE TEMP TABLE customer_order_temp AS
SELECT 
  order_id, 
  customer_id, 
  pizza_id, 
  CASE
	  WHEN exclusions = 'null' THEN NULL
	  WHEN exclusions = '' THEN NULL
	  ELSE exclusions
	  END AS exclusions,
  CASE
	  WHEN extras = 'null'  THEN NULL
	  WHEN extras = '' THEN NULL
	  ELSE extras
	  END AS extras,
	order_time
FROM pizza_runner.customer_orders;

-- 1. 
  SELECT count(pizza_id) AS total_ordered_pizzas
  FROM customer_order_temp;

-- 2.
SELECT count( distinct order_id) AS total_unique_orders
FROM customer_order_temp;

-- 3.  
WITH cleaned_runner_orders AS 
(
SELECT order_id, runner_id, pickup_time, distance, duration,
CASE WHEN cancellation = 'NaN' then NULL
	 WHEN cancellation = ''  then NULL
	 WHEN cancellation = 'null' then NULL
	 ELSE cancellation
	 END as cancellation
FROM pizza_runner.runner_orders
)

SELECT count(*) AS sucessful_orders
from runner_order_temp
WHERE cancellation IS NULL;

-- 4. 
SELECT pizza_id, COUNT (*) AS no_of_pizzas
from(
	SELECT c.pizza_id,o.cancellation
	FROM customer_order_temp AS c
	LEFT JOIN runner_order_temp AS o USING (order_id)
	)AS order_subquery
WHERE cancellation IS NULL
GROUP BY pizza_id;

-- 5. 
SELECT distinct customer_id,
COALESCE(SUM(CASE WHEN pizza_id = 1 THEN 1 END),0) AS "Meat Lovers",	
COALESCE(SUM(CASE WHEN pizza_id = 2 THEN 1 END),0) AS "Vegetarian" 
FROM customer_order_temp
GROUP BY customer_id
ORDER BY 1;

-- 6.
SELECT count(pizza_id)AS order_count
FROM customer_order_temp
RIGHT JOIN runner_order_temp AS r USING (order_id)
WHERE cancellation IS NULL
GROUP BY order_id
ORDER BY 1 desc
LIMIT 1;

-- 7. 
SELECT c.customer_id,
SUM(CASE WHEN exclusions IS NULL OR EXTRAS IS NULL THEN 1 ELSE 0 END)AS  No_changes,
SUM(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END)AS At_least_1_change
FROM customer_order_temp AS c
LEFT JOIN runner_order_temp AS r USING(order_id)
WHERE r.cancellation IS NULL  
GROUP BY c.customer_id;

-- 8.
SELECT
SUM(CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1 ELSE 0 END)AS Pizzas_with_Exclusions_and_Extras
FROM customer_order_temp AS c
LEFT JOIN runner_order_temp AS r USING(order_id)
WHERE r.cancellation IS NULL; 

-- 9.
SELECT DATE_PART('hour', order_time) AS hour_of_day, count(pizza_id)AS pizzas_ordered
FROM customer_order_temp
GROUP by  hour_of_day
ORDER BY pizzas_ordered DESC;

-- 10.
SELECT TO_CHAR(order_time,'Day') AS day_of_week,
EXTRACT(dow FROM order_time)AS day_of_week2,
COUNT(pizza_id)AS pizzas_ordered
FROM customer_order_temp
GROUP by  day_of_week,day_of_week2
ORDER BY pizzas_ordered DESC; 

/* B. Runner and Customer Experience */

/* 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner? */

-- 1.
SELECT 
CONCAT('Week ',to_char(registration_date,'WW'))AS registration_week,
COUNT(runner_id) AS runners_registered
FROM pizza_runner.runners 
GROUP BY 1
ORDER BY 1;


-- 2. 
--Method 1- Using Subquery
SELECT ROUND(AVG(time_taken_seconds/60.0),1) AS avg_pickup_minutes
FROM
(
	SELECT order_id,runner_id,pickup_time,order_time,
	EXTRACT(epoch FROM (pickup_time::timestamp - order_time::timestamp)) AS time_taken_seconds
	FROM runner_order_temp
	LEFT JOIN customer_order_temp
	USING (order_id)
	WHERE cancellation IS NULL
)AS runner_time


--Method 2 Using CTE
WITH time_taken_cte AS
(
  SELECT 
    c.order_id, 
    c.order_time, 
    r.pickup_time, 
 EXTRACT(EPOCH FROM (r.pickup_time::timestamp - c.order_time::timestamp)) / 60 AS pickup_minutes
  FROM customer_order_temp AS c
  JOIN runner_order_temp AS r
    ON c.order_id = r.order_id
  WHERE cancellation IS NULL
)

SELECT 
ROUND(AVG(pickup_minutes)) AS avg_pickup_minutes
FROM time_taken_cte
WHERE pickup_minutes > 1;

-- 3. 
-- -- There exists a positive relationship b/w no of pizzas ordered and the time taken to prepare
WITH pizza_details AS
(

	SELECT order_id, pizza_ordered, runner_id,pickup_time,order_time,
	EXTRACT(epoch FROM (pickup_time::timestamp - order_time::timestamp)) AS time_taken_seconds
	FROM runner_order_temp
		LEFT JOIN
	(
		SELECT order_id, COUNT(*) AS pizza_ordered,
		MIN(order_time) AS order_time
		FROM customer_order_temp
)

SELECT pizza_ordered, ROUND(AVG(time_taken_seconds/60.0),1) AS avg_seconds
FROM pizza_details
GROUP BY 1
ORDER BY 1


-- 4.
-- Let's assume that distance is calculated from Pizza Runner HQ to customer’s place
SELECT 
  c.customer_id, 
  ROUND(AVG(r.distance)) AS avg_distance
FROM customer_order_temp AS c
JOIN runner_order_temp AS r
  ON c.order_id = r.order_id
WHERE r.duration != 0
GROUP BY c.customer_id;


-- 5.
SELECT MAX(duration::FLOAT) - MIN(duration::FLOAT) AS delivery_time_difference
FROM runner_order_temp
WHERE duration IS NOT NULL;
-- 6.

-- Average speed = Distance in km / Duration in hour
SELECT 
  r.runner_id, 
  c.customer_id, 
  c.order_id, 
  COUNT(c.order_id) AS pizza_count, 
  r.distance, ROUND((r.duration / 60),1) AS duration_hr , 
  ROUND((r.distance/r.duration * 60), 1) AS avg_speed
FROM runner_order_temp AS r
JOIN customer_order_temp AS c
  ON r.order_id = c.order_id
WHERE distance IS NOT NULL
GROUP BY r.runner_id, c.customer_id, c.order_id, r.distance, r.duration
ORDER BY c.order_id;

7. 

SELECT runner_id,COUNT(CASE WHEN cancellation IS NULL THEN 1 END)AS successful_order,COUNT(*) AS total_orders,
COUNT(CASE WHEN cancellation IS NULL THEN 1 END)/ COUNT(*)::FLOAT *100 AS successful_delivery_percent
FROM runner_order_temp
GROUP BY 1;

/*
C. Ingredient Optimisation

1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
*/

--1. 
WITH topping_unnest AS (
SELECT pizza_id,
UNNEST(STRING_TO_ARRAY(toppings,', '))::INTEGER AS topping_id
FROM pizza_runner.pizza_recipes
),

toppings AS (
SELECT t.*, topping_name
FROM topping_unnest AS t
LEFT JOIN pizza_runner.pizza_toppings USING (topping_id)
)
SELECT pizza_id,
STRING_AGG (topping_name, ', ') AS ingredients
FROM toppings
GROUP BY pizza_id ORDER BY 1

-- 2. 
WITH orders_extra AS (
  SELECT order_id, UNNEST(STRING_TO_ARRAY(extras, ', ')) AS extras
  FROM customer_order_temp
)

SELECT topping_name As most_common_extra, COUNT(*) AS no_of_times
FROM orders_extra
INNER JOIN pizza_runner.pizza_toppings p
ON orders_extra.extras::INTEGER = p.topping_id
WHERE orders_extra.extras IS NOT NULL
GROUP BY topping_name
ORDER BY no_of_times DESC
LIMIT 1;


-- 3. 
WITH orders_exclusion AS (
  SELECT order_id, UNNEST(STRING_TO_ARRAY(exclusions, ', ')) AS exclusions
  FROM customer_order_temp
)

SELECT topping_name As most_common_exclusion, COUNT(*) AS no_of_times
FROM orders_exclusion
INNER JOIN pizza_runner.pizza_toppings AS p
ON orders_exclusion.exclusions::INTEGER = p.topping_id
WHERE orders_exclusion.exclusions IS NOT NULL
GROUP BY topping_name
ORDER BY no_of_times DESC
LIMIT 1;

-- 4.
WITH orders AS (
  SELECT *, ROW_NUMBER() OVER () AS row_index
  FROM customer_order_temp
),
exclusions AS (
  -- Extract individual exclusions from the 'exclusions' column and unnest them
  SELECT order_id, pizza_id, row_index, topping_name
  FROM 
	(
    	SELECT order_id, pizza_id, row_index,
        UNNEST(STRING_TO_ARRAY(exclusions, ', ')) AS exclusions
        FROM orders
		 WHERE exclusions IS NOT NULL  -- Filter out NULL
    ) AS tmp
  LEFT JOIN pizza_runner.pizza_toppings p
  ON tmp.exclusions::INTEGER = p.topping_id -- Join with pizza_toppings table to get topping names
  
),
extras AS (
  -- Extract individual extras from the 'extras' column and unnest them
  SELECT order_id, pizza_id, row_index, topping_name
  FROM (
    SELECT * FROM (
    	SELECT order_id, pizza_id, row_index,
        UNNEST(STRING_TO_ARRAY(extras, ', ')) AS extras
        FROM orders
    ) AS tmp
    WHERE extras IS NOT NULL -- Filter out NULL 
  ) AS temp_table
  LEFT JOIN pizza_runner.pizza_toppings p
  ON temp_table.extras::INTEGER = p.topping_id -- Join with pizza_toppings table to get topping names
  
),
exclusions_toppings AS (
  -- Aggregate exclusions for each order and concatenate them as a comma-separated list
  SELECT row_index, 
  STRING_AGG(topping_name, ', ') AS exclusions 
  FROM exclusions
  GROUP BY 1
),
extras_toppings AS (
  -- Aggregate extras for each order and concatenate them as a comma-separated list
  SELECT row_index, 
  STRING_AGG(topping_name, ', ') AS extras 
  FROM extras
  GROUP BY 1
)

-- Combine the results from all CTEs to generate the final output
SELECT CONCAT(pizza_name, 
              CASE WHEN t.exclusions IS NULL THEN '' ELSE ' - Exclude ' END, 
              t.exclusions,
             CASE WHEN e.extras IS NULL THEN '' ELSE ' - Extra ' END,
              e.extras
             ) AS pizza_ordered 
FROM orders AS o
LEFT JOIN exclusions_toppings AS t USING (row_index)
LEFT JOIN extras_toppings AS e USING (row_index)
LEFT JOIN pizza_runner.pizza_names AS p USING (pizza_id);
