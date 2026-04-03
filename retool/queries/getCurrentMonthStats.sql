-- getCurrentMonthStats.sql
-- Comprehensive KPI statistics for the current calendar month
-- Retool variables: none

SELECT
  TO_CHAR(DATE_TRUNC('month', NOW()), 'Month YYYY')     AS month_label,
  DATE_TRUNC('month', NOW())                            AS month_start,
  DATE_TRUNC('month', NOW()) + INTERVAL '1 month' - INTERVAL '1 day' AS month_end,

  -- Transaction counts
  COUNT(*)                                              AS total,
  COUNT(*) FILTER (WHERE status = 'approved')           AS approved,
  COUNT(*) FILTER (WHERE status = 'rejected')           AS rejected,
  COUNT(*) FILTER (WHERE status = 'pending')            AS pending,
  COUNT(*) FILTER (WHERE status = 'failed')             AS failed,

  -- Volume metrics
  COALESCE(SUM(amount) FILTER (WHERE status = 'approved'), 0)   AS approved_volume,
  COALESCE(SUM(amount) FILTER (WHERE status = 'rejected'), 0)   AS rejected_volume,
  COALESCE(AVG(amount) FILTER (WHERE status = 'approved'), 0)   AS avg_approved_amount,
  COALESCE(MAX(amount) FILTER (WHERE status = 'approved'), 0)   AS max_approved_amount,

  -- Approval rate
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE status = 'approved') / NULLIF(COUNT(*), 0),
    2
  ) AS approval_rate_pct,

  -- Daily average
  ROUND(
    COUNT(*)::numeric / NULLIF(EXTRACT(DAY FROM NOW()), 0),
    1
  ) AS avg_daily_transactions

FROM transactions
WHERE created_at >= DATE_TRUNC('month', NOW())
  AND created_at < DATE_TRUNC('month', NOW()) + INTERVAL '1 month';
