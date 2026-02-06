DROP TABLE IF EXISTS hpce.segment_transition_probs;

CREATE TABLE hpce.segment_transition_probs AS
WITH totals AS (
  SELECT prev_segment, SUM(n) AS total_n
  FROM hpce.segment_transitions_clusters
  GROUP BY 1
)
SELECT
  t.prev_segment,
  t.curr_segment,
  t.n,
  (t.n::double precision / tot.total_n) AS p
FROM hpce.segment_transitions_clusters t
JOIN totals tot USING (prev_segment);
