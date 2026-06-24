-- ============================================================
-- Olist Delivery Performance  |  PostgreSQL Schema (star-ish)
-- Mirrors the real Kaggle dataset: olistbr/brazilian-ecommerce
-- ============================================================

DROP TABLE IF EXISTS order_reviews, order_payments, order_items,
                     orders, products, sellers, customers,
                     category_translation CASCADE;

CREATE TABLE customers (
    customer_id              VARCHAR(32) PRIMARY KEY,
    customer_unique_id       VARCHAR(32),
    customer_zip_code_prefix INTEGER,
    customer_city            VARCHAR(64),
    customer_state           CHAR(2)
);

CREATE TABLE sellers (
    seller_id              VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city            VARCHAR(64),
    seller_state           CHAR(2)
);

CREATE TABLE products (
    product_id            VARCHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(64),
    product_weight_g      INTEGER,
    product_length_cm     INTEGER,
    product_height_cm     INTEGER,
    product_width_cm      INTEGER
);

CREATE TABLE orders (
    order_id                      VARCHAR(32) PRIMARY KEY,
    customer_id                   VARCHAR(32) REFERENCES customers(customer_id),
    order_status                  VARCHAR(16),
    order_purchase_timestamp      TIMESTAMP,
    order_approved_at             TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items (
    order_id           VARCHAR(32) REFERENCES orders(order_id),
    order_item_id      INTEGER,
    product_id         VARCHAR(32) REFERENCES products(product_id),
    seller_id          VARCHAR(32) REFERENCES sellers(seller_id),
    shipping_limit_date TIMESTAMP,
    price              NUMERIC(10,2),
    freight_value      NUMERIC(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE order_payments (
    order_id             VARCHAR(32) REFERENCES orders(order_id),
    payment_sequential   INTEGER,
    payment_type         VARCHAR(16),
    payment_installments INTEGER,
    payment_value        NUMERIC(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE order_reviews (
    review_id              VARCHAR(32),
    order_id               VARCHAR(32) REFERENCES orders(order_id),
    review_score           INTEGER,
    review_creation_date   TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE category_translation (
    product_category_name         VARCHAR(64) PRIMARY KEY,
    product_category_name_english VARCHAR(64)
);

-- Indexes that matter for the reporting queries
CREATE INDEX idx_orders_status   ON orders(order_status);
CREATE INDEX idx_orders_purchase ON orders(order_purchase_timestamp);
CREATE INDEX idx_items_seller    ON order_items(seller_id);
CREATE INDEX idx_items_product   ON order_items(product_id);

-- ---- LOAD (psql \copy; run from the data/ directory) ----
-- \copy customers           FROM 'olist_customers_dataset.csv'            CSV HEADER;
-- \copy sellers             FROM 'olist_sellers_dataset.csv'              CSV HEADER;
-- \copy products            FROM 'olist_products_dataset.csv'             CSV HEADER;
-- \copy orders              FROM 'olist_orders_dataset.csv'               CSV HEADER NULL '';
-- \copy order_items         FROM 'olist_order_items_dataset.csv'          CSV HEADER;
-- \copy order_payments      FROM 'olist_order_payments_dataset.csv'       CSV HEADER;
-- \copy order_reviews       FROM 'olist_order_reviews_dataset.csv'        CSV HEADER;
-- \copy category_translation FROM 'product_category_name_translation.csv' CSV HEADER;
