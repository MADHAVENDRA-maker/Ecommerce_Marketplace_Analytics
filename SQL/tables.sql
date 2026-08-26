-- The following commands have been used to create the tables inside the database
-- 1)Orders
CREATE TABLE `orders` (
  `order_id` varchar(32) NOT NULL,
  `customer_id` varchar(32) NOT NULL,
  `order_status` varchar(20) DEFAULT NULL,
  `order_purchase_timestamp` datetime DEFAULT NULL,
  `order_approved_at` datetime DEFAULT NULL,
  `order_delivered_carrier_date` datetime DEFAULT NULL,
  `order_delivered_customer_date` datetime DEFAULT NULL,
  `order_estimated_delivery_date` datetime DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `idx_orders_customer` (`customer_id`),
  CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
)
-- 2)Order items
CREATE TABLE `order_items` (
  `order_id` varchar(32) NOT NULL,
  `order_item_id` int NOT NULL,
  `product_id` varchar(32) NOT NULL,
  `seller_id` varchar(32) NOT NULL,
  `shipping_limit_date` datetime DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `freight_value` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`order_id`,`order_item_id`),
  KEY `idx_order_items_order` (`order_id`),
  KEY `idx_order_items_product` (`product_id`),
  KEY `idx_order_items_seller` (`seller_id`),
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  CONSTRAINT `fk_order_items_seller` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`seller_id`)
)

-- 3)Order payments
CREATE TABLE `order_payments` (
  `order_id` varchar(32) NOT NULL,
  `payment_sequential` int NOT NULL,
  `payment_type` varchar(30) DEFAULT NULL,
  `payment_installments` int DEFAULT NULL,
  `payment_value` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`order_id`,`payment_sequential`),
  KEY `idx_payments_order` (`order_id`),
  CONSTRAINT `fk_order_payments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
)
-- 4)Order reviews
CREATE TABLE `order_reviews` (
  `review_id` varchar(32) NOT NULL,
  `order_id` varchar(32) NOT NULL,
  `review_score` tinyint DEFAULT NULL,
  `review_comment_title` text,
  `review_comment_message` text,
  `review_creation_date` datetime DEFAULT NULL,
  `review_answer_timestamp` datetime DEFAULT NULL,
  PRIMARY KEY (`review_id`,`order_id`),
  KEY `idx_reviews_order` (`order_id`),
  CONSTRAINT `fk_order_reviews_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
)
-- 5)Products
CREATE TABLE `products` (
  `product_id` varchar(32) NOT NULL,
  `product_category_name` varchar(100) DEFAULT NULL,
  `product_name_length` int DEFAULT NULL,
  `product_description_length` int DEFAULT NULL,
  `product_photos_qty` int DEFAULT NULL,
  `product_weight_g` decimal(10,2) DEFAULT NULL,
  `product_length_cm` decimal(10,2) DEFAULT NULL,
  `product_height_cm` decimal(10,2) DEFAULT NULL,
  `product_width_cm` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`product_id`),
  KEY `idx_products_category` (`product_category_name`)
)
-- 6)Sellers
CREATE TABLE `sellers` (
  `seller_id` varchar(32) NOT NULL,
  `seller_zip_code_prefix` varchar(5) DEFAULT NULL,
  `seller_city` varchar(100) DEFAULT NULL,
  `seller_state` varchar(2) DEFAULT NULL,
  PRIMARY KEY (`seller_id`),
  KEY `idx_sellers_zip` (`seller_zip_code_prefix`)
)
-- 7)Customers
CREATE TABLE `customers` (
  `customer_id` varchar(32) NOT NULL,
  `customer_unique_id` varchar(32) NOT NULL,
  `customer_zip_code_prefix` varchar(5) DEFAULT NULL,
  `customer_city` varchar(100) DEFAULT NULL,
  `customer_state` varchar(2) DEFAULT NULL,
  PRIMARY KEY (`customer_id`),
  KEY `idx_customers_zip` (`customer_zip_code_prefix`)
)
-- 8)Geolocation
CREATE TABLE `geolocation` (
  `zip_code_prefix` varchar(5) NOT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(2) DEFAULT NULL,
  PRIMARY KEY (`zip_code_prefix`),
  KEY `idx_geolocation_state` (`state`)
)
-- 9)Category translation
CREATE TABLE `category_translation` (
  `product_category_name` varchar(100) NOT NULL,
  `product_category_name_english` varchar(100) NOT NULL,
  PRIMARY KEY (`product_category_name`)
)