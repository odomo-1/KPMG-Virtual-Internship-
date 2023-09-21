create DATABASE KPMG

SELECT * from "Transaction"
SELECT * from customer_address
SELECT * from customer_demography

-- Converting DOB column to Date datatype
alter table customer_demography
add column date_of_birth date  --- Creating the new column
update customer_demography
SET date_of_birth= To_date (dob, 'YYYY-MM-DD')----- Inserting the values into the new column
alter table customer_demography
drop COLUMN dob 

--- Creating Age Categories
select
case 
when age(date_of_birth) < '30 years' THEN 'Young'
when age(date_of_birth) >= '30 years' and age(date_of_birth) < '60 years' THEN 'Middle_aged'
else 'Senior'
end as Age_Group from customer_demography
--- Adding the Age_Category to the column
alter table customer_demography
add column Age_Group TEXT
update customer_demography
SET age_group= (select
case 
when age(date_of_birth) < '30 years' THEN 'Young'
when age(date_of_birth) >= '30 years' and age(date_of_birth) < '60 years' THEN 'Middle_aged'
else 'Senior'
end)

--- The top 10 customer in the past 3years 
SELECT customer_id, first_name,gender,job_title,wealth_segment,owns_car,age_group,past_3_years_bike_related_purchases
from customer_demography
order by past_3_years_bike_related_purchases desc 
limit 10

---- CALCULATING THE PROFIT and Adding it to the Transaction table
select * from "Transaction"

alter table "Transaction"
add column Profit real
update "Transaction"
set profit = (select list_price - standard_cost )

-- JOINING THE TABLES
create table Customer_Transactions as (
select first_name,gender,age_group,wealth_segment,job_title,job_industry_category,owns_car,tenure,brand,order_status,product_line,product_class,product_size,online_order, property_valuation,customer_address.state,past_3_years_bike_related_purchases,profit
from  "Transaction" 
join  customer_demography 
on customer_demography.customer_id = "Transaction".customer_id
join customer_address
on customer_address.customer_id = customer_demography.customer_id
order by profit DESC)
select * from Customer_Transactions

-- PROFIT BY WEALTH SEGMENT
SELECT wealth_segment,round(sum(profit)) as Total_Profit from customer_transactions
group by wealth_segment
order by Total_Profit desc

-- PROFIT BY AGE GROUP
select age_group, round(sum(profit)) as Total_profit from customer_transactions
group by age_group
order by total_profit desc 

-- PROFIT BY BRAND
select brand, round(sum(profit)) as Total_profit from Customer_Transactions
group by brand
order by Total_profit desc

-- PROFIT BY PRODUCT LINE
select product_line, round(sum(profit)) as Total_profit  from Customer_Transactions
GROUP by product_line
order by Total_profit desc

-- PROFIT BY PRODUCT SIZE
select product_size, round(sum(profit)) as Total_profit  from Customer_Transactions
GROUP by product_size
order by Total_profit desc

--- PROFIT BY PRODUCT CLASS
select product_class, round(sum(profit)) as Total_profit  from Customer_Transactions
GROUP by product_class
order by Total_profit desc

-- PROFIT BY STATE
select customer_transactions."state", round(sum(profit)) as Total_profit  from Customer_Transactions
GROUP by customer_transactions."state"
order by Total_profit desc

-- ADDING COLUMN TO THE TABLE BASED ON PREVIUOS TRANSACTION
ALTER TABLE customer_transactions
ADD COLUMN previous_transaction
update customer_transactions
set previous_transaction = (select 
case 
when past_3_years_bike_related_purchases < 48 THEN 'Irregular Customer'
when past_3_years_bike_related_purchases >= 48 THEN 'Regular Customer'
end)

-- ADDING COLUMN TO THE TABLE BASED ON CUSTOMER PROPERTY VALUATION
ALTER TABLE customer_transactions
ADD COLUMN property_valuation_Category TEXT
UPDATE customer_transactions
SET property_valuation_category = (select case
when property_valuation < 4 then 'Low Value'
when property_valuation >= 4 and property_valuation < 7 then 'Medium Value'
else 'High Value'
end)

-- PROFIT BY PROPERTY VALUATION 
select property_valuation_category, round(sum(profit)) as Total_Profit from customer_transactions
group by property_valuation_category
order by Total_Profit desc

-- PROFIT BY PREVIUOS TRANSACTION
select previous_transaction, round(sum(profit))  as Total_Profit from customer_transactions
group by previous_transaction
order by Total_Profit DESC

SELECT * from   customer_transactions
