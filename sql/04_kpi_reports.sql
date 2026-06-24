-- ============================================================
-- Recurring KPI / Root-Cause Reports
-- These are the "daily/weekly SQL reporting" deliverables.
-- Each block is a standalone query you can schedule or publish.
-- ============================================================

-- ---- REPORT 1: Executive KPI scorecard (single row) ----
SELECT
    COUNT(*)                                    AS delivered_orders,
    ROUND(AVG(1 - is_late)::numeric, 3)         AS on_time_rate,
    ROUND(AVG(delivery_days)::numeric, 1)       AS avg_delivery_days,
    ROUND(AVG(delivery_gap_days)::numeric, 1)   AS avg_gap_vs_estimate,
    ROUND(AVG(review_score)::numeric, 2)        AS avg_review_score,
    ROUND(SUM(order_price)::numeric, 0)         AS gmv
FROM v_delivery_performance;

-- ---- REPORT 2: Monthly on-time trend ----
SELECT purchase_month,
       COUNT(*)                              AS orders,
       ROUND(AVG(1 - is_late)::numeric, 3)   AS on_time_rate,
       ROUND(AVG(delivery_days)::numeric, 1) AS avg_delivery_days
FROM v_delivery_performance
GROUP BY purchase_month
ORDER BY purchase_month;

-- ---- REPORT 3: Root cause - late rate by route (the headline) ----
SELECT route,
       is_cross_region,
       COUNT(*)                            AS orders,
       ROUND(AVG(is_late)::numeric, 3)     AS late_rate,
       ROUND(AVG(delivery_days)::numeric,1) AS avg_delivery_days,
       ROUND(AVG(review_score)::numeric,2)  AS avg_review_score
FROM v_delivery_performance
GROUP BY route, is_cross_region
HAVING COUNT(*) >= 100
ORDER BY late_rate DESC;

-- ---- REPORT 4: Business impact - lateness vs review score ----
SELECT is_late,
       COUNT(*)                           AS orders,
       ROUND(AVG(review_score)::numeric,2) AS avg_review_score,
       ROUND(AVG(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END)::numeric,3) AS pct_1_2_star
FROM v_delivery_performance
GROUP BY is_late
ORDER BY is_late;

-- ---- REPORT 5: Pareto - which regions concentrate the delays ----
WITH late_orders AS (
    SELECT customer_region, COUNT(*) AS late_n
    FROM v_delivery_performance
    WHERE is_late = 1
    GROUP BY customer_region
)
SELECT customer_region,
       late_n,
       ROUND(100.0 * late_n / SUM(late_n) OVER (), 1) AS pct_of_late,
       ROUND(100.0 * SUM(late_n) OVER (ORDER BY late_n DESC)
                   / SUM(late_n) OVER (), 1)           AS cumulative_pct
FROM late_orders
ORDER BY late_n DESC;

-- ---- REPORT 6: Worst categories by late rate (min volume guard) ----
SELECT product_category_name,
       COUNT(*)                        AS orders,
       ROUND(AVG(is_late)::numeric,3)  AS late_rate,
       ROUND(AVG(review_score)::numeric,2) AS avg_review_score
FROM v_delivery_performance
GROUP BY product_category_name
HAVING COUNT(*) >= 100
ORDER BY late_rate DESC
LIMIT 10;
