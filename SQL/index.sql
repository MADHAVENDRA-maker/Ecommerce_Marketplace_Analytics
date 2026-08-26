-- The following commands were used to create the indexes for the various tables used in the databse
CREATE INDEX idx_orders_customer
ON orders(customer_id);

CREATE INDEX idx_order_items_order
ON order_items(order_id);

CREATE INDEX idx_order_items_product
ON order_items(product_id);

CREATE INDEX idx_order_items_seller
ON order_items(seller_id);

CREATE INDEX idx_payments_order
ON order_payments(order_id);

CREATE INDEX idx_reviews_order
ON order_reviews(order_id);

CREATE INDEX idx_products_category
ON products(product_category_name);

CREATE INDEX idx_customers_zip
ON customers(customer_zip_code_prefix);

CREATE INDEX idx_sellers_zip
ON sellers(seller_zip_code_prefix);

CREATE INDEX idx_geolocation_state
ON geolocation(state);