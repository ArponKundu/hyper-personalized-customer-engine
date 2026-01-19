DROP TABLE IF EXISTS hpce.intervention_templates;

CREATE TABLE hpce.intervention_templates (
  template_id SERIAL PRIMARY KEY,
  segment_label TEXT NOT NULL,
  risk_band TEXT NOT NULL,            -- 'high', 'medium', 'low'
  channel TEXT NOT NULL,              -- 'email', 'push', 'sms' (simulated)
  offer_type TEXT NOT NULL,           -- 'coupon', 'reminder', 'upsell', 'content'
  message_template TEXT NOT NULL
);


INSERT INTO hpce.intervention_templates (segment_label, risk_band, channel, offer_type, message_template) VALUES
('At Risk','high','email','coupon','We miss you! Here is a limited-time coupon to come back.'),
('Low Value','high','email','coupon','Special offer just for you—complete your next purchase with a discount.'),
('Recent','medium','email','reminder','Thanks for visiting—check out products you might like.'),
('Loyal','low','email','upsell','Exclusive picks based on popular bundles—upgrade your next purchase.'),
('Champion','low','email','upsell','Premium recommendations curated for you—discover top bundles.');
