--1. Create database topodesigns
--ans 1

create database Topodesigns


--3. update all table with appropriate data types
--ans 3

select * from product_sales
alter table product_sales 
alter column start_txn_time datetime   ---- to modify datatype

alter table product_sales
add [year] int,[month] int, weekend_flag bit  -- to create column

update Product_Sales 
set year =year(start_txn_time) ,  --extract year
	month =MONTH(start_txn_time),  --extract month
	weekend_flag =case
					 WHEN DATEPART(WEEKDAY,start_txn_time) IN (1, 7)	---update weekend flag
					 THEN 1 
					 ELSE 0 
				 END 


--4.what is the count of records in each table
---ans 4

select COUNT(*) as records_in_product_hierarchy 
from Product_Hierarchy
select COUNT(*) as records_in_product_details
from Product_Details
select COUNT(*) as records_in_product_sales
from Product_Sales
select COUNT(*) as records_of_user
from Users
select COUNT(*) as records_in_product_price 
from Product_Price

--5. Create combined table of all the four tables by joining these tables.the final table 
---	 name should be 'final_raw_data' in the data base also create new column 'amount' with calculation
--	 of qty* price
--ans 5
select 
		s.prod_id,s.qty,s.discount,s.user_id,s.member_flag,s.txn_id,s.start_txn_time,s.year,s.month,s.weekend_flag
		,u.cookie_id,u.Gender,u.Location,p.price,
		d.product_name,d.Parent_id_category,d.Parent_id_segment,d.Parent_id_style,
		h.Level_code,h.level_name,h.level_text,s.qty * p.price as amount into final_raw_data 
		from Product_Sales as s
		join Users as u
		on s.user_id=u.User_id
		join Product_Price as p
		on s.prod_id=p.product_id
		join Product_Details as d
		on p.product_id=d.product_id
		join Product_Hierarchy as h
		on d.Parent_id_category=h.Parent_id
		           or
		d.Parent_id_style = h.Parent_id
	               or
		 d.Parent_id_segment= h.Parent_id



select * from final_raw_data


--6.create summary table with name 'customer_360' with below columns

/* user_id,gender,location,max_transaction_date,no_of_transactions,no_of_transactions_weekends,
no_of_transactions_weekdays,no_of_transactions_after_2PM,no_of_transactions_before_2_PM,total_spend,Total_discount_amount,
Discount_percentage,Total_quantity,no_of_transactions_with_discounts_more_than_20pct,NO_of_distinct_products_purchased,
no_of_distinct_category_purchased,no_oF_distinct_segments_purchased,no_of_distinct_style_purchased*/
--ans 6

select u.user_id,u.gender,u.location,max(S.start_txn_time) as max_transaction_date,count(S.txn_id) as no_of_transaction,
COUNT( Case  when datepart(WEEKDAY,s.start_txn_time) in (1, 7) then 1 end) as no_of_transaction_in_weekends,
COUNT( Case when datepart(WEEKDAY,s.start_txn_time) not in (1, 7) then 1 end) as no_of_transaction_in_weekday,
COUNT( case when DATEPART(HOUR,s.start_txn_time)>=14 then 1 end) as no_of_transaction_after_2pm,
COUNT( case when datepart (hour,s.start_txn_time)<14 then 1 end) as no_of_transaction_before_2pm,
sum(s.qty*p.price) as total_spend,
SUM(p.price*s.qty*discount)/100 as total_discount_amount,
sum(discount)/count(txn_id) as discount_percentage,
sum(qty) as total_quantity,
count(case when discount >20 
			then 1 end) as No_of_transactions_with_discount_more_than_20pct,
count(distinct prod_id) as no_of_distinct_product_purshased,
count(distinct parent_id_category) as no_of_distinct_category_purshased,
count(distinct parent_id_segment) as no_of_distinct_segment_purshased,
count(distinct parent_id_style) as no_of_distinct_style_purchased
into customer_360
from Users as U
Inner Join Product_Sales as S
On U.User_id = S.user_id
Inner Join Product_Details as D
On S.prod_id = D.product_id
Inner Join Product_Price as P
On S.prod_id= P.product_id
Group By U.User_id , U.Gender , U.Location


--7.Create new column as segment in customer_360 table with below defination
--if total spend <500 then segment='low'
--if total spend between 500 and 1000 then segment='medium'
--if total spend>1000 then segment ='high'
--ans 7

alter table customer_360
add segment varchar(10)

update customer_360
set segment = case 
				when Total_spend<500 then 'low'
				when Total_spend>=500 and Total_spend<=1000 then 'medium'
				when Total_spend>1000 then 'high'
			   end

 select * from customer_360
	

select * from final_raw_data_1