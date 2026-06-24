-- ============================================================
-- Core analytical view: one row per delivered order with KPIs
-- This is the "single source of truth" the recurring reports
-- and the Tableau extract are built on.
-- PostgreSQL syntax.
-- ============================================================
CREATE OR REPLACE VIEW v_delivery_performance AS
WITH order_geo AS (
    -- first item per order gives us seller + product (order-level proxy)
    SELECT DISTINCT ON (oi.order_id)
        oi.order_id, oi.seller_id, oi.product_id
    FROM order_items oi
    ORDER BY oi.order_id, oi.order_item_id
),
order_totals AS (
    SELECT order_id,
           SUM(price)         AS order_price,
           SUM(freight_value) AS order_freight,
           COUNT(*)           AS n_items
    FROM order_items
    GROUP BY order_id
),
order_review AS (
    SELECT order_id, AVG(review_score)::NUMERIC(4,2) AS review_score
    FROM order_reviews
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.order_purchase_timestamp::date                          AS purchase_date,
    to_char(o.order_purchase_timestamp,'YYYY-MM')             AS purchase_month,
    c.customer_state,
    cr.region                                                 AS customer_region,
    s.seller_state,
    sr.region                                                 AS seller_region,
    sr.region || ' -> ' || cr.region                          AS route,
    CASE WHEN cr.region <> sr.region THEN 1 ELSE 0 END        AS is_cross_region,
    p.product_category_name,
    t.n_items, t.order_price, t.order_freight,
    ROUND(t.order_freight / NULLIF(t.order_price + t.order_freight,0), 3) AS freight_ratio,
    -- KPIs
    EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp))/86400      AS delivery_days,
    EXTRACT(EPOCH FROM (o.order_estimated_delivery_date - o.order_purchase_timestamp))/86400      AS estimated_days,
    EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date))/86400 AS delivery_gap_days,
    CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
         THEN 1 ELSE 0 END                                    AS is_late,
    rv.review_score
FROM orders o
JOIN customers c       ON o.customer_id = c.customer_id
JOIN order_geo g       ON o.order_id    = g.order_id
JOIN sellers s         ON g.seller_id   = s.seller_id
JOIN products p        ON g.product_id  = p.product_id
JOIN order_totals t    ON o.order_id    = t.order_id
LEFT JOIN order_review rv ON o.order_id = rv.order_id
LEFT JOIN state_region cr ON c.customer_state = cr.uf
LEFT JOIN state_region sr ON s.seller_state   = sr.uf
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;
