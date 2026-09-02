/*
# E-Commerce Sales Analytics — SQL Project

## What This Project Is

A self-contained relational database that simulates a small e-commerce business — customers, products, orders, payments, and reviews. The goal isn't just to store data, but to demonstrate the full range of SQL skills that employers actually check for: schema design, data integrity, querying, and the "medium/advanced" features (window functions, views, stored procedures, triggers) that separate a beginner from someone who's comfortable in a real database.

This is designed to be a portfolio piece — something you build once, document well, and reuse across your resume, GitHub, and LinkedIn.

---

## Step 1: Schema Design — *Why it matters*

**What we did:** Created 7 tables (`categories`, `customers`, `products`, `orders`, `order_items`, `payments`, `reviews`) with `PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `UNIQUE`, and `DEFAULT` constraints. `order_items` uses a **composite primary key** (order_id + product_id).

**Why this step exists:** Before you can write a single query, you need a schema that reflects how real businesses model data. This step proves you understand:
- **Normalization** — splitting data into logical tables instead of one giant flat table (e.g., `order_items` as its own table instead of repeating product info inside `orders`)
- **Relationships** — one customer has many orders (1-to-many), one order has many products (many-to-many, resolved via `order_items`)
- **Data integrity** — `CHECK (price > 0)` and `FOREIGN KEY` constraints stop bad data from ever entering the database, which is exactly what interviewers probe when they ask "how do you ensure data quality?"

This is the "foundation" section of your README — it's what a hiring manager glances at first to judge whether you understand database design, not just SQL syntax.

---

## Step 2: Populating with Sample Data — *Why it matters*

**What we did:** Inserted realistic rows into every table — but deliberately included gaps: a customer who never ordered, a product that was never sold, an order that's still pending with no payment, and a cancelled order.

**Why this step exists:** Clean, "perfect" data doesn't test anything. Real datasets have missing links, and a big part of SQL fluency is handling that correctly (`NULL`s, `LEFT JOIN`s, edge cases). By seeding intentional gaps now, every query in Step 3 has something meaningful to reveal — it turns the project from "look, I can insert rows" into "look, I designed data specifically to demonstrate edge-case handling."

---

## Step 3: Core Querying — *Why it matters*

**What we did:** Ran 7 queries covering:
1. Basic filtering/sorting (`ORDER BY`, `LIMIT`)
2. Aggregation with `GROUP BY` + `HAVING`
3. Multi-table `INNER JOIN`
4. `LEFT JOIN` to find customers with no orders
5. `LEFT JOIN` to find products never sold
6. A **correlated subquery** (products priced above their category average)
7. `CASE WHEN` for customer segmentation (VIP/Regular/New)

**Why this step exists:** This is the "can you actually answer business questions with SQL" section. Each query maps to a real question a business would ask:
- *"Who are our best customers?"* → GROUP BY + HAVING
- *"Which category makes the most money?"* → JOIN + aggregation
- *"Which customers are we losing / never engaged?"* → LEFT JOIN
- *"Which products are underperforming?"* → LEFT JOIN
- *"Which products are overpriced relative to their category?"* → correlated subquery
- *"How do we segment customers for marketing?"* → CASE WHEN

Framing every query around a *business question* (rather than just "here's a JOIN example") is what makes this look professional instead of like a textbook exercise — and it's exactly the language to use in your LinkedIn post.

---

## Step 4 (Coming Next): Medium/Advanced Concepts — *Why it will matter*

This is the differentiator section — most beginner portfolios stop at Step 3. Adding these signals you're closer to job-ready:
- **Window functions** (`RANK()`, `LAG()`, running totals) — used constantly in real analytics for rankings and trend comparisons, and it's the single most common thing recruiters scan for to separate "knows SQL basics" from "can actually do analyst work"
- **CTEs (`WITH`)** — makes complex multi-step queries readable, which matters when someone else (or future-you) has to maintain the query
- **Views** — shows you understand how to package a query for reuse, the way BI tools or dashboards would consume it
- **Stored procedures** — shows you can encapsulate business logic inside the database itself (e.g., a repeatable "apply discount" operation)
- **Triggers** — shows you understand automatic, event-driven data integrity (e.g., auto-updating stock when an order is placed)
- **Indexing + `EXPLAIN`** — shows performance awareness, not just correctness

---

## Step 5 (Coming Next): Packaging for GitHub & LinkedIn — *Why it will matter*

A great SQL project that sits only on your laptop has zero value to a recruiter. The final step is presentation:
- Splitting the work into `schema.sql`, `seed.sql`, `queries.sql` files in a GitHub repo
- An ER diagram, so people can understand the structure at a glance without reading code
- A LinkedIn post framed as a **problem → build → concepts demonstrated → key learning**, because recruiters skim LinkedIn, they don't read code — the post has to sell the project in 30 seconds
*/


CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(50),
    signup_date DATE NOT NULL
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id INT,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATE,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
-- Categories
INSERT INTO categories (category_name) VALUES
('Electronics'), ('Clothing'), ('Home & Kitchen'), ('Books'), ('Sports');

-- Customers (10 total, including some who signed up but never ordered)
INSERT INTO customers (first_name, last_name, email, city, signup_date) VALUES
('Rahul', 'Menon', 'rahul.menon@mail.com', 'Kochi', '2025-01-15'),
('Sneha', 'Nair', 'sneha.nair@mail.com', 'Trivandrum', '2025-02-10'),
('Arjun', 'Pillai', 'arjun.pillai@mail.com', 'Kozhikode', '2025-02-20'),
('Divya', 'Krishnan', 'divya.k@mail.com', 'Kochi', '2025-03-05'),
('Vishnu', 'Raj', 'vishnu.raj@mail.com', 'Kannur', '2025-03-12'),
('Anjali', 'Suresh', 'anjali.s@mail.com', 'Thrissur', '2025-04-01'),
('Karthik', 'Balan', 'karthik.b@mail.com', 'Kochi', '2025-04-18'),
('Meera', 'Vijayan', 'meera.v@mail.com', 'Alappuzha', '2025-05-02'),
('Nikhil', 'Thomas', 'nikhil.t@mail.com', 'Kottayam', '2025-05-22'),
('Priya', 'Das', 'priya.das@mail.com', 'Trivandrum', '2025-06-10');

-- Products (some never ordered later, some low stock)
INSERT INTO products (product_name, category_id, price, stock_quantity) VALUES
('Wireless Mouse', 1, 799.00, 50),
('Bluetooth Headphones', 1, 1999.00, 30),
('Smartwatch', 1, 4999.00, 15),
('Cotton T-Shirt', 2, 499.00, 100),
('Denim Jeans', 2, 1299.00, 40),
('Non-stick Pan', 3, 899.00, 25),
('Blender', 3, 2199.00, 20),
('Fiction Novel', 4, 349.00, 60),
('Yoga Mat', 5, 699.00, 35),
('Cricket Bat', 5, 1599.00, 10);

-- Orders (spread across months, some pending, some delivered)
INSERT INTO orders (customer_id, order_date, order_status) VALUES
(1, '2025-02-01', 'Delivered'),
(2, '2025-02-15', 'Delivered'),
(1, '2025-03-10', 'Delivered'),
(3, '2025-03-15', 'Delivered'),
(4, '2025-04-02', 'Delivered'),
(5, '2025-04-20', 'Pending'),
(6, '2025-05-05', 'Delivered'),
(1, '2025-05-18', 'Delivered'),
(7, '2025-06-01', 'Delivered'),
(8, '2025-06-12', 'Cancelled'),
(9, '2025-06-20', 'Delivered'),
(2, '2025-07-01', 'Delivered');

-- Order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 799.00),
(1, 4, 2, 499.00),
(2, 2, 1, 1999.00),
(3, 3, 1, 4999.00),
(4, 8, 3, 349.00),
(5, 6, 1, 899.00),
(5, 7, 1, 2199.00),
(6, 9, 2, 699.00),
(7, 5, 1, 1299.00),
(8, 2, 1, 1999.00),
(8, 1, 2, 799.00),
(9, 10, 1, 1599.00),
(10, 4, 1, 499.00),
(11, 3, 1, 4999.00),
(12, 8, 2, 349.00);

-- Payments
INSERT INTO payments (order_id, payment_date, amount, payment_method) VALUES
(1, '2025-02-01', 1797.00, 'UPI'),
(2, '2025-02-15', 1999.00, 'Credit Card'),
(3, '2025-03-10', 4999.00, 'UPI'),
(4, '2025-03-16', 1047.00, 'Debit Card'),
(5, '2025-04-03', 3098.00, 'UPI'),
(7, '2025-05-06', 1398.00, 'Credit Card'),
(8, '2025-05-19', 3597.00, 'UPI'),
(9, '2025-06-02', 1599.00, 'Cash on Delivery'),
(11, '2025-06-21', 4999.00, 'UPI'),
(12, '2025-07-01', 698.00, 'Debit Card');

-- Reviews
INSERT INTO reviews (product_id, customer_id, rating, review_date) VALUES
(1, 1, 4, '2025-02-05'),
(4, 1, 5, '2025-02-05'),
(2, 2, 3, '2025-02-20'),
(3, 3, 5, '2025-03-18'),
(8, 4, 4, '2025-04-05'),
(6, 5, 2, '2025-04-22'),
(9, 6, 5, '2025-05-08'),
(2, 1, 4, '2025-05-20');

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;

-- Top 5 most expensive products
SELECT product_name, price FROM products
ORDER BY price DESC LIMIT 5;
SELECT c.customer_id, c.first_name, c.last_name, SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(oi.quantity * oi.unit_price) > 3000
ORDER BY total_spent DESC;


#GROUP BY + HAVING — customers who spent over ₹3000 total
SELECT c.customer_id, c.first_name, c.last_name, SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(oi.quantity * oi.unit_price) > 3000
ORDER BY total_spent DESC;

#INNER JOIN across 3 tables — revenue per category
SELECT cat.category_name, SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM categories cat
JOIN products p ON cat.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY cat.category_name
ORDER BY category_revenue DESC;

#LEFT JOIN — find customers who never placed an order (this is where Priya shows up)
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
#LEFT JOIN — products never ordered
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;
#Subquery — products priced above the average price in their own category
SELECT p.product_name, p.price, p.category_id
FROM products p
WHERE p.price > (
    SELECT AVG(p2.price) FROM products p2
    WHERE p2.category_id = p.category_id
);


#segment customers by spend
SELECT c.customer_id, c.first_name,
    SUM(oi.quantity * oi.unit_price) AS total_spent,
    CASE
        WHEN SUM(oi.quantity * oi.unit_price) >= 4000 THEN 'VIP'
        WHEN SUM(oi.quantity * oi.unit_price) >= 1500 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name;