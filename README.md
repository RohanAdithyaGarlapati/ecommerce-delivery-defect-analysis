# E-Commerce Delivery Defect Analysis

An end-to-end analytics project that examines delivery performance across 96,468 real e-commerce orders, identifies the root causes of late deliveries, and quantifies their impact on customer satisfaction. The project moves raw transactional data through a SQL warehouse and a Python feature-engineering layer into a four-dashboard Tableau report designed for operations leadership.

**Stack:** PostgreSQL · Python (pandas) · Tableau Public
**Data:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (~100K real orders, 2016–2018)
**Live dashboard:** [View on Tableau Public](https://public.tableau.com/app/profile/rohan.adithya.garlapati4858/viz/OlistDeliveryPerformanceRootCauseAnalysis)

## Overview

The analysis follows a clear narrative: establish overall delivery health, locate where performance breaks down, explain why, and measure what it costs the business. It was built to mirror the workflow of an operations data analyst — recurring SQL reporting, defect and root-cause investigation, and clear visualization for decision-makers.

## Key Findings

| Metric | Result |
|---|---|
| Orders analyzed | 96,468 delivered orders (2016–2018) |
| On-time delivery rate | 91.9% (7,824 orders delivered late) |
| Review-score impact of lateness | 4.29 stars on-time vs 2.57 stars late (a 1.7-star decline) |
| Worst-performing lanes | South to Northeast (15.3% late), Southeast to Northeast (14.4% late) |
| Concentration of delays | Southeast and Northeast destinations account for ~79% of all late orders |
| Highest-defect categories | Electronics (9.9%), Baby (9.3%), Office Furniture (9.2%) |

**Recommendation:** Concentrate carrier-capacity planning and delivery-estimate recalibration on the Northeast and North inbound lanes. These represent a small, well-defined set of routes where intervention would improve both the on-time rate and customer satisfaction most effectively.

## Dashboards

**1. Executive Scorecard.** Five headline KPIs — on-time rate, average delivery days, average gap against the customer estimate, average review score, and gross merchandise value — alongside a monthly on-time trend with a 90% target reference line.

**2. Root Cause Analysis.** Late rate by delivery route, colored by destination region, presented next to the relationship between lateness and review score so the operational driver and its consequence appear together.

**3. Key Insights and Recommendations.** A concise written summary of the findings and the recommended course of action for leadership.

**4. Operational Deep Dive.** A choropleth map of Brazil shaded by state-level late rate, paired with a late-rate breakdown by product category.

## Repository Structure

```
ecommerce-delivery-defect-analysis/
├── README.md
├── requirements.txt
├── LICENSE
├── .gitignore
├── data/
│   ├── README.md                          Data sourcing instructions
│   └── analysis_delivery_performance.csv   Engineered table used by Tableau
├── sql/
│   ├── 01_schema.sql                       PostgreSQL schema and load commands
│   ├── 02_region_mapping.sql               State-to-region lookup
│   ├── 03_core_view.sql                    Core analytical view
│   └── 04_kpi_reports.sql                  Recurring KPI and root-cause queries
├── python/
│   └── build_analysis_table.py             Joins raw tables into the analysis CSV
└── tableau/
    ├── TABLEAU_STEP_BY_STEP.md             Detailed build guide
    ├── TABLEAU_BUILD_SPEC.md               Field and sheet reference
    └── screenshots/                        Dashboard images
```

## Getting Started

**1. Obtain the data.** Download the dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and place the CSV files in the `data/` directory. The raw files are excluded from version control; see `data/README.md` for the full list.

**2. Build the analysis table.**
```bash
pip install -r requirements.txt
python python/build_analysis_table.py
```
This produces `data/analysis_delivery_performance.csv`, the single table that powers the dashboards.

**3. Load the SQL warehouse (optional).**
```bash
psql -d olist -f sql/01_schema.sql
psql -d olist -f sql/02_region_mapping.sql
psql -d olist -f sql/03_core_view.sql
psql -d olist -f sql/04_kpi_reports.sql
```

**4. Build the report.** Connect Tableau to `data/analysis_delivery_performance.csv` and follow `tableau/TABLEAU_STEP_BY_STEP.md`.

## Methodology

The analysis is limited to delivered orders, the population for which on-time performance is defined. An order is classified as late when the actual delivery date falls after the estimated delivery date provided to the customer. A route is defined as the seller's macro-region paired with the customer's macro-region. Where an order contains multiple items, the first item determines the order-level seller and category, while price and freight are summed across all items.

## Data Source

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — anonymized records of real orders placed through a Brazilian e-commerce platform between 2016 and 2018, released publicly on Kaggle under the CC BY-NC-SA 4.0 license. The dataset is used here for analysis only.
