
![Logo](https://ironfocus.com/wp-content/uploads/2019/12/RFM-Analysis.png
# Recency-frequency-monetary analysis

Recency, frequency, monetary value (RFM) is a marketing analysis tool used to identify a firm's best clients based on the nature of their spending habits.
An RFM analysis evaluates clients and customers by scoring them in three categories: how recently they've made a purchase, how often they buy, and the size of their purchases.
The RFM model assigns a score of 1-4 (from worst to best) for customers in each of the three categories.
RFM analysis helps firms reasonably predict which customers are likely to purchase their products again, how much revenue comes from new (versus repeat) clients, and how to turn occasional buyers into habitual ones.

## Methodology

-  this Analysis was to highlight  the various benefits of RFM Analysis. RFM Analysis is effective and intuitive when it comes to giving businesses the ability to recognize the latest buyer persona trends. It also allows businesses to identify and focus on converting critical customer segments. For instance, customers that are on the verge of churning then end up becoming active users. Here are the steps involved in conducting RFM Analysis for your business:

Step 1: Relevant Data Assembly

Step 2: Setting Up RFM Scales

Step 3: Score Designation

Step 4: Segment Classification

Step 5: Personalization of Strategies for Relevant Segments


## Questions to be answered 

#### 1. what was the best month for sales in a specific year?   how much was earned that month

#### 2. who is our best customer 

#### 3. what two products are most  often sold together  




## Examples: what was the best month for sales 

select MONTH_ID, 
(sum(sales)) as REVENUE_YEAR, 
COUNT(ORDERLINENUMBER) as frequency
 
 FROM [covidportfolioproject].[dbo].[sales_data_sample]
 
 where YEAR_ID = 2003
 group by  MONTH_ID 
 order by 2 desc

## Examples: who is our best customer 


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


## Examples: what two products are most often sold together


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

## Examples: prices across cities 

SELECT distinct PRODUCTCODE, PRICEEACH,CITY
  FROM [covidportfolioproject].[dbo].[sales_data_sample]
  order by 2
 

## Analysis and key findings 

1. NOVEMBER EXPERIENCES MORE SALES

 
