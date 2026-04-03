-- getStats.sql
-- Comprehensive dashboard KPI stats with period comparisons
-- Retool variables: none (uses current date server-side)

SELECT
  -- Transaction counts by status
  COUNT(*)                                                   AS total_transactions,
  COUNT(*) FILTER (WHERE status = 'approved')               AS approved,
  COUNT(*) FILTER (WHERE status = 'rejected')               AS rejected,
  COUNT(*) FILTER (WHERE status = 'pending')                AS pending,
  COUNT(*) FILTER (WHERE status = 'processing')             AS processing,
  COUNT(*) FILTER (WHERE status = 'failed')                 AS failed,

  -- Volume metrics
  COALESCE(SUM(amount) FILTER (WHERE status = 'approved'), 0)         AS total_approved_volume,
  COALESCE(SUM(amount) FILTER (WHERE status = 'rejected'), 0)         AS total_rejected_volume,
  COALESCE(AVG(amount) FILTER (WHERE status = 'approved'), 0)         AS avg_approved_amount,

  -- Today's metrics
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE)                  AS today_total,
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE AND status = 'approved') AS today_approved,
  COALESCE(SUM(amount) FILTER (WHERE created_at >= CURRENT_DATE AND status = 'approved'), 0) AS today_volume,

  -- This week's metrics
  COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW()))      AS this_week_total,
  COALESCE(SUM(amount) FILTER (WHERE created_at >= date_trunc('week', NOW()) AND status = 'approved'), 0) AS this_week_volume,

  -- Approval rate
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE status = 'approved') / NULLIF(COUNT(*), 0),
    2
  ) AS approval_rate_pct,

  -- Queue health
  (SELECT COUNT(*) FROM event_queue WHERE status = 'queued')           AS queue_pending,
  (SELECT COUNT(*) FROM event_queue WHERE status = 'failed')           AS queue_failed,
  (SELECT COUNT(*) FROM event_queue WHERE status = 'dead')             AS queue_dead

FROM transactions;
