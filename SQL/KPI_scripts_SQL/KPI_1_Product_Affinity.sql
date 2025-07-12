-- KPI #1: Product Affinity Analysis

-- The Retail Strategy team has asked me to conduct a market basket 
-- analysis to identify the top 10 product category pairs most 
-- frequently purchased together in a single order. Exclude orders that were cancelled

-- For each pair, please include the following metrics:
--		Support: How often the two categories are bought together in orders
--		Confidence: The likelihood of purchasing category B when Category A is purchased
--		Lift: How much more likely the pair is bought together compared to being bought independently
--

-------------------------------
-- EXPLORATORY DATA ANALYSIS --
-------------------------------

-- distinct # of orders
select
	count(distinct order_id) as count
from master_orders


-- average items per order
select 
	round(avg(item_count),2) as avg_order_size
from (
	select
		order_id,
		count(*) as item_count
	from master_orders
	where order_status != 'canceled'
	group by order_id
) as order_counts;


-- count of orders with multiple categories
select 
	count(*) as multi_category_order_count
from (
	select
		order_id,
		count(distinct product_category_english) as category_count
	from master_orders
	where order_status != 'canceled'
	group by order_id
) as order_catgory_counts
where category_count > 1;


-- top 10 highest selling categories
create table kpi1_10_highest_selling as
select
	product_category_english,
	count(product_category_english) as salecount
from master_orders
where order_status != 'canceled'
group by product_category_english
order by salecount desc
Limit 10;


-- top 10 lowest selling categories
create table kpi1_10_lowest_selling as
select
	product_category_english,
	count(product_category_english) as salecount
from master_orders
where product_category_english is not null
	and order_status != 'canceled'
group by product_category_english
order by salecount asc
Limit 10;


-- Identify orders with multiple distinct product categories
create table kpi1_multiple_categories as
select 
	order_id,
	count(distinct product_category_english) as ProductCatCount
from master_orders
where order_status != 'canceled'
group by order_id
having count(distinct product_category_english) >= 1
order by count(distinct product_category_english) desc;


-- identify single product categories with different product_id's
create table kpi1_single_categories as
select 
	order_id,
	product_category_english,
	count(distinct product_id) as productid_count
from master_orders
where order_status != 'canceled'
group by order_id, product_category_english
having count(distinct product_id) > 1
 and count(distinct product_category_english) = 1
order by count(distinct product_id) desc;


-- Generate product category pairs
-- We need to identify the top 10 product categories that are frequently purchased together in the same order.
create table kpi1_paircounts as
with OrderProducts as (
	select 
		order_id,
		product_category_english
	from master_orders
	where order_status != 'canceled'
)
select
	op1.product_category_english as Cat1,
	op2.product_category_english as Cat2,
	count(distinct op1.order_id) as PairCount
from OrderProducts op1
join OrderProducts op2
	on op1.order_id = op2.order_id
	and op1.product_category_english < op2.product_category_english
	and op1.product_category_english <> op2.product_category_english
group by 
	op1.product_category_english,
	op2.product_category_english
order by PairCount desc
limit 10;


-- Calculate Support values for individual categories
create table kpi1_support_values as
select
	product_category_english as product_category,
	count(distinct order_id) as TransactionCount,
	Round(count(distinct order_id) * 1.0 / (select count(distinct order_id) from master_orders ),3)*100 as Support_pct
from master_orders
where order_status != 'canceled'
group by product_category_english
order by Support_pct desc;


-------------------
-- MAIN ANALYSIS --
-------------------

--Calculating Confidence and Lift for top 10 product categories by Lift values with > 10 paired purchase
--We need to determine which product categories are frequently purchased together 
--to optimize marketing strategies and cross-selling opportunities.

-- Step 1: Product-level category mapping per order
create table kpi1_top_cat_pairs as

with OrderCategories as (
  select distinct
    order_id,
    product_category_english as category
  from master_orders
  where order_status != 'canceled'
),

-- Step 2: Unique category pairs per order
CategoryPairs as (
  select distinct
    oc1.order_id,
    least(oc1.category, oc2.category) as Category_A,
    greatest(oc1.category, oc2.category) as Category_B
  from OrderCategories oc1
  join OrderCategories oc2 
    on oc1.order_id = oc2.order_id
    and oc1.category < oc2.category
),

-- Step 3: Calculating total orders containing each category
ProductSupport as (
  select
    category,
    count(distinct order_id) as TransactionCount,
    count(distinct order_id) * 1.0 / (select count(distinct order_id) from master_orders) as Support
  from OrderCategories
  group by category
),

-- Step 4: Count of orders containing each category pair
PairSupport as (
  select
    Category_A,
    Category_B,
    count(distinct order_id) as PairTransactionCount,
    count(distinct order_id) * 1.0 / (select count(distinct order_id) from master_orders) as PairSupport
  from CategoryPairs
  group by Category_A, Category_B
  having count(distinct order_id) > 10
)

-- Step 5: Final output with confidence and lift
select
  ps.Category_A,
  ps.Category_B,
  PairTransactionCount,
  ps.PairSupport as SupportAB,
  ROUND(ps.PairSupport / p1.Support, 6) as Confidence_AtoB,
  ROUND(ps.PairSupport / p2.Support, 6) as Confidence_BtoA,
  ROUND(ps.PairSupport / (p1.Support * p2.Support), 3) as Lift
from PairSupport ps
join ProductSupport p1 
	on ps.Category_A = p1.category
join ProductSupport p2 
	on ps.Category_B = p2.category
order by Lift desc;
--The results are sorted by Lift in descending order to identify 
--the strongest product associations.

--End of Query

