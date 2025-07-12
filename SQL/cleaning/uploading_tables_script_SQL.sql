-- Uploading clean Tables
-- cleaning script can be found in "R/cleaning/cleaning_script.R"

-- Clean Customers
CREATE TABLE clean_customers (
    customer_id CHAR(32),
    customer_unique_id CHAR(32),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

-- Clean Geolocation
Create Table clean_geolocation (
	geolocation_zip_code_prefix INT,
	geolocation_lat DECIMAL(9,6),
	geolocation_lng DECIMAL(9,6),
	geolocation_city VARCHAR,
	geolocation_state CHAR(2)
);

-- Clean Order Items
Create Table clean_order_items (
	order_id CHAR(32),
	order_item_id INT,
	product_id CHAR(32),
	seller_id CHAR(32),
	shipping_limit_date TIMESTAMP,
	price FLOAT,
	freight_value FLOAT
);

-- Clean Order Payments
Create Table clean_order_payments (
	order_id CHAR(32),
	payment_sequential INT,
	payment_type VARCHAR,
	payment_installments INT,
	payment_value FLOAT
);

-- Clean Order Reviews
Create Table clean_order_reviews (
	review_id CHAR(32),
	order_id CHAR(32),
	review_score INT,
	review_comment_message TEXT,
	review_creation_date TIMESTAMP,
	review_answer_timestamp TIMESTAMP
);

-- Clean Orders
Create Table clean_orders (
	order_id CHAR(32),
	customer_id CHAR(32),
	order_status VARCHAR(20),
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,
	order_delivered_carrier_date TIMESTAMP,
	order_delivered_customer_date TIMESTAMP,
	order_estimated_delivery_date TIMESTAMP
);

-- Clean Product Category Name Translation
Create Table clean_product_category_name_translation (
	product_category_name VARCHAR,
	product_category_name_english VARCHAR
);

-- Clean Products
Create Table clean_products (
	product_id CHAR(32),
	product_category_name VARCHAR,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
);

-- Clean Sellers
Create Table clean_sellers (
	seller_id CHAR(32),
	seller_zip_code_prefix INT,
	seller_city VARCHAR,
	seller_state CHAR(2)
);

-- Master Orders
Create Table master_orders (
	order_id CHAR(32),
	customer_id CHAR(32),
	order_status VARCHAR(20),
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,
	order_delivered_carrier_date TIMESTAMP,
	order_delivered_customer_date TIMESTAMP,
	order_estimated_delivery_date TIMESTAMP,
	customer_unique_id CHAR(32),
	customer_city VARCHAR(100),
    customer_state CHAR(2),
	customer_zip_code_prefix VARCHAR(5),
	product_id CHAR(32),
	seller_id CHAR(32),
	price DECIMAL(10,2),
	product_category_name VARCHAR(100),
	payment_type VARCHAR(50),
	payment_value DECIMAL(10,2),
	payment_installments INT,
	review_score INT,
	review_creation_date TIMESTAMP,
	seller_city VARCHAR(100),
	geolocation_lat DECIMAL(9,6),
	geolocation_lng DECIMAL(9,6),
	product_category_english VARCHAR(100)
);
