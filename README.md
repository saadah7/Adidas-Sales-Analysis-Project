# Adidas US Sales Analysis Dashboard

An end-to-end data analytics project on Adidas US sales for 2020 and 2021. Data
cleaning and exploratory analysis in Python, business queries in PostgreSQL, and
an interactive Power BI dashboard.

---

## Project Overview

The objective is to analyse Adidas' US sales performance to identify:
- Revenue and profit distribution across retailers, regions and channels
- Top-performing states, cities and product categories
- Relative performance of the three sales methods (in-store, online, outlet)
- Where profitability is strongest, and where the data cannot support a claim

The workflow has three stages:
1. Data cleaning and preparation in Python
2. Business analysis in PostgreSQL
3. Dashboard creation in Power BI

---

## Reproducing this analysis

```bash
pip install -r requirements.txt
jupyter notebook Adidas_Sales_DataAnalysis.ipynb   # run all cells
psql -d your_database -f Adidas_BusinessAnalysis_PostgreSql.sql
```

The notebook reads `Adidas US Sales Dataset (Raw).xlsx` and writes
`adidas_cleaned_dataset.csv`. The SQL script creates the table, loads that CSV
with `\copy`, and then runs the analysis queries, so the two stages line up
without any manual import step.

---

## Dashboard Preview

![Adidas Sales Dashboard](Adidas_Sales_Dashboard_image.png)

> **Note on the figures in this screenshot.** The dashboard has a retailer
> slicer, and this capture was taken with it set to **Amazon**, which is 8.6% of
> the dataset. The KPI cards therefore read 77.70M revenue rather than the
> 899.90M whole-dataset total. The tables below give both scopes so the two do
> not contradict each other. Re-exporting the image with the slicer cleared is
> still outstanding.

---

## Tech Stack

| Tool | Purpose |
|------|----------|
| Python (Pandas, NumPy, Matplotlib) | Data cleaning, preparation, and EDA |
| PostgreSQL | Data querying and business analysis |
| Power BI | Data visualization and dashboard design |
| Excel | Raw dataset source |

---

## Dataset Details

**Raw file:** `Adidas US Sales Dataset (Raw).xlsx`
**Cleaned file:** `adidas_cleaned_dataset.csv`

9,648 rows covering 2020-01-01 to 2021-12-31, across 6 retailers, 50 states,
52 cities and 6 product categories.

| Column | Description |
|---------|-------------|
| retailer | Retailer name (Amazon, Foot Locker, etc.) |
| retailer_id | Retailer identifier |
| invoice_date | Date of transaction |
| region | US region |
| state | State of sale |
| city | City of sale |
| product | Product category |
| price_per_unit | Selling price per item |
| units_sold | Quantity sold |
| total_sales | Total revenue |
| operating_profit | Profit after expenses |
| operating_margin | Margin as a fraction, so 0.50 is 50% |
| sales_method | Sales channel (Online, Outlet, In-store) |
| year | Derived from invoice_date |
| month | Month name, derived from invoice_date |

---

## Data Cleaning and Preparation (Python)

**Steps performed:**
- Skipped the four metadata rows and the blank leading column in the export
- Normalised column names to lowercase with underscores for PostgreSQL
- Converted types first, then handled missing values, since coercing to numeric
  creates new nulls that a missing-value pass run beforehand would never see
- Removed duplicate rows
- Derived `year` and `month`
- Flagged interquartile outliers but kept them, since they are large wholesale
  orders rather than data errors
- Exported the cleaned CSV for PostgreSQL

---

## Business Analysis (PostgreSQL)

`Adidas_BusinessAnalysis_PostgreSql.sql` contains the table definition, the
`\copy` load, and twelve analysis queries: revenue totals, revenue by region,
product and retailer, average margin by region, yearly coverage, revenue share
by sales method, top states and cities, the monthly trend, and a per-retailer
KPI summary.

---

## Key Business Metrics

Whole dataset, all six retailers:

| Metric | Value |
|---------|-------|
| Total Revenue | 899.90M |
| Total Operating Profit | 332.13M |
| Total Units Sold | 2,478,861 |
| Average Operating Margin | 42.30% |
| Average Price per Unit | 45.22 |

Broken down by retailer, which is what the dashboard slicer selects between:

| Retailer | Revenue | Profit | Units | Avg margin | Avg price | Share of revenue |
|---|---|---|---|---|---|---|
| West Gear | 242.96M | 85.67M | 625.3K | 41.79% | 46.74 | 27.0% |
| Foot Locker | 220.09M | 80.72M | 604.4K | 41.79% | 44.78 | 24.5% |
| Sports Direct | 182.47M | 74.33M | 557.6K | 44.49% | 42.05 | 20.3% |
| Kohl's | 102.11M | 36.81M | 287.4K | 41.93% | 44.61 | 11.3% |
| Amazon | 77.70M | 28.82M | 198.0K | 41.79% | 48.76 | 8.6% |
| Walmart | 74.56M | 25.78M | 206.2K | 40.65% | 47.18 | 8.3% |

---

## Dashboard Visuals

| Visual | Description |
|--------|--------------|
| KPI Cards | Display high-level business metrics |
| Cumulative Sales Growth Over Time (Line Chart) | Shows progressive revenue growth |
| Total Sales by City (Bar Chart) | Highlights top-performing cities |
| Product-wise Total Sales Performance (Column Chart) | Compares revenue across product categories |
| Monthly Total Sales Trend (Line Chart) | Tracks sales fluctuations and seasonality |
| Region-wise Treemap | Visualizes regional sales contribution |
| Donut Charts | Compare Online, Outlet, and In-store performance |
| Retailer Filter | Interactive slicer for retailer selection |

---

## Key Business Insights

**Revenue is concentrated in the two largest retailers.** West Gear and Foot
Locker together account for 51.5% of all revenue. Amazon and Walmart, despite
having the two highest average prices per unit, are the two smallest at 8.6%
and 8.3%.

**The West leads on both revenue and profit,** not the Northeast:

| Region | Revenue | Operating profit |
|---|---|---|
| West | 269.94M | 89.61M |
| Northeast | 186.32M | 68.02M |
| Southeast | 163.17M | 60.56M |
| South | 144.66M | 61.14M |
| Midwest | 135.80M | 52.81M |

The South is the notable case: it is fourth on revenue but second on profit,
so it converts sales to profit more efficiently than the Southeast above it.

**Men's Street Footwear leads on product, followed by Women's Apparel:**

| Product | Revenue |
|---|---|
| Men's Street Footwear | 208.83M |
| Women's Apparel | 179.04M |
| Men's Athletic Footwear | 153.67M |
| Women's Street Footwear | 128.00M |
| Men's Apparel | 123.73M |
| Women's Athletic Footwear | 106.63M |

**No single sales channel dominates.** In-store leads at 39.6% of revenue,
followed by outlet at 32.8% and online at 27.5%. The split is far more even
than a majority-in-store reading would suggest.

**New York is the strongest city at 39.80M,** ahead of San Francisco (34.54M),
Miami (31.60M), Charleston SC (29.29M) and Orlando (27.68M). City names have to
be paired with their state here: Charleston appears in both South Carolina and
West Virginia, and Portland in both Oregon and Maine, so grouping on city alone
merges two different markets and inflates them.

**Sales peak in mid-summer, not at year end.** July is the strongest month at
95.5M, followed by August at 92.2M, then December at 85.8M. March is the
weakest at 56.8M.

**Margins are consistent across retailers,** between 40.7% and 44.5%, averaging
42.30%. Sports Direct is the most efficient at 44.49%, which it achieves on the
lowest average price per unit at 42.05.

### What this dataset cannot show

**Year-over-year growth.** 2020 and 2021 are not comparable:

| Year | Rows | Retailers | Revenue |
|---|---|---|---|
| 2020 | 1,302 | 5 | 182.08M |
| 2021 | 8,346 | 6 | 717.82M |

Amazon has no 2020 rows at all, and Kohl's has 8. The apparent jump is almost
entirely retailer coverage widening rather than organic growth, so the totals
should not be read as a growth rate.

---

## Project Deliverables

| File Name | Description |
|------------|-------------|
| `Adidas US Sales Dataset (Raw).xlsx` | Raw dataset |
| `Adidas_Sales_DataAnalysis.ipynb` | Cleaning, EDA and CSV export |
| `adidas_cleaned_dataset.csv` | Cleaned dataset, loaded by the SQL script |
| `Adidas_BusinessAnalysis_PostgreSql.sql` | Table definition, CSV load and analysis queries |
| `Adidas_Sales_Dashboard.pbix` | Power BI dashboard file |
| `Adidas_Sales_Dashboard_image.png` | Dashboard screenshot, retailer slicer set to Amazon |
| `requirements.txt` | Python dependencies |
| `README.md` | This file |

---

## Learning Outcomes

- Data preprocessing and transformation with Python
- SQL-based business analysis on a real-world dataset
- Interactive visualization with Power BI
- Checking whether a dataset actually supports a claim before making it

---

## Author

**Created by:** Rudra
**Tools Used:** Python | PostgreSQL | Power BI
