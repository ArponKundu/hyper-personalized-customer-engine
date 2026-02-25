TRUNCATE TABLE hpce.segment_transitions;

INSERT INTO hpce.segment_transitions (customer_id, feature_date, risk_band, prev_risk_band, changed)
SELECT
  customer_id,
  feature_date,
  risk_band,
  COALESCE(
    LAG(risk_band) OVER (PARTITION BY customer_id ORDER BY feature_date),
    risk_band
  ) AS prev_risk_band,
  CASE
    WHEN LAG(risk_band) OVER (PARTITION BY customer_id ORDER BY feature_date) IS NULL THEN false
    WHEN risk_band <> LAG(risk_band) OVER (PARTITION BY customer_id ORDER BY feature_date) THEN true
    ELSE false
  END AS changed
FROM hpce.decision_engine_output_daily;
