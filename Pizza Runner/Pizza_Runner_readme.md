# SQL_Projects

# 🍜 Case Study #1: Pizza Runner

## Solution

View the complete syntax [here](https://github.com/Temitope5/SQL_Projects/blob/main/Dany's%20Dinner/Dany's%20Dinner.sql)

***
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

Solution

1. SELECT count(pizza_id) AS total_ordered_pizzas
FROM pizza_runner.customer_orders;
2.SELECT count( distinct order_id) AS total_unique_orders
FROM pizza_runner.customer_orders;

3.  WITH cleaned_runner_orders AS 
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
from cleaned_runner_orders
WHERE cancellation IS NULL

4.  WITH cleaned_runner_orders AS 
(
SELECT order_id, runner_id, pickup_time, distance, duration,
CASE WHEN cancellation = 'NaN' then NULL
	 WHEN cancellation = ''  then NULL
	 WHEN cancellation = 'null' then NULL
	 ELSE cancellation
	 END as cancellation
FROM pizza_runner.runner_orders
)

SELECT pizza_id, COUNT (*) AS no_of_pizzas
from(
	SELECT c.pizza_id,o.cancellation
	FROM pizza_runner.customer_orders AS c
	LEFT JOIN cleaned_runner_orders AS o USING (order_id)
	)AS order_subquery
WHERE cancellation IS NULL
GROUP BY pizza_id

5. 
	