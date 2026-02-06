DROP TABLE IF EXISTS hpce.markov_transition_matrix;

CREATE TABLE hpce.markov_transition_matrix AS
WITH trans AS (
  SELECT prev_risk_band, risk_band
  FROM hpce.segment_transitions
  WHERE prev_risk_band IS NOT NULL
)
SELECT
  prev_risk_band,
  risk_band,
  COUNT(*) AS n,
  COUNT(*)::float / SUM(COUNT(*)) OVER (PARTITION BY prev_risk_band) AS p
FROM trans
GROUP BY 1,2;

CREATE INDEX IF NOT EXISTS idx_mtm_prev ON hpce.markov_transition_matrix(prev_risk_band);
