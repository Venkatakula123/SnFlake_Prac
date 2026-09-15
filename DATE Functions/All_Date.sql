Use database MDB;
use schema PUBLIC;

CREATE TABLE user_events (
    user_id VARCHAR(20),
    event_time TIMESTAMP
);

INSERT INTO user_events (user_id, event_time) VALUES
('U-1045', '2023-10-01 10:00:00'),
('U-1045', '2023-10-01 10:15:00'),
('U-1045', '2023-10-01 11:10:00'),
('U-1046', '2023-10-01 09:00:00'),
('U-1046', '2023-10-01 09:45:00'),
('U-1046', '2023-10-01 10:50:00'),
('U-1047', '2023-10-01 14:00:00'),
('U-1047', '2023-10-01 15:00:00'),
('U-1047', '2023-10-01 16:00:00');

Select * from user_events;

SELECT
        e1.user_id,
        e1.event_time,
        MAX(e2.event_time) AS prev_event_time
    FROM user_events e1
    LEFT JOIN user_events e2
    ON e1.user_id = e2.user_id
    AND e2.event_time < e1.event_time
    GROUP BY e1.user_id, e1.event_time ORDER by e1.user_id;

WITH prev_events AS (
    SELECT
        e1.user_id,
        e1.event_time,
        MAX(e2.event_time) AS prev_event_time
    FROM user_events e1
    LEFT JOIN user_events e2
      ON e1.user_id = e2.user_id
     AND e2.event_time < e1.event_time
    GROUP BY e1.user_id, e1.event_time
)
, flagged AS (
    SELECT
        user_id,
        event_time,
        prev_event_time,
        CASE
            WHEN prev_event_time IS NULL 
                 OR TIMESTAMPDIFF(MINUTE, prev_event_time, event_time) > 30
            THEN 1 ELSE 0
        END AS new_session_flag
    FROM prev_events
)
SELECT
    user_id,
    event_time,
    SUM(new_session_flag) OVER (
        PARTITION BY user_id
        ORDER BY event_time
        ROWS UNBOUNDED PRECEDING
    ) AS session_id
FROM flagged
ORDER BY user_id, event_time;
