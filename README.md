# E-Commerce Marketplace Analysis

## Overview

This project uses SQL to analyze the Brazilian Olist e-commerce marketplace dataset and understand customer behavior, sales performance, delivery efficiency, and seller contributions. Using MySQL, I built a relational database, created analytical views, and wrote complex queries to turn transactional data into actionable business insights.

## Project Structure

### 1. Database Design and Optimization
- **`tables.sql`** — Creates nine relational tables with primary and foreign key constraints to maintain data integrity.
- **`index.sql`** — Adds ten indexes to frequently queried columns to improve query performance.

### 2. Analytical Views
**`views.sql`** creates five views that simplify analysis and provide a consistent foundation for business metrics:

- `vw_order_summary` — Order values, payments, reviews, and delivery performance.
- `vw_product_sales` — Product sales and seller-level revenue.
- `vw_customer_summary` — Customer spending, retention, and purchasing behavior.
- `vw_seller_summary` — Seller performance, logistics, and customer satisfaction.
- `vw_category_summary` — Sales and performance across product categories.

### 3. Business Analysis
- **`questions_list_updated.txt`** — Lists 20 business questions covering customer retention, sales, logistics, and seller performance.
- **`questions.sql`** — Contains the SQL queries used to answer these questions through aggregations, joins, common table expressions (CTEs), window functions, and ranking techniques.

### 4. Documentation
- **`Project_Data_Dictionary_Updated.pdf`** — Documents the database schema, analytical views, metrics, and data definitions.
- **`Business_Questions_and_Answers.pdf`** — Presents the findings and recommendations derived from the analysis.

## Key Findings

- **Customer Retention:** 96.88% of customers made only one purchase. Repeat customers spent approximately 1.92 times as much on average as one-time buyers (R$307.66 vs. R$160.28), highlighting an opportunity to improve retention.
- **Delivery and Satisfaction:** Orders delivered on time or early received an average review score of 4.30, compared with just 2.27 for late deliveries.
- **Seller Performance:** The top 10 sellers accounted for 13.15% of product sales, indicating that sales were distributed across a broad seller base.
- **Regional Delivery Gaps:** São Paulo had an average delivery time of 8.30 days, while Alagoas averaged 24.04 days and had a late-delivery rate of 21.41%.

## Setup and Execution

**Prerequisites:** MySQL and the Olist dataset CSV files.

1. **Create the schema:** Execute `tables.sql` to create the nine base tables.
2. **Add indexes:** Run `index.sql` to optimize frequently used queries.
3. **Load the data:** Import the corresponding CSV files into the base tables.
4. **Create analytical views:** Execute `views.sql` to generate the five views.
5. **Run the analysis:** Execute the queries in `questions.sql` to reproduce the analysis and explore additional business questions.

## Author

**Madhavendra Gautam**  
Indian Institute of Technology Jammu
