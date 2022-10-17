/****** Script for SelectTopNRows command from SSMS  ******/
--DATA INSPECTION TO DETERMINE METRICS NEEDED FOR ANALYSIS AND EXPLORATION

SELECT *
  FROM [covidportfolioproject].[dbo].[sales_data_sample]

  --CHECKING UNIQUE VALUES CONTAINED IN THE DATA SET 
  select distinct status from [covidportfolioproject].[dbo].[sales_data_sample]-- to be plotted in tableau
  select distinct year_id from  [covidportfolioproject].[dbo].[sales_data_sample]
  select distinct productline from [covidportfolioproject].[dbo].[sales_data_sample]-- to be plotted in tableau
  select distinct country from [covidportfolioproject].[dbo].[sales_data_sample]-- to be plotted in tableau
  select distinct dealsize from [covidportfolioproject].[dbo].[sales_data_sample]-- to be plotted in tableau
  select distinct territory from [covidportfolioproject].[dbo].[sales_data_sample]-- to be plotted in tableau

--GROUPING SALES BY PRODUCT LINE
select PRODUCTLINE, sum(sales) as REVENUE_PRODUCTLINE
 FROM [covidportfolioproject].[dbo].[sales_data_sample]
 group by PRODUCTLINE 
 order by 2 desc

 --GROUPING SALES BY YEAR
select YEAR_ID, (sum(sales)) as REVENUE_YEAR
 FROM [covidportfolioproject].[dbo].[sales_data_sample]
 group by YEAR_ID 
 order by 2 desc

  --GROUPING SALES BY DEAL-SIZE
select DEALSIZE, (sum(sales)) as REVENUE_YEAR
 FROM [covidportfolioproject].[dbo].[sales_data_sample]
 group by  DEALSIZE 
 order by 2 desc
 
  -- DETERMINING BEST MONTH OF SALES IN THE YEAR 2003
select MONTH_ID, (sum(sales)) as REVENUE_YEAR, COUNT(ORDERLINENUMBER) as frequency
 FROM [covidportfolioproject].[dbo].[sales_data_sample]
 where YEAR_ID = 2003
 group by  MONTH_ID 
 order by 2 desc

  -- NOVEMBER EXPERIENCES MORE SALES IN TERMS OF REVENUE AND FREQUENCY, WHAT PRODUCTS IMPROVES SALES
select MONTH_ID,PRODUCTLINE, (sum(sales)) as REVENUE_YEAR, COUNT(ORDERLINENUMBER) as frequency
 FROM [covidportfolioproject].[dbo].[sales_data_sample]
 where MONTH_ID = 11 AND YEAR_ID = 2003
 group by  MONTH_ID,PRODUCTLINE
 order by 3 desc
 
  -- DETERMINING BEST CUSTOMER USING RECENCY-FREQUENCY-MONETARY ANALYSIS
DROP TABLE IF EXISTS #RMF_CALCULATION;
WITH RFM AS
(select CUSTOMERNAME, 
       (sum(sales)) as TOTAL_REVENUE, 
	  (AVG(sales)) as AVG_REVENUE, 
	   COUNT(ORDERLINENUMBER) as frequency,
	   MAX(ORDERDATE) as Last_order_date,
      (select max(orderdate)FROM [covidportfolioproject].[dbo].[sales_data_sample]) maximum_order_date,
	  DATEDIFF(dd,MAX(ORDERDATE),(select max(orderdate)FROM [covidportfolioproject].[dbo].[sales_data_sample])) RECENCY
 FROM [covidportfolioproject].[dbo].[sales_data_sample]
 group by  CUSTOMERNAME),
  RFM_CALC as
 
 
   (select r.*,
	NTILE(4) over (order by recency desc) RFM_RECENCY,
	NTILE(4) over (order by Frequency) RFM_FREQENCY,
	NTILE(4) over (order by TOTAL_REVENUE) RFM_MONETARY
   from RFM r)
   select rc.*,RFM_RECENCY+RFM_FREQENCY+RFM_MONETARY as RFM_cell,
  cast(RFM_RECENCY as varchar)+ cast(RFM_FREQENCY as varchar) +cast(RFM_MONETARY as varchar) RFM_cell_string
    into #RMF_CALCULATION
   from  RFM_CALC rc

select CUSTOMERNAME,RFM_RECENCY,RFM_FREQENCY,RFM_MONETARY,
    
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end RFM_SEGMENTATION

from #RMF_CALCULATION 

-- PRODUCTS OFTEN SOLD TOGETHER 

select distinct ORDERNUMBER,STUFF(
(select ','+PRODUCTCODE 
 FROM [covidportfolioproject].[dbo].[sales_data_sample] S
 where ORDERNUMBER  in
(select ORDERNUMBER
 from
 (select ORDERNUMBER,count(*) order_count
 FROM [covidportfolioproject].[dbo].[sales_data_sample]
 where STATUS ='shipped'
 group by ORDERNUMBER) m
 where order_count=2) and p.ORDERNUMBER=s.ORDERNUMBER
 for xml path (''))
 ,1,1,'') PRODUCT_CODES
  FROM [covidportfolioproject].[dbo].[sales_data_sample] P
  order by 2 desc
  --TOP TEN COUNTRIES WITH THE HIGHEST SALES
  SELECT top 10 COUNTRY, sum(sales) as TOTAL_SALES
  FROM [covidportfolioproject].[dbo].[sales_data_sample]
  group by COUNTRY
  order by 2 desc

   --PRICES ACROSS CITIES

   SELECT distinct PRODUCTCODE, PRICEEACH,CITY
  FROM [covidportfolioproject].[dbo].[sales_data_sample]
  order by 2
 
 