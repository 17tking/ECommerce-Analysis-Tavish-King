-- KPI #2: Product Review Analysis

-- The Product Strategy team has asked me to analyze customer reviews 
-- to identify the key factors influencing product rating scores (1–5). 
-- The goal is to understand what drives higher satisfaction and uncover 
-- any patterns that could inform product improvements, pricing, or 
-- service enhancements.

-- Each order has a review score. However, some orders have multiple products.
-- Therefore, I am behaving as if each product has that review score. For example,
-- three products in a 4-star order will each be a 4-star rating.

-------------------------------
-- EXPLORATORY DATA ANALYSIS --
-------------------------------

-- distribution of reviews (share of star ratings)
create table review_dist as

with review_sum as (
	select 
		count(review_score) as tot_review_scores
	from master_orders
	where review_score is not null
)
select
	review_score,
	count(review_score) as review_score_ct,
	round(count(review_score) * 100.0 / review_sum.tot_review_scores, 1) as review_score_prop
from master_orders, review_sum
where review_score is not null
group by review_score, review_sum.tot_review_scores
order by review_score desc;


-- 10 highest reviewed product categories
-- only including products with a count greater than 50 reviews for a safe baseline.
create table kpi2_10_highest_reviewed as
select 
	product_category_english,
	round(avg(review_score),2) as avg_review_score
from master_orders
where review_score is not null
	and product_category_english is not null
group by product_category_english
having count(*) > 50
order by avg_review_score desc
limit 10;


-- 10 lowest reviewed product categories
-- only including products with a count greater than 50 reviews for a safe baseline.
create table kpi2_10_lowest_reviewed as
select 
	product_category_english,
	round(avg(review_score),2) as avg_review_score
from master_orders
where review_score is not null
	and product_category_english is not null
	and product_category_english not like 'unknown'
group by product_category_english
having count(*) > 50
order by avg_review_score asc
limit 10;


-- tot_price, payment_value, order_size, delivery_days v. review scores
-- (calculated at the order level)
-- note: there were errors with order_approved_at having a later timestamp
-- then the delivery date, creating negative values (impossible). 
-- Therefore, I used order_purchase_timestamp instead. No negative values and still usable.
create table kpi2_review_model_analysis as
select
	order_id,
	count(product_id) as order_size,
	round(extract(epoch from (max(order_delivered_customer_date) - min(order_purchase_timestamp))) / 86400.0, 3) as delivery_days,
	sum(price) as tot_price,
	payment_value,
	review_score
from master_orders
where order_delivered_customer_date is not null
	and order_approved_at is not null
group by order_id, payment_value, review_score;


-------------------
-- MAIN ANALYSIS --
-------------------
-- ordinal logistic regression analysis conducted in R.
-- see "R/KPI_scripts_R/KPI2_product_reviews"


-- End of Query
