SELECT extname
FROM pg_extension
WHERE extname = 'timescaledb';


CREATE EXTENSION IF NOT EXISTS timescaledb;


SELECT create_hypertable(
  'hpce.customer_features_daily',
  'feature_date',
  if_not_exists => TRUE,
  migrate_data => TRUE
);


SELECT create_hypertable(
  'hpce.rees46_events',
  'event_time',
  if_not_exists => TRUE,
  migrate_data => TRUE
);



ALTER TABLE hpce.customer_features_daily SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'customer_id'
);

SELECT add_compression_policy('hpce.customer_features_daily', INTERVAL '30 days');


-- Daily feature store access pattern: customer + date
CREATE INDEX IF NOT EXISTS idx_cfd_customer_date
ON hpce.customer_features_daily (customer_id, feature_date);

-- For date filtering alone
CREATE INDEX IF NOT EXISTS idx_cfd_feature_date
ON hpce.customer_features_daily (feature_date);

-- Events: customer + time lookups
CREATE INDEX IF NOT EXISTS idx_events_customer_time
ON hpce.rees46_events (customer_id, event_time);

-- Events: time filtering
CREATE INDEX IF NOT EXISTS idx_events_time
ON hpce.rees46_events (event_time);

-- Intervention logs access pattern
CREATE INDEX IF NOT EXISTS idx_logs_customer_time
ON hpce.intervention_logs (customer_id, action_ts);

SELECT
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'hpce'
ORDER BY tablename, indexname;
