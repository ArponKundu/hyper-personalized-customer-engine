DROP TABLE IF EXISTS hpce.intervention_effectiveness_by_segment;

CREATE TABLE hpce.intervention_effectiveness_by_segment AS
SELECT
    segment_label,
    recommended_action,
    COUNT(*) AS n,
    AVG(responded::int) AS response_rate,
    AVG(converted_14d::int) AS conversion_rate,
    AVG(revenue_14d) AS avg_revenue_14d
FROM hpce.intervention_logs
WHERE outcome_ts IS NOT NULL
GROUP BY segment_label, recommended_action;
