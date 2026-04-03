-- getCurrentMonthStats.sql
-- KPI statistics for the current calendar month

SELECT
  COUNT(*)                                             AS total,
  COUNT(*) FILTER (WHERE status = 'approved')          AS approved,
  COUNT(*) FILTER (WHERE status = 'rejected')          AS rejected,
  COALESCE(SUM(amount) FILTER (WHERE status = 'approved'), 0) AS approved_volume,
  COALESCE(AVG(amount) FILTER (WHERE status = 'approved'), 0) AS avg_transaction
FROM transactions
WHERE
  created_at >= DATE_TRUNC('month', NOW());
