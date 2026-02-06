CREATE SCHEMA IF NOT EXISTS hpce;

-- 1) Persisted decision engine output (new table)
DROP TABLE IF EXISTS hpce.decision_engine_output_daily;
CREATE TABLE hpce.decision_engine_output_daily (
  customer_id           text NOT NULL,
  feature_date          date NOT NULL,

  churn_prob            double precision NOT NULL,
  risk_band             text NOT NULL,
  action                text NOT NULL,
  priority_score        double precision NOT NULL,

  -- event enrichment (synthetic)
  views_7               integer,
  views_30              integer,
  searches_30           integer,
  carts_30              integer,
  events_30             integer,
  cart_to_view_rate_30  double precision,
  event_recency_days    integer,

  created_at            timestamp NOT NULL DEFAULT now(),
  PRIMARY KEY (customer_id, feature_date)
);

CREATE INDEX IF NOT EXISTS idx_deo_date ON hpce.decision_engine_output_daily(feature_date);
CREATE INDEX IF NOT EXISTS idx_deo_risk ON hpce.decision_engine_output_daily(risk_band);