DROP TABLE IF EXISTS hpce.intervention_effectiveness;

CREATE TABLE hpce.intervention_effectiveness AS
SELECT
    recommended_action,
    COUNT(*) AS n_interventions,
    AVG(responded::int) AS response_rate,
    AVG(converted_14d::int) AS conversion_rate,
    AVG(revenue_14d) AS avg_revenue_14d
FROM hpce.intervention_logs
WHERE outcome_ts IS NOT NULL
GROUP BY recommended_action;
