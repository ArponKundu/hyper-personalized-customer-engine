CREATE SCHEMA IF NOT EXISTS hpce;

DROP TABLE IF EXISTS hpce.synthetic_events_raw;

CREATE TABLE hpce.synthetic_events_raw (
  event_id      bigserial PRIMARY KEY,
  customer_id   text NOT NULL,
  event_time    timestamp NOT NULL,
  event_type    text NOT NULL,
  session_id    text NULL,
  source        text NOT NULL DEFAULT 'synthetic',
  meta          jsonb NULL
);

CREATE INDEX IF NOT EXISTS idx_ser_customer_time
ON hpce.synthetic_events_raw (customer_id, event_time);
