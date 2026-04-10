DROP TABLE IF EXISTS hpce.segment_transitions_control;

CREATE TABLE hpce.segment_transitions_control AS
WITH seg AS (
  SELECT
    s.customer_id,
    s.feature_date,
    s.segment_name,
    LEAD(s.segment_name) OVER (PARTITION BY s.customer_id ORDER BY s.feature_date) AS next_segment
  FROM hpce.customer_segments_snapshot s
),
treated AS (
  SELECT DISTINCT customer_id, feature_date
  FROM hpce.intervention_logs
  WHERE action <> 'No Action'
)
SELECT
  seg.segment_name AS prev_segment,
  seg.next_segment  AS curr_segment,
  COUNT(*)::int AS n
FROM seg
LEFT JOIN treated t
  ON seg.customer_id = t.customer_id
 AND seg.feature_date = t.feature_date
WHERE t.customer_id IS NULL
  AND seg.next_segment IS NOT NULL
GROUP BY 1,2;
