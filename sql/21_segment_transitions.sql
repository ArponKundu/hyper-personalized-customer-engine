-- 3) Segment transitions (explicit)
DROP TABLE IF EXISTS hpce.segment_transitions;
CREATE TABLE hpce.segment_transitions (
  customer_id     text NOT NULL,
  feature_date    date NOT NULL,
  risk_band       text NOT NULL,
  prev_risk_band  text,
  changed         boolean NOT NULL,
  PRIMARY KEY (customer_id, feature_date)
);

CREATE INDEX IF NOT EXISTS idx_st_changed ON hpce.segment_transitions(changed);