DROP TABLE IF EXISTS hpce.intervention_execution_plan;

CREATE TABLE hpce.intervention_execution_plan AS
SELECT
  l.intervention_id,
  l.customer_id,
  l.segment_label,
  l.churn_probability,
  l.recommended_action,
  NOW() AS planned_at,
  NOW() + INTERVAL '1 hour' AS scheduled_send_ts,
  t.channel,
  t.offer_type,
  t.message_template,
  'planned'::text AS status
FROM hpce.intervention_logs l
LEFT JOIN hpce.intervention_templates t
  ON t.segment_label = l.segment_label
 AND t.risk_band = CASE
   WHEN l.churn_probability >= 0.8 THEN 'high'
   WHEN l.churn_probability >= 0.4 THEN 'medium'
   ELSE 'low'
 END;
