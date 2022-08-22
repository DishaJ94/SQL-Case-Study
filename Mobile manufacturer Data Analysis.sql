Create database Test_Run

SELECT TOP 1 * FROM CUSTOMER
SELECT TOP 1 * FROM Product_Info
SELECT TOP 1 * FROM Transactions


Select count (customer_ID), customer_Id from Customer group by customer_Id



/*Q1 What is the total number of rows in each of the 3 tables in the database?*/ 

Select count(*) as Cust from Customer union
Select count(*) from Product_info union
Select count(*)  from Transactions 
--OR

SELECT 'CUSTOMER' as [Table(s)], COUNT(*) as [Count of rows] FROM CUSTOMER
UNION
SELECT 'Product_Info' , COUNT(*) FROM Product_Info
UNION
SELECT 'Transactions' , COUNT(*) FROM Transactions
/*Q2* What is the total number of transactions that have a return? */
Select Count(*) as [Total return transactions] from (Select count(Qty) as [Return]
from Transactions where Qty < 0 group by transaction_id) as T4
/*Q3 As you would have noticed, the dates provided across the datasets are not in a 
correct format. As first steps, pls convert the date variables into valid date formats 
before proceeding ahead. */
SELECT tran_date FROM Transactions
Select DOB from Customer
select Getdate()

UPDATE Customer
SET
DOB = REPLACE(DOB, '/', '-');

Select CONVERT (date,GETDATE(),105)
Select convert (date, DOB,105) from customer
Select DATEDIFF(year,(Select convert (date, DOB,105) from customer),getdate()) from Customer
/*Q4 What is the time range of the transaction data available for analysis? Show the 
output in number of days, months and years simultaneously in different columns. */
Select DATEDIFF(year,min(tran_date),max(tran_date)) as [Year],DATEDIFF(Month,min(tran_date),max(tran_date)) as [Month],
DATEDIFF(Day,min(tran_date),max(tran_date)) as [Days], 
min(tran_date) as[Min_Date], max(tran_date) as[Max_Date] from Transactions

/*Q5 Which product category does the sub-category “DIY” belong to? */
SELECT DISTINCT prod_cat from Product_Info 
SELECT DISTINCT prod_subcat from Product_Info
--------------------------------------------------------------------------------------------------------------------------------------------------
/*Q1 Which channel is most frequently used for transactions?*/
Select distinct Store_type from Transactions

Select Store_type, count(*)as [Frequently used channel] from (Select Store_type,
Case when Store_type = 'Flagship store' then 1 end as [Flagship store],
Case when Store_type = 'MBR' then 1 end as [MBR],
Case when Store_type = 'e-Shop' then 1 end as [e-Shop],
Case when Store_type = 'TeleShop' then 1 end as [TeleShop]
from Transactions)as T5 group by Store_type order by [Frequently used channel] desc
/*Q2 What is the count of Male and Female customers in the database? */
Select Gender,Count(*)from 
(Select Gender, Case when Gender in ('M') then 'M'end as Male , Case when Gender in ('F') then 'F'end as Female from Customer  ) as T1
group by Gender
--OR 
Select count(Gender) as [Count of Gender], Gender  from CUSTOMER   Group by Gender
/*Q3 From which city do we have the maximum number of customers and how many?*/
Select top 1 * from (Select city_code,count (city_code) as [Count] from Customer group by city_code) as T3 order by [Count] desc
/*Q4.How many sub-categories are there under the Books category? */
SELECT prod_cat, count(prod_subcat) as Sub_Category  FROM Product_Info where prod_cat = 'Books' group by prod_cat
/*Q5 What is the maximum quantity of products ever ordered?*/
ALTER TABLE Transactions
    ALTER COLUMN Qty float;
GO
Select prod_cat_code, max(Qty) as Maximum from Transactions where transaction_id is not null group by prod_cat_code
/*Q6 What is the net total revenue generated in categories Electronics and Books? */
SELECT DISTINCT prod_cat,prod_cat_code from Product_Info order by prod_cat
ALTER TABLE Transactions
    ALTER COLUMN total_amt Decimal(10,3)
GO

Select sum(total_amt) as [Net Total Revenue]  from Transactions as T 
join Product_Info as P on T.prod_cat_code = P.prod_cat_code
where P.prod_cat = 'Books' or P.prod_cat = 'Electronics' 

--OR

Select sum(total_amt) as [Net Total Revenue]  from Transactions as T 
Where T.prod_cat_code  IN (Select prod_cat_code from Product_Info where prod_cat= 'Electronics' or prod_cat = 'Books');

/*Q7 How many customers have >10 transactions with us, excluding returns? */

Select cust_id,count(transaction_id) as [Count of transaction ID] from Transactions 
where sign(Qty)>=0 
group by cust_id 
having count(transaction_id)>10

/*Q8 What is the combined revenue earned from the “Electronics” & “Clothing” 
categories, from “Flagship stores”? */

Select 
Sum(total_amt) as tot
from Transactions as T 
inner join Product_Info as P on T.prod_cat_code = P.prod_cat_code
where (P.prod_cat = 'Clothing' or P.prod_cat = 'Electronics') and Store_type = 'Flagship store'

/*Q9 What is the total revenue generated from “Male” customers in “Electronics” 
category? Output should display total revenue by prod sub-cat. */
Select P.prod_subcat,sum(total_amt) as [Tot Male Rev] from Transactions as T
inner join Product_Info as P ON T.prod_cat_code = P.prod_cat_code 
inner join Customer as C on T.cust_id = C.customer_Id
where Gender= 'M' and P.prod_cat = 'Electronics'
group by P.prod_subcat
--OR
Select sum(total_amt) from Transactions 
where cust_id in (Select customer_id from Customer where Gender='M' ) and 
prod_cat_code in (Select prod_cat_code from Product_Info where prod_cat = 'Electronics')
/*Q10 What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?*/

Select top 5 prod_subcat_code,SumPositiveValue_Amt/sum(SumPositiveValue_Amt)as [%_of_Total_Sales],abs(SumNegativeValues)/SumPositiveValue as [%_of_Returned_Qty]from (select prod_subcat_code,
       SUM(case when Qty>0 then Qty else 0 end)SumPositiveValue,
       SUM(case when Qty<0 then Qty else 0 end)SumNegativeValues,
	   SUM(case when total_amt>0 then total_amt else 0 end)SumPositiveValue_Amt,
       SUM(case when total_amt<0 then total_amt else 0 end)SumNegativeValues_Amt
	   from Transactions
	   left join Product_Info on Transactions.prod_cat_code= Product_info.prod_cat_code
 group by prod_subcat_code  ) as T11 group by prod_subcat_code order by [%_of_Total_Sales] desc

/*Q11 For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in
 last 30 days of transactions from max transaction date available in the data?*/



SELECT cust_id,SUM(total_amt) [Total Net Revenue] 
FROM Transactions right join Customer on Transactions.cust_id=Customer.customer_Id
where DATEDIFF(YEAR, DOB ,GETDATE()) BETWEEN 25 AND 30 AND DATEDIFF(DAY,tran_date,max(tran_date))<= 30


/*Q12  Which product category has seen the max value of returns in the last 3 months of transactions?*/
Select P.prod_cat,min(Qty),tran_date from Transactions as T
Left join Product_Info as P on T.prod_cat_code= P.prod_cat_code
where tran_date >= (Select format (DATEADD(month,-3,max(tran_date)),'dd-mm-yyyy') from Transactions)
group by P.prod_cat,tran_date

/*Q13- Which store-type sells the maximum products; by value of sales amount and by quantity sold?*/
Select Store_type,max(Qty)as [Quantity],sum(total_amt) as [Total amount] from transactions group by Store_type 
order by [Total amount], [Quantity] desc

/*Q14-What are the categories for which average revenue is above the overall average.*/
Select avg(total_amt) from Transactions

Select * from(Select T.prod_cat_code,avg(total_amt) as [Avg Categorically]  from Transactions as T
inner join Product_Info as P on T.prod_cat_code = P.prod_cat_code
group by T.prod_cat_code) as T9 where [Avg Categorically] > 2107.308001 order by [Avg Categorically]
--OR
Select T.prod_cat_code as [code],avg(total_amt) as [Avg_Categorically] 
from Transactions as T
inner join Product_Info as P on T.prod_cat_code = P.prod_cat_code
group by T.prod_cat_code
having  avg(total_amt) > (Select avg(total_amt) from Transactions)


/*Q15-Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms
of quantity sold.*/


	Select  prod_cat,prod_subcat,prod_subcat_code ,sum(total_amt) as sum, avg(total_amt) as average from Transactions T 
	inner join Product_info as P_I on T.prod_cat_code=P_I.prod_cat_code 
	where T.prod_cat_code IN  
	(
	select DISTINCT prod_sub_cat_code from Product_info where prod_cat in 
	 
	(Select P1.category from 
	(Select top 5* from 
	(
		Select prod_cat as category, sum(Qty) as [Quanity sold]
		from Transactions as T 
		inner join Product_info as P on 
		T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code=P.prod_sub_cat_code
		group by prod_cat
	) 
	as T10 order by [Quanity sold] desc) as P1
	) )
	
    group by prod_subcat_code,prod_subcat,prod_cat
	order by prod_subcat_code
	




	