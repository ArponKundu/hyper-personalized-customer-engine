DROP TABLE IF EXISTS hpce.action_effectiveness;

CREATE TABLE hpce.action_effectiveness AS
SELECT
  action,
  AVG(responded_14d::double precision) AS response_rate_14d,
  AVG(COALESCE(revenue_14d,0)) AS avg_revenue_14d,
  COUNT(*) AS n
FROM hpce.intervention_outcomes_daily
GROUP BY 1;
