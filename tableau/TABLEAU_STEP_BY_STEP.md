# Tableau Build Guide

This walks you from zero to a **published, shareable Tableau dashboard** using
`data/analysis_delivery_performance.csv`. No prior Tableau experience assumed. Budget
about 2–3 hours the first time.

> **Which Tableau?** Use **Tableau Public** — it's **free** and gives you a public link you
> can put on your resume/LinkedIn/GitHub. Download: https://public.tableau.com/app/discover
> (Tableau Desktop works identically but costs money and doesn't give a free public link.)

---

## PART 0 — Setup (10 min)

1. Download & install **Tableau Public Desktop** from the link above.
2. Create a free account at https://public.tableau.com (you'll need it to publish).
3. Make sure you've run `python/build_analysis_table.py` so
   `data/analysis_delivery_performance.csv` exists.

---

## PART 1 — Connect the data (5 min)

1. Open Tableau Public. On the left under **Connect → To a File**, click **Text file**.
2. Select `analysis_delivery_performance.csv`. You'll land on the **Data Source** tab.
3. You'll see the data preview. Check the little icons above each column header — they show
   the data type. Fix any that are wrong by clicking the icon:

| Field | Should be | Icon |
|---|---|---|
| `purchase_date` | Date | calendar |
| `purchase_month` | Date or String | calendar / Abc |
| `is_late`, `is_cross_region` | Number (whole) | # |
| `delivery_days`, `delivery_gap_days`, `freight_ratio`, `order_price`, `order_freight`, `review_score` | Number (decimal) | # |
| everything else (`route`, `customer_region`, `product_category_name`, …) | String | Abc |

4. Bottom-left, click the **Sheet 1** tab to start building.

> **Dimensions vs Measures:** Tableau auto-sorts fields into **Dimensions** (categories —
> blue, things you slice *by*) and **Measures** (numbers — green, things you aggregate).
> `is_late` may land in Dimensions; that's fine — we'll average it via a calculated field.

---

## PART 2 — Create calculated fields (10 min)

Do this once; all sheets reuse them. **Analysis menu → Create Calculated Field** for each.

| Name | Formula |
|---|---|
| `On-Time Rate` | `1 - AVG([Is Late])` |
| `Late Rate` | `AVG([Is Late])` |
| `Avg Delivery Days` | `AVG([Delivery Days])` |
| `Avg Gap vs Estimate` | `AVG([Delivery Gap Days])` |
| `Low Review Flag` | `IF [Review Score] <= 2 THEN 1 ELSE 0 END` |
| `1-2 Star Rate` | `AVG([Low Review Flag])` |
| `GMV` | `SUM([Order Price])` |

For the two **rate** fields, set the format to percentage: right-click the field in the
left panel → **Default Properties → Number Format → Percentage** (1 decimal place).

---

## PART 3 — Build the worksheets

You'll build **9 sheets**, then arrange them into 3 dashboards. Each sheet = one tab at the
bottom (click the new-sheet icon to add). Name each tab as you go (double-click the tab).

### Sheet 1 — "KPI: On-Time Rate" (a big-number tile)
1. Double-click `On-Time Rate` → it appears on the **Text** card / as a number.
2. From the top menu, set the mark type to **Text** (Marks card dropdown).
3. Make it big: click **Text** on the Marks card → resize font to ~40pt.
4. Repeat this whole sheet 4 more times for: `Avg Delivery Days`, `Avg Gap vs Estimate`,
   `AVG(Review Score)`, `GMV`. (Five tiny sheets total — name them KPI: ….)

> Tip: these one-number sheets are your dashboard's "scorecard" across the top.

### Sheet 6 — "On-Time Trend"
1. Drag `Purchase Month` to **Columns** (if it's a date, right-click the pill → choose
   **Month** continuous, the green version, so it's a smooth line).
2. Drag `On-Time Rate` to **Rows**. You get a line.
3. Add a target: right-click the vertical axis → **Add Reference Line** → Constant **0.90**,
   label "Target 90%".
4. (Optional) Drag `Order Id` to **Rows** as a second axis → set to **Count** → make it a
   **dual axis** (right-click the second pill → Dual Axis) → set that mark to **Bar** for
   volume context.

### Sheet 7 — "Late Rate by Route" (the centerpiece)
1. Drag `Route` to **Rows**.
2. Drag `Late Rate` to **Columns**. Bars appear.
3. Sort descending: click the sort icon on the `Route` header.
4. Filter to meaningful routes: drag `Order Id` to **Filters** → **Count** → "At least" →
   **300**. (Removes tiny routes that look extreme on noise.)
5. Drag `Customer Region` to **Color** so the Northeast/North pattern pops.
6. This is the visual that shows lateness is a *destination* problem — your headline insight.

### Sheet 8 — "Lateness vs Review Score" (business impact)
1. Drag `Is Late` to **Columns** (it acts as a 0/1 category — right-click → **Discrete** if
   needed so you get two bars).
2. Drag `Review Score` to **Rows**, set to **AVG** (click the pill → Measure → Average).
3. Edit the `Is Late` aliases to read nicely: right-click the field → **Aliases** → 0 =
   "On-Time", 1 = "Late".
4. Drag `AVG(Review Score)` to **Label** so the 4.29 vs 2.57 shows on the bars.

### Sheet 9 — "Delay Pareto by Region"
1. Drag `Customer Region` to **Columns**.
2. Drag `Order Id` to **Rows** → set to **Count**.
3. Add a filter: `Is Late` = 1 (drag to Filters, keep only True/1).
4. Sort descending. Then add running total: click the COUNT pill → **Quick Table
   Calculation → Running Total**, and duplicate as a line on a dual axis to show the
   cumulative % climbing past ~79% by the second bar.

---

## PART 4 — Assemble the dashboards (30 min)

Click the **New Dashboard** icon (next to new-sheet, bottom bar). Set **Size → Automatic**
or a fixed 1200×800.

### Dashboard 1 — "Executive Scorecard"
- Drag the 5 KPI sheets across the top in a row (use a **Horizontal** layout container).
- Drag "On-Time Trend" into the center/large area.
- Title it. This is the leadership glance.

### Dashboard 2 — "Root-Cause Drill-Down"
- Drag "Late Rate by Route" large on the left.
- "Delay Pareto by Region" on the right.
- Add `Purchase Month` and `Customer Region` as filters (on a sheet, right-click the field →
  **Show Filter**), then make them global: filter dropdown → **Apply to Worksheets → All
  Using This Data Source**.

### Dashboard 3 — "Business Impact"
- "Lateness vs Review Score" as the hero.
- Add a **Text** object with your recommendation (the Northeast/North lanes carry ~79% of
  delays; prioritize carrier capacity + estimate recalibration there).

### Add interactivity (the "wow")
- **Dashboard menu → Actions → Add Action → Filter.** Source = Dashboard 2's route chart,
  target = the other sheets. Now clicking a route filters everything to that route.

---

## PART 5 — Polish (20 min)

- **Titles & captions:** every sheet and dashboard gets a clear title.
- **Color:** use one consistent accent (Tableau's "Orange-Blue Diverging" reads well for
  rates). Red = bad (high late rate), green/blue = good.
- **Tooltips:** hover a mark → edit the tooltip to read like a sentence
  ("{Route}: {Late Rate} late across {COUNT(Order Id)} orders, avg review {AVG(Review Score)}").
- **Remove clutter:** hide gridlines you don't need (Format → Lines).
- **Number formatting:** rates as %, GMV as currency with thousands separators.

---

## PART 6 — Publish & get your shareable link (10 min)

1. **File → Save to Tableau Public As…** → sign in → name it
   *"Olist Delivery Performance & Root-Cause Analysis."*
2. It opens in your browser. Copy the URL — that's your **portfolio link**.
3. On the web view, set a good **thumbnail** (the dashboard you want shown first).
4. Paste the link into:
   - the main `README.md` ("🔗 Live dashboard")
   - your resume project entry
   - your LinkedIn "Projects" / "Featured" section

### Screenshots for GitHub
- In the browser view (or Desktop), take a clean PNG of each dashboard.
- Save them as `tableau/screenshots/01_executive_scorecard.png`,
  `02_root_cause.png`, `03_business_impact.png`.
- The README already references those paths, so they'll render automatically once pushed.

---

## Completion Checklist

You should now have:
- [ ] A published Tableau Public dashboard with a public URL
- [ ] 3 dashboards: scorecard, root-cause, impact
- [ ] Click-to-filter interactivity
- [ ] Screenshots in `tableau/screenshots/`
- [ ] The link pasted into README + resume + LinkedIn

If something doesn't match the expected numbers, re-run `build_analysis_table.py` and
reconnect — the CSV is the single source of truth.
