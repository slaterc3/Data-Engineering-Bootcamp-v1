INSERT INTO user_devices_cumulated
SELECT
    CAST(e.user_id AS TEXT) AS user_id,
    d.browser_type,
    ARRAY_AGG(DISTINCT DATE(CAST(e.event_time AS TIMESTAMP)) ORDER BY DATE(CAST(e.event_time AS TIMESTAMP))) AS device_activity_datelist,
    DATE('2023-01-31') AS date
FROM events e
JOIN devices d ON e.device_id = d.device_id
WHERE DATE(CAST(e.event_time AS TIMESTAMP)) BETWEEN DATE('2023-01-01') AND DATE('2023-01-31')
    AND e.user_id IS NOT NULL
GROUP BY e.user_id, d.browser_type;