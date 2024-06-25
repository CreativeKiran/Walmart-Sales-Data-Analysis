use sales;
select *
from `walmartsalesdata.csv`
where 'Invoice ID' is null;
SET SQL_SAFE_UPDATES=0;
UPDATE `walmartsalesdata.csv`
SET time_of_day = 
    CASE 
        WHEN TIME(Time) >= '00:00:00' AND TIME(Time) <= '11:59:59' THEN 'Morning'
        WHEN TIME(Time) >= '12:00:00' AND TIME(Time) <= '17:59:59' THEN 'Afternoon'
        WHEN TIME(Time) >= '18:00:00' AND TIME(Time) <= '23:59:59' THEN 'Evening'
        ELSE 'Unknown' -- Handle any unexpected times
    END;
ALTER TABLE `walmartsalesdata.csv`
ADD COLUMN day_name VARCHAR(10),
ADD COLUMN month_name VARCHAR(10); 
UPDATE `walmartsalesdata.csv`
SET day_name = DATE_FORMAT(Date, '%a');
UPDATE `walmartsalesdata.csv`
SET month_name = DATE_FORMAT(Date, '%b');
/* 
BusinessQuestions To Answer
GenericQuestion 
*/
-- 1. How many unique cities does the data have?
select count(distinct city) as No_Of_Unique_Cities from `walmartsalesdata.csv`;
-- 2. In which city is each branch?
select  City,Branch from `walmartsalesdata.csv`;
-- Product
-- 1. How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line) FROM `walmartsalesdata.csv`;
-- 2. What is the most common payment method?
SELECT Payment,count(*) as frequency from `walmartsalesdata.csv` GROUP BY Payment order by frequency desc LIMIT 1;
-- 3. What is the most selling product line?
SELECT Product_line,count(*) as frequency FROM `walmartsalesdata.csv` GROUP BY Product_line order by frequency desc
LIMIT 1;
-- 4. What is the total revenue by month?
SELECT month_name,SUM(cogs) FROM `walmartsalesdata.csv` GROUP BY month_name;
-- 5. What month had the largest COGS?
SELECT month_name,max(cogs) AS largest FROM `walmartsalesdata.csv` GROUP BY month_name ORDER BY largest desc limit 1;
-- 6. What product line had the largest revenue?
SELECT product_line,max(cogs) AS largest_revenue FROM `walmartsalesdata.csv` GROUP BY Product_line ORDER BY largest_revenue desc LIMIT 1;
-- 7. What is the city with the largest revenue?
SELECT city,max(cogs) AS largest_revenue FROM `walmartsalesdata.csv` GROUP BY city ORDER BY largest_revenue desc LIMIT 1;
-- 8. What product line had the largest VAT?
SELECT product_line,max(0.05*cogs) as largest_VAT FROM `walmartsalesdata.csv` GROUP BY Product_line ORDER BY largest_VAT desc LIMIT 1;
-- 9. Fetch each product line and add a column to those product line showing "Good","Bad".Good if its greater than average sales
SELECT product_line,
       Quantity,
       CASE
           WHEN Quantity > 5.51 THEN 'Good'
           ELSE 'Bad'
       END AS status
FROM (
    SELECT product_line,
           Quantity,
           (SELECT AVG(Quantity) FROM `walmartsalesdata.csv` WHERE product_line = t.product_line) AS avg_sales
    FROM `walmartsalesdata.csv` t
) AS subquery_alias;  
--  10. Which branch sold more products than average product sold?
SELECT Branch,SUM(Quantity) AS no_of_sold FROM `walmartsalesdata.csv` WHERE Quantity > 5.51 GROUP BY Branch ORDER BY no_of_sold DESC limit 1 ;  
-- 11. What is the most common product line by gender?
SELECT gender,
       product_line,
       COUNT(*) AS total_purchases
FROM `walmartsalesdata.csv`
GROUP BY gender, product_line
HAVING COUNT(*) = (
    SELECT MAX(purchase_count)
    FROM (
        SELECT gender, product_line, COUNT(*) AS purchase_count
        FROM `walmartsalesdata.csv`
        GROUP BY gender, product_line
    ) AS subquery
    WHERE subquery.gender = `walmartsalesdata.csv`.gender
)
ORDER BY gender;
-- 12. What is the average rating of each product line?
SELECT product_line,avg(Rating) AS avg_rating FROM `walmartsalesdata.csv` GROUP BY Product_line order by avg_rating desc;
-- Sales
-- 1. Number of sales made in each time of the day per weekday
SELECT day_name,time_of_day,sum(quantity) as total_sales from `walmartsalesdata.csv` group by day_name,time_of_day order by total_sales desc ;
-- 2. Which of the customer types brings the most revenue?
SELECT Customer_type,sum(cogs) as largest_revenue FROM `walmartsalesdata.csv`GROUP BY Customer_type ORDER BY largest_revenue desc limit 1;
-- 3. Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT City, MAX(Tax_5pct) AS largest_tax_percent FROM `walmartsalesdata.csv`GROUP BY City;
-- 4. Which customer type pays the most in VAT?
SELECT Customer_type, SUM(tax_5pct) AS total_vat_payment FROM `walmartsalesdata.csv` GROUP BY Customer_type ORDER BY total_vat_payment DESC LIMIT 1;
-- Customer
-- 1. How many unique customer types does the data have?
SELECT COUNT(DISTINCT Customer_type) AS unique_customer_types FROM `walmartsalesdata.csv`;
-- 2. How many unique payment methods does the data have?
SELECT COUNT(DISTINCT Payment) AS unique_payment_methods FROM `walmartsalesdata.csv`;
-- 3. What is the most common customer type?
SELECT Customer_type, COUNT(*) AS frequency FROM `walmartsalesdata.csv` GROUP BY Customer_type ORDER BY frequency DESC LIMIT 1;
-- 4. Which customer type buys the most?
SELECT Customer_type, SUM(Quantity) AS total_quantity FROM `walmartsalesdata.csv` GROUP BY Customer_type ORDER BY total_quantity DESC LIMIT 1;
-- 5. What is the gender of most of the customers?
SELECT Gender, COUNT(*) AS frequency FROM `walmartsalesdata.csv`  GROUP BY Gender ORDER BY frequency DESC LIMIT 1;
-- 6. What is the gender distribution per branch?
SELECT Branch, Gender, COUNT(*) AS frequency FROM `walmartsalesdata.csv` GROUP BY Branch ORDER BY Branch, frequency DESC;
-- 7. Which time of the day do customers give most ratings?
SELECT time_of_day, COUNT(*) AS ratings_count FROM `walmartsalesdata.csv` GROUP BY time_of_day ORDER BY ratings_count DESC LIMIT 1;
-- 8. Which time of the day do customers give most ratings per branch?
SELECT Branch,time_of_day,count(rating) as rating FROM `walmartsalesdata.csv` GROUP BY branch ORDER by rating desc;
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
-- 9. Which day of the week has the best avg ratings?
SELECT day_name,avg(rating) AS avg_rating from `walmartsalesdata.csv` GROUP BY day_name ORDER BY avg_rating DESC LIMIT 1;
-- 10. Which day of the week has the best average ratings per branch?
SELECT Branch,day_name,AVG(Rating) AS avg_rating FROM `walmartsalesdata.csv` GROUP BY Branch ORDER BY Branch, avg_rating DESC;
/*
== My Conclusions after looking into the results of the queries ==
==Product Lines and Sales:
           The dataset contains six unique product lines, with "Health and beauty" being the most common product line sold.
==Payment Methods:
           The most common payment method used by customers is Ewallet.
==Revenue and Profit:
           The largest revenue was generated in March, with "Health and beauty" being the product line that contributed the most to revenue.
		   Yangon is the city that generated the largest revenue.
           The product line "Sports and travel" had the largest VAT.
==Customer Analysis:
           The Mandalay branch sold more products than the average branch.
           "Health and beauty" is the most common product line for both genders.
			Members and females are the customer types that bring the most revenue.
            The majority of customers are females, with the highest concentration in the Mandalay branch.
==Rating and Feedback:
		    Customers tend to give the most ratings during the afternoon.
            The Mandalay branch receives the most ratings during the evening.
==Time and Weekday Analysis:
            The best average ratings are received on Sundays.
==These conclusions provide a snapshot of the key insights from the dataset regarding product sales, revenue generation, customer behavior, and feedback patterns.
   Overall, leveraging these insights can help optimize sales strategies,
   improve customer satisfaction, and drive business growth. Tailoring marketing efforts,
   optimizing inventory management, and refining pricing strategies based
   on these data-driven conclusions can lead to more efficient and profitable operations.
*/








