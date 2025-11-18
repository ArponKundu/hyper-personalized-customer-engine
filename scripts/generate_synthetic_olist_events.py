import os
import math
import uuid
import numpy as np
import pandas as pd
from datetime import timedelta
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

TARGET_EVENTS = 10_000_000  # approx

def fetch_df(sql: str) -> pd.DataFrame:
    with engine.connect() as conn:
        return pd.read_sql(text(sql), conn)

def load_base_data():
    # Orders + customers (only delivered / non-canceled if you prefer)
    orders = fetch_df("""
        SELECT
            o.order_id,
            o.customer_id,
            o.order_status,
            o.order_purchase_ts
        FROM hpce.olist_orders o
        WHERE o.order_purchase_ts IS NOT NULL
          AND o.order_status NOT IN ('canceled', 'unavailable')
    """)

    # ✅ Ensure order_purchase_ts is naive datetime (no timezone)
    col = "order_purchase_ts"
    if str(orders[col].dtype).startswith("datetime64[ns,"):
        # already tz-aware -> drop timezone
        orders[col] = orders[col].dt.tz_convert(None)
    else:
        # string or object -> parse as UTC then drop tz
        orders[col] = (
            pd.to_datetime(orders[col], utc=True, errors="coerce")
              .dt.tz_convert(None)
        )

    # Order items with products
    items = fetch_df("""
        SELECT
            order_id,
            product_id
        FROM hpce.olist_order_items
    """)

    order_items = orders.merge(items, on="order_id", how="inner")

    # All customers & products (for browsing-only sessions)
    customers = fetch_df("SELECT DISTINCT customer_id FROM hpce.olist_customers")
    products  = fetch_df("SELECT DISTINCT product_id   FROM hpce.olist_products")

    return orders, order_items, customers, products


def generate_events_for_purchase(row, rng):
    """
    Given a single purchased (customer_id, product_id, order_purchase_ts),
    generate:
      - several view events before purchase
      - some cart events
      - one purchase event
    """
    events = []
    base_time = row["order_purchase_ts"]
    customer_id = row["customer_id"]
    product_id = row["product_id"]

    # synthetic session id
    session_id = f"sess_{uuid.uuid4().hex[:16]}"

    # how many views & carts
    n_views = rng.integers(2, 8)        # 2 to 7 views
    n_carts = rng.integers(1, 3)        # 1 or 2 cart events

    # Views: from 3 hours to 10 minutes before purchase
    for i in range(n_views):
        minutes_before = rng.integers(10, 180)
        t = base_time - timedelta(minutes=int(minutes_before))
        events.append({
            "event_time": t,
            "customer_id": customer_id,
            "product_id": product_id,
            "event_type": "view",
            "session_id": session_id,
        })

    # Carts: from 30 minutes to 2 minutes before purchase
    for i in range(n_carts):
        minutes_before = rng.integers(2, 30)
        t = base_time - timedelta(minutes=int(minutes_before))
        events.append({
            "event_time": t,
            "customer_id": customer_id,
            "product_id": product_id,
            "event_type": "cart",
            "session_id": session_id,
        })

    # Purchase event at purchase time
    events.append({
        "event_time": base_time,
        "customer_id": customer_id,
        "product_id": product_id,
        "event_type": "purchase",
        "session_id": session_id,
    })

    return events

def generate_browsing_only_sessions(customers, products, n_sessions, rng):
    """
    Generate sessions where the user browses (views / carts) but does not purchase.
    """
    events = []
    customer_ids = customers["customer_id"].values
    product_ids = products["product_id"].values

    for _ in range(n_sessions):
        cid = rng.choice(customer_ids)
        pid = rng.choice(product_ids)
        # random date in Olist range
        date = pd.to_datetime("2017-01-01") + pd.to_timedelta(
            int(rng.integers(0, 600)), unit="D"
        )
        session_id = f"sess_{uuid.uuid4().hex[:16]}"

        n_views = rng.integers(1, 10)
        n_carts = rng.integers(0, 2)  # some sessions with cart, no purchase

        for i in range(n_views):
            t = date + timedelta(minutes=int(rng.integers(0, 180)))
            events.append({
                "event_time": t,
                "customer_id": cid,
                "product_id": pid,
                "event_type": "view",
                "session_id": session_id,
            })

        for i in range(n_carts):
            t = date + timedelta(minutes=int(rng.integers(10, 200)))
            events.append({
                "event_time": t,
                "customer_id": cid,
                "product_id": pid,
                "event_type": "cart",
                "session_id": session_id,
            })

    return events

def main():
    rng = np.random.default_rng(42)

    print("Loading base data from DB...")
    orders, order_items, customers, products = load_base_data()
    print("orders:", orders.shape, "order_items:", order_items.shape)

    # 1) Generate events linked to real purchases
    purchase_events = []
    print("Generating events for purchased items...")
    for _, row in order_items.iterrows():
        purchase_events.extend(generate_events_for_purchase(row, rng))

    events_df = pd.DataFrame(purchase_events)
    print("Events after purchase-based generation:", events_df.shape)

    # 2) Add browsing-only sessions until we reach ~10M events
    current_n = len(events_df)
    if current_n < TARGET_EVENTS:
        remaining = TARGET_EVENTS - current_n
        # assume ~30 events per browsing-only session on average
        approx_events_per_session = 30
        n_sessions = math.ceil(remaining / approx_events_per_session)
        print(f"Generating ~{n_sessions} browsing-only sessions...")

        browse_events = generate_browsing_only_sessions(customers, products, n_sessions, rng)
        browse_df = pd.DataFrame(browse_events)
        events_df = pd.concat([events_df, browse_df], ignore_index=True)

    # Final tidy up
    events_df["event_time"] = pd.to_datetime(events_df["event_time"])
    events_df = events_df.sort_values("event_time").reset_index(drop=True)

    print("Final events shape:", events_df.shape)

    # Save to CSV
    output_path = "synthetic_olist_events_10M.csv"
    print(f"Saving to {output_path} ...")
    events_df.to_csv(output_path, index=False)
    print("Done.")

if __name__ == "__main__":
    main()
