SELECT create_hypertable(
  'hpce.customer_features_daily',
  'feature_date',
  if_not_exists => TRUE,
  migrate_data => TRUE
);
