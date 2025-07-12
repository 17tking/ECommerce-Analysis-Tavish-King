-- KPI #3: Sales by Location

-- The Finance team has requested a sales performance report 
-- based on our complete available e-commerce sales data spanning from January 
-- 2017 to September 2018. The primary goals of this analysis are:
--
-- 		* Identify the top revenue-generating states in Brazil to 
-- 		inform where current marketing efforts are most effective.
--
-- 		* Highlight underperforming states in terms of revenue, 
-- 		where the team could consider targeted marketing and advertising 
-- 		campaigns to boost sales.
--
-- This report will include geographic visualizations of revenue by state 
-- and time series breakdowns of sales trends over the two-year period.

-------------------------------
-- EXPLORATORY DATA ANALYSIS --
-------------------------------
-- removed 2016 due to only having 3 months of sales data and unusually low sales (clerical error?)
-- also removed canceled and unavailable orders

-- sales aggregated by month & year
create table kpi3_yearmonth_sales as

with monthly_sales as (
  select
    extract(year from order_purchase_timestamp) as year,
    extract(month from order_purchase_timestamp) as month,
    sum(price) as total_sales,
    count(order_id) as order_volume
  from master_orders
  where extract(year from order_purchase_timestamp) != 2016
    and order_status not in ('canceled', 'unavailable')
  group by year, month
  having sum(price) is not null
),

first_orders as (
  select
    customer_id,
    min(date_trunc('month', order_purchase_timestamp)) as first_order_month
  from master_orders
  where order_status not in ('canceled', 'unavailable')
  group by customer_id
),

monthly_new_customers as (
  select
    extract(year from first_order_month) as year,
    extract(month from first_order_month) as month,
    count(distinct customer_id) as new_customers
  from first_orders
  where extract(year from first_order_month) != 2016
  group by year, month
)

select
  ms.year,
  ms.month,
  ms.order_volume,
  round(
    ms.order_volume - lag(ms.order_volume) over (order by ms.year, ms.month)
  ) as order_volume_growth,
  ms.total_sales,
  round(
    (ms.total_sales - lag(ms.total_sales) over (order by ms.year, ms.month)) /
    nullif(lag(ms.total_sales) over (order by ms.year, ms.month), 0) * 100, 2) as sales_growth,
  coalesce(nc.new_customers, 0) as new_customers
from monthly_sales ms
left join monthly_new_customers nc
  on ms.year = nc.year and ms.month = nc.month
order by ms.year, ms.month;



-- sales aggregated by customer_state
create table kpi3_total_state_sales as

select
	customer_state,
	sum(price) as total_sales,
	count(distinct(order_id)) as order_count,
	round(sum(price) / count(distinct(order_id)),2) as aov, --average order value
	round(avg(extract(epoch from (order_delivered_customer_date - order_purchase_timestamp)) / 86400.0), 0) as avg_delivery_days
from master_orders
where order_status != 'canceled'
	and order_status != 'unavailable'
	and extract(year from order_purchase_timestamp) != 2016
group by customer_state
order by total_sales desc;

-- End of Query

