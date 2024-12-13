-- Create database
CREATE DATABASE IF NOT EXISTS salesDatawalmart;

USE salesDatawalmart;

-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

SELECT *
FROM sales;


-- ------------------------------------------ FEATURE ENGINEERING -----------------------------------------
-- Add the time_of_day column
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;


ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);


-- Add day_name column
SELECT
	date,
	DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);


-- Add month_name column
SELECT
	date,
	MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);


-- ------------------------------------------- Generic Question --------------------------------------------
-- 1. How many unique cities does the data have?
SELECT DISTINCT city
FROM sales;


-- 2. In which city is each branch?
SELECT DISTINCT city, branch
FROM sales;

-- ------------------------------------------------ Product -------------------------------------------------
-- 1. How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line)
FROM sales;


-- 2. What is the most common payment method?
SELECT payment_method, COUNT(payment_method) AS CNT
FROM sales
GROUP BY payment_method
ORDER BY CNT DESC
LIMIT 1;

-- 3. What is the most selling product line?
SELECT product_line, COUNT(product_line) AS sale_count
FROM sales
GROUP BY product_line
ORDER BY sale_count DESC
LIMIT 1;

-- 4. What is the total revenue by month?
SELECT month_name, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;


-- 5. What month had the largest COGS?
SELECT month_name, SUM(cogs) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC;

-- 6. What product line had the largest revenue?
 SELECT product_line, SUM(total) AS largest_revenue
 FROM sales
 GROUP BY product_line
 ORDER BY largest_revenue DESC
 LIMIT 1;

-- 7. What is the city with the largest revenue?
SELECT city, SUM(total) AS largest_revenue
FROM sales
GROUP BY city
ORDER BY largest_revenue DESC
LIMIT 1;

-- 8. What product line had the largest VAT?
SELECT product_line, AVG(VAT) as avg_VAT
FROM sales
GROUP BY product_line
ORDER BY avg_VAT DESC;

-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". 
-- Good if its greater than average sales
SELECT product_line,
(
	CASE 
		WHEN AVG(total) > (SELECT AVG(total) FROM sales) THEN 'good'
		ELSE 'bad'
    END
) AS Remark
FROM sales
GROUP BY product_line;

ALTER TABLE sales ADD COLUMN remark VARCHAR(10);

UPDATE sales
SET remark = 
(
	CASE 
		WHEN total > (SELECT AVG(total) FROM (SELECT AVG(total) AS total FROM sales) AS subquery) THEN 'good'
		ELSE 'bad'
    END
);

-- 10. Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > AVG(quantity);

-- 11. What is the most common product line by gender?
SELECT gender, product_line, COUNT(product_line) AS total_product
FROM sales
GROUP BY gender, product_line
ORDER BY total_product DESC;
  

-- 12. What is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;


-- ----------------------------------------- Sales -----------------------------------------------

-- 1. Number of sales made in each time of the day per weekday
SELECT time_of_day, COUNT(total) AS sale_count
FROM sales
WHERE day_name != 'Saturday' AND day_name != 'Sunday'
GROUP BY time_of_day
ORDER BY sale_count DESC;

-- 2. Which of the customer types brings the most revenue?
SELECT customer_type, ROUND(SUM(total),2) AS revenue_count
FROM sales
GROUP BY customer_type
ORDER BY revenue_count DESC;

-- 3. Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, SUM(VAT) AS total_VAT
FROM sales
GROUP BY city
ORDER BY total_VAT DESC; 

-- 4. Which customer type pays the most in VAT?
SELECT customer_type, COUNT(VAT) as most_VAT
FROM sales
GROUP BY customer_type
ORDER BY most_VAT DESC;

-- ----------------------------------------------- Customer -----------------------------------------------

-- 1. How many unique customer types does the data have?
SELECT DISTINCT customer_type
FROM sales;

-- 2. How many unique payment methods does the data have?
SELECT COUNT(DISTINCT payment_method) AS payment_method_count
FROM sales;

-- 3. What is the most common customer type?
SELECT customer_type, COUNT(customer_type)
FROM sales
GROUP BY customer_type;

-- 4. Which customer type buys the most?
SELECT customer_type, COUNT(quantity) AS total_qty
FROM sales
GROUP BY customer_type
ORDER BY total_qty DESC;

-- 5. What is the gender of most of the customers?
SELECT gender, COUNT(gender) AS gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;

-- 6. What is the gender distribution per branch?
SELECT branch, gender, COUNT(gender) AS gender_dist
FROM sales
GROUP BY branch, gender
ORDER BY gender_dist DESC;

-- 7. Which time of the day do customers give most ratings?
SELECT AVG(rating) avg_rating, time_of_day
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- 8. Which time of the day do customers give most ratings per branch?
SELECT time_of_day, branch, AVG(rating) avg_rating 
FROM sales
GROUP BY time_of_day, branch 
ORDER BY avg_rating DESC;

-- 9. Which day of the week has the best avg ratings?
SELECT day_name, AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- 10. Which day of the week has the best average ratings per branch?
SELECT day_name, AVG(rating) AS avg_rating
FROM sales
WHERE branch = 'A'
GROUP BY day_name, branch
ORDER BY avg_rating DESC;
