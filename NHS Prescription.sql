---Task 2 advanced database
---------------------------------------------------------------------------------------------
---Solving question number 1
---------------------------------------------------------------------------------------------
Create database PrescriptionsDB;
-----------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
--create tables after importing 4 csv files
--------------------------------------------------------------------------------------

--Create tables MEDICAL_PRACTICE 

Use PrescriptionsDB;
GO
create Table Medical_Practice (
PRACTICE_CODE nvarchar(50) not null PRIMARY KEY, --practice code will be unique and identifier
PRACTICE_NAME nvarchar(100) not null,
ADDRESS_1 nvarchar(100)  null,
ADDRESS_2 nvarchar(100)  null,
ADDRESS_3 nvarchar(100) null,
ADDRESS_4 nvarchar(100) null,
POSTCODE nvarchar(20)  null);

--CREATE TABLE DRUGS

Use PrescriptionsDB;
go
Create table Drugs(
BNF_CODE  NVARCHAR(50) NOT NULL PRIMARY KEY, --They are used as identifier wo will be primary key
CHEMICAL_SUBSTANCE_BNF_DESCR  NVARCHAR(225) NULL,
BNF_DESCRIPTION  NVARCHAR(500) NULL,
BNF_CHAPTER_PLUS_CODE  NVARCHAR(225) NULL);

--CREATE TABLE PRESCTIPTIONS

Use PrescriptionsDB;
GO
create table Prescriptions(
PRESCRIPTION_CODE int not null primary key,
PRACTICE_CODE nvarchar(50) not null FOREIGN KEY REFERENCES Medical_Practice(Practice_Code),   --this will be refer to medical practice so would be foreign key
BNF_CODE nvarchar(50) not null FOREIGN KEY REFERENCES Drugs(BNF_CODE) ,
QUANTITY DECIMAL(18,2) not null,
ITEMS int not null,
ACTUAL_COST DECIMAL(18,5) NOT NULL);

--CREATE TABKE PRESCRIPTION_SUMMARY

Use PrescriptionsDB;
GO
CREATE TABLE Prescriptions_Summary
(
PRACTICE_CODE nvarchar(50) not null foreign key references Medical_Practice(PRACTICE_CODE),  ---this will be refer to medical practice so would be foreign key
TOTAL_ITEMS int not null,
TOTAL_QUANTITY decimal(18,2) not null,
TOTAL_COST decimal(18,2) not null,
REPORT_MONTH nvarchar(20) not null);

--POPULATE THE TABLES WITH CSV FILES                  --I imported 4 csv files so i used them to populate tables.  we use select to read data from those tables and insert into our table
 ---populate table medical_practice
Use PrescriptionsDB;
GO
INSERT INTO Medical_Practice (PRACTICE_CODE,PRACTICE_NAME,ADDRESS_1,ADDRESS_2,ADDRESS_3,ADDRESS_4,POSTCODE)
SELECT PRACTICE_CODE,PRACTICE_NAME,ADDRESS_1,ADDRESS_2,ADDRESS_3,ADDRESS_4,POSTCODE
FROM TASK2_Prescriptions.dbo.Medical_Practice;

--populate table drugs
Use PrescriptionsDB;
GO
insert into Drugs (BNF_CODE,CHEMICAL_SUBSTANCE_BNF_DESCR,BNF_DESCRIPTION,BNF_CHAPTER_PLUS_CODE)
select BNF_CODE,CHEMICAL_SUBSTANCE_BNF_DESCR,BNF_DESCRIPTION,BNF_CHAPTER_PLUS_CODE
from Task2_prescriptions.dbo.Drugs;


--populate table prescriptions
Use PrescriptionsDB;
GO
insert into Prescriptions(PRESCRIPTION_CODE,PRACTICE_CODE,BNF_CODE,QUANTITY,ITEMS,ACTUAL_COST)
select PRESCRIPTION_CODE,PRACTICE_CODE,BNF_CODE,QUANTITY,ITEMS,ACTUAL_COST
from Task2_prescriptions.dbo.Prescriptions;

--populate table prescriptions summary
Use PrescriptionsDB;
GO
insert into Prescriptions_Summary ( PRACTICE_CODE,TOTAL_ITEMS,TOTAL_QUANTITY,TOTAL_COST,REPORT_MONTH)
select PRACTICE_CODE,TOTAL_ITEMS,TOTAL_QUANTITY,TOTAL_COST,REPORT_MONTH
from Task2_prescriptions.dbo.[Prescription Summary];

---------------------------------------------------------------------
---see whether they are populated well or not
Use PrescriptionsDB;
GO
select *
from Medical_Practice

Use PrescriptionsDB;
GO
select *
from Drugs

Use PrescriptionsDB;
GO
select *
from Prescriptions

Use PrescriptionsDB;
GO
select *
from Prescriptions_Summary   
                             


--THEN i DECIDED TO  insert a unique column in prescription summary to make primary key
use PrescriptionsDB
go
ALTER TABLE Prescriptions_Summary
ADD SummaryID int IDENTITY(0,1) NOT NULL;
GO
                                          --because we have same column number in prescription and prescription summary, so we can add summary id which starts from 0 to mach with prescription rows.
use PrescriptionsDB                                                 --this would help me for question number 4 which need primary key
go
ALTER TABLE Prescriptions_Summary
ADD CONSTRAINT PK_Prescriptions_Summary
PRIMARY KEY (SummaryID);
GO

------------------------------------------------------------------------------------------------------------------
--- Question number 2
--Write a query that returns details of all drugs which are in the form of tablets or capsules. You 
--can assume that all drugs in this form will have one of these words in the BNF_DESCRIPTION 
--column. 
--------------------------------------------------------------------------------------------------------------------
 select *
 from Drugs

 use PrescriptionsDB
 go
 select BNF_CODE,CHEMICAL_SUBSTANCE_BNF_DESCR, lower(BNF_DESCRIPTION) as description_lower, BNF_CHAPTER_PLUS_CODE
 FROM Drugs       --for solving this question we only need drugs table, so i don't join them
 where lower(BNF_DESCRIPTION) LIKE ('%capsule%')   --I wrote a query which can dedicate all capsules and tablets even if they have s or not.
 or lower(BNF_DESCRIPTION) like ('%capsules%')   --before searching making them lower case to be in the same format to search
 or lower(BNF_DESCRIPTION) like ('%tablet%') 
 or lower(BNF_DESCRIPTION) like ('%tablets%');


 ------------------------------------------------------------------------------------------------------------------------------------
 --Question number 3. Write a query that returns the total quantity for each of prescriptions 
 -- this is given by the number of items multiplied by the quantity. Some of the quantities are not integer values and 
--your client has asked you to round the result to the nearest integer value. 
-------------------------------------------------------------------------------------------------------------------------------------
select *
from Prescriptions


use PrescriptionsDB
 go
select PRESCRIPTION_CODE,Quantity,Items, round((Items*Quantity),0) as TotalQuantity   --I used round and set the decimal to 0 to make sure the data is round to nearest value
FROM Prescriptions

--------------------------------------------------------------------------------------------------------------------------------------
--question number 4. Write a query that returns a list of the distinct most prescribed chemical substance per month 
--(chemical which appear in the Drugs table listed in the CHEMICAL_SUBSTANCE_BNF_DESCR column)  
--------------------------------------------------------------------------------------------------------------------------------------
USE PrescriptionsDB;
GO

-- Step 1: Create a view   
--first of all I created a view which is count the number of prescription prescribed 
--per mounth and also show chemical_substance_bnf_descr

CREATE VIEW MonthlyChemicalSubstance
AS
select
    ps.REPORT_MONTH,
    d.CHEMICAL_SUBSTANCE_BNF_DESCR,
    COUNT(p.PRESCRIPTION_CODE) AS TotalPrescriptions
from Prescriptions AS p
INNER JOIN Drugs AS d
    ON p.BNF_CODE = d.BNF_CODE inner join Prescriptions_Summary AS ps
    ON p.PRACTICE_CODE = ps.PRACTICE_CODE
GROUP BY
    ps.REPORT_MONTH,
    d.CHEMICAL_SUBSTANCE_BNF_DESCR;
GO

select * 
from MonthlyChemicalSubstance

-- Step 2: Return the TOP chemical per month using DENSE_RANK
-- Return the most prescribed chemical substance per month and using DENSE_RANK to rank chemicals within each month
USE PrescriptionsDB;
GO
select
    REPORT_MONTH,
    CHEMICAL_SUBSTANCE_BNF_DESCR,
    TotalPrescriptions  --number of times priscribed
FROM (
    SELECT
        REPORT_MONTH,  
        CHEMICAL_SUBSTANCE_BNF_DESCR,
        TotalPrescriptions,
        dense_rank() OVER (   --Applies dense rank to rank chemicals per montsh, we use partition by when we want to
                                        --do calculate on each group
            PARTITION BY REPORT_MONTH
            ORDER BY TotalPrescriptions DESC   --order by total prescribed desc means  highest priscribed appear high
        ) AS rank
    FROM MonthlyChemicalSubstance
) AS rank
WHERE rank = 1     --only return rank number 1 chemical and most prescribed each month
ORDER BY REPORT_MONTH;   --order financial out put by months


-------------------------------------------------------------------------------------------------------
--question 5. Write a query that returns the number of prescriptions for each BNF_CHAPTER_PLUS_CODE, 
--along with the average cost for that chapter code, and the minimum and maximum prescription 
--costs for that chapter code. 
-------------------------------------------------------------------------------------------------------
 -- this task is easily solved we need to group by bnf-chapter to see the count of prescribed and min/avg/max cost for each of them
use PrescriptionsDB
go
select count(*) as prescriptions, min(p.actual_cost) as minimum_cost, round(avg(p.actual_cost),0) as average_cost, max(p.actual_cost) as maximum_cost, bnf_chapter_plus_code
from drugs as d inner join prescriptions as p on d.bnf_code=p.bnf_code
group by bnf_chapter_plus_code


----------------------------------------------------------------------------------------------------------------------
--Question number 6. Write a query that returns the most expensive prescription prescribed by each practice, sorted 
--in descending order by prescription cost (the ACTUAL_COST column in the prescription table.) 
--Return only those rows where the most expensive prescription is more than £4000. You should 
--include the practice name in your result. 
-----------------------------------------------------------------------------------------------------------------------
--this question asked us to return the most expensive prescription prescribed each month so we need to partition by each practice
--then order by the cost within them 
use PrescriptionsDB
go
select p.prescription_code,m.practice_name, p.rank, p.actual_cost, p.practice_code
from
--order actual cost in descending way in each practice using rank
(select  prescription_code,practice_code,actual_cost, rank() over (partition by practice_code order by actual_cost desc) as rank  
from prescriptions
)p

inner join Medical_Practice as m on m.practice_code=p.practice_code  --we need table of medical practice and prescription
where (p.rank = 1) and (p.actual_cost>4000)
--filtered the result to rank 1 to see the most expensive and which is more than 4000
order by p.actual_cost desc;

-------------------------------------------------------------------------------------------------------------------
--question number 7. You should also write at least four queries of your own and provide a brief explanation of the 
--results which each query returns using each of the mentioned as: EXISTS/IN, joins, systems 
--functions, Group by/having and Order by clauses. You should specify the reason of listing those 
--queries according to the following: 
-------------------------------------------------------------------------------------------------------------------
--1. Useful for evaluating practice specialization. 
--2.  Can support bulk purchasing decisions.  
--3.  Could report errors or unusual cases. 
--4.  Showing comparisons of current with previous


--------------------------------------------------------------------------------------------------------------------
--question 7.1 
 --1: Useful for evaluating practice specialization. 

 --Question provided: Write a function which takes a name of disease and return medical_practice with high 
 --specializations in this field and also have a full address to provide for patient
 

 --------------------------------------------------------------------------------------------------------------------

 use PrescriptionsDB
 go
 create function Recognise_Medical_Specializations (@BNF_chapter nvarchar(225))
  returns table  --this should return a table which have information about medical practice like address and postcode
  as return
 (
 
 --join drugs table with prescription table with medical practice table 
 -- count number of prescription as total prescription to identify the specialization for each medical practice
 -- we should extract chapter which have form of disease in any format in the middle of text
 select practice_name, d.BNF_CHAPTER_PLUS_CODE, count(prescription_code) as total_prescription,m.ADDRESS_1, m.POSTCODE
 from drugs as d inner join prescriptions as p on p.bnf_code=d.bnf_code inner join medical_practice as m on m.practice_code=p.practice_code
 where d.bnf_chapter_plus_code like '%'+@BNF_chapter+'%'
 --another condition that I created is that medical practice must have address 1 and post code to provide for patient
 and exists 
 ( select 1
   from Medical_Practice as med
   where med.practice_code=p.practice_code
   and med.ADDRESS_1 is not null
   and med.Postcode is not null)
 group by d.BNF_CHAPTER_PLUS_CODE,m.PRACTICE_NAME,m.ADDRESS_1, m.POSTCODE
 having count (prescription_code) >300)
 ---medical practice which have precription on the specific diseas more than 300 times considered as specialization
 ---test
 SELECT *
FROM dbo.Recognise_Medical_Specializations('Cardiovascular System')
ORDER BY total_prescription DESC;

 -------------------------------------------------------------------------------------------------------------
 --question 7.2
  --Can support bulk purchasing decisions. 
  --Question 7.2- Find the best drugs for each disease by most frequently prescribed and lowest cost.
--------------------------------------------------------------------------------------------------------------
-- probabely for each diseas we want to detect which chapter is more practical and affordable to bulk purchasing

select *
from
(select 
d.BNF_CHAPTER_PLUS_CODE,
d.chemical_substance_bnf_descr,
sum(p.items) as total_items,  -- sum items to recognise each items were used more
avg (p.actual_cost) as average_cost,  --calculate avg cost for each chapter to finally sprt them 
rank () over (partition by bnf_chapter_plus_code order by sum(p.items) desc, avg (p.actual_cost) asc) as valueRank
--again we use rank because we want to determine for each chapter, what is the highest items and lowest cost
from drugs as d inner join prescriptions as p on p.bnf_code=d.bnf_code 
group by d.BNF_CHAPTER_PLUS_CODE,d.chemical_substance_bnf_descr
) 
as ranked
where valueRank = 1  --rank 1 means most prescribed and lowest cost for each chapter
ORDER BY total_items DESC; 

---as you can see, amoxicilin for infections is the best, so it make sence :))


--------------------------------------------------------------------------------------------------------------
--7.3 Could report errors or unusual cases.
--Question 7.3 drugs with unusual higher costs than their average and low prescription frequency
--------------------------------------------------------------------------------------------------------------
-- I solved this question 2 times with two approach 
--first: Identifying unusual drugs based on few prescription frequency and high cost.
--second:Detecting drugs by comparing each prescription cost with the average cost of its chemical substance.

--first approach:

use PrescriptionsDB
go

select d.bnf_chapter_plus_code, d.chemical_substance_bnf_descr, avg(p.actual_cost) as average_cost,
ROUND(MAX(p.ACTUAL_COST), 2) as MaximumCost, --round max cost with 2 decimal
count(p.prescription_code) as Number_of_priscribed
from Prescriptions AS p
inner join Drugs AS d
    on p.BNF_CODE = d.BNF_CODE
group by d.bnf_chapter_plus_code, d.chemical_substance_bnf_descr
having    
    count(p.PRESCRIPTION_CODE) < 5  --it should be priscribed less than 5 times
    AND AVG(p.ACTUAL_COST) > 500  --and average actual cost is more than 500 pound considered as unusual
order by average_cost DESC;




--second approach

-- This query is developed for unusual prescription records where the actual cost
-- is higher than the average cost of that chemical substance.

-- First, a view is created to calculate the average cost per chemical.
-- Then, prescriptions are filtered where the actual cost is more than 10 times the average cost, 
-- this may indicate errors or exceptional cases.
--The result probabley can be used for more exploration on some drugs

    CREATE VIEW average_cost_per_chemical
AS
SELECT 
    d.CHEMICAL_SUBSTANCE_BNF_DESCR,
    AVG(p.ACTUAL_COST) AS average_cost_each_chemical --average cost for each chemical substance
FROM Drugs AS d
INNER JOIN Prescriptions AS p 
    ON p.BNF_CODE = d.BNF_CODE
GROUP BY d.CHEMICAL_SUBSTANCE_BNF_DESCR;



select a.average_cost_each_chemical, p.prescription_code,m.practice_name, d.BNF_CHAPTER_PLUS_CODE,
    d.CHEMICAL_SUBSTANCE_BNF_DESCR,
    p.ACTUAL_COST

from Prescriptions as p inner join Medical_Practice as m on p.PRACTICE_CODE= m.practice_code
INNER JOIN Drugs AS d
    ON p.BNF_CODE = d.BNF_CODE
    inner join average_cost_per_chemical as a on d.CHEMICAL_SUBSTANCE_BNF_DESCR = a.CHEMICAL_SUBSTANCE_BNF_DESCR
    --we compare each chemical with their average cost of them selves.
WHERE p.ACTUAL_COST > a.average_cost_each_chemical * 10  -- if their cost is more than 10 times of their everage, must be unusual
    order by p.ACTUAL_COST desc;






------------------------------------------------------------------------------------
--question 7.4-Showing comparisons of current with previous
--Question 7.4;compares monthly total costs for each medical practice
--------------------------------------------------------------------------------------
--First, total prescription cost is calculated per practice per month using SUM().
--LAG() window function is used to extract the previous month's total cost
--again partition by as before explaied
--The difference between current and previous month is calculated to identify cost trends.
select ps.report_month, m.PRACTICE_NAME,
sum(ps.total_cost) as Current_total_cost, ----Total cost in current month

-- Uses LAG() to return the previous month's total cost for each practice,
--enabling month-to-month comparison 
lag(sum(ps.total_cost)) over
(partition by ps.practice_code order by ps.report_month) as previous_month_cost,  

--calculate differences between this month and previous month
sum(ps.total_cost)-lag(sum(ps.TOTAL_COST)) over(  --
      PARTITION BY ps.PRACTICE_CODE
        ORDER BY ps.REPORT_MONTH) as differences

from medical_practice as m inner join prescriptions_summary as ps on m.practice_code = ps.PRACTICE_CODE
GROUP BY ps.PRACTICE_CODE, m.PRACTICE_NAME, ps.REPORT_MONTH  --group by becasue we want to see per clinic
ORDER BY m.PRACTICE_NAME,  
    CASE ps.REPORT_MONTH --we should set this, otherswise they sort them in order of alphabet
        WHEN 'January'   THEN 1
        WHEN 'February'  THEN 2
        WHEN 'March'     THEN 3
        WHEN 'April'     THEN 4
        WHEN 'May'       THEN 5
        WHEN 'June'      THEN 6
        WHEN 'July'      THEN 7
        WHEN 'August'    THEN 8
        WHEN 'September' THEN 9
        WHEN 'October'   THEN 10
        WHEN 'November'  THEN 11
        WHEN 'December'  THEN 12
    END;




