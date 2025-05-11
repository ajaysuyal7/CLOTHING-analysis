


--1.what is the total quantity sold for all products?
--ans 1
select sum(total_quantity) as total_quantity_sold from customer_360

--2.what is the total generated revenue for all products before discount
--ans 2
select sum(amount) as total_revenue_before_discount from final_raw_data

--3.what was the total discount amount for all products 
--ans 3
select sum(total_discount_amount) as total_discount_amount from customer_360

--4.how many unique transactions were there
--ans 4
select count(DISTINCT txn_id) as unique_transactions from final_raw_data

--5.what is the average unique products purchased in each transacton
--ans 5
select avg(unique_product) as average_unique_products 
from(
select txn_id,count(distinct prod_id) AS unique_product  -- first calculate the avg unique product foe every txn
from final_raw_data
group by txn_id
) as x


--6.what is the 25th,50th and 75th percentile values for the revenue per transactions
--ans 6



--7.what is the average discount value per transactions
--ans 7
select avg(total_discount_amount) as avg_discount_per_transaction 
from customer_360 



--8.what is the percentage split of all transactions for members vs non_members
--ans 8
select count(*) as total_tran,
(SUM(CASE WHEN member_flag = 1 THEN 1 ELSE 0 END)*100/count(*)) as members_percentage,
(SUM(CASE WHEN member_flag = 0 THEN 1 ELSE 0 END)*100/count(*)) as non_members_percentage
from final_raw_data



--9.what is the average revenue for member transaction and non_member transaction
--ans 9
select 
avg(CASE WHEN member_flag = 1 THEN amount END) as member_avg_spend, 
avg(CASE WHEN member_flag = 0 THEN amount END) as non_member_avg_spend
from final_raw_data 

--10 what is the top3 products by total revenue before discount
--ans 10
select distinct top 3 product_name, sum(amount) as total_revenue from 
final_raw_data 
group by product_name
order by total_revenue desc

--11 what is the total quantity,revenue and discount for each segment
--ans 11
SELECT parent_id_segment AS segment,SUM(qty) AS total_quantity,SUM(amount) AS total_revenue,
    SUM(discount) AS total_discount
FROM Final_Raw_Data
GROUP BY
    parent_id_segment


--12.what is the top selling product for each segment
--ans 12
select product_segment,product_name from (
select parent_id_segment as product_segment ,product_name,
Rank() over(partition by parent_id_segment order by sum(qty) desc) as rank
from final_raw_data
group by parent_id_segment,product_name) as x
where RANK=1



--13.what is the total quantity,revenue and discounts for each category
--ans 13
select  no_of_distinct_category_purshased,sum(total_quantity) as total_quantity ,
SUM(Total_spend) AS total_revenue,SUM(Total_discount_amount) AS total_discount 
from customer_360 
group by no_of_distinct_category_purshased


--14.what is the top selling product for each category
--ans 14
select product_category,product_name from (
select parent_id_category as product_category ,product_name,
Rank() over(partition by parent_id_category order by sum(qty) desc) as rank
from final_raw_data
group by parent_id_category,product_name) as x
where RANK=1



--15.what is percentage split of revenue by product for each segment 
--ans 15
select product_name , parent_id_segment AS segment , 
sum(amount)*100/(select sum(amount) from final_raw_data) as revenue_percent
from final_raw_data 
group by product_name ,parent_id_segment
order by revenue_percent desc


--16.what is the percentage split of revenue by segment for each category
--ans 16
select parent_id_category AS category, product_name ,
sum(amount)*100/(select sum(amount) from final_raw_data) as revenue_percent
from final_raw_data 
group by product_name ,parent_id_category
order by category 




--17.what is the percentage split of total revenue by category
--ans 17
select parent_id_category AS category, 
sum(amount)*100/(select sum(amount) from final_raw_data) as revenue_percent
from final_raw_data 
group by parent_id_category
order by category




--18.what is the total transaction 'pentration' for each product
--ans 18
with x as (
    SELECT product_name , COUNT(txn_id) AS num_transactions
    FROM Final_Raw_Data
    GROUP BY product_name )
select 
product_name , num_transactions * 100  / (select  COUNT( txn_id) from final_raw_data)as penetraction_percentage 
from x



--19.what is the most common combination of at least 1 quantity of any 3 products in a 1 singles transaction
--ans 19



--20.calculate the below metrics by each
--month,revenue,qty,average_transaction_value,no_of_transaction,no_of_customers,discount_amount,no_customers_who _are_members,
--no_of_distinct_products_products_name_with_highest_sales
--ans 20

SELECT
    DATEPART(MONTH, start_txn_time) AS transaction_month,product_name  AS Product_name_with_highest_sales,
	SUM(amount) AS revenue,SUM(qty) AS qty,AVG(amount) AS avg_transaction_value,
	COUNT(DISTINCT txn_id) AS No_of_transactions, COUNT(DISTINCT User_id) AS No_of_Customers,
	SUM(discount) AS Discount_amount,
    count(DISTINCT CASE WHEN member_flag = 1 THEN user_id END) AS No_of_members,
    COUNT(DISTINCT prod_id) AS No_of_distinct_products
    from Final_Raw_Data
GROUP BY product_name ,DATEPART(YEAR, start_txn_time), DATEPART(MONTH, start_txn_time)
ORDER By qty desc,transaction_month 

