DROP TABLE IF EXISTS hpce.segment_markov_matrix;

CREATE TABLE hpce.segment_markov_matrix AS
WITH trans AS (
  SELECT
    prev_segment_label,
    segment_label,
    COUNT(*) AS n
  FROM hpce.segment_transitions
  WHERE prev_segment_label IS NOT NULL
  GROUP BY prev_segment_label, segment_label
),
tot AS (
  SELECT prev_segment_label, SUM(n) AS total_n
  FROM trans
  GROUP BY prev_segment_label
)
SELECT
  t.prev_segment_label,
  t.segment_label,
  t.n,
  (t.n::double precision / tot.total_n) AS transition_prob
FROM trans t
JOIN tot ON t.prev_segment_label = tot.prev_segment_label
ORDER BY t.prev_segment_label, transition_prob DESC;
