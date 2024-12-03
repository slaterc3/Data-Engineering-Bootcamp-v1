INSERT INTO hosts_cumulated (host, host_activity_datelist)
WITH date_series AS (
    SELECT generate_series(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 day')::DATE AS date
), daily_aggregate AS (
    SELECT 
        host,
        DATE(event_time) AS date_active
    FROM events
    WHERE DATE(event_time) BETWEEN DATE('2023-01-01') AND DATE('2023-01-31')
    GROUP BY host, DATE(event_time)
), all_dates_hosts AS (
    SELECT 
        da.host,
        ARRAY_AGG(DISTINCT da.date_active ORDER BY da.date_active) AS host_activity_datelist
    FROM daily_aggregate da
    GROUP BY da.host
), yesterday_array AS (
    SELECT 
        host,
        host_activity_datelist
    FROM hosts_cumulated
)
SELECT 
    COALESCE(adh.host, ya.host) AS host,
    CASE
        WHEN ya.host_activity_datelist IS NOT NULL
            THEN ARRAY(SELECT DISTINCT UNNEST(ya.host_activity_datelist || adh.host_activity_datelist) ORDER BY 1)
        WHEN ya.host_activity_datelist IS NULL
            THEN adh.host_activity_datelist
    END AS host_activity_datelist
FROM all_dates_hosts adh
FULL OUTER JOIN yesterday_array ya
    ON adh.host = ya.host
ON CONFLICT (host)
DO UPDATE
    SET host_activity_datelist = EXCLUDED.host_activity_datelist;
