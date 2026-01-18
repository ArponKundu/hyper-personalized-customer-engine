CREATE TABLE IF NOT EXISTS hpce.segment_transitions (
    transition_id      BIGSERIAL PRIMARY KEY,
    customer_id        TEXT NOT NULL,
    snapshot_month     DATE NOT NULL,
    prev_segment_label TEXT,
    segment_label      TEXT NOT NULL,
    transitioned       BOOLEAN NOT NULL,
    created_ts         TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_segtrans_customer_month
ON hpce.segment_transitions (customer_id, snapshot_month);
