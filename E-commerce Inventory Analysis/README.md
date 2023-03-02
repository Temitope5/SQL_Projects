# E-commerce Inventory Analysis

The eCommerce store of a major online retailer is facing a critical challenge of inaccurate inventory tracking resulting in dissatisfied customers and lost sales, potentially leading to the survival of the company being at risk. As a data analyst, your responsibility is to utilize SQL to monitor and assess the inventory levels of the eCommerce store, in order to address the issue and prevent any further damage.
In this analysis, I will be answering 5 major questions using 3 different approaches for each of the question :

- What are the top 5 products with the highest inventory levels on the most recent inventory date?
- What is the total inventory level for each product category on the most recent inventory date?
- What is the average inventory level for each product category for the month of January 2022?
- Which products had a decrease in inventory level from the previous inventory date to the current inventory date?
- What is the overall trend in inventory levels for each product category over the month of January 2022?

Table 1: products
This table contains information about the products sold by the eCommerce store. The fields in this table include:

product_id: unique identifier for each product
product_name: name of the product
product_category: category of the product
product_price: price of the product

Table 2: inventory
This table contains information about the inventory levels of the products sold by the eCommerce store. The fields in this table include:

product_id: unique identifier for each product
inventory_date: date of the inventory count
inventory_level: number of units in inventory on the inventory date
