CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone_number VARCHAR(20),
    location VARCHAR(100),
    age INT,
    gender VARCHAR(10)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_time TIME,
    total_amount DECIMAL(10,2),
    delivery_location VARCHAR(200),
    payment_method VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id INT,
    item_id INT,
    item_name VARCHAR(100),
    quantity INT,
    price DECIMAL(10,2),
    cuisine_type VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE promotions (
    promotion_id INT PRIMARY KEY,
    promotion_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    discount_type VARCHAR(50),  // e.g., percentage, fixed amount
    discount_value DECIMAL(10,2)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    order_id INT,
    rating INT,
    comment TEXT,
    sentiment VARCHAR(20),  // e.g., positive, negative, neutral
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

--  Customer Segmentation:

-- Segmentation by Order Frequency:

SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
ORDER BY order_count DESC;

-- Segmentation by Average Order Value:

SELECT customer_id, AVG(total_amount) AS avg_order_value
FROM orders
GROUP BY customer_id
ORDER BY avg_order_value DESC;

-- Segmentation by Preferred Cuisine:

SELECT customer_id, COUNT(*) AS cuisine_count, 
       GROUP_CONCAT(DISTINCT cuisine_type) AS preferred_cuisines
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
GROUP BY customer_id
ORDER BY cuisine_count DESC;

-- Analyzing Customer Behavior:

-- Peak Order Times:

SELECT HOUR(order_time) AS hour, COUNT(*) AS order_count
FROM orders
GROUP BY hour
ORDER BY order_count DESC;

-- Popular Delivery Locations:

SELECT delivery_location, COUNT(*) AS order_count
FROM orders
GROUP BY delivery_location
ORDER BY order_count DESC;

-- Customer Preferences and Aversion:

SELECT item_id, COUNT(*) AS order_count, 
       AVG(rating) AS avg_rating
FROM order_items
GROUP BY item_id
ORDER BY order_count DESC;

--  Impact of Promotions and Discounts:

-- Promotion Effectiveness:

SELECT promotion_id, COUNT(*) AS orders_with_promotion, 
       SUM(total_amount) AS total_revenue
FROM orders
JOIN promotions ON orders.promotion_id = promotions.promotion_id
GROUP BY promotion_id;

-- Customer Response to Discounts:

SELECT customer_id, COUNT(*) AS discount_orders, 
       SUM(discount_amount) AS total_discount
FROM orders
JOIN promotions ON orders.promotion_id = promotions.promotion_id
WHERE discount_amount > 0
GROUP BY customer_id;

--  Identifying Top-Spending Customers:

SELECT customer_id, SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- Analyzing Peak Hours for Orders:

SELECT HOUR(order_time) AS hour, COUNT(*) AS order_count
FROM orders
GROUP BY hour
ORDER BY order_count DESC;

-- Identifying Popular Cuisine Combinations:

SELECT o1.customer_id, GROUP_CONCAT(o1.cuisine_type, ', ') AS cuisine_combo
FROM order_items o1
JOIN order_items o2 ON o1.order_id = o2.order_id AND o1.cuisine_type <> o2.cuisine_type
GROUP BY o1.customer_id
HAVING COUNT(DISTINCT o1.cuisine_type) > 1;

-- Analyzing Customer Retention:

WITH CustomerRetention AS (
  SELECT customer_id, MIN(order_date) AS first_order_date, MAX(order_date) AS last_order_date
  FROM orders
  GROUP BY customer_id
)
SELECT DATEDIFF(MAX(last_order_date), MIN(first_order_date)) AS customer_lifetime, 
       COUNT(*) AS total_customers
FROM CustomerRetention;

--  Identifying High-Value Customers:

WITH CustomerRFM AS (
  SELECT customer_id, 
         DATEDIFF(CURDATE(), MAX(order_date)) AS recency,
         COUNT(*) AS frequency,
         SUM(total_amount) AS monetary_value
  FROM orders
  GROUP BY customer_id
)
SELECT customer_id, recency, frequency, monetary_value,
       NTILE(4) OVER (ORDER BY recency DESC) AS r_quartile,
       NTILE(4) OVER (ORDER BY frequency DESC) AS f_quartile,
       NTILE(4) OVER (ORDER BY monetary_value DESC) AS m_quartile
FROM CustomerRFM
ORDER BY r_quartile DESC, f_quartile DESC, m_quartile DESC;

-- Analyzing Customer Behavior and Preferences:

-- Identifying Frequent Items:

SELECT item_name, COUNT(*) AS item_count
FROM order_items
GROUP BY item_name
ORDER BY item_count DESC;

--  Identifying Popular Cuisine Combinations:

SELECT o1.customer_id, GROUP_CONCAT(o1.cuisine_type, ', ') AS cuisine_combo
FROM order_items o1
JOIN order_items o2 ON o1.order_id = o2.order_id AND o1.cuisine_type <> o2.cuisine_type
GROUP BY o1.customer_id
HAVING COUNT(DISTINCT o1.cuisine_type) > 1;

-- Analyzing Customer Retention:

WITH CustomerRetention AS (
  SELECT customer_id, MIN(order_date) AS first_order_date, MAX(order_date) AS last_order_date
  FROM orders
  GROUP BY customer_id
)
SELECT DATEDIFF(MAX(last_order_date), MIN(first_order_date)) AS customer_lifetime, 
       COUNT(*) AS total_customers
FROM CustomerRetention;

-- Identifying High-Value Customers:

WITH CustomerRFM AS (
  SELECT customer_id, 
         DATEDIFF(CURDATE(), MAX(order_date)) AS recency,
         COUNT(*) AS frequency,
         SUM(total_amount) AS monetary_value
  FROM orders
  GROUP BY customer_id
)
SELECT customer_id, recency, frequency, monetary_value,
       NTILE(4) OVER (ORDER BY recency DESC) AS r_quartile,
       NTILE(4) OVER (ORDER BY frequency DESC) AS f_quartile,
       NTILE(4) OVER (ORDER BY monetary_value DESC) AS m_quartile
FROM CustomerRFM
ORDER BY r_quartile DESC, f_quartile DESC, m_quartile DESC;

-- Analyzing the Impact of Promotions and Discounts:

--  Promotion Effectiveness:

SELECT promotion_id, COUNT(*) AS orders_with_promotion, 
       SUM(total_amount) AS total_revenue
FROM orders
JOIN promotions ON orders.promotion_id = promotions.promotion_id
GROUP BY promotion_id;

-- Customer Response to Discounts:

SELECT customer_id, COUNT(*) AS discount_orders, 
       SUM(discount_amount) AS total_discount
FROM orders
JOIN promotions ON orders.promotion_id = promotions.promotion_id
WHERE discount_amount > 0
GROUP BY customer_id;

-- Recency, Frequency, Monetary (RFM) Analysis:

-- Recency: Days since last purchase
WITH CustomerRecency AS (
  SELECT customer_id, MAX(order_date) AS last_order_date
  FROM orders
  GROUP BY customer_id
)
SELECT o.customer_id, DATEDIFF(CURDATE(), cr.last_order_date) AS recency
FROM orders o
JOIN CustomerRecency cr ON o.customer_id = cr.customer_id;

-- Frequency: Total number of orders
SELECT customer_id, COUNT(*) AS frequency
FROM orders
GROUP BY customer_id;

-- Monetary Value: Total amount spent
SELECT customer_id, SUM(total_amount) AS monetary_value
FROM orders
GROUP BY customer_id;

-- Customer Segmentation Based on RFM:

WITH CustomerRFM AS (
  SELECT o.customer_id, 
         DATEDIFF(CURDATE(), MAX(o.order_date)) AS recency,
         COUNT(*) AS frequency,
         SUM(o.total_amount) AS monetary_value
  FROM orders o
  GROUP BY o.customer_id
)
SELECT customer_id, recency, frequency, monetary_value,
       NTILE(4) OVER (ORDER BY recency DESC) AS r_quartile,
       NTILE(4) OVER (ORDER BY frequency DESC) AS f_quartile,
       NTILE(4) OVER (ORDER BY monetary_value DESC) AS m_quartile
FROM CustomerRFM;

-- Calculating CLTV:

SELECT customer_id, 
       (r_quartile * 4 + f_quartile * 3 + m_quartile * 2) / 9 AS cltv_score
FROM CustomerRFM;


