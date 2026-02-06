DROP TABLE IF EXISTS hpce.mvp_recommendations_daily;

CREATE TABLE hpce.mvp_recommendations_daily (
  customer_id TEXT NOT NULL,
  feature_date DATE NOT NULL,
  strategy TEXT NOT NULL,
  product_id TEXT NOT NULL,
  product_category_name TEXT,
  score DOUBLE PRECISION,
  reason TEXT,
  PRIMARY KEY (customer_id, feature_date, strategy, product_id)
);
