DROP TABLE IF EXISTS hpce.customer_map_canonical;

CREATE TABLE hpce.customer_map_canonical AS
WITH last_purchase AS (
  SELECT
    o.customer_id,
    MAX(o.order_purchase_ts) AS last_ts
  FROM hpce.olist_orders o
  WHERE o.order_status NOT IN ('canceled','unavailable')
    AND o.order_purchase_ts IS NOT NULL
  GROUP BY 1
),
ranked AS (
  SELECT
    m.customer_unique_id,
    m.customer_id,
    COALESCE(lp.last_ts, TIMESTAMP '1900-01-01') AS last_ts,
    ROW_NUMBER() OVER (
      PARTITION BY m.customer_unique_id
      ORDER BY COALESCE(lp.last_ts, TIMESTAMP '1900-01-01') DESC, m.customer_id
    ) AS rn
  FROM hpce.customer_map m
  LEFT JOIN last_purchase lp
    ON lp.customer_id = m.customer_id
)
SELECT customer_unique_id, customer_id
FROM ranked
WHERE rn = 1;


CREATE UNIQUE INDEX IF NOT EXISTS ux_customer_map_canonical_unique
ON hpce.customer_map_canonical(customer_unique_id);

CREATE INDEX IF NOT EXISTS ix_customer_map_canonical_customer
ON hpce.customer_map_canonical(customer_id);
