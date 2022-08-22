
SELECT TOP 1 * FROM CUSTOMER
SELECT TOP 1 * FROM Product_Info
SELECT TOP 1 * FROM Transactions

Select * from customer where customer_Id='268408'
Select count (customer_ID), customer_Id from Customer group by customer_Id
Select count (transaction_id), transaction_id from Transactions group by transaction_id
/*Q1*/


Select count(*) as Cust from Customer union
Select count(*) from Product_info union
Select count(*)  from Transactions 

--OR

SELECT 'CUSTOMER' as [Table(s)], COUNT(*) as [Count of rows] FROM CUSTOMER
UNION
SELECT 'Product_Info' , COUNT(*) FROM Product_Info
UNION
SELECT 'Transactions' , COUNT(*) FROM Transactions

/*Q2*/
Select Count(*) as [Total return transactions] from (Select count(Qty) as [Return]
from Transactions where Qty < 0 group by transaction_id) as T4
/*Q3*/


/*Q4*/
/*Q5*/
SELECT DISTINCT prod_cat from Product_Info 
SELECT DISTINCT prod_subcat from Product_Info

-------------------------------------------------------------------
/*Q1*/
Select distinct Store_type from Transactions
Select Store_type, count(*)as [Frequently used channel] from (Select Store_type,
Case when Store_type = 'Flagship store' then 1 end as [Flagship store],
Case when Store_type = 'MBR' then 1 end as [MBR],
Case when Store_type = 'e-Shop' then 1 end as [e-Shop],
Case when Store_type = 'TeleShop' then 1 end as [TeleShop]
from Transactions)as T5 group by Store_type order by [Frequently used channel] desc
/*Q2*/
Select Gender,Count(*)from 
(Select Gender, Case when Gender in ('M') then 'M'end as Male , Case when Gender in ('F') then 'F'end as Female from Customer  ) as T1
group by Gender
--OR 
Select count(Gender) as [Count of Gender], Gender  from CUSTOMER   Group by Gender
/*Q3*/
Select top 1 * from (Select city_code,count (city_code) as [Count] from Customer group by city_code) as T3 order by [Count] desc
/*Q4*/
SELECT prod_cat, count(prod_subcat) as Sub_Category  FROM Product_Info where prod_cat = 'Books' group by prod_cat
/*Q5*/
ALTER TABLE Transactions
    ALTER COLUMN Qty float;
GO

Select prod_cat_code, max(Qty) as Maximum from Transactions where transaction_id is not null group by prod_cat_code
/*Q6*/
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


/*Q7*/

Select cust_id,count(transaction_id) as [Count of transaction ID] from Transactions 
where sign(Qty)>=0 
group by cust_id 
having count(transaction_id)>10

/*Q8*/

Select 
Sum(total_amt) as tot
from Transactions as T 
inner join Product_Info as P on T.prod_cat_code = P.prod_cat_code
where (P.prod_cat = 'Clothing' or P.prod_cat = 'Electronics') and Store_type = 'Flagship store'


/*Q9*/
Select P.prod_subcat,sum(total_amt) as [Tot Male Rev] from Transactions as T
inner join Product_Info as P ON T.prod_cat_code = P.prod_cat_code 
inner join Customer as C on T.cust_id = C.customer_Id
where Gender= 'M' and P.prod_cat = 'Electronics'
group by P.prod_subcat
--OR
Select sum(total_amt) from Transactions 
where cust_id in (Select customer_id from Customer where Gender='M' ) and 
prod_cat_code in (Select prod_cat_code from Product_Info where prod_cat = 'Electronics')

/*Q10*/


--SELECT total_amt, total_amt * 100.0/ (SELECT SUM(total_amt) FROM transactions) 'Percentage(%)'
--FROM transactions 
--Select sum(Blah) from ( Select sum(Qty) as [Blah],prod_subcat_code from Transactions group by prod_subcat_code) as T9
--Select sum(total_amt) as [Total amount],prod_subcat_code, Qty  from transactions  group by prod_subcat_code,Qty  having sign(Qty)<0

Select top 5* from (Select prod_subcat_code, abs(total_amt * 100.0/ (SELECT SUM(total_amt)
FROM transactions)) as [Percentage]
from transactions  
group by prod_subcat_code,Qty,total_amt
having sign(Qty)<0 
) as T7 order by [Percentage] desc


Select sum(total_amt)*100/(Select sum(total_amt) 
from Transactions) as [Percentage of Sales],sum(Qty)*100/(Select sum(Qty) 
from Transactions) as [Percentage of Qty],prod_subcat_code 
from Transactions group by prod_subcat_code order by [Percentage of Sales]  desc --Final

Select prod_subcat, sum(total_amt)*100/(Select sum(total_amt) 
from Transactions) as [Percentage of Sales],sum(Qty)*100/(Select sum(Qty) 
from Transactions) as [Percentage of Qty]
from Transactions
inner join Product_Info on Transactions.prod_subcat_code = Product_Info.prod_sub_cat_code
group by product_info.prod_subcat  order by [Percentage of Sales]  desc--second final

Select sum(Qty)*100/(Select sum(Qty) 
from Transactions) as [Percentage as Qty],prod_subcat_code 
from Transactions  group by prod_subcat_code




/*10. What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?

11. For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of transactions from max transaction date available in the data?*/
--Percentage od sales,type,percentage of returns,union, order by product sub cat code, type
/*11*/
/*12*/
/*13*/
Select Store_type,max(Qty),sum(total_amt) as [Total amount] from transactions group by Store_type
/*14*/

Select convert(date,DOB,103) from Customer
where customer_Id='268408'
