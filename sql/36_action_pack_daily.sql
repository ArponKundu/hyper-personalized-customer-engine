DROP TABLE IF EXISTS hpce.action_pack_daily;

CREATE TABLE hpce.action_pack_daily AS
SELECT
  d.customer_id,
  d.feature_date,
  d.churn_prob,
  d.risk_band,
  d.action,
  d.priority_score,
  s.segment_name
FROM hpce.decision_engine_output_daily d
LEFT JOIN hpce.customer_segments_snapshot s
  ON s.customer_id = d.customer_id
 AND s.feature_date = d.feature_date;

CREATE INDEX IF NOT EXISTS idx_action_pack_cd
ON hpce.action_pack_daily(customer_id, feature_date);
