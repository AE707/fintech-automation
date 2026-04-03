-- getChartData.sql
-- Daily transaction volume and approval rate for the last N days (chart data)
-- Retool variables: {{days}} (default 30), {{currency}}

WITH date_series AS (
  SELECT generate_series(
    date_trunc('day', NOW() - ({{ days }}::int || ' days')::interval),
    date_trunc('day', NOW()),
    '1 day'::interval
  )::date AS day
),
transaction_data AS (
  SELECT
    DATE_TRUNC('day', created_at)::date  AS day,
    COUNT(*)                              AS total_count,
    COUNT(*) FILTER (WHERE status = 'approved') AS approved_count,
    COUNT(*) FILTER (WHERE status = 'rejected') AS rejected_count,
    COUNT(*) FILTER (WHERE status = 'failed')   AS failed_count,
    COALESCE(SUM(amount) FILTER (WHERE status = 'approved'), 0) AS approved_volume,
    COALESCE(AVG(amount) FILTER (WHERE status = 'approved'), 0) AS avg_approved_amount
  FROM transactions
  WHERE
    created_at >= NOW() - ({{ days }}::int || ' days')::interval
    AND ({{ currency }} = '' OR currency = {{ currency }})
  GROUP BY 1
)
SELECT
  d.day,
  COALESCE(t.total_count, 0)       AS total_count,
  COALESCE(t.approved_count, 0)    AS approved_count,
  COALESCE(t.rejected_count, 0)    AS rejected_count,
  COALESCE(t.failed_count, 0)      AS failed_count,
  COALESCE(t.approved_volume, 0)   AS approved_volume,
  COALESCE(t.avg_approved_amount, 0) AS avg_approved_amount,
  ROUND(
    100.0 * COALESCE(t.approved_count, 0) / NULLIF(COALESCE(t.total_count, 0), 0),
    2
  ) AS approval_rate_pct
FROM date_series d
LEFT JOIN transaction_data t ON t.day = d.day
ORDER BY d.day ASC;
