DROP TABLE IF EXISTS hpce.segment_transitions_clusters;

CREATE TABLE hpce.segment_transitions_clusters AS
WITH ordered AS (
  SELECT
    customer_id,
    feature_date,
    segment_name,
    LEAD(segment_name) OVER (PARTITION BY customer_id ORDER BY feature_date) AS next_segment
  FROM hpce.customer_segments_snapshot
)
SELECT
  segment_name AS prev_segment,
  next_segment AS curr_segment,
  COUNT(*)::int AS n
FROM ordered
WHERE next_segment IS NOT NULL
GROUP BY 1,2;
