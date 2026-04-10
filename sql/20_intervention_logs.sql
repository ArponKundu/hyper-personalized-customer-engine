-- 2) Intervention logs (feedback-loop table)
DROP TABLE IF EXISTS hpce.intervention_logs;
CREATE TABLE hpce.intervention_logs (
  log_id               bigserial PRIMARY KEY,
  customer_id          text NOT NULL,
  intervention_date    date NOT NULL,
  feature_date         date NOT NULL,
  action               text NOT NULL,
  churn_prob           double precision NOT NULL,
  risk_band            text NOT NULL,
  priority_score       double precision NOT NULL,

  -- optional context columns (useful for analysis)
  events_30            integer,
  event_recency_days   integer,

  source               text NOT NULL DEFAULT 'decision_engine',
  created_at           timestamp NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_il_customer_date ON hpce.intervention_logs(customer_id, intervention_date);
CREATE INDEX IF NOT EXISTS idx_il_action ON hpce.intervention_logs(action);