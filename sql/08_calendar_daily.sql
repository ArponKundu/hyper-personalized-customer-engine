DROP TABLE IF EXISTS hpce.calendar_daily;

CREATE TABLE hpce.calendar_daily AS
WITH bounds AS (
  SELECT
    MIN(purchase_date) AS dmin,
    MAX(purchase_date) AS dmax
  FROM hpce.orders_valid
)
SELECT
  gs::date AS feature_date
FROM bounds,
     generate_series(bounds.dmin, bounds.dmax, interval '1 day') AS gs;

CREATE UNIQUE INDEX IF NOT EXISTS idx_calendar_daily_date
ON hpce.calendar_daily (feature_date);
