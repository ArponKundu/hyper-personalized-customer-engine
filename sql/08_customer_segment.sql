CREATE TABLE hpce.customer_segments AS
SELECT
    customer_id,

    CASE
        WHEN recency_days = 999 THEN 'Never Purchased'

        WHEN recency_days <= 30
             AND f_30 >= 3
             AND m_30 >= 300
        THEN 'Champion'

        WHEN recency_days <= 30
             AND f_30 >= 2
        THEN 'Loyal'

        WHEN recency_days <= 30
             AND f_30 >= 1
        THEN 'Recent'

        WHEN recency_days > 90
             AND f_30 >= 1
        THEN 'At Risk'

        ELSE 'Low Value'
    END AS segment_label

FROM hpce.customer_rfm_snapshot;
