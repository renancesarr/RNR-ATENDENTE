CREATE OR REPLACE FUNCTION fn_message_windows(p_window_minutes integer DEFAULT 30)
RETURNS TABLE(chat_id uuid, window_index integer, start_at timestamptz, end_at timestamptz) AS
$$
WITH ordered AS (
  SELECT
    chat_id,
    created_at,
    lag(created_at) OVER (PARTITION BY chat_id ORDER BY created_at) AS prev_created_at
  FROM messages
), groups AS (
  SELECT
    chat_id,
    created_at,
    CASE
      WHEN prev_created_at IS NULL THEN 1
      WHEN created_at - prev_created_at > make_interval(mins => p_window_minutes) THEN 1
      ELSE 0
    END AS is_new_group
  FROM ordered
), grouped AS (
  SELECT
    chat_id,
    created_at,
    sum(is_new_group) OVER (PARTITION BY chat_id ORDER BY created_at ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS grp
  FROM groups
)
SELECT chat_id,
       grp AS window_index,
       min(created_at) AS start_at,
       max(created_at) AS end_at
FROM grouped
GROUP BY chat_id, grp
ORDER BY chat_id, grp;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE VIEW chat_windows AS
SELECT * FROM fn_message_windows(30);
