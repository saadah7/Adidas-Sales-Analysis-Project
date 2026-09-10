-- Adidas US Sales: business analysis queries
--
-- Input: adidas_cleaned_dataset.csv, produced by Adidas_Sales_DataAnalysis.ipynb.
-- The column order below matches that file's header exactly, which is what
-- lets the COPY further down run without a column list.
--
-- Run with:  psql -d your_database -f Adidas_BusinessAnalysis_PostgreSql.sql

-- Creating table
DROP TABLE IF EXISTS adidas_sales;

CREATE TABLE adidas_sales (
  retailer VARCHAR,
  retailer_id BIGINT,
  invoice_date DATE,
  region VARCHAR,
  state VARCHAR,
  city VARCHAR,
  product VARCHAR,
  price_per_unit NUMERIC,
  units_sold INT,
  total_sales NUMERIC,
  operating_profit NUMERIC,
  operating_margin NUMERIC,
  sales_method VARCHAR,
  year INT,
  month VARCHAR
);

-- Load the cleaned CSV. \copy is a psql client-side command, so it reads the
-- file from wherever you launched psql and needs no server-side file access.
-- If you are loading from the server's own filesystem instead, use:
--   COPY adidas_sales FROM '/absolute/path/adidas_cleaned_dataset.csv' WITH (FORMAT csv, HEADER true);
\copy adidas_sales FROM 'adidas_cleaned_dataset.csv' WITH (FORMAT csv, HEADER true)

-- Expect 9648 rows.
SELECT COUNT(*) AS rows_loaded FROM adidas_sales;

-- 1. Total Revenue Generated
SELECT SUM(total_sales) AS total_revenue
FROM adidas_sales;

-- 2. Total Revenue by Region
SELECT region, SUM(total_sales) AS total_revenue
FROM adidas_sales
GROUP BY region
ORDER BY total_revenue DESC;

-- 3. Total Revenue by Product
SELECT product, SUM(total_sales) AS total_revenue
FROM adidas_sales
GROUP BY product
ORDER BY total_revenue DESC;

-- 4. Average Operating Margin by Region
-- operating_margin is stored as a fraction (0.50 = 50%), hence the *100.
SELECT region, ROUND(AVG(operating_margin) * 100, 2) AS avg_margin_percent
FROM adidas_sales
GROUP BY region
ORDER BY avg_margin_percent DESC;

-- 5. Yearly Sales Totals
-- Read as coverage, not growth: 2020 holds 1302 rows across five retailers
-- while 2021 holds 8346 across six, so the gap is mostly the dataset widening.
SELECT
    year,
    COUNT(*) AS rows_in_year,
    COUNT(DISTINCT retailer) AS retailers,
    SUM(total_sales) AS total_revenue
FROM adidas_sales
GROUP BY year
ORDER BY year;

-- 6. Most Profitable Product
SELECT product, SUM(operating_profit) AS total_profit
FROM adidas_sales
GROUP BY product
ORDER BY total_profit DESC
LIMIT 1;

-- 7. Revenue Share by Sales Method (Online vs Outlet vs In-store)
SELECT
    sales_method,
    SUM(total_sales) AS total_revenue,
    ROUND(100.0 * SUM(total_sales) / SUM(SUM(total_sales)) OVER (), 1) AS share_percent
FROM adidas_sales
GROUP BY sales_method
ORDER BY total_revenue DESC;

-- 8. Top 5 States by Total Sales
SELECT state, SUM(total_sales) AS total_sales
FROM adidas_sales
GROUP BY state
ORDER BY total_sales DESC
LIMIT 5;

-- 9. Monthly Sales Trend
-- The alias is sales_month, not month, on purpose. This table already has a
-- month column, and PostgreSQL resolves an ambiguous GROUP BY name to the
-- input column rather than the SELECT alias, so `GROUP BY month` here would
-- group by the month-name column and then reject invoice_date as ungrouped.
-- Grouping by the expression itself removes the ambiguity.
SELECT
    TO_CHAR(invoice_date, 'YYYY-MM') AS sales_month,
    SUM(total_sales) AS monthly_sales
FROM adidas_sales
GROUP BY TO_CHAR(invoice_date, 'YYYY-MM')
ORDER BY sales_month;

-- 10. Top 5 Retailers by Revenue
SELECT retailer, SUM(total_sales) AS total_revenue
FROM adidas_sales
GROUP BY retailer
ORDER BY total_revenue DESC
LIMIT 5;

-- 11. Per-Retailer KPI Summary
-- The Power BI dashboard has a retailer slicer, so a KPI read off a filtered
-- view reflects one retailer rather than the whole dataset. This query shows
-- both scopes side by side.
SELECT
    retailer,
    SUM(total_sales) AS revenue,
    SUM(operating_profit) AS operating_profit,
    SUM(units_sold) AS units_sold,
    ROUND(AVG(operating_margin) * 100, 2) AS avg_margin_percent,
    ROUND(AVG(price_per_unit), 2) AS avg_price_per_unit,
    ROUND(100.0 * SUM(total_sales) / SUM(SUM(total_sales)) OVER (), 1) AS share_of_revenue_percent
FROM adidas_sales
GROUP BY retailer
ORDER BY revenue DESC;

-- 12. Top 10 Cities by Revenue
SELECT city, state, SUM(total_sales) AS total_revenue
FROM adidas_sales
GROUP BY city, state
ORDER BY total_revenue DESC
LIMIT 10;
