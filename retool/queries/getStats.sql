-- getStats.sql
-- Summary statistics for the dashboard header cards

SELECT
  COUNT(*)                                          AS total,
  COUNT(*) FILTER (WHERE status = 'approved')       AS approved,
  COUNT(*) FILTER (WHERE status = 'rejected')       AS rejected,
  COUNT(*) FILTER (WHERE status = 'pending')        AS pending,
  COUNT(*) FILTER (WHERE status = 'processing')     AS processing,
  COUNT(*) FILTER (WHERE status = 'failed')         AS failed,
  COALESCE(SUM(amount) FILTER (WHERE status = 'approved'), 0) AS total_approved_amount
FROM transactions;
