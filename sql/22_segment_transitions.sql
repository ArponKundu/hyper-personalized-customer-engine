DROP TABLE IF EXISTS hpce.segment_transitions;

CREATE TABLE hpce.segment_transitions AS
WITH t AS (
  SELECT
    customer_id,
    feature_date,
    risk_band,
    LAG(risk_band) OVER (PARTITION BY customer_id ORDER BY feature_date) AS prev_risk_band
  FROM hpce.decision_engine_output_daily
)
SELECT
  customer_id,
  feature_date,
  prev_risk_band,
  risk_band,
  (risk_band <> prev_risk_band) AS changed
FROM t
WHERE prev_risk_band IS NOT NULL;
