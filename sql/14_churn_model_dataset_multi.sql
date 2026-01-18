DROP TABLE IF EXISTS hpce.churn_model_dataset_multi;

CREATE TABLE hpce.churn_model_dataset_multi AS
SELECT
    f.customer_id,
    f.feature_date,

    -- Core features (already validated)
    f.recency_days,
    f.f_30,
    f.m_30,
    f.views_30,
    f.events_30,

    -- Optional longer window (if exists)
    f.f_90,
    f.m_90,
    f.views_90,
    f.events_90,

    -- Multi-horizon churn labels
    c.churn_30d,
    c.churn_60d,
    c.churn_90d

FROM hpce.customer_features_daily f
JOIN hpce.customer_churn_labels_multi c
  ON f.customer_id = c.customer_id
WHERE f.feature_date = c.obs_end;
