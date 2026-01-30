DROP TABLE IF EXISTS hpce.snapshot_calendar;

CREATE TABLE hpce.snapshot_calendar AS
SELECT DISTINCT feature_date AS snapshot_date
FROM hpce.customer_features_daily;

CREATE UNIQUE INDEX IF NOT EXISTS uq_snapshot_calendar
ON hpce.snapshot_calendar(snapshot_date);
