# Tableau Build Spec — Delivery Performance & Late-Delivery Root Cause

**Data source:** `data/analysis_delivery_performance.csv` — 96,468 delivered orders (real Olist data, Sep 2016–Aug 2018), one row per order, 23 fields

**Headline numbers (real data) to anchor the dashboards:**
- On-time rate: **91.9%** (7,824 late orders)
- Avg delivery: **12.6 days**; avg ~11 days ahead of the customer estimate
- Late orders score **2.57 stars** vs **4.29** for on-time — a **1.7-star** hit
- Worst lanes are deliveries **into the Northeast/North** (South→Northeast 15%, Southeast→Northeast 14%) vs the Southeast→Southeast core lane at 8%
- Southeast + Northeast destinations carry **~79% of all late deliveries**

**Audience:** Operations leadership (status-at-a-glance + drill-down to root cause)
**Story arc:** *What* is our delivery health → *Where* is it breaking → *Why* → *What it costs us.*

---

## Connect & data types

Connect to the CSV (Text File). Set these types in the Data Source tab:

| Field | Type | Role |
|---|---|---|
| `purchase_date` | Date | Dimension |
| `purchase_month` | String (or Date `YYYY-MM`) | Dimension |
| `customer_region`, `seller_region`, `route`, `customer_state`, `seller_state` | String | Dimension |
| `product_category_name`, `purchase_dow` | String | Dimension |
| `is_late`, `is_cross_region` | Number (whole) → treat as Measure for averaging | Measure |
| `delivery_days`, `delivery_gap_days`, `estimated_days`, `freight_ratio`, `order_price`, `order_freight`, `review_score` | Number (decimal) | Measure |

### Calculated fields (create these once)
```
On-Time Rate        = 1 - AVG([Is Late])
Late Rate           = AVG([Is Late])
Avg Delivery Days   = AVG([Delivery Days])
Avg Gap vs Estimate = AVG([Delivery Gap Days])
Low Review Flag     = IF [Review Score] <= 2 THEN 1 ELSE 0 END
1-2 Star Rate       = AVG([Low Review Flag])
GMV                 = SUM([Order Price])
```

---

## Dashboard 1 — Executive Delivery Scorecard

Purpose: the weekly leadership glance. No drill-down, just health.

1. **KPI tiles (BANs)** — 5 text sheets, large number:
   - On-Time Rate (format %) — target reference line at 90%
   - Avg Delivery Days
   - Avg Gap vs Estimate (negative = ahead of promise — good)
   - Avg Review Score
   - GMV
2. **On-Time Trend** — `purchase_month` (Columns) × On-Time Rate (Rows), line. Add a constant 90% reference line; color the line red below target.
3. **Volume bars (dual axis)** — order count per month behind the trend line for context.
4. **Region tile map** — `customer_region`, color = Late Rate (sequential red). One glance shows the worst region.

Layout: tiles across the top, trend chart center, map right.

---

## Dashboard 2 — Root-Cause Drill-Down (the centerpiece)

Purpose: answer *why* deliveries are late. This is the Dive Deep dashboard.

1. **Route late-rate bar chart** — `route` (Rows) × Late Rate (Columns), sorted descending, filtered to routes with ≥300 orders (add a data-source filter `COUNT(order_id) >= 300`). Color by `customer_region` to surface the pattern. *On real data this makes the "deliveries into the Northeast/North run late" story jump out — South→Northeast and Southeast→Northeast top the list.*
2. **Destination region late rate** — `customer_region` × Late Rate bar. Headline: deliveries into the **Northeast and North** run materially hotter than the Southeast core.
3. **Category late-rate** — `product_category_name` × Late Rate, top 10, ≥100 orders.
4. **Pareto of delays** — `customer_region` sorted by late-order count, with a secondary-axis running-total line hitting **~79%** by the second region (Southeast then Northeast). (Running total via Quick Table Calc on COUNT where `is_late=1`.)

Add a **`purchase_month` range filter** and **`customer_region` filter**, applied to all worksheets on this dashboard.

---

## Dashboard 3 — Business Impact

Purpose: translate the defect into money/CX language. Deliver Results.

1. **Lateness → review score** — `is_late` (On-Time / Late) × Avg Review Score bar. Annotate the **1.7-star drop** (4.29 → 2.57).
2. **1–2 star rate** — `is_late` × 1-2 Star Rate. Late orders draw far more 1–2 star reviews.
3. **Scatter: delivery gap vs review** — bin `delivery_gap_days`, plot avg review per bin → shows the cliff once you cross the estimate.
4. **Freight ratio context** — late vs on-time avg `freight_ratio`, secondary signal.

End with a **text annotation** stating the recommendation: prioritize carrier capacity and delivery-estimate recalibration on lanes **into the Northeast and North** (South→Northeast, Southeast→Northeast, Southeast→North), since Southeast + Northeast destinations carry ~79% of all delays.

---

## Interactivity to wire up

- Dashboard actions: clicking a `route` bar (D2) filters D3 to that route.
- `purchase_month` as a global filter across all three dashboards (right-click → Apply to Worksheets → All Using This Data Source).
- Tooltips: on the route bar, show orders, late rate, avg delivery days, avg review.

---

## Publishing (mirrors the JD)

Publish to **Tableau Public** for your portfolio link. In your resume/LinkedIn, frame it as "published an operational delivery dashboard" — which maps directly to the JD's *"publishing via QuickSight, email, or Excel."* Note in interviews that QuickSight is Amazon's internal equivalent and the same dashboard concepts transfer 1:1.
