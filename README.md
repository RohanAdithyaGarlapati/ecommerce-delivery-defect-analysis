# 📦 Olist Delivery Performance & Root Cause Analysis

> End-to-end analytics project: 96,468 real e-commerce orders → SQL warehouse → Python feature engineering → 4-dashboard Tableau story identifying where, why, and what late deliveries cost.

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-336791)
![Python](https://img.shields.io/badge/Python-pandas-3776AB)
![Tableau](https://img.shields.io/badge/Tableau-Public-E97627)
![Data](https://img.shields.io/badge/Data-96K%20Real%20Orders-blue)
![License](https://img.shields.io/badge/License-MIT-green)

**🔗 Live Dashboard:** [View on Tableau Public](https://public.tableau.com/app/profile/rohan.adithya.garlapati4858/viz/OlistDeliveryPerformanceRootCauseAnalysis)

---

## 🎯 Key Findings

| Metric | Result |
|---|---|
| Orders analyzed | **96,468 delivered orders** (real Olist data, 2016–2018) |
| On-time delivery rate | **91.9%** — 7,824 orders arrived late |
| Review score impact | Late orders: **2.57 ★** vs On-time: **4.29 ★** (−1.7 stars) |
| Worst delivery lanes | **South→Northeast 15.3%** late, **Southeast→Northeast 14.4%** late |
| Delay concentration | Southeast + Northeast destinations = **79% of all late orders** |
| Worst categories | Electronics (9.9%), Baby (9.3%), Office Furniture (9.2%) |

**Recommendation:** Prioritize carrier capacity and delivery-estimate recalibration on Northeast/North inbound lanes — the targeted set of routes where intervention moves both on-time rate and customer satisfaction the most.

---

## 📊 Dashboards

### Dashboard 1 — Executive Scorecard
5 KPI tiles (On-Time Rate, Avg Delivery Days, Avg Gap vs Estimate, Avg Review Score, GMV) + monthly on-time trend line with 90% target reference.

### Dashboard 2 — Root Cause Analysis
Late rate by route (colored by destination region) + Lateness vs Review Score impact bars side by side.

### Dashboard 3 — Key Insights & Recommendations
Text summary of findings and actionable recommendation for leadership.

### Dashboard 4 — Operational Deep Dive
Filled map of Brazil colored by state-level late rate + Late rate by product category bar chart.

---

## 🗂️ Repository Structure

```
olist-delivery-performance/
├── README.md
├── requirements.txt
├── LICENSE
├── .gitignore
├── data/
│   ├── README.md                        # Kaggle download instructions
│   └── analysis_delivery_performance.csv  # Engineered table (powers Tableau)
├── sql/
│   ├── 01_schema.sql                    # PostgreSQL schema + load commands
│   ├── 02_region_mapping.sql            # State → macro-region lookup
│   ├── 03_core_view.sql                 # v_delivery_performance view
│   └── 04_kpi_reports.sql              # 6 recurring KPI/root-cause reports
├── python/
│   └── build_analysis_table.py          # Joins raw tables → Tableau CSV
└── tableau/
    ├── TABLEAU_STEP_BY_STEP.md          # Beginner build guide
    ├── TABLEAU_BUILD_SPEC.md            # Field/sheet reference
    └── screenshots/                     # Dashboard screenshots
```

---

## 🚀 How to Run

**Step 1 — Get the data:**
Download 8 CSVs from [Kaggle: olistbr/brazilian-ecommerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) → place in `data/`

**Step 2 — Build analysis table:**
```bash
pip install -r requirements.txt
python python/build_analysis_table.py
```

**Step 3 — Load SQL warehouse (optional):**
```bash
psql -d olist -f sql/01_schema.sql
psql -d olist -f sql/02_region_mapping.sql
psql -d olist -f sql/03_core_view.sql
psql -d olist -f sql/04_kpi_reports.sql
```

**Step 4 — Open Tableau:**
Connect to `data/analysis_delivery_performance.csv` → follow `tableau/TABLEAU_STEP_BY_STEP.md`

---

## 📁 Data Source
[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — real orders from a Brazilian e-commerce company, released publicly on Kaggle under CC BY-NC-SA 4.0.
