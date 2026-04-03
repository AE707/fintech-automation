-- getChartData.sql
-- Daily transaction volume for the last 30 days (chart)

SELECT
  DATE_TRUNC('day', created_at)::DATE AS day,
  COUNT(*)                             AS total_count,
  SUM(amount)                          AS total_amount,
  COUNT(*) FILTER (WHERE status = 'approved')  AS approved_count,
  COUNT(*) FILTER (WHERE status = 'rejected')  AS rejected_count
FROM transactions
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY 1
ORDER BY 1 ASC;
