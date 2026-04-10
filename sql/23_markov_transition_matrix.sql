DROP TABLE IF EXISTS hpce.markov_transition_matrix;

CREATE TABLE hpce.markov_transition_matrix AS
WITH base AS (
  SELECT prev_risk_band, risk_band, COUNT(*)::int AS n
  FROM hpce.segment_transitions
  GROUP BY 1,2
),
den AS (
  SELECT prev_risk_band, SUM(n) AS total_n
  FROM base
  GROUP BY 1
)
SELECT
  b.prev_risk_band,
  b.risk_band,
  b.n,
  (b.n::double precision / d.total_n) AS p
FROM base b
JOIN den d USING (prev_risk_band);