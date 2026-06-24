"""
Olist Delivery Performance - Feature Engineering
-------------------------------------------------
Joins the raw Olist tables into a single analysis-ready table for Tableau,
engineering the delivery KPIs the analysis depends on:
  - actual vs estimated delivery gap (the core "defect" signal)
  - on-time / late flag
  - delivery & approval cycle times
  - distance proxy (same-region vs cross-region)
  - freight ratio
Run:  python build_analysis_table.py
Input:  ../data/olist_*.csv   (download real data from Kaggle: olistbr/brazilian-ecommerce)
Output: ../data/analysis_delivery_performance.csv
"""
import pandas as pd
import numpy as np
from pathlib import Path

DATA = Path(__file__).resolve().parent.parent / "data"

def load(name):
    return pd.read_csv(DATA / name)

orders   = load("olist_orders_dataset.csv")
items    = load("olist_order_items_dataset.csv")
cust     = load("olist_customers_dataset.csv")
sellers  = load("olist_sellers_dataset.csv")
products = load("olist_products_dataset.csv")
pays     = load("olist_order_payments_dataset.csv")
reviews  = load("olist_order_reviews_dataset.csv")
cat_tr   = load("product_category_name_translation.csv")

# map Portuguese category names -> English for readability
products = products.merge(cat_tr, on="product_category_name", how="left")
products["product_category_name"] = (
    products["product_category_name_english"].fillna(products["product_category_name"])
)

# --- parse timestamps ---
ts_cols = ["order_purchase_timestamp","order_approved_at",
           "order_delivered_carrier_date","order_delivered_customer_date",
           "order_estimated_delivery_date"]
for c in ts_cols:
    orders[c] = pd.to_datetime(orders[c], errors="coerce")

# --- focus on delivered orders for delivery-performance analysis ---
d = orders[orders["order_status"] == "delivered"].copy()

# --- core engineered KPIs ---
d["delivery_days"]      = (d["order_delivered_customer_date"] - d["order_purchase_timestamp"]).dt.total_seconds()/86400
d["estimated_days"]     = (d["order_estimated_delivery_date"] - d["order_purchase_timestamp"]).dt.total_seconds()/86400
d["delivery_gap_days"]  = (d["order_delivered_customer_date"] - d["order_estimated_delivery_date"]).dt.total_seconds()/86400
d["is_late"]            = (d["delivery_gap_days"] > 0).astype(int)
d["approval_hours"]     = (d["order_approved_at"] - d["order_purchase_timestamp"]).dt.total_seconds()/3600
d["carrier_handoff_days"]=(d["order_delivered_carrier_date"] - d["order_approved_at"]).dt.total_seconds()/86400

# time dimensions
d["purchase_date"]   = d["order_purchase_timestamp"].dt.date
d["purchase_month"]  = d["order_purchase_timestamp"].dt.to_period("M").astype(str)
d["purchase_year"]   = d["order_purchase_timestamp"].dt.year
d["purchase_dow"]    = d["order_purchase_timestamp"].dt.day_name()

# --- geography: customer + seller state, region, cross-region flag ---
region_map = {"SP":"Southeast","RJ":"Southeast","MG":"Southeast","ES":"Southeast",
              "RS":"South","PR":"South","SC":"South",
              "BA":"Northeast","PE":"Northeast","CE":"Northeast","MA":"Northeast",
              "PB":"Northeast","RN":"Northeast","AL":"Northeast","PI":"Northeast",
              "DF":"Central-West","GO":"Central-West","MT":"Central-West","MS":"Central-West",
              "PA":"North"}

d = d.merge(cust[["customer_id","customer_state","customer_city"]], on="customer_id", how="left")

# one seller/product per order (take first item) for order-level geography + category
items_first = items.sort_values("order_item_id").groupby("order_id").first().reset_index()
items_first = items_first.merge(sellers[["seller_id","seller_state"]], on="seller_id", how="left")
items_first = items_first.merge(products[["product_id","product_category_name"]], on="product_id", how="left")

# order-level freight + price totals
agg = items.groupby("order_id").agg(
    order_price=("price","sum"),
    order_freight=("freight_value","sum"),
    n_items=("order_item_id","count")
).reset_index()

d = d.merge(items_first[["order_id","seller_state","product_category_name"]], on="order_id", how="left")
d = d.merge(agg, on="order_id", how="left")

d["customer_region"] = d["customer_state"].map(region_map).fillna("Other")
d["seller_region"]   = d["seller_state"].map(region_map).fillna("Other")
d["is_cross_region"] = (d["customer_region"] != d["seller_region"]).astype(int)
d["route"]           = d["seller_region"] + " \u2192 " + d["customer_region"]
d["freight_ratio"]   = d["order_freight"] / (d["order_price"] + d["order_freight"])

# --- reviews ---
rev = reviews.groupby("order_id")["review_score"].mean().reset_index()
d = d.merge(rev, on="order_id", how="left")

# --- final cleanup: drop impossible rows ---
d = d[(d["delivery_days"] > 0) & (d["delivery_days"] < 200)].copy()

out_cols = ["order_id","purchase_date","purchase_month","purchase_year","purchase_dow",
            "customer_state","customer_region","seller_state","seller_region","route",
            "is_cross_region","product_category_name",
            "n_items","order_price","order_freight","freight_ratio",
            "delivery_days","estimated_days","delivery_gap_days","is_late",
            "approval_hours","carrier_handoff_days","review_score"]
out = d[out_cols].copy()

OUT = DATA / "analysis_delivery_performance.csv"
out.to_csv(OUT, index=False)
print(f"Wrote {len(out)} rows -> {OUT}")
print(f"On-time rate: {1 - out['is_late'].mean():.1%}")
print(f"Avg delivery days: {out['delivery_days'].mean():.1f}")
print(f"Avg gap (actual - estimated): {out['delivery_gap_days'].mean():.1f} days")
