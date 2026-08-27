# E-Commerce Marketplace Analysis

## Overview
This project is a comprehensive SQL-based data analysis of an e-commerce marketplace (Olist). It transforms raw transactional data into actionable business intelligence by building a robust relational database schema, optimizing query performance, constructing an analytical layer using views, and extracting strategic insights through complex SQL queries.

## Project Structure
The repository is structured to take the data from raw tables to final business insights:

### 1. Database Schema & Optimization
* **`tables.sql`**: Contains the Data Definition Language (DDL) scripts to create the core relational schema. It establishes 9 interconnected tables (`orders`, `order_items`, `order_payments`, `order_reviews`, `products`, `sellers`, `customers`, `geolocation`, and `category_translation`) with stringent Primary and Foreign Key constraints to maintain data integrity.
* **`index.sql`**: Contains scripts to create 10 database indexes on frequently queried columns (such as foreign keys, zip codes, and states) to significantly improve query execution times across large datasets.

### 2. Analytical Layer (Views)
* **`views.sql`**: This file generates 5 denormalized views that serve as the analytical grain for the project, simplifying complex aggregations and standardizing metric calculations:
  * `vw_order_summary`: Order-level sales, payment, review, and delivery analysis.
  * `vw_product_sales`: Item-level financial metrics, connecting transactions to products and sellers.
  * `vw_customer_summary`: Customer lifetime value, retention, and purchasing behavior.
  * `vw_seller_summary`: Seller commercial performance, logistics, and customer satisfaction metrics.
  * `vw_category_summary`: Category-level sales, volume, and performance evaluation.

### 3. Business Intelligence & Analysis
* **`questions_list_updated.txt`**: Outlines the 20 strategic business questions driving this analysis, covering themes like sales growth, customer retention, logistics, and seller performance.
* **`questions.sql`**: Contains the 20 complex SQL queries formulated to answer the exact questions listed above. These queries utilize the analytical views to calculate growth rates, rank top performers, evaluate delivery delays, and assess financial impacts.

### 4. Documentation & Findings
* **`Project_Data_Dictionary_Updated.pdf`**: A comprehensive data dictionary that defines all tables, views, metrics, and analytical grains. It ensures consistent metric interpretation (e.g., distinguishing between `customer_id` and `customer_unique_id`).
* **`Business_Questions_and_Answers.pdf`**: The final business intelligence report detailing the insights and actionable recommendations derived from the SQL analysis. 

## Key Business Insights
As detailed in the `Business_Questions_and_Answers.pdf`, major findings include:
* **Customer Retention:** A staggering 96.88% of customers are one-time buyers. Converting this massive pool into repeat buyers (who spend almost twice as much on average) represents the marketplace's biggest growth opportunity.
* **Logistics & Satisfaction:** Delivery reliability dictates customer satisfaction. Late deliveries crash average review scores to an abysmal 2.27, whereas on-time/early deliveries average 4.30.
* **Seller Concentration:** Revenue is well-distributed. The top 10 sellers generate only 13.15% of product sales, meaning the platform is not overly reliant on a few dominant entities.
* **Regional Discrepancies:** Delivery performance varies drastically by region. While São Paulo averages a fast 8.30-day delivery time, states like Alagoas suffer from average times of 24.04 days and a 21.41% late delivery rate.

## Setup & Execution Instructions
1. **Schema Initialization:** Execute `tables.sql` in your MySQL database to create the foundational tables.
2. **Performance Tuning:** Run `index.sql` to apply indexes.
3. **Data Loading:** Import your CSV data files into the corresponding 9 base tables.
4. **Analytical Layer Generation:** Execute `views.sql` to build the 5 summary views.
5. **Data Analysis:** Run the queries inside `questions.sql` to replicate the analysis or explore the dataset further.
