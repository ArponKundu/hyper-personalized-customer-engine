CREATE TABLE IF NOT EXISTS hpce.intervention_logs (
    intervention_id      BIGSERIAL PRIMARY KEY,
    run_id               TEXT NOT NULL,
    action_ts            TIMESTAMP NOT NULL DEFAULT NOW(),

    customer_id          TEXT NOT NULL,

    segment_label        TEXT,
    recency_days         INTEGER,

    churn_probability    DOUBLE PRECISION,

    recommended_action   TEXT NOT NULL,
    action_reason        TEXT NOT NULL,

    action_channel       TEXT NOT NULL,
    action_priority      INTEGER NOT NULL,

    model_version        TEXT,
    notes                TEXT
);

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_intervention_logs_customer ON hpce.intervention_logs(customer_id);
CREATE INDEX IF NOT EXISTS idx_intervention_logs_run      ON hpce.intervention_logs(run_id);
CREATE INDEX IF NOT EXISTS idx_intervention_logs_actionts ON hpce.intervention_logs(action_ts);
