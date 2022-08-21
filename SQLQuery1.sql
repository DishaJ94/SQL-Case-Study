Select Top 1* from DIM_MANUFACTURER
Select Top 1* from DIM_MODEL
Select Top 1* from DIM_CUSTOMER
Select Top 1* from DIM_LOCATION
Select Top 1* from DIM_DATE
Select Top 1* from FACT_TRANSACTIONS

/* Q1. List all the states in which we have customers who have bought cellphones from 2005 till today. */

Select  DIM_LOCATION.State from DIM_LOCATION where DIM_LOCATION.IDLocation in 
(Select FACT_TRANSACTIONS.IDLocation from FACT_TRANSACTIONS where FACT_TRANSACTIONS.Date in 
(Select DIM_DATE.DATE from DIM_DATE where DIM_DATE.YEAR between 2003 and DATEPART(year,GETDATE())))
group by DIM_LOCATION.State

 --OR
 Select State from FACT_TRANSACTIONS as F
 left join DIM_DATE as D on F.Date = D.DATE
 left join DIM_LOCATION as L on F.IDLocation = L.IDLocation
 where YEAR between 2003 and DATEPART(year,GETDATE()) group by State
 
/* Q2.  What state in the US is buying more 'Samsung' cell phones? */

Select State from FACT_TRANSACTIONS as F 
left join DIM_MODEL as Mo on F.IDModel= Mo.IDModel
left join DIM_LOCATION as L on F.IDLocation = L.IDLocation
where Mo.IDModel in 
(Select IDModel from DIM_MODEL as Mo
inner join DIM_MANUFACTURER as Ma on Mo.IDManufacturer= Ma.IDManufacturer) and Country = 'US'
group by state

/* Q3. Show the number of transactions for each model per zip code per state. */

Select  Model_Name,ZipCode,state,count(ZipCode) as [Number_of_transactions] from FACT_TRANSACTIONS as F 
left join DIM_MODEL as Mo on F.IDModel= Mo.IDModel
right join DIM_LOCATION as L on F.IDLocation = L.IDLocation
where Mo.IDModel in 
(Select IDModel from DIM_MODEL as Mo
inner join DIM_MANUFACTURER as Ma on Mo.IDManufacturer= Ma.IDManufacturer) 
group by ZipCode,state, Model_Name

/*Q4. Show the cheapest cellphone*/
Select Model_Name, IDModel,Unit_price from DIM_MODEL 
where  Unit_price = (Select MIN(Unit_price) from DIM_MODEL)

/*Q5.  Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.*/
Select top 5 Mo.IDModel,Model_Name, count (F.IDModel)as [Quantity _Sold],avg(TotalPrice) as [Avgerage_price]
from FACT_TRANSACTIONS as F
left join DIM_MODEL as Mo on F.IDModel = Mo.IDModel
group by Mo.IDModel,Model_Name order by avg(TotalPrice) desc

/*Q6. List the names of the customers and the average amount spent in 2009 , where the average is higher than 500*/


Select F.IDCustomer, Customer_Name,avg(TotalPrice) as [Avg_Price] from  FACT_TRANSACTIONS as F
left join DIM_CUSTOMER on F.IDCustomer=DIM_CUSTOMER.IDCustomer
left join DIM_DATE as D on F.Date = D.DATE
 where D.YEAR in (2009 )
 group by F.IDCustomer,Customer_Name
 having avg(TotalPrice)>500


/*Q7 List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008,2009 and 2010*/--DOUBT


Select top 5 T10.IDModel,Model_Name,Sum(Quantity) as [Sum Quantity] from (Select *,
Case 
When DATEPART(Year,Date) in (2009) then '2009'
When DATEPART(Year,Date)in (2008)  then '2008'
When DATEPART(Year,Date) in (2010) then '2010'
Else 0
End as [Year_in]
from FACT_TRANSACTIONS
) as T10 
Left join DIM_MODEL on T10.IDModel=DIM_MODEL.IDModel
where [Year_in] <> 0
group by T10.IDModel,Model_Name
order by Sum(Quantity) desc


/*Q8. Show the manufacturer with the 2 nd top sales in the year of 2009 and the manufacturer with the 2 nd top sales in the year of 2010 .*/

Select Manufacturer_Name from DIM_MODEL
inner join  DIM_MANUFACTURER on DIM_MODEL.IDManufacturer= DIM_MANUFACTURER.IDManufacturer
where IDModel in
 (Select IDModel from (Select rank()over (order by sum(TotalPrice)desc) as [Rank_2009],IDMODEL from FACT_TRANSACTIONS as F
left join DIM_DATE as Da on F.Date=Da.DATE
where Da.YEAR= 2009
group by IDModel) as T5 where Rank_2009 = 2)
union
Select Manufacturer_Name from DIM_MODEL
inner join  DIM_MANUFACTURER on DIM_MODEL.IDManufacturer= DIM_MANUFACTURER.IDManufacturer
where IDModel in
 (Select IDModel from (Select rank()over (order by sum(TotalPrice)desc) as [Rank_2010],IDMODEL from FACT_TRANSACTIONS as F
left join DIM_DATE as Da on F.Date=Da.DATE
where Da.YEAR= 2010
group by IDModel) as T6 where Rank_2010= 2)


/*Q9. Show the manufacturers that sold cellphone in 2010 but didn't in 2009 */



Select Manufacturer_Name from DIM_MANUFACTURER
right join DIM_MODEL on DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
where DIM_MODEL.IDModel in
(Select FACT_TRANSACTIONS.IDModel from DIM_MODEL 
right join FACT_TRANSACTIONS on DIM_MODEL.IDModel= FACT_TRANSACTIONS.IDModel
where DATEPART(year,Date) in (2010)
group by FACT_TRANSACTIONS.IDModel) group by Manufacturer_Name 

intersect

Select Manufacturer_Name from DIM_MANUFACTURER
right join DIM_MODEL on DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
where DIM_MODEL.IDModel in
(Select FACT_TRANSACTIONS.IDModel from DIM_MODEL 
right join FACT_TRANSACTIONS on DIM_MODEL.IDModel= FACT_TRANSACTIONS.IDModel
where DATEPART(year,Date) in (2009) 
group by FACT_TRANSACTIONS.IDModel) group by Manufacturer_Name 


/*Q10. Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.*/

Select top 100 IDCustomer,DATEPART(year,Date)[Year_wise],AVG(TotalPrice)[Avg_Spend],count(IDCustomer)[Avg_Quantity] from FACT_TRANSACTIONS
group by DATEPART(year,Date),IDCustomer

