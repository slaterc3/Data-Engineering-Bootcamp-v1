INSERT INTO host_activity_reduced 
WITH date_series AS (
    SELECT generate_series(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 day')::DATE AS date
), daily_activity AS (
    SELECT 
        host,
        DATE(event_time) AS date,
        COUNT(1) AS num_hits,
        COUNT(DISTINCT user_id) AS unique_visitors
    FROM events
    WHERE DATE(event_time) BETWEEN DATE('2023-01-01') AND DATE('2023-01-31')
    GROUP BY host, DATE(event_time)
), monthly_aggregate AS (
    SELECT 
        DATE_TRUNC('month', da.date) AS month,
        da.host,
        ARRAY_AGG(da.num_hits ORDER BY da.date) AS hit_array,
        ARRAY_AGG(da.unique_visitors ORDER BY da.date) AS unique_visitors_array
    FROM daily_activity da
    GROUP BY DATE_TRUNC('month', da.date), da.host
)
SELECT 
    ma.month,
    ma.host,
    ma.hit_array,
    ma.unique_visitors_array
FROM monthly_aggregate ma
ON CONFLICT (month, host)
DO UPDATE
    SET hit_array = EXCLUDED.hit_array,
        unique_visitors_array = EXCLUDED.unique_visitors_array;