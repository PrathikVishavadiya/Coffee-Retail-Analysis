SELECT * FROM city;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM sales;

-- Analysis

-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT city_name, round(((population * 0.25)/1000000),2) AS coffee_consumers_in_millions, city_rank
FROM city
ORDER BY coffee_consumers_in_millions DESC;

-- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT SUM(total) AS total_revenue
FROM sales
WHERE year(sale_date) = 2023 AND quarter(sale_date) = 4;

-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?

SELECT COUNT(total) AS total_units, product_name
FROM sales AS s
LEFT JOIN products AS p ON s.product_id = p.product_id
GROUP BY product_name
ORDER BY total_units DESC;

-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?

SELECT city_name, SUM(total) AS total_revenue, COUNT(DISTINCT s.customer_id) AS unique_cus, ROUNd(sum(total)/COUNT(DISTINCT s.customer_id),2) AS avg_sales_cust
FROM sales AS s
LEFT JOIN customers cu ON s.customer_id = cu.customer_id
LEFT JOIN city c ON cu.city_id = c.city_id
GROUP BY city_name
ORDER BY avg_sales_cust DESC;

-- Q5
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT *
FROM
(	SELECT 
		c.city_name, 
		p.product_name, 
		count(sale_id) AS orders, 
		dense_rank()over(partition by(c.city_name) order by(count(sale_id)) DESC) as sale_rank
	FROM city c
	LEFT JOIN customers cu ON c.city_id = cu.city_id
	LEFT JOIN sales s ON cu.customer_id = s.customer_id
	LEFT JOIN products p ON s.product_id = p.product_id
	GROUP BY 1,2
) as product_sales
WHERE sale_rank <= 3;

-- Q.6
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee?

SELECT 
	c.city_name,
    COUNT(DISTINCT cu.customer_id) as uniq_cust
FROM city c
LEFT JOIN customers cu ON c.city_id = cu.city_id
LEFT JOIN sales s ON cu.customer_id = s.customer_id
LEFT JOIN products p ON s.product_id = p.product_id
WHERE s.product_id BETWEEN 1 AND 14
GROUP BY 1;

-- -- Q.7
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

WITH sale_tb
As
(
	SELECT 
		c.city_name,
		count(distinct s.customer_id) as total_cust,
		sum(s.total) as revenue,
		ROUND(sum(s.total) / count(distinct s.customer_id),2) as avg_cust_sale 
	FROM city c
	LEFT JOIN customers cu ON c.city_id = cu.city_id
	LEFT JOIN sales s ON cu.customer_id = s.customer_id
	LEFT JOIN products p ON s.product_id = p.product_id
	GROUP BY 1
	ORDER BY 3 DESC
),
city_rent
AS 
(
	SELECT 
		city_name,
		estimated_rent
	FROM city
)
SELECT 
	s.city_name,
	s.total_cust,
    s.avg_cust_sale,
    cr.estimated_rent,
    ROUND(cr.estimated_rent/s.total_cust,2) as avg_cust_rent
FROM sale_tb s
LEFT JOIN city_rent cr on s.city_name = cr.city_name
ORDER BY 3 DESC

-- Q.8
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city

-- Q.9
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer




